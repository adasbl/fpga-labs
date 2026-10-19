library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- VHDL-93, Nexys A7-100T, 100 MHz. Bez zewnetrznego resetu.
-- IP: video_mem (147456 x 1, simple dual port, common clock, read latency 1)
-- oraz singen (DDS: 2 kanaly, phase width 16, output width 11, Sine,
-- Programmable PINC/POFF, ACLKEN i ARESETn, bez TREADY/TUSER/DATA TLAST).
entity top is
    generic (G_DEBOUNCE_TICKS : positive := 1000000); -- 10 ms
    port (
        clk_i   : in  std_logic;
        sw_i    : in  std_logic_vector(7 downto 0);
        btn_i   : in  std_logic_vector(3 downto 0);
        red_o   : out std_logic_vector(3 downto 0);
        green_o : out std_logic_vector(3 downto 0);
        blue_o  : out std_logic_vector(3 downto 0);
        hsync_o : out std_logic := '1';
        vsync_o : out std_logic := '1'
    );
end entity top;

architecture Behavioral of top is
    component video_mem is
        port (
            clka  : in std_logic;
            wea   : in std_logic_vector(0 downto 0);
            addra : in std_logic_vector(17 downto 0);
            dina  : in std_logic_vector(0 downto 0);
            clkb  : in std_logic;
            addrb : in std_logic_vector(17 downto 0);
            doutb : out std_logic_vector(0 downto 0)
        );
    end component;
    component singen is
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
    end component;

    constant C_SIDE : positive := 384;
    constant C_PIXELS : positive := C_SIDE * C_SIDE;
    constant C_LEFT : natural := 128; -- (640 - 384)/2
    constant C_TOP : natural := 48;   -- (480 - 384)/2

    signal sw_meta, sw_sync : std_logic_vector(7 downto 0) := (others => '0');
    signal btn_meta, btn_sync : std_logic_vector(3 downto 0) := (others => '0');
    signal btn_stable, btn_pulse : std_logic_vector(3 downto 0) := (others => '0');
    type debounce_t is array(0 to 3) of natural range 0 to G_DEBOUNCE_TICKS - 1;
    signal debounce_count : debounce_t := (others => 0);
    attribute ASYNC_REG : string;
    attribute ASYNC_REG of sw_meta, sw_sync, btn_meta, btn_sync : signal is "TRUE";

    -- 50 MHz / 65536 * 256 = 0.1953125 MHz na kanal.
    signal freq_x : std_logic_vector(15 downto 0) := x"0100";
    signal freq_y : std_logic_vector(15 downto 0) := x"0100";
    signal phase_y : std_logic_vector(15 downto 0) := x"4000"; -- pi/2
    signal request_config : boolean := true;
    signal request_clear : boolean := false;
    signal config_word_x, config_word_y : std_logic_vector(31 downto 0) := (others => '0');

    type control_t is (CLEAR_SCREEN, SNAPSHOT, RELEASE_DDS,
                       CONFIG_X, CONFIG_Y, APPLY_CONFIG, RESET_DDS, DRAW);
    signal control_state : control_t := CLEAR_SCREEN;
    signal clear_address : natural range 0 to C_PIXELS - 1 := 0;
    signal wait_count : natural range 0 to 63 := 0;
    signal screen_ready : std_logic := '0';

    signal dds_resetn : std_logic;
    signal config_valid, config_last : std_logic;
    signal config_data : std_logic_vector(31 downto 0);
    signal dds_valid : std_logic;
    signal dds_data : std_logic_vector(15 downto 0);
    signal next_is_y : boolean := false;
    signal x_pixel : natural range 0 to C_SIDE - 1 := 0;
    signal plot_address : std_logic_vector(17 downto 0) := (others => '0');
    signal plot_write : std_logic := '0';

    signal ram_we, ram_in, ram_out : std_logic_vector(0 downto 0);
    signal ram_write_addr, ram_read_addr : std_logic_vector(17 downto 0);

    signal pixel_div : natural range 0 to 3 := 0;
    signal h_count : natural range 0 to 799 := 0;
    signal v_count : natural range 0 to 524 := 0;
    signal in_window : boolean;
    signal visible_d : std_logic := '0';
    signal white_pixel : std_logic;

    function coordinate(sample : std_logic_vector(10 downto 0)) return natural is
        variable n : natural range 0 to 2047;
    begin
        n := to_integer(signed(sample)) + 1024;
        return (n * 3) / 16; -- Pelny zakres 0..383, bez dzielenia ogolnego.
    end function;
begin
    -- Wszystkie bloki sa taktowane 100 MHz. VGA uzywa clock enable co 4 takty.
    u_video : video_mem
        port map (
            clka => clk_i, wea => ram_we, addra => ram_write_addr, dina => ram_in,
            clkb => clk_i, addrb => ram_read_addr, doutb => ram_out
        );
    u_dds : singen
        port map (
            aclk => clk_i, aclken => '1', aresetn => dds_resetn,
            s_axis_config_tvalid => config_valid,
            s_axis_config_tdata => config_data,
            s_axis_config_tlast => config_last,
            m_axis_data_tvalid => dds_valid, m_axis_data_tdata => dds_data,
            event_s_config_tlast_missing => open,
            event_s_config_tlast_unexpected => open
        );

    p_inputs : process(clk_i)
    begin
        if rising_edge(clk_i) then
            sw_meta <= sw_i;
            sw_sync <= sw_meta;
            btn_meta <= btn_i;
            btn_sync <= btn_meta;
            btn_pulse <= (others => '0');
            for k in 0 to 3 loop
                if btn_sync(k) = btn_stable(k) then
                    debounce_count(k) <= 0;
                elsif debounce_count(k) = G_DEBOUNCE_TICKS - 1 then
                    debounce_count(k) <= 0;
                    btn_stable(k) <= btn_sync(k);
                    if btn_sync(k) = '1' then btn_pulse(k) <= '1'; end if;
                else
                    debounce_count(k) <= debounce_count(k) + 1;
                end if;
            end loop;
        end if;
    end process;

    -- CONFIG: dwa kolejne takty TVALID, TLAST tylko dla kanalu Y.
    -- TREADY wylaczone w IP, wiec kazdy takt z TVALID jest transakcja.
    config_valid <= '1' when control_state = CONFIG_X or control_state = CONFIG_Y else '0';
    config_last <= '1' when control_state = CONFIG_Y else '0';
    config_data <= config_word_y when control_state = CONFIG_Y else config_word_x;
    dds_resetn <= '0' when control_state = CLEAR_SCREEN or control_state = RESET_DDS else '1';

    p_control : process(clk_i)
        -- Wspolny licznik opoznien DDS. Procedura nie zatrzymuje zegara:
        -- jest wywolywana raz na zbocze, dopoki automat czeka w danym stanie.
        procedure wait_cycles(ticks : positive; next_state : control_t) is
        begin
            if wait_count = ticks - 1 then
                wait_count <= 0;
                control_state <= next_state;
            else
                wait_count <= wait_count + 1;
            end if;
        end procedure;
    begin
        if rising_edge(clk_i) then
            case control_state is
                when CLEAR_SCREEN =>
                    if clear_address = C_PIXELS - 1 then
                        -- Ostatni piksel jest zerowany na tym zboczu RAM.
                        screen_ready <= '1';
                        control_state <= SNAPSHOT;
                    else
                        clear_address <= clear_address + 1;
                    end if;
                when SNAPSHOT =>
                    config_word_x <= x"0000" & freq_x;
                    config_word_y <= phase_y & freq_y;
                    request_config <= false;
                    wait_count <= 0;
                    control_state <= RELEASE_DDS;
                when RELEASE_DDS =>
                    wait_cycles(4, CONFIG_X);
                when CONFIG_X => control_state <= CONFIG_Y;
                when CONFIG_Y =>
                    wait_count <= 0;
                    control_state <= APPLY_CONFIG;
                when APPLY_CONFIG =>
                    wait_cycles(32, RESET_DDS);
                when RESET_DDS =>
                    wait_cycles(4, DRAW);
                when DRAW =>
                    if request_clear then
                        request_clear <= false;
                        clear_address <= 0;
                        screen_ready <= '0';
                        control_state <= CLEAR_SCREEN;
                    elsif request_config then
                        control_state <= SNAPSHOT;
                    end if;
            end case;

            -- Zdarzenia na koncu procesu maja pierwszenstwo nad kasowaniem zadan.
            if btn_pulse(3) = '1' then -- BTNL: czestotliwosc X.
                freq_x <= x"00" & sw_sync;
                request_config <= true;
            end if;
            if btn_pulse(2) = '1' then -- BTNC: czestotliwosc Y.
                freq_y <= x"00" & sw_sync;
                request_config <= true;
            end if;
            if btn_pulse(1) = '1' then -- BTNR: faza Y w najstarszych bitach.
                phase_y <= sw_sync & x"00";
                request_config <= true;
            end if;
            if btn_pulse(0) = '1' then request_clear <= true; end if; -- BTND.
        end if;
    end process;

    -- Po resecie pierwszy wazny wynik jest X, drugi Y. Odbieramy tylko TVALID.
    -- Para pojawia sie co dwa takty: port A RAM zdazy zapisac kazda pare.
    p_plot : process(clk_i)
        variable y_pixel : natural range 0 to C_SIDE - 1;
    begin
        if rising_edge(clk_i) then
            plot_write <= '0';
            if control_state /= DRAW then
                next_is_y <= false;
            elsif dds_valid = '1' then
                if not next_is_y then
                    x_pixel <= coordinate(dds_data(10 downto 0));
                    next_is_y <= true;
                else
                    y_pixel := C_SIDE - 1 - coordinate(dds_data(10 downto 0));
                    plot_address <= std_logic_vector(to_unsigned(y_pixel * C_SIDE + x_pixel, 18));
                    plot_write <= '1';
                    next_is_y <= false;
                end if;
            end if;
        end if;
    end process;

    ram_we(0) <= '1' when control_state = CLEAR_SCREEN else plot_write;
    ram_in(0) <= '0' when control_state = CLEAR_SCREEN else '1';
    ram_write_addr <= std_logic_vector(to_unsigned(clear_address, 18))
                      when control_state = CLEAR_SCREEN else plot_address;

    -- 640x480: 640+16+96+48 = 800; 480+10+2+33 = 525; piksel 40 ns.
    p_vga_counters : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if pixel_div = 3 then
                pixel_div <= 0;
                if h_count = 799 then
                    h_count <= 0;
                    if v_count = 524 then v_count <= 0;
                    else v_count <= v_count + 1; end if;
                else
                    h_count <= h_count + 1;
                end if;
            else
                pixel_div <= pixel_div + 1;
            end if;
        end if;
    end process;

    -- Jeden wspolny warunek dla adresowania RAM i wygaszania obrazu.
    in_window <= h_count >= C_LEFT and h_count < C_LEFT + C_SIDE and
                 v_count >= C_TOP and v_count < C_TOP + C_SIDE;
    ram_read_addr <= std_logic_vector(to_unsigned(
        (v_count - C_TOP) * C_SIDE + h_count - C_LEFT, 18))
        when in_window else (others => '0');
    -- Sterowanie opoznione o ten sam jeden takt co synchroniczny odczyt RAM.
    p_video_pipeline : process(clk_i)
    begin
        if rising_edge(clk_i) then
            visible_d <= '0';
            if in_window and screen_ready = '1' then
                visible_d <= '1';
            end if;
            hsync_o <= '1';
            if h_count >= 656 and h_count < 752 then hsync_o <= '0'; end if;
            vsync_o <= '1';
            if v_count >= 490 and v_count < 492 then vsync_o <= '0'; end if;
        end if;
    end process;

    white_pixel <= ram_out(0) when visible_d = '1' else '0';
    red_o <= (others => white_pixel);
    green_o <= (others => white_pixel);
    blue_o <= (others => white_pixel);
end architecture Behavioral;

