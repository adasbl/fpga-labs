library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    generic (DEBOUNCE_CYCLES : positive := 1_000_000);
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

architecture behavioral of top is
    constant SIDE : positive := 384;
    constant CENTER : natural := SIDE / 2;
    constant PIXELS : positive := SIDE * SIDE;
    constant LEFT_EDGE : natural := (640 - SIDE) / 2;
    constant TOP_EDGE : natural := (480 - SIDE) / 2;

    subtype address_t is std_logic_vector(17 downto 0);
    subtype product_t is signed(19 downto 0);
    subtype phase_step_t is std_logic_vector(15 downto 0);

    component video_mem is
        port (
            clka  : in  std_logic;
            wea   : in  std_logic_vector(0 downto 0);
            addra : in  address_t;
            dina  : in  std_logic_vector(0 downto 0);
            clkb  : in  std_logic;
            addrb : in  address_t;
            doutb : out std_logic_vector(0 downto 0)
        );
    end component;

    type debounce_t is array (0 to 3) of natural range 0 to DEBOUNCE_CYCLES - 1;
    signal debounce_count : debounce_t := (others => 0);
    signal sw_meta, sw_sync : std_logic_vector(7 downto 0) := (others => '0');
    signal btn_meta, btn_sync : std_logic_vector(3 downto 0) := (others => '0');
    signal btn_stable, btn_press : std_logic_vector(3 downto 0) := (others => '0');
    attribute ASYNC_REG : string;
    attribute ASYNC_REG of sw_meta, sw_sync, btn_meta, btn_sync : signal is "TRUE";

    signal freq_a, freq_b : phase_step_t := x"0100";
    signal config_a, config_b : phase_step_t := x"0100";
    signal amplitude_a : unsigned(7 downto 0) := to_unsigned(64, 8);
    signal amplitude_b, pair_amplitude_b : unsigned(7 downto 0) := (others => '0');
    signal config_pending, clear_pending : boolean := false;

    type state_t is (CLEAR_SCREEN, DRAW, CONFIG_FIRST, CONFIG_SECOND);
    signal state : state_t := CLEAR_SCREEN;
    signal clear_address : natural range 0 to PIXELS - 1 := 0;
    signal dds_reset_n, config_valid, config_last, dds_valid : std_logic;
    signal config_data : phase_step_t;
    signal dds_data : std_logic_vector(31 downto 0);

    signal channel_b : boolean := false;
    signal sample_amplitude : signed(8 downto 0);
    signal sample_x, sample_y : product_t;
    signal ax, ay, bx, by : product_t := (others => '0');
    signal pair_valid, point_valid : boolean := false;
    signal plot_x, plot_y : integer range CENTER - 300 to CENTER + 300 := CENTER;
    signal plot_in_window : boolean;

    signal write_enable, write_data, read_data : std_logic_vector(0 downto 0);
    signal write_address, read_address : address_t;
    signal pixel_divider : natural range 0 to 3 := 0;
    signal horizontal : natural range 0 to 799 := 0;
    signal vertical : natural range 0 to 524 := 0;
    signal in_window : boolean;
    signal visible : boolean := false;
    signal white_pixel : std_logic;

    function rounded_pixel(value : product_t) return integer is
    begin
        return to_integer(shift_right(value + 512, 10));
    end function;
begin
    memory : video_mem
        port map (
            clka => clk_i,
            wea => write_enable,
            addra => write_address,
            dina => write_data,
            clkb => clk_i,
            addrb => read_address,
            doutb => read_data
        );

    dds : entity work.singen
        port map (
            aclk => clk_i,
            aclken => '1',
            aresetn => dds_reset_n,
            s_axis_config_tvalid => config_valid,
            s_axis_config_tdata => config_data,
            s_axis_config_tlast => config_last,
            m_axis_data_tvalid => dds_valid,
            m_axis_data_tdata => dds_data,
            event_s_config_tlast_missing => open,
            event_s_config_tlast_unexpected => open
        );

    inputs : process(clk_i)
    begin
        if rising_edge(clk_i) then
            sw_meta <= sw_i;
            sw_sync <= sw_meta;
            btn_meta <= btn_i;
            btn_sync <= btn_meta;
            btn_press <= (others => '0');

            for i in btn_sync'range loop
                if btn_sync(i) = btn_stable(i) then
                    debounce_count(i) <= 0;
                elsif debounce_count(i) = DEBOUNCE_CYCLES - 1 then
                    debounce_count(i) <= 0;
                    btn_stable(i) <= btn_sync(i);
                    btn_press(i) <= btn_sync(i);
                else
                    debounce_count(i) <= debounce_count(i) + 1;
                end if;
            end loop;
        end if;
    end process;

    dds_reset_n <= '0' when state = CLEAR_SCREEN else '1';
    config_valid <= '1' when state = CONFIG_FIRST or state = CONFIG_SECOND else '0';
    config_last <= '1' when state = CONFIG_SECOND else '0';
    config_data <= config_b when state = CONFIG_SECOND else config_a;

    control : process(clk_i)
    begin
        if rising_edge(clk_i) then
            case state is
                when CLEAR_SCREEN =>
                    if clear_address = PIXELS - 1 then
                        state <= DRAW;
                    else
                        clear_address <= clear_address + 1;
                    end if;
                when DRAW =>
                    if clear_pending then
                        clear_pending <= false;
                        clear_address <= 0;
                        state <= CLEAR_SCREEN;
                    elsif config_pending then
                        config_pending <= false;
                        config_a <= freq_a;
                        config_b <= freq_b;
                        state <= CONFIG_FIRST;
                    end if;
                when CONFIG_FIRST =>
                    state <= CONFIG_SECOND;
                when CONFIG_SECOND =>
                    state <= DRAW;
            end case;

            if btn_press(3) = '1' then
                freq_a <= x"00" & sw_sync;
                config_pending <= true;
            end if;
            if btn_press(2) = '1' then
                freq_b <= x"00" & sw_sync;
                config_pending <= true;
            end if;
            if btn_press(1) = '1' then
                amplitude_a <= unsigned(sw_sync(7 downto 4) & "0000");
                amplitude_b <= unsigned("00" & sw_sync(3 downto 0) & "00");
            end if;
            if btn_press(0) = '1' then
                clear_pending <= true;
            end if;
        end if;
    end process;

    sample_amplitude <= signed('0' & pair_amplitude_b) when channel_b else signed('0' & amplitude_a);
    sample_x <= signed(dds_data(10 downto 0)) * sample_amplitude;
    sample_y <= signed(dds_data(26 downto 16)) * sample_amplitude;

    plot : process(clk_i)
    begin
        if rising_edge(clk_i) then
            pair_valid <= false;
            point_valid <= false;
            if state = CLEAR_SCREEN then
                channel_b <= false;
            else
                if dds_valid = '1' then
                    if channel_b then
                        bx <= sample_x;
                        by <= sample_y;
                        pair_valid <= true;
                    else
                        ax <= sample_x;
                        ay <= sample_y;
                        pair_amplitude_b <= amplitude_b;
                    end if;
                    channel_b <= not channel_b;
                end if;

                if pair_valid then
                    plot_x <= CENTER + rounded_pixel(ax - bx);
                    plot_y <= CENTER - rounded_pixel(ay - by);
                    point_valid <= true;
                end if;
            end if;
        end if;
    end process;

    plot_in_window <= plot_x >= 0 and plot_x < SIDE and plot_y >= 0 and plot_y < SIDE;
    write_enable(0) <= '1' when state = CLEAR_SCREEN or (point_valid and plot_in_window) else '0';
    write_data(0) <= '0' when state = CLEAR_SCREEN else '1';
    write_address <= std_logic_vector(to_unsigned(clear_address, address_t'length))
                     when state = CLEAR_SCREEN else
                     std_logic_vector(to_unsigned(plot_y * SIDE + plot_x, address_t'length))
                     when plot_in_window else (others => '0');

    vga : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if pixel_divider = 3 then
                pixel_divider <= 0;
                if horizontal = 799 then
                    horizontal <= 0;
                    if vertical = 524 then
                        vertical <= 0;
                    else
                        vertical <= vertical + 1;
                    end if;
                else
                    horizontal <= horizontal + 1;
                end if;
            else
                pixel_divider <= pixel_divider + 1;
            end if;

            visible <= in_window and state /= CLEAR_SCREEN;
            if horizontal >= 656 and horizontal < 752 then
                hsync_o <= '0';
            else
                hsync_o <= '1';
            end if;
            if vertical >= 490 and vertical < 492 then
                vsync_o <= '0';
            else
                vsync_o <= '1';
            end if;
        end if;
    end process;

    in_window <= horizontal >= LEFT_EDGE and horizontal < LEFT_EDGE + SIDE and
                 vertical >= TOP_EDGE and vertical < TOP_EDGE + SIDE;
    read_address <= std_logic_vector(to_unsigned(
        (vertical - TOP_EDGE) * SIDE + horizontal - LEFT_EDGE, address_t'length))
        when in_window else (others => '0');

    white_pixel <= read_data(0) when visible else '0';
    red_o <= (others => white_pixel);
    green_o <= (others => white_pixel);
    blue_o <= (others => white_pixel);
end architecture behavioral;
