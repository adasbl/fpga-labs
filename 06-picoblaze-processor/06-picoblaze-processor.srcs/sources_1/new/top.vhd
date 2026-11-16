library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    generic (
        G_SCAN_DIV         : positive := 100000;    -- 1 ms at 100 MHz
        G_DEBOUNCE_TICKS   : positive := 1000000;   -- 10 ms at 100 MHz
        G_LONG_PRESS_TICKS : positive := 50000000;  -- 500 ms at 100 MHz
        G_BLINK_TICKS      : positive := 25000000   -- 250 ms per phase at 100 MHz
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
    signal left_hold_count : natural range 0 to G_LONG_PRESS_TICKS := 0;
    signal left_events : std_logic_vector(4 downto 3) := "00";
    signal address : std_logic_vector(11 downto 0);
    signal instruction : std_logic_vector(17 downto 0);
    signal bram_enable, read_strobe, write_strobe : std_logic;
    signal port_id, in_port, out_port : std_logic_vector(7 downto 0);

    type digits_t is array (0 to 3) of std_logic_vector(3 downto 0);
    signal display_values : digits_t := (others => x"0");
    signal digit_port, control_write : boolean;
    signal selected_digit : natural range 0 to 3 := 0;
    signal edit_mode, blink_off : std_logic := '0';
    signal blink_count : natural range 0 to G_BLINK_TICKS - 1 := 0;
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

    -- A long press is reported once while held, a short press on release.
    -- Events stay pending until the processor reads port 00.
    p_left_button : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_sync = '1' then
                left_events <= "00";
                left_hold_count <= 0;
            else
                if read_strobe = '1' and port_id = x"00" then
                    left_events <= "00";
                end if;

                if button_clean(3) = '0' then
                    if left_hold_count > 0 and left_hold_count < G_LONG_PRESS_TICKS then
                        left_events(3) <= '1';
                    end if;
                    left_hold_count <= 0;
                elsif left_hold_count < G_LONG_PRESS_TICKS then
                    if left_hold_count = G_LONG_PRESS_TICKS - 1 then
                        left_events(4) <= '1';
                    end if;
                    left_hold_count <= left_hold_count + 1;
                end if;
            end if;
        end if;
    end process;

    processor : entity work.kcpsm6
        generic map (hwbuild => x"00", interrupt_vector => x"3FF", scratch_pad_memory_size => 64)
        port map (
            address => address, instruction => instruction, bram_enable => bram_enable,
            in_port => in_port, out_port => out_port, port_id => port_id,
            write_strobe => write_strobe, k_write_strobe => open, read_strobe => read_strobe,
            interrupt => '0', interrupt_ack => open, sleep => '0', reset => rst_sync, clk => clk_i
        );

    program : entity work.counter_rom
        port map (clk => clk_i, enable => bram_enable, address => address, instruction => instruction);

    -- Port 00 returns BTNL events and the other three button levels.
    -- Ports 10-13 read and write the digits from right to left.
    digit_port <= port_id(7 downto 2) = "000100";
    control_write <= write_strobe = '1' and port_id = x"02";
    in_port <= "000" & left_events & button_clean(2 downto 0) when port_id = x"00" else
               "0000" & display_values(to_integer(unsigned(port_id(1 downto 0)))) when digit_port else
               x"00";

    p_output : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_sync = '1' then
                display_values <= (others => x"0");
                selected_digit <= 0;
                edit_mode <= '0';
            elsif control_write then
                selected_digit <= to_integer(unsigned(out_port(1 downto 0)));
                edit_mode <= out_port(2);
            elsif write_strobe = '1' and digit_port then
                display_values(to_integer(unsigned(port_id(1 downto 0)))) <= out_port(3 downto 0);
            end if;
        end if;
    end process;

    p_blink : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_sync = '1' or edit_mode = '0' or control_write then
                blink_count <= 0;
                blink_off <= '0';
            elsif blink_count = G_BLINK_TICKS - 1 then
                blink_count <= 0;
                blink_off <= not blink_off;
            else
                blink_count <= blink_count + 1;
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

    with digit select led7_an_o <=
        "1110" when 0,
        "1101" when 1,
        "1011" when 2,
        "0111" when 3;

    led7_seg_o <= x"FF" when edit_mode = '1' and digit = selected_digit and blink_off = '1' else
                  hex_segments(display_values(digit));
end architecture;
