library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Proste wymuszenia do recznego ogladania przebiegow; bez automatycznych ocen.
-- Symulacja korzysta z wygenerowanych IP char_mem i fifo_mem.
entity tb is
end entity;

architecture Behavioral of tb is
    constant BIT_TIME : time := 104170 ns; -- 9600 bps, jak na plytce.
    signal clk : std_logic := '0';
    signal rx : std_logic := '1';
    signal tx, ld0 : std_logic;
    signal an : std_logic_vector(3 downto 0);
    signal seg : std_logic_vector(7 downto 0);

    procedure send_byte(signal rxd : out std_logic;
                        constant value : natural) is
        variable data : std_logic_vector(7 downto 0);
    begin
        data := std_logic_vector(to_unsigned(value, 8));
        rxd <= '0';
        wait for BIT_TIME;
        for bit_index in 0 to 7 loop
            rxd <= data(bit_index);
            wait for BIT_TIME;
        end loop;
        rxd <= '1';
        wait for BIT_TIME;
    end procedure;
begin
    clk <= not clk after 5 ns;
    dut : entity work.top
        port map (clk_i => clk, RXD_i => rx, TXD_o => tx, ld0 => ld0,
                  led7_an_o => an, led7_seg_o => seg);

    process
    begin
        wait for 1 us;
        send_byte(rx, 65); -- A
        send_byte(rx, 98); -- b
        send_byte(rx, 13); -- Wydruk niepelnej linii.
        -- Dane odbierane podczas drukowania pierwszej linii.
        for code in 48 to 65 loop
            send_byte(rx, code); -- 18 znakow: wydruk bez Entera.
        end loop;
        wait for 4 sec;
        send_byte(rx, 1);   -- Piksele '*', ksztalt znaku o kodzie 1.
        send_byte(rx, 128); -- Piksele '*', ksztalt znaku o kodzie 128.
        send_byte(rx, 13);
        -- Zapelnienie i przepelnienie FIFO w czasie wydruku.
        for n in 1 to 70 loop
            send_byte(rx, 88);
        end loop;
        wait;
    end process;
end architecture;
