library ieee;
use ieee.std_logic_1164.all;

entity top is
    generic (G_SCAN_DIV : positive := 100000); -- 1 ms przy 100 MHz
    port (
        clk_i      : in  std_logic;
        rst_i      : in  std_logic;
        RXD_i      : in  std_logic;
        led7_an_o  : out std_logic_vector(3 downto 0);
        led7_seg_o : out std_logic_vector(7 downto 0)
    );
end entity;

architecture Behavioral of top is
    constant BIT_TICKS  : positive := 10417; -- 100 MHz / 9600, zaokraglone
    constant HALF_BIT   : positive := 5208;
    type state_t is (IDLE, START_BIT, DATA_BITS, STOP_BIT, WAIT_IDLE);
    signal state : state_t;
    signal count : natural range 0 to BIT_TICKS - 1;
    signal bit_index : natural range 0 to 7;
    signal shift_reg, data_rx : std_logic_vector(7 downto 0);
    signal rst_meta, rst_sync, rx_meta, rx_sync : std_logic;
    signal scan_count : natural range 0 to G_SCAN_DIV - 1;
    signal digit : natural range 0 to 3;
    attribute ASYNC_REG : string;
    attribute ASYNC_REG of rst_meta, rst_sync, rx_meta, rx_sync : signal is "TRUE";

    -- Kolejnosc bitow: A B C D E F G DP. Segment zapala sie przy 0.
    function hex_segments(h : std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        case h is
            when x"0" => return x"03";
            when x"1" => return x"9F";
            when x"2" => return x"25";
            when x"3" => return x"0D";
            when x"4" => return x"99";
            when x"5" => return x"49";
            when x"6" => return x"41";
            when x"7" => return x"1F";
            when x"8" => return x"01";
            when x"9" => return x"09";
            when x"A" => return x"11";
            when x"B" => return x"C1";
            when x"C" => return x"63";
            when x"D" => return x"85";
            when x"E" => return x"61";
            when x"F" => return x"71";
            when others => return x"FF";
        end case;
    end function;
begin
    -- Reset wlaczany asynchronicznie, zwalniany po dwoch zboczach zegara.
    p_reset : process(clk_i, rst_i)
    begin
        if rst_i = '1' then
            rst_meta <= '1';
            rst_sync <= '1';
        elsif rising_edge(clk_i) then
            rst_meta <= '0';
            rst_sync <= rst_meta;
        end if;
    end process;

    -- Dwa przerzutniki synchronizujace asynchroniczne wejscie RXD.
    p_rx_sync : process(clk_i, rst_sync)
    begin
        if rst_sync = '1' then
            rx_meta <= '1';
            rx_sync <= '1';
        elsif rising_edge(clk_i) then
            rx_meta <= RXD_i;
            rx_sync <= rx_meta;
        end if;
    end process;

    p_receiver : process(clk_i, rst_sync)
    begin
        if rst_sync = '1' then
            state <= IDLE;
            count <= 0;
            bit_index <= 0;
            shift_reg <= (others => '0');
            data_rx <= (others => '0');
        elsif rising_edge(clk_i) then
            case state is
                when IDLE =>
                    count <= 0;
                    if rx_sync = '0' then state <= START_BIT; end if;
                when START_BIT =>
                    if count = HALF_BIT - 1 then
                        count <= 0;
                        if rx_sync = '0' then
                            bit_index <= 0;
                            state <= DATA_BITS;
                        else
                            state <= IDLE;
                        end if;
                    else count <= count + 1;
                    end if;
                when DATA_BITS =>
                    if count = BIT_TICKS - 1 then
                        count <= 0;
                        shift_reg(bit_index) <= rx_sync;
                        if bit_index = 7 then state <= STOP_BIT;
                        else bit_index <= bit_index + 1;
                        end if;
                    else count <= count + 1;
                    end if;
                when STOP_BIT =>
                    if count = BIT_TICKS - 1 then
                        count <= 0;
                        if rx_sync = '1' then
                            data_rx <= shift_reg;
                            state <= IDLE;
                        else state <= WAIT_IDLE;
                        end if;
                    else count <= count + 1;
                    end if;
                when WAIT_IDLE =>
                    if rx_sync = '1' then state <= IDLE; end if;
            end case;
        end if;
    end process;

    -- Niezalezny licznik odswiezania wyswietlacza: zmiana pozycji co 1 ms.
    p_scan : process(clk_i, rst_sync)
    begin
        if rst_sync = '1' then
            scan_count <= 0;
            digit <= 0;
        elsif rising_edge(clk_i) then
            if scan_count = G_SCAN_DIV - 1 then
                scan_count <= 0;
                if digit = 3 then digit <= 0;
                else digit <= digit + 1;
                end if;
            else scan_count <= scan_count + 1;
            end if;
        end if;
    end process;

    p_decode : process(rst_sync, digit, data_rx)
    begin
        led7_an_o <= "1111";
        led7_seg_o <= x"FF";
        if rst_sync = '0' then
            case digit is
                when 0 =>
                    led7_an_o <= "1110";
                    led7_seg_o <= hex_segments(data_rx(3 downto 0));
                when 1 =>
                    led7_an_o <= "1101";
                    led7_seg_o <= hex_segments(data_rx(7 downto 4));
                when 2 => led7_an_o <= "1011";
                when 3 => led7_an_o <= "0111";
            end case;
        end if;
    end process;
end architecture Behavioral;
