-- Modele IP do testow VHDL-93; na FPGA potrzebne sa IP video_mem i singen.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package tb_support is
    type frame_t is array(0 to 147455) of std_logic;
    signal observed_memory : frame_t := (others => 'U');
    signal clearing : boolean := true;
    signal clears_done : natural := 0;
    signal packets_done : natural := 0;
    signal plots_done : natural := 0;
    signal cfg_x : natural := 256;
    signal cfg_y : natural := 256;
    signal cfg_phase : natural := 16384;
    signal capture_request : natural := 0;
    signal captures_done : natural := 0;
    function sine_sample(phase : natural) return integer;
    function ref_address(step, fx, fy, py : natural) return natural;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package body tb_support is
    type sine_table_t is array(0 to 65535) of integer range -1022 to 1022;
    function make_sine return sine_table_t is
        variable lut : sine_table_t;
    begin
        for i in lut'range loop
            lut(i) := integer(1022.0 * sin(2.0 * MATH_PI * real(i) / 65536.0));
        end loop;
        return lut;
    end function;
    constant SINE : sine_table_t := make_sine;
    function sine_sample(phase : natural) return integer is
    begin
        return SINE(phase mod 65536);
    end function;
    function ref_address(step, fx, fy, py : natural) return natural is
        variable x, y : natural range 0 to 383;
    begin
        x := (3072 + 3 * sine_sample((step * fx) mod 65536)) / 16;
        y := (3071 - 3 * sine_sample((step * fy + py) mod 65536)) / 16;
        return y * 384 + x;
    end function;
end package body;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tb_support.all;

entity tb_singen is
    port (
        aclk : in std_logic;
        aclken : in std_logic;
        aresetn : in std_logic;
        s_axis_config_tvalid : in std_logic;
        s_axis_config_tdata : in std_logic_vector(31 downto 0);
        s_axis_config_tlast : in std_logic;
        m_axis_data_tvalid : out std_logic;
        m_axis_data_tdata : out std_logic_vector(15 downto 0);
        event_s_config_tlast_missing : out std_logic;
        event_s_config_tlast_unexpected : out std_logic
    );
end entity;

architecture Behavioral of tb_singen is
    constant LATENCY : positive := 9;
    type data_pipe_t is array(0 to LATENCY - 1) of std_logic_vector(15 downto 0);
    signal pipe : data_pipe_t := (others => (others => '0'));
    signal valid_pipe : std_logic_vector(0 to LATENCY - 1) := (others => '0');
begin
    m_axis_data_tdata <= pipe(LATENCY - 1);
    m_axis_data_tvalid <= valid_pipe(LATENCY - 1);
    event_s_config_tlast_missing <= '0';
    event_s_config_tlast_unexpected <= '0';
    process(aclk)
        type words_t is array(0 to 1) of natural range 0 to 65535;
        variable phase : words_t := (others => 0);
        variable pinc : words_t := (others => 256);
        variable poff : words_t := (0, 16384);
        variable channel : natural range 0 to 1 := 0;
        variable config_channel : natural range 0 to 1 := 0;
        variable first_word : std_logic_vector(31 downto 0) := (others => '0');
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                -- Reset akumulatorow i potoku; PINC i POFF pozostaja zapisane.
                phase := (others => 0);
                channel := 0;
                config_channel := 0;
                valid_pipe <= (others => '0');
            elsif aclken = '1' then
                for i in LATENCY - 1 downto 1 loop
                    pipe(i) <= pipe(i - 1);
                    valid_pipe(i) <= valid_pipe(i - 1);
                end loop;
                pipe(0) <= std_logic_vector(to_signed(sine_sample(phase(channel) + poff(channel)), 16));
                valid_pipe(0) <= '1';
                phase(channel) := (phase(channel) + pinc(channel)) mod 65536;
                channel := 1 - channel;

                if s_axis_config_tvalid = '1' then
                    if config_channel = 0 then
                        assert s_axis_config_tlast = '0'
                            report "TLAST ustawione dla X zamiast Y" severity failure;
                        first_word := s_axis_config_tdata;
                        config_channel := 1;
                    else
                        assert s_axis_config_tlast = '1'
                            report "Brak TLAST dla Y" severity failure;
                        assert first_word(31 downto 16) = x"0000"
                            report "Faza X nie jest zerowa" severity failure;
                        pinc(0) := to_integer(unsigned(first_word(15 downto 0)));
                        poff(0) := to_integer(unsigned(first_word(31 downto 16)));
                        pinc(1) := to_integer(unsigned(s_axis_config_tdata(15 downto 0)));
                        poff(1) := to_integer(unsigned(s_axis_config_tdata(31 downto 16)));
                        cfg_x <= pinc(0);
                        cfg_y <= pinc(1);
                        cfg_phase <= poff(1);
                        packets_done <= packets_done + 1;
                        config_channel := 0;
                    end if;
                end if;
            end if;
        end if;
    end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.tb_support.all;

entity tb_video_mem is
    port (
        clka : in std_logic;
        wea : in std_logic_vector(0 downto 0);
        addra : in std_logic_vector(17 downto 0);
        dina : in std_logic_vector(0 downto 0);
        clkb : in std_logic;
        addrb : in std_logic_vector(17 downto 0);
        doutb : out std_logic_vector(0 downto 0)
    );
end entity;

architecture Behavioral of tb_video_mem is
begin
    clearing <= wea(0) = '1' and dina(0) = '0';
    process(clka)
        variable address : natural;
        variable next_clear : natural := 0;
        variable first_draw : boolean := true;
        variable expected_frame : frame_t;
        variable last_capture : natural := 0;
        variable white_count : natural;
        file image : text;
        variable l : line;
    begin
        if rising_edge(clka) then
            assert clkb = '1' report "Porty RAM nie maja wspolnego zegara" severity failure;
            assert to_integer(unsigned(addrb)) < 147456
                report "Adres odczytu poza RAM" severity failure;
            doutb(0) <= observed_memory(to_integer(unsigned(addrb))); -- Read-first, latency 1.
            if wea(0) = '1' then
                address := to_integer(unsigned(addra));
                assert address < 147456 report "Adres zapisu poza RAM" severity failure;
                if dina(0) = '0' then
                    assert address = next_clear
                        report "Pominiety lub powtorzony adres podczas czyszczenia" severity failure;
                    if next_clear = 147455 then
                        next_clear := 0;
                        clears_done <= clears_done + 1;
                        first_draw := true;
                    else next_clear := next_clear + 1; end if;
                else
                    if first_draw then
                        assert address = ref_address(0, cfg_x, cfg_y, cfg_phase)
                            report "Bledny pierwszy punkt po resecie DDS" severity failure;
                        first_draw := false;
                    end if;
                    plots_done <= plots_done + 1;
                end if;
                observed_memory(address) <= dina(0);
            end if;

            if capture_request /= last_capture then
                expected_frame := (others => '0');
                for n in 0 to 65535 loop
                    expected_frame(ref_address(n, cfg_x, cfg_y, cfg_phase)) := '1';
                end loop;
                white_count := 0;
                for n in expected_frame'range loop
                    assert observed_memory(n) = expected_frame(n)
                        report "Bledny obraz: adres " & integer'image(n) severity failure;
                    if observed_memory(n) = '1' then white_count := white_count + 1; end if;
                end loop;
                assert white_count > 0 report "Pusty obraz" severity failure;
                -- Obraz PGM mozna otworzyc/konwertowac po symulacji.
                file_open(image, "figure_" & integer'image(capture_request) & ".pgm", write_mode);
                write(l, string'("P2")); writeline(image, l);
                write(l, string'("384 384")); writeline(image, l);
                write(l, string'("255")); writeline(image, l);
                for y in 0 to 383 loop
                    for x in 0 to 383 loop
                        if observed_memory(y * 384 + x) = '1' then write(l, string'("255 "));
                        else write(l, string'("0 ")); end if;
                    end loop;
                    writeline(image, l);
                end loop;
                file_close(image);
                report "Obraz " & integer'image(capture_request) & ": " &
                       integer'image(white_count) & " bialych pikseli" severity note;
                last_capture := capture_request;
                captures_done <= capture_request;
            end if;
        end if;
    end process;
end architecture;

configuration top_simulation of top is
    for Behavioral
        for u_video : video_mem use entity work.tb_video_mem(Behavioral); end for;
        for u_dds : singen use entity work.tb_singen(Behavioral); end for;
    end for;
end configuration;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tb_support.all;

entity tb is end entity;

architecture Behavioral of tb is
    signal clk : std_logic := '0';
    signal sw : std_logic_vector(7 downto 0) := (others => '0');
    signal btn : std_logic_vector(3 downto 0) := (others => '0');
    signal r, g, b : std_logic_vector(3 downto 0);
    signal hs, vs : std_logic;
    signal sim_done : boolean := false;
    signal frames_seen : natural := 0;
begin
    clk <= not clk after 5 ns when not sim_done else '0';
    dut : configuration work.top_simulation
        generic map (G_DEBOUNCE_TICKS => 4)
        port map (clk_i => clk, sw_i => sw, btn_i => btn,
                  red_o => r, green_o => g, blue_o => b, hsync_o => hs, vsync_o => vs);

    -- Niezalezna kontrola kazdego taktu VGA, wraz z odczytem RAM i blankingiem.
    p_vga_check : process
        variable h : natural range 0 to 799 := 0;
        variable v : natural range 0 to 524 := 0;
        variable div : natural range 0 to 3 := 0;
        variable expected_hs, expected_vs : std_logic;
        variable expected_rgb : std_logic_vector(3 downto 0);
    begin
        wait until rising_edge(clk);
        expected_hs := '1'; expected_vs := '1'; expected_rgb := "0000";
        if h >= 656 and h <= 751 then expected_hs := '0'; end if;
        if v >= 490 and v <= 491 then expected_vs := '0'; end if;
        if h >= 128 and h <= 511 and v >= 48 and v <= 431 and not clearing then
            if observed_memory((v - 48) * 384 + h - 128) = '1' then expected_rgb := "1111";
            else
                assert observed_memory((v - 48) * 384 + h - 128) = '0'
                    report "Niezainicjalizowana pamiec widoczna na ekranie" severity failure;
            end if;
        end if;
        if div = 3 then
            div := 0;
            if h = 799 then
                h := 0;
                if v = 524 then v := 0; frames_seen <= frames_seen + 1;
                else v := v + 1; end if;
            else h := h + 1; end if;
        else div := div + 1; end if;
        wait for 1 ns;
        assert hs = expected_hs and vs = expected_vs
            report "Bledne impulsy synchronizacji VGA" severity failure;
        assert r = expected_rgb and g = expected_rgb and b = expected_rgb
            report "Bledny piksel RGB, obszar obrazu lub opoznienie odczytu RAM" severity failure;
    end process;

    p_stimulus : process
        variable old_packets : natural;
        procedure capture(constant number : positive) is
        begin
            wait for 2 ms; -- Ponad 65536 par, pelny okres dla PINC=1.
            capture_request <= number;
            wait until captures_done = number for 1 us;
            assert captures_done = number report "Nie zapisano obrazu" severity failure;
        end procedure;
        procedure program_button(constant button : natural; constant value : natural) is
            variable packets_before : natural;
        begin
            packets_before := packets_done;
            sw <= std_logic_vector(to_unsigned(value, 8));
            wait for 100 ns;
            btn(button) <= '1';
            wait for 1 us;
            btn(button) <= '0';
            wait for 1 us;
            assert packets_done = packets_before + 1
                report "Przycisk nie wyslal dokladnie jednego pakietu konfiguracji" severity failure;
        end procedure;
        procedure clear_screen is
            variable before_clear : natural;
        begin
            before_clear := clears_done;
            btn(0) <= '1'; wait for 1 us; btn(0) <= '0';
            wait until clears_done = before_clear + 1 for 2 ms;
            assert clears_done = before_clear + 1 report "Nie wyczyszczono calego ekranu" severity failure;
        end procedure;
        procedure figure(constant fx, fy, phase, number : natural) is
        begin
            report "TEST: X=" & integer'image(fx) & " Y=" & integer'image(fy) &
                   " faza SW=" & integer'image(phase) severity note;
            program_button(3, fx);
            program_button(2, fy);
            program_button(1, phase);
            assert cfg_x = fx and cfg_y = fy and cfg_phase = phase * 256
                report "Bledna czestotliwosc lub faza z przelacznikow" severity failure;
            clear_screen;
            capture(number);
        end procedure;
    begin
        report "TEST: start bez resetu, okrag z osobnych punktow" severity note;
        wait until clears_done = 1 for 2 ms;
        assert clears_done = 1 report "Brak czyszczenia po wlaczeniu" severity failure;
        capture(1);
        assert cfg_x = 256 and cfg_y = 256 and cfg_phase = 16384
            report "Bledne ustawienia poczatkowe" severity failure;

        report "TEST: tlumienie drgan stykow" severity note;
        old_packets := packets_done;
        btn(3) <= '1'; wait for 10 ns; btn(3) <= '0'; wait for 10 ns;
        btn(3) <= '1'; wait for 10 ns; btn(3) <= '0'; wait for 2 us;
        assert packets_done = old_packets report "Drgania stykow zmienily konfiguracje" severity failure;

        figure(1, 2, 0,   2); -- 0
        figure(1, 2, 64,  3); -- pi/2
        figure(1, 2, 192, 4); -- 3*pi/2
        figure(2, 1, 0,   5); -- 0
        figure(2, 1, 32,  6); -- pi/4
        figure(2, 1, 96,  7); -- 3*pi/4
        figure(3, 5, 13,  8); -- Dodatkowa dowolna figura.
        assert frames_seen >= 1 report "Nie sprawdzono pelnej ramki VGA" severity failure;
        report "PASS: 8 obrazow, VGA, blanking, RAM, DDS, przyciski i fazy" severity note;
        sim_done <= true;
        wait;
    end process;

    p_timeout : process
    begin
        wait until sim_done for 40 ms;
        assert sim_done report "TIMEOUT symulacji" severity failure;
        wait;
    end process;
end architecture Behavioral;
