library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is end entity;

architecture Behavioral of tb is
    constant BIT_NOM  : time := 1 sec / 9600;
    constant BIT_SLOW : time := 1 sec / 9216;
    constant BIT_FAST : time := 1 sec / 9984;
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal rx : std_logic := '1';
    signal an : std_logic_vector(3 downto 0);
    signal seg : std_logic_vector(7 downto 0);
    signal done : boolean := false;
    type hex_t is array(0 to 15) of std_logic_vector(7 downto 0);
    constant HEX_SEG : hex_t := (
        x"03", x"9F", x"25", x"0D", x"99", x"49", x"41", x"1F",
        x"01", x"09", x"11", x"C1", x"63", x"85", x"61", x"71"
    );

    procedure send_byte(signal wire : out std_logic;
                        constant value : std_logic_vector(7 downto 0);
                        constant bit_time : time) is
    begin
        wire <= '0'; wait for bit_time;
        for i in 0 to 7 loop
            wire <= value(i); wait for bit_time;
        end loop;
        wire <= '1'; wait for bit_time;
    end procedure;
begin
    clk <= not clk after 5 ns when not done else '0';
    dut : entity work.top(Behavioral)
        port map (clk_i => clk, rst_i => rst, RXD_i => rx,
                  led7_an_o => an, led7_seg_o => seg);

    p_check_scan : process
        variable last_change : time := 0 ns;
        variable started : boolean := false;
    begin
        wait on an, rst;
        if rst = '1' then started := false;
        elsif an'event and an /= "1111" then
            if started then
                assert now - last_change = 1 ms
                    report "Zmiana pozycji nie nastepuje co 1 ms" severity failure;
            end if;
            started := true;
            last_change := now;
        end if;
    end process;

    p_stimulus : process
        procedure check_display(constant value : std_logic_vector(7 downto 0)) is
            variable seen : std_logic_vector(3 downto 0) := "0000";
            variable old_an : std_logic_vector(3 downto 0);
        begin
            for k in 0 to 4 loop
                wait for 1 ns;
                case an is
                    when "1110" =>
                        assert seg = HEX_SEG(to_integer(unsigned(value(3 downto 0))))
                            report "Bledna mlodsza cyfra" severity failure;
                        seen(0) := '1';
                    when "1101" =>
                        assert seg = HEX_SEG(to_integer(unsigned(value(7 downto 4))))
                            report "Bledna starsza cyfra" severity failure;
                        seen(1) := '1';
                    when "1011" =>
                        assert seg = x"FF" report "AN2 nie jest pusta" severity failure;
                        seen(2) := '1';
                    when "0111" =>
                        assert seg = x"FF" report "AN3 nie jest pusta" severity failure;
                        seen(3) := '1';
                    when others => assert false report "Bledna anoda" severity failure;
                end case;
                if k < 4 then
                    old_an := an;
                    wait until an /= old_an for 1100 us;
                    assert an /= old_an report "Zatrzymane multipleksowanie" severity failure;
                end if;
            end loop;
            assert seen = "1111" report "Nie sprawdzono wszystkich pozycji" severity failure;
        end procedure;
        procedure send_and_check(constant value : std_logic_vector(7 downto 0);
                                 constant bit_time : time) is
        begin
            wait for 137 ns;
            send_byte(rx, value, bit_time);
            wait for 1 us;
            check_display(value);
        end procedure;
    begin
        wait for 13 ns;
        rst <= '1'; wait for 1 ns;
        assert an = "1111" and seg = x"FF"
            report "Reset nie wygasil wyswietlacza" severity failure;
        wait for 99 ns;
        rst <= '0'; wait for 1 us;
        check_display(x"00");

        report "TEST 1: 53 przy 9600 bps" severity note;
        send_and_check(x"53", BIT_NOM);
        send_and_check(x"00", BIT_NOM); -- Zmiana obrazu przed kolejnym 53.
        report "TEST 2: 53 przy 9216 bps (-4%)" severity note;
        send_and_check(x"53", BIT_SLOW);
        send_and_check(x"FF", BIT_NOM); -- Stare 53 nie moze zamaskowac braku odbioru.
        report "TEST 3: 53 przy 9984 bps (+4%)" severity note;
        send_and_check(x"53", BIT_FAST);
        report "PASS: trzy predkosci UART, hex, reset i skanowanie 1 ms" severity note;
        done <= true;
        wait;
    end process;

    p_timeout : process
    begin
        wait until done for 40 ms;
        assert done report "TIMEOUT" severity failure;
        wait;
    end process;
end architecture Behavioral;
