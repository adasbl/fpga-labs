library ieee;
use ieee.std_logic_1164.all;

entity top is
    generic (
        G_SCAN_DIV       : positive := 100000;  -- 1 ms at 100 MHz
        G_DEBOUNCE_TICKS : positive := 1000000  -- 10 ms at 100 MHz
    );
    port (
        clk_i      : in  std_logic;
        rst_i      : in  std_logic;
        button_i   : in  std_logic_vector(3 downto 0);
        led7_an_o  : out std_logic_vector(3 downto 0);
        led7_seg_o : out std_logic_vector(7 downto 0)
    );
end entity;

architecture Behavioral of top is
    signal rst_meta, rst_sync : std_logic := '1';
    signal button_meta, button_sync, button_clean : std_logic_vector(3 downto 0) := (others => '0');
    type debounce_counts_t is array (0 to 3) of natural range 0 to G_DEBOUNCE_TICKS - 1;
    signal debounce_count : debounce_counts_t := (others => 0);
    signal address : std_logic_vector(11 downto 0);
    signal instruction : std_logic_vector(17 downto 0);
    signal bram_enable, write_strobe : std_logic;
    signal port_id, in_port, out_port : std_logic_vector(7 downto 0);
    signal display_value : std_logic_vector(3 downto 0) := x"0";
    signal scan_count : natural range 0 to G_SCAN_DIV - 1 := 0;
    signal digit : natural range 0 to 3 := 0;
    attribute ASYNC_REG : string;
    attribute ASYNC_REG of rst_meta, rst_sync, button_meta, button_sync : signal is "TRUE";

    -- Bits A B C D E F G DP, active low.
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
    -- SW7 and buttons are asynchronous to the 100 MHz system clock.
    p_sync : process(clk_i)
    begin
        if rising_edge(clk_i) then
            rst_meta <= rst_i;
            rst_sync <= rst_meta;
            button_meta <= button_i;
            button_sync <= button_meta;
        end if;
    end process;

    -- Both press and release must be stable for 10 ms.
    p_debounce : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_sync = '1' then
                button_clean <= (others => '0');
                debounce_count <= (others => 0);
            else
                for i in 0 to 3 loop
                    if button_sync(i) = button_clean(i) then
                        debounce_count(i) <= 0;
                    elsif debounce_count(i) = G_DEBOUNCE_TICKS - 1 then
                        button_clean(i) <= button_sync(i);
                        debounce_count(i) <= 0;
                    else
                        debounce_count(i) <= debounce_count(i) + 1;
                    end if;
                end loop;
            end if;
        end if;
    end process;

    processor : entity work.kcpsm6
        generic map (hwbuild => x"00", interrupt_vector => x"3FF", scratch_pad_memory_size => 64)
        port map (
            address => address, instruction => instruction, bram_enable => bram_enable,
            in_port => in_port, out_port => out_port, port_id => port_id,
            write_strobe => write_strobe, k_write_strobe => open, read_strobe => open,
            interrupt => '0', interrupt_ack => open, sleep => '0', reset => rst_sync, clk => clk_i
        );

    program : entity work.counter_rom
        port map (clk => clk_i, enable => bram_enable, address => address, instruction => instruction);

    -- INPUT 00: bit 3=BTNL, 2=BTNR, 1=BTNU, 0=BTND.
    in_port <= "0000" & button_clean when port_id = x"00" else x"00";

    -- OUTPUT 01: low digit. All counting is performed by PicoBlaze firmware.
    p_output : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_sync = '1' then
                display_value <= x"0";
            elsif write_strobe = '1' and port_id = x"01" then
                display_value <= out_port(3 downto 0);
            end if;
        end if;
    end process;

    p_scan : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_sync = '1' then
                scan_count <= 0;
                digit <= 0;
            elsif scan_count = G_SCAN_DIV - 1 then
                scan_count <= 0;
                if digit = 3 then digit <= 0;
                else digit <= digit + 1;
                end if;
            else
                scan_count <= scan_count + 1;
            end if;
        end if;
    end process;

    p_decode : process(digit, display_value)
    begin
        led7_seg_o <= hex_segments(x"0");
        case digit is
            when 0 => led7_an_o <= "1110"; led7_seg_o <= hex_segments(display_value);
            when 1 => led7_an_o <= "1101";
            when 2 => led7_an_o <= "1011";
            when 3 => led7_an_o <= "0111";
        end case;
    end process;
end architecture;
