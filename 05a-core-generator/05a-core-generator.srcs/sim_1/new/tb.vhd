-- VHDL-93. Modele IP ponizej sa tylko do symulacji.
-- Czcionka jest kopia bajtow oryginalnego chargen.coe (bez modyfikacji).
library ieee;
use ieee.std_logic_1164.all;

package tb_font_pkg is
    subtype byte_t is std_logic_vector(7 downto 0);
    function font_byte(address : natural) return byte_t;
end package tb_font_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package body tb_font_pkg is
    constant C_FONT_HEX : string :=
        "0000000000000000000000000000000000007C82AA8282BA92827C000000000000007CFED6FEFEC6EEFE7C00000000000000006CFEFEFEFE7C38100000000000" &
        "00000010387CFE7C38100000000000000000387C7C38FEFE7C107C0000000000000010387CFEFE7C10107C000000000000000000003078783000000000000000" &
        "FFFFFFFFFFCF8787CFFFFFFFFFFFFFFF0000000078CC8484CC78000000000000FFFFFFFFC793BBBB93C7FFFFFFFFFFFF00003E0E1A3278CCCCCC780000000000" &
        "000078CCCCCC7830FC3030000000000000003C243C20202060E0C0000000000000003E223E2222222EEEEC600000000000001010D638EE38D610100000000000" &
        "0000406070787E787060400000000000000002060E1E7E1E0E0602000000000000003078FC303030FC7830000000000000006666666666660066660000000000" &
        "00007EF6F6F676363636360000000000007CC660386CC6C66C380CC67C00000000000000000000007E7E7E0000000000000010387C3838387C38100000000000" &
        "0010387C38383838383800000000000000003838383838387C3810000000000000000000180CFE0C1800000000000000000000003060FE603000000000000000" &
        "00000000006060607E0000000000000000000000286CFE6C28000000000000000000000018183C3C7E7E0000000000000000007E7E3C3C181800000000000000" &
        "000000000000000000000000000000000000307878783030003030000000000000666666240000000000000000000000000024247E2424247E24240000000000" &
        "18183C6662603C0642663C18180000000000000062660C1830664600000000000000386C6C383A6E6C6E3A000000000000303030600000000000000000000000" &
        "00000C183030303030180C0000000000000030180C0C0C0C0C18300000000000000000006C38FE386C000000000000000000000018187E181800000000000000" &
        "00000000000000001818183000000000000000000000FE0000000000000000000000000000000000001818000000000000000002060C183060C0800000000000" &
        "00003C666E6E7E7676663C0000000000000018387818181818183C000000000000003C6606060C1830667E000000000000003C6606063C0606663C0000000000" &
        "00000C1C3C6CCCFE0C0C1E000000000000007E6060607C0606663C000000000000001C3060607C6666663C000000000000007E66060C0C181818180000000000" &
        "00003C6666663C6666663C000000000000003C6666663E06060C7800000000000000001818000018180000000000000000000018180000001818300000000000" &
        "0000060C18306030180C06000000000000000000007E00007E0000000000000000006030180C060C183060000000000000003C6666060C180018180000000000" &
        "00003C6666666E6E6E603C00000000000000183C6666667E66666600000000000000FC6666667C666666FC000000000000001C366260606062361C0000000000" &
        "0000F86C66666666666CF8000000000000007E3230343C3430327E000000000000007E3230343C34303078000000000000003C766060606E66763C0000000000" &
        "0000666666667E66666666000000000000003C181818181818183C000000000000001E0C0C0C0C0CCCCC7800000000000000E6666C6C786C6C66E60000000000" &
        "000078303030303030327E00000000000000C6EEFED6C6C6C6C6C600000000000000666676767E6E6E6666000000000000003C666666666666663C0000000000" &
        "0000FC6666667C606060F0000000000000003C66666666667E6E3C06070000000000FC6666667E6C6666F6000000000000003C6666301C0666663C0000000000" &
        "0000FF99181818181818180000000000000066666666666666663C00000000000000C6C6C6C6C6C66C381000000000000000C6C6C6C6D6D6FE6C6C0000000000" &
        "0000C6C66C3838386CC6C600000000000000C6C6C6C66C3838387C00000000000000FEC68C183060C2C6FE000000000000003C303030303030303C0000000000" &
        "0000406070381C0E060200000000000000003C0C0C0C0C0C0C0C3C000000000000183C660000000000000000000000000000000000000000000000FE00000000" &
        "18180C000000000000000000000000000000000000780C7CCCCC7600000000000000E060607C66666676EC000000000000000000003C666060663C0000000000" &
        "00000E06061E366666663B000000000000000000003C667E60663C000000000000001C3632307C30303078000000000000000000003B6666663E06663C000000" &
        "0000E06060607C666666E60000000000000018180038181818183C000000000000000606000E06060666663C000000000000E06060666E7C6E66E60000000000" &
        "000038181818181818183C00000000000000000000FED6D6D6C6C600000000000000000000DC6666666666000000000000000000003C666666663C0000000000" &
        "0000000000DC6666667C6060F000000000000000003B6666663E06060F00000000000000006E3333303078000000000000000000003E62380C663C0000000000" &
        "00000818187E1818181A0E0000000000000000000066666666663B00000000000000000000C6C6C66C381000000000000000000000C6C6D6D67C6C0000000000" &
        "0000000000663C18183C6600000000000000000000666666663E060C3800000000000000007E660C18367E000000000000000E181818701818180E0000000000" &
        "000018181818001818181800000000000000701818181C18181870000000000000003B6E000000000000000000000000000000000000183C6666667E00000000" &
        "00001E3660606066663E06033E000000000066660066666666663B000000000000060C18003C667E60663C000000000000081C36003C063E66663B0000000000" &
        "00006666003C063E66663B00000000000030180C003C063E66663B0000000000001C361C003C063E66663B000000000000000000003C6660663C063C00000000" &
        "00081C36003C667E60663C000000000000006666003C667E60663C00000000000030180C003C667E60663C000000000000003636001C0C0C0C0C1E0000000000" &
        "00183C660038181818183C0000000000006030180038181818183C0000000000006666183C6666667E666600000000003C663C003C6666667E66660000000000" &
        "0C1830007E32303C30327E00000000000000000000DC76367CD8DC760000000000001F3666667F66666667000000000000183C66003C666666663C0000000000" &
        "00006666003C666666663C00000000000030180C003C666666663C000000000000183C660066666666663B00000000000030180C0066666666663B0000000000" &
        "0000666600666666663E060C380000000062623C6666666666663C0000000000006666006666666666663C00000000000018187EC6C0C0C67E18180000000000" &
        "001C36303078303030737E00000000000000C66C3810FE10FE1010000000000000FC66667C62666F6666F30000000000000E1B1818187E18181818D870000000" &
        "000C1830003C063E66663B0000000000000C18300038181818183C0000000000000C1830003C666666663C0000000000000C18300066666666663B0000000000" &
        "000076DC00DC6666666666000000000076DC006676767E6E6E66660000000000003C6C6C3E007E00000000000000000000386C6C38007C000000000000000000" &
        "0000181800183066663C0000000000000000000000007E6060000000000000000000000000007E0606000000000000000060E062646810205C860C183E000000" &
        "0060E0626468102056B63E0606000000000018180018183C3C3C18000000000000000000366CD86C3600000000000000000000006C361B366C00000000000000" &
        "1144114411441144114411441144114455AA55AA55AA55AA55AA55AA55AA55AADD77DD77DD77DD77DD77DD77DD77DD7718181818181818181818181818181818" &
        "18181818181818F818181818181818181818181818F818F8181818181818181836363636363636F6363636363636363600000000000000FE3636363636363636" &
        "0000000000F818F818181818181818183636363636F606F63636363636363636363636363636363636363636363636360000000000FE06F63636363636363636" &
        "3636363636F606FE000000000000000036363636363636FE00000000000000001818181818F818F8000000000000000000000000000000F81818181818181818" &
        "181818181818181F000000000000000018181818181818FF000000000000000000000000000000FF1818181818181818181818181818181F1818181818181818" &
        "00000000000000FF000000000000000018181818181818FF181818181818181818181818181F181F181818181818181836363636363636373636363636363636" &
        "363636363637303F000000000000000000000000003F303736363636363636363636363636F700FF00000000000000000000000000FF00F73636363636363636" &
        "363636363637303736363636363636360000000000FF00FF00000000000000003636363636F700F736363636363636361818181818FF00FF0000000000000000" &
        "36363636363636FF00000000000000000000000000FF00FF181818181818181800000000000000FF3636363636363636363636363636363F0000000000000000" &
        "18181818181F181F000000000000000000000000001F181F1818181818181818000000000000003F363636363636363636363636363636FF3636363636363636" &
        "1818181818FF18FF181818181818181818181818181818F80000000000000000000000000000001F1818181818181818FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF" &
        "00000000000000FFFFFFFFFFFFFFFFFFF0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F00F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0FFFFFFFFFFFFFFF000000000000000000" &
        "00000000033E6C6C6C6E3B0000000000000000003C667C66667C60602000000000007E6666606060606060000000000000000000FE6C6C6C6C6C6C0000000000" &
        "00007E6630180C1830667E000000000000000000003E6C6C6C6C38000000000000000000363636363C303060000000000000000076DC18181818180000000000" &
        "00007E183C6666663C187E00000000000000183C66667E66663C18000000000000003C66666666663C6666E70000000000001E30180C3E6666663C0000000000" &
        "00000000007CD6D67C00000000000000000002067CDED6F67C60C0000000000000001C3060607C6060301C0000000000000000003C6666666666666600000000" &
        "000000007E007E7E007E0000000000000000101010FE10101000FE0000000000000030180C060C183000FE000000000000000C18306030180C00FE0000000000" &
        "00000E1B1B18181818181818181818181818181818181818D8D8700000000000000018180000FE0000181800000000000000000076DC0076DC00000000000000" &
        "00386C6C3800000000000000000000000000000000001818000000000000000000000000000000300000000000000000001E1818181818D87838180000000000" &
        "00D86C6C6C6C6C0000000000000000000070D83060C8F8000000000000000000000000003C3C3C3C3C3C00000000000000000000000000000000000000000000";
    function hex_digit(c : character) return natural is
    begin
        case c is
            when '0' to '9' => return character'pos(c) - character'pos('0');
            when 'A' to 'F' => return character'pos(c) - character'pos('A') + 10;
            when others => assert false report "Blad danych czcionki" severity failure;
                           return 0;
        end case;
    end function;
    function font_byte(address : natural) return byte_t is
        variable n : natural;
    begin
        assert address < 4096 report "Adres ROM poza zakresem" severity failure;
        n := 16 * hex_digit(C_FONT_HEX(2 * address + 1)) +
                  hex_digit(C_FONT_HEX(2 * address + 2));
        return std_logic_vector(to_unsigned(n, 8));
    end function;
end package body tb_font_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tb_font_pkg.all;

entity tb_char_mem is
    port (
        clka  : in  std_logic;
        addra : in  std_logic_vector(11 downto 0);
        douta : out std_logic_vector(7 downto 0)
    );
end entity;

architecture Behavioral of tb_char_mem is
begin
    process(clka)
    begin
        if rising_edge(clka) then
            douta <= font_byte(to_integer(unsigned(addra)));
        end if;
    end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity tb_fifo_mem is
    port (
        clk   : in  std_logic;
        din   : in  std_logic_vector(7 downto 0);
        wr_en : in  std_logic;
        rd_en : in  std_logic;
        dout  : out std_logic_vector(7 downto 0);
        full  : out std_logic;
        empty : out std_logic
    );
end entity;

architecture Behavioral of tb_fifo_mem is
    type ram_t is array(0 to 63) of std_logic_vector(7 downto 0);
    signal ram : ram_t := (others => (others => '0'));
    signal wp : natural range 0 to 63 := 0;
    signal rp : natural range 0 to 63 := 0;
    signal used : natural range 0 to 64 := 0;
    signal q : std_logic_vector(7 downto 0) := (others => '0');
begin
    full <= '1' when used = 64 else '0';
    empty <= '1' when used = 0 else '0';
    dout <= q;
    process(clk)
        variable do_read : boolean;
        variable do_write : boolean;
    begin
        if rising_edge(clk) then
            do_read := rd_en = '1' and used > 0;
            do_write := wr_en = '1' and used < 64;
            assert not (rd_en = '1' and used = 0)
                report "Proba odczytu pustego FIFO" severity failure;
            assert not (wr_en = '1' and used = 64)
                report "Zapis do pelnego FIFO nie zostal zablokowany" severity failure;
            if do_read then
                q <= ram(rp);
                rp <= (rp + 1) mod 64;
            end if;
            if do_write then
                ram(wp) <= din;
                wp <= (wp + 1) mod 64;
            end if;
            if do_write and not do_read then
                used <= used + 1;
            elsif do_read and not do_write then
                used <= used - 1;
            end if;
        end if;
    end process;
end architecture;

-- Jawne powiazanie komponentow DUT z modelami testowymi.
-- W syntezie top korzysta z prawdziwych char_mem / fifo_mem z IP Catalog.
configuration top_simulation of top is
    for Behavioral
        for u_rom : char_mem
            use entity work.tb_char_mem(Behavioral);
        end for;
        for u_fifo : fifo_mem
            use entity work.tb_fifo_mem(Behavioral);
        end for;
    end for;
end configuration top_simulation;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tb_font_pkg.all;

entity tb is
    generic (
        -- Przyspieszenie TYLKO testu. top na plytce ma domyslnie 9600 bps.
        -- G_TEST_BAUD=9600 i G_FULL_TEST=false: krotka proba nominalna.
        G_TEST_BAUD : positive := 1000000;
        G_FULL_TEST : boolean := true
    );
end entity tb;

architecture Behavioral of tb is
    constant C_BIT : time := 1 sec / G_TEST_BAUD;
    signal clk : std_logic := '0';
    signal rx : std_logic := '1';
    signal tx : std_logic;
    signal led : std_logic;
    signal an : std_logic_vector(3 downto 0);
    signal seg : std_logic_vector(7 downto 0);
    signal sim_done : boolean := false;
    signal received : natural := 0;

    type chars_t is array(0 to 17) of byte_t;
    type batch_t is record
        size : natural range 1 to 18;
        chars : chars_t;
    end record;
    type batches_t is array(0 to 8) of batch_t;

    function make_batches return batches_t is
        variable b : batches_t := (others => (size => 1, chars => (others => x"00")));
    begin
        b(0).chars(0) := x"52"; -- R, zakonczenie Enterem.
        b(1).size := 7;
        b(1).chars(0) := x"00";
        b(1).chars(1) := x"0A"; -- LF jest zwyklym glifem, piksele '*'.
        b(1).chars(2) := x"1F";
        b(1).chars(3) := x"20";
        b(1).chars(4) := x"7F";
        b(1).chars(5) := x"80";
        b(1).chars(6) := x"FF";
        b(2).size := 18;
        for i in 0 to 17 loop
            b(2).chars(i) := std_logic_vector(to_unsigned(65 + i, 8));
        end loop;
        b(3).chars(0) := x"41"; -- A: trwa drukowanie podczas wypelniania FIFO.
        for k in 4 to 6 loop
            b(k).size := 18;
            b(k).chars := (others => x"58");
        end loop;
        b(7).size := 9;
        b(7).chars := (others => x"58"); -- Razem 63 X + CR = 64 wpisy FIFO.
        b(8).chars(0) := x"5A"; -- Z: poprawny odbior po przepelnieniu.
        return b;
    end function;
    constant BATCHES : batches_t := make_batches;

    function bytes_through(number : natural) return natural is
        variable n : natural := 0;
    begin
        for i in 0 to number - 1 loop
            n := n + 16 * (8 * BATCHES(i).size + 2);
        end loop;
        return n;
    end function;
    function total_bytes return natural is
    begin
        if G_FULL_TEST then return bytes_through(9);
        else return bytes_through(1); end if;
    end function;
    constant C_TOTAL : natural := total_bytes;
    constant C_TIMEOUT : time := C_TOTAL * 14 * C_BIT + 100 ms;

    -- Referencja: 16 wierszy; w kazdym po 8 pikseli na znak, potem CR LF.
    function expected_byte(position : natural) return byte_t is
        variable n : natural := position;
        variable width : natural;
        variable row : natural;
        variable offset : natural;
        variable code : byte_t;
        variable bitmap : byte_t;
    begin
        for b in BATCHES'range loop
            width := BATCHES(b).size * 8 + 2;
            if n < 16 * width then
                row := n / width;
                offset := n mod width;
                if offset = width - 2 then return x"0D";
                elsif offset = width - 1 then return x"0A";
                else
                    code := BATCHES(b).chars(offset / 8);
                    bitmap := font_byte(to_integer(unsigned(code)) * 16 + row);
                    if bitmap(7 - (offset mod 8)) = '0' then return x"20";
                    elsif unsigned(code) < 32 or unsigned(code) > 127 then return x"2A";
                    else return code; end if;
                end if;
            end if;
            n := n - 16 * width;
        end loop;
        assert false report "Brak bajtu w strumieniu referencyjnym" severity failure;
        return x"00";
    end function;

    type hex_t is array(0 to 15) of byte_t;
    constant HEX_SEG : hex_t := (
        x"03", x"9F", x"25", x"0D", x"99", x"49", x"41", x"1F",
        x"01", x"09", x"11", x"C1", x"63", x"85", x"61", x"71"
    );

    procedure send_byte(signal wire : out std_logic;
                        constant value : byte_t;
                        constant duration : time;
                        constant good_stop : boolean := true) is
    begin
        wire <= '0';
        wait for duration;
        for i in 0 to 7 loop
            wire <= value(i);
            wait for duration;
        end loop;
        if good_stop then wire <= '1'; else wire <= '0'; end if;
        wait for duration;
    end procedure;
begin
    clk <= not clk after 5 ns when not sim_done else '0';

    dut : configuration work.top_simulation
        generic map (G_BAUD => G_TEST_BAUD)
        port map (
            clk_i => clk, RXD_i => rx, TXD_o => tx, ld0 => led,
            led7_an_o => an, led7_seg_o => seg
        );

    p_serial_monitor : process
        variable value : byte_t;
        variable expected : byte_t;
        variable count : natural := 0;
    begin
        wait until tx = '0';
        wait for C_BIT / 2;
        assert tx = '0' report "Bledny start TX" severity failure;
        for i in 0 to 7 loop
            wait for C_BIT;
            value(i) := tx;
        end loop;
        wait for C_BIT;
        assert tx = '1' report "Bledny stop TX" severity failure;
        assert count < C_TOTAL report "Nadmiarowy bajt na TX" severity failure;
        expected := expected_byte(count);
        assert value = expected
            report "Bledny bajt TX nr " & integer'image(count) &
                   ": odebrano " & integer'image(to_integer(unsigned(value))) &
                   ", oczekiwano " & integer'image(to_integer(unsigned(expected)))
            severity failure;
        count := count + 1;
        received <= count;
        wait for C_BIT / 2;
        assert tx = '1' report "Za krotki bit stopu TX" severity failure;
    end process;

    p_check_scan : process
        variable started : boolean := false;
        variable previous : time := 0 ns;
    begin
        wait on an;
        if now > 0 ns then
            assert an = "1110" or an = "1101" or an = "1011" or an = "0111"
                report "Bledny wybor anody" severity failure;
            if started then
                assert now - previous = 1 ms
                    report "Skanowanie nie ma okresu 1 ms" severity failure;
            end if;
            started := true;
            previous := now;
        end if;
    end process;

    p_stimulus : process
        procedure check_display(constant code : byte_t) is
            variable seen : std_logic_vector(3 downto 0) := "0000";
            variable old_an : std_logic_vector(3 downto 0);
        begin
            for k in 0 to 4 loop
                wait for 1 ns;
                case an is
                    when "1110" =>
                        assert seg = HEX_SEG(to_integer(unsigned(code(3 downto 0))))
                            report "Bledna mlodsza cyfra monitora" severity failure;
                        seen(0) := '1';
                    when "1101" =>
                        assert seg = HEX_SEG(to_integer(unsigned(code(7 downto 4))))
                            report "Bledna starsza cyfra monitora" severity failure;
                        seen(1) := '1';
                    when "1011" =>
                        assert seg = x"FF" report "AN2 nie jest pusta" severity failure;
                        seen(2) := '1';
                    when "0111" =>
                        assert seg = x"FF" report "AN3 nie jest pusta" severity failure;
                        seen(3) := '1';
                    when others => assert false report "Niepoprawna anoda" severity failure;
                end case;
                if k < 4 then
                    old_an := an;
                    wait until an /= old_an for 1100 us;
                    assert an /= old_an report "Zatrzymane skanowanie" severity failure;
                end if;
            end loop;
            assert seen = "1111" report "Nie sprawdzono wszystkich pozycji" severity failure;
        end procedure;
    begin
        report "START: test bez resetu, baud=" & integer'image(G_TEST_BAUD) severity note;
        wait for 10 * C_BIT;
        assert tx = '1' and led = '0' report "Bledny stan poczatkowy" severity failure;
        check_display(x"00");

        -- Falszywy start i bledny stop nie moga trafic do FIFO ani monitora.
        rx <= '0'; wait for C_BIT / 10; rx <= '1'; wait for 2 * C_BIT;
        send_byte(rx, x"21", C_BIT, false);
        rx <= '1'; wait for 2 * C_BIT;
        assert received = 0 report "Blad odbioru falszywej ramki" severity failure;

        report "TEST: R + Enter, brak wydruku przed Enterem" severity note;
        send_byte(rx, x"52", C_BIT);
        wait for 20 * C_BIT;
        assert tx = '1' and received = 0 report "Wydruk przed Enterem" severity failure;
        send_byte(rx, x"0D", C_BIT);

        if G_FULL_TEST then
            report "TEST: znaki sterujace i buforowanie podczas wydruku" severity note;
            for i in 0 to 6 loop
                if i = 2 then
                    send_byte(rx, BATCHES(1).chars(i), 1 sec / (G_TEST_BAUD * 96 / 100));
                elsif i = 4 then
                    send_byte(rx, BATCHES(1).chars(i), 1 sec / (G_TEST_BAUD * 104 / 100));
                else
                    send_byte(rx, BATCHES(1).chars(i), C_BIT);
                end if;
            end loop;
            send_byte(rx, x"0D", C_BIT);
            report "TEST: automatyczny wydruk 18 znakow" severity note;
            for i in 0 to 17 loop send_byte(rx, BATCHES(2).chars(i), C_BIT); end loop;
            send_byte(rx, x"0D", C_BIT); -- Enter po pelnej linii: pusta linia pominieta.
            send_byte(rx, x"0D", C_BIT);
            wait until received = bytes_through(3) for C_TIMEOUT;
            assert received = bytes_through(3) report "Nie wydrukowano pierwszych linii" severity failure;
            wait for 2 * C_BIT;
            assert led = '0' report "LD0 swieci bez przepelnienia FIFO" severity failure;

            report "TEST: dokladnie 64 wpisy FIFO, potem 2 odrzucone" severity note;
            send_byte(rx, x"41", C_BIT);
            send_byte(rx, x"0D", C_BIT);
            wait for 2 * C_BIT;
            for i in 1 to 63 loop send_byte(rx, x"58", C_BIT); end loop;
            assert led = '0' report "LD0 zapalila sie przed przepelnieniem FIFO" severity failure;
            send_byte(rx, x"0D", C_BIT); -- 64. wpis: Enter.
            assert led = '0' report "LD0 przed faktyczna utrata znaku" severity failure;
            send_byte(rx, x"45", C_BIT); -- E: odrzucony.
            send_byte(rx, x"46", C_BIT); -- F: odrzucony, ale widoczny na LED7.
            wait for 2 * C_BIT;
            assert led = '1' report "Brak sygnalizacji przepelnienia FIFO" severity failure;
            wait until received = bytes_through(4) for C_TIMEOUT;
            assert received = bytes_through(4) report "Nie wydrukowano linii A" severity failure;
            assert led = '1' report "LD0 zgasla przed zwolnieniem miejsca w FIFO" severity failure;
            -- Po linii A pierwszy odczyt zwalnia miejsce w pelnym FIFO.
            wait until led = '0' for 100 * C_BIT;
            assert led = '0' report "LD0 nie zgasla po zwolnieniu miejsca w FIFO" severity failure;
            assert received = bytes_through(4)
                report "LD0 czekala na wydruk znakow z FIFO" severity failure;
            check_display(x"46");
            wait until received = bytes_through(8) for C_TIMEOUT;
            assert received = bytes_through(8) report "Blad danych po przepelnieniu" severity failure;
            wait for 2 * C_BIT;
            assert led = '0' report "LD0 swieci przy pustym FIFO" severity failure;

            report "TEST: dalsza praca po przepelnieniu" severity note;
            send_byte(rx, x"5A", C_BIT);
            send_byte(rx, x"0D", C_BIT);
        end if;

        wait until received = C_TOTAL for C_TIMEOUT;
        assert received = C_TOTAL report "Niepelny wydruk" severity failure;
        wait for 2 * C_BIT;
        check_display(x"0D");
        assert led = '0' report "LD0 pozostala zapalona" severity failure;
        report "PASS: sprawdzono " & integer'image(C_TOTAL) & " bajtow TX" severity note;
        sim_done <= true;
        wait;
    end process;

    p_timeout : process
    begin
        wait until sim_done for C_TIMEOUT;
        assert sim_done report "TIMEOUT symulacji" severity failure;
        wait;
    end process;
end architecture Behavioral;

