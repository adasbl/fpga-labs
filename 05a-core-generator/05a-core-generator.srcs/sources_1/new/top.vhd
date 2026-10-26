library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- VHDL-93. Wygeneruj w IP Catalog: char_mem oraz fifo_mem.
-- Bez resetu: wartosci poczatkowe sa ladowane przy konfiguracji FPGA.
entity top is
    generic (
        G_BAUD     : positive := 9600;
        G_SCAN_DIV : positive := 100000
    );
    port (
        clk_i      : in  std_logic;
        RXD_i      : in  std_logic;
        TXD_o      : out std_logic;
        ld0        : out std_logic;
        led7_an_o  : out std_logic_vector(3 downto 0);
        led7_seg_o : out std_logic_vector(7 downto 0)
    );
end entity top;

architecture Behavioral of top is
    -- ROM 4096 x 8, Always Enabled, bez dodatkowego rejestru wyjsciowego.
    -- Plik inicjalizacji: chargen.coe; opoznienie odczytu: jeden takt.
    component char_mem is
        port (
            clka  : in  std_logic;
            addra : in  std_logic_vector(11 downto 0);
            douta : out std_logic_vector(7 downto 0)
        );
    end component;

    -- Common Clock, 8 x 64, Standard FIFO (nie FWFT), bez Reset Pin.
    -- Opoznienie odczytu: jeden takt; tylko ponizsze porty obowiazkowe.
    component fifo_mem is
        port (
            clk   : in  std_logic;
            din   : in  std_logic_vector(7 downto 0);
            wr_en : in  std_logic;
            rd_en : in  std_logic;
            dout  : out std_logic_vector(7 downto 0);
            full  : out std_logic;
            empty : out std_logic
        );
    end component;

    constant C_BIT_TICKS  : positive := (100000000 + G_BAUD / 2) / G_BAUD;
    constant C_HALF_TICKS : positive := C_BIT_TICKS / 2;
    constant C_LINE_MAX   : positive := 18;

    type rx_state_t is (RX_IDLE, RX_START, RX_BITS, RX_STOP, RX_WAIT_IDLE);
    signal rx_state : rx_state_t := RX_IDLE;
    signal rx_meta  : std_logic := '1';
    signal rx_sync  : std_logic := '1';
    signal rx_count : natural range 0 to C_BIT_TICKS - 1 := 0;
    signal rx_index : natural range 0 to 7 := 0;
    signal rx_shift : std_logic_vector(7 downto 0) := (others => '0');
    signal data_rx  : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_valid : std_logic := '0';
    attribute ASYNC_REG : string;
    attribute ASYNC_REG of rx_meta, rx_sync : signal is "TRUE";

    signal fifo_dout  : std_logic_vector(7 downto 0);
    signal fifo_full  : std_logic;
    signal fifo_empty : std_logic;
    signal fifo_wr_en : std_logic;
    signal fifo_rd_en : std_logic := '0';
    signal overflow   : std_logic := '0';

    type line_t is array(0 to C_LINE_MAX - 1) of std_logic_vector(7 downto 0);
    signal line_buffer : line_t := (others => (others => '0'));
    signal line_length : natural range 0 to C_LINE_MAX := 0;
    signal char_index  : natural range 0 to C_LINE_MAX - 1 := 0;
    signal row_index   : natural range 0 to 15 := 0;
    signal pixel_index : natural range 0 to 7 := 7;
    signal rom_addr    : std_logic_vector(11 downto 0);
    signal rom_data    : std_logic_vector(7 downto 0);
    signal glyph_row   : std_logic_vector(7 downto 0) := (others => '0');

    type printer_state_t is (
        COLLECT, FIFO_WAIT, FIFO_CAPTURE,
        ROM_WAIT, ROM_CAPTURE,
        SEND_PIXEL, NEXT_PIXEL, SEND_CR, SEND_LF, NEXT_ROW,
        WAIT_TX_START, WAIT_TX_END
    );
    signal printer_state : printer_state_t := COLLECT;
    signal after_tx      : printer_state_t := NEXT_PIXEL;

    -- Cala ramka UART: bit stopu, D7..D0, bit startu.
    -- Na wyjscie trafia bit 0; ramka przesuwa sie co okres bitu.
    signal tx_frame : std_logic_vector(9 downto 0) := (others => '1');
    signal tx_count : natural range 0 to C_BIT_TICKS - 1 := 0;
    signal tx_left  : natural range 0 to 9 := 0;
    signal tx_data  : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_start : std_logic := '0';
    signal tx_busy  : std_logic := '0';
    signal scan_count : natural range 0 to G_SCAN_DIV - 1 := 0;
    signal digit      : natural range 0 to 3 := 0;

    function hex_to_segments(h : std_logic_vector(3 downto 0))
        return std_logic_vector is
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
    assert C_BIT_TICKS >= 8 report "Za malo taktow na bit UART" severity failure;
    TXD_o <= tx_frame(0);
    ld0 <= overflow;

    u_rom : char_mem
        port map (clka => clk_i, addra => rom_addr, douta => rom_data);
    u_fifo : fifo_mem
        port map (
            clk => clk_i, din => data_rx,
            wr_en => fifo_wr_en, rd_en => fifo_rd_en,
            dout => fifo_dout, full => fifo_full, empty => fifo_empty
        );

    fifo_wr_en <= rx_valid and not fifo_full;

    -- Adres zmienia sie razem z indeksem znaku lub wiersza.
    -- Mnozenie kodu przez 16 to dopisanie czterech bitow numeru wiersza.
    rom_addr <= line_buffer(char_index) & std_logic_vector(to_unsigned(row_index, 4));

    p_rx_sync : process(clk_i)
    begin
        if rising_edge(clk_i) then
            rx_meta <= RXD_i;
            rx_sync <= rx_meta;
        end if;
    end process;

    p_receiver : process(clk_i)
    begin
        if rising_edge(clk_i) then
            rx_valid <= '0';
            case rx_state is
                when RX_IDLE =>
                    rx_count <= 0;
                    if rx_sync = '0' then rx_state <= RX_START; end if;
                when RX_START =>
                    if rx_count = C_HALF_TICKS - 1 then
                        rx_count <= 0;
                        if rx_sync = '0' then
                            rx_index <= 0;
                            rx_state <= RX_BITS;
                        else
                            rx_state <= RX_IDLE;
                        end if;
                    else
                        rx_count <= rx_count + 1;
                    end if;
                when RX_BITS =>
                    if rx_count = C_BIT_TICKS - 1 then
                        rx_count <= 0;
                        rx_shift(rx_index) <= rx_sync;
                        if rx_index = 7 then
                            rx_state <= RX_STOP;
                        else
                            rx_index <= rx_index + 1;
                        end if;
                    else
                        rx_count <= rx_count + 1;
                    end if;
                when RX_STOP =>
                    if rx_count = C_BIT_TICKS - 1 then
                        rx_count <= 0;
                        if rx_sync = '1' then
                            -- Monitor aktualizuje sie PRZED buforowaniem,
                            -- takze dla CR i znakow odrzuconych przy pelnym FIFO.
                            data_rx <= rx_shift;
                            rx_valid <= '1';
                            rx_state <= RX_IDLE;
                        else
                            rx_state <= RX_WAIT_IDLE;
                        end if;
                    else
                        rx_count <= rx_count + 1;
                    end if;
                when RX_WAIT_IDLE =>
                    if rx_sync = '1' then rx_state <= RX_IDLE; end if;
            end case;
        end if;
    end process;

    -- Jak w cw5a Christopha: LD0 zapala sie po utracie znaku
    -- i gasnie, gdy FIFO przestaje byc pelne (zwalnia sie miejsce).
    p_overflow : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rx_valid = '1' and fifo_full = '1' then
                overflow <= '1';
            elsif fifo_full = '0' then
                overflow <= '0';
            end if;
        end if;
    end process;

    p_transmitter : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if tx_busy = '0' then
                tx_count <= 0;
                if tx_start = '1' then
                    tx_frame <= '1' & tx_data & '0';
                    tx_left <= 9;
                    tx_busy <= '1';
                end if;
            elsif tx_count = C_BIT_TICKS - 1 then
                tx_count <= 0;
                tx_frame <= '1' & tx_frame(9 downto 1);
                if tx_left = 0 then
                    tx_busy <= '0';
                else
                    tx_left <= tx_left - 1;
                end if;
            else
                tx_count <= tx_count + 1;
            end if;
        end if;
    end process;
    p_printer : process(clk_i)
    begin
        if rising_edge(clk_i) then
            fifo_rd_en <= '0';
            tx_start <= '0';
            case printer_state is
                when COLLECT =>
                    if fifo_empty = '0' then
                        fifo_rd_en <= '1';
                        printer_state <= FIFO_WAIT;
                    end if;
                when FIFO_WAIT =>
                    -- IP odczytuje teraz dane na zboczu; wynik po zboczu.
                    printer_state <= FIFO_CAPTURE;
                when FIFO_CAPTURE =>
                    if fifo_dout = x"0D" then
                        if line_length > 0 then
                            row_index <= 0;
                            char_index <= 0;
                            printer_state <= ROM_WAIT;
                        else
                            -- Pusty Enter, takze tuz po linii 18 znakow: pomijamy.
                            printer_state <= COLLECT;
                        end if;
                    else
                        line_buffer(line_length) <= fifo_dout;
                        line_length <= line_length + 1;
                        if line_length = C_LINE_MAX - 1 then
                            row_index <= 0;
                            char_index <= 0;
                            printer_state <= ROM_WAIT;
                        else
                            printer_state <= COLLECT;
                        end if;
                    end if;
                when ROM_WAIT =>
                    printer_state <= ROM_CAPTURE;
                when ROM_CAPTURE =>
                    glyph_row <= rom_data;
                    pixel_index <= 7;
                    printer_state <= SEND_PIXEL;
                when SEND_PIXEL =>
                    if tx_busy = '0' then
                        if glyph_row(pixel_index) = '0' then
                            tx_data <= x"20"; -- Niezapalony piksel: spacja.
                        elsif unsigned(line_buffer(char_index)) < 32 or
                              unsigned(line_buffer(char_index)) > 127 then
                            tx_data <= x"2A"; -- Gwiazdka; ksztalt z ROM oryginalnego kodu.
                        else
                            tx_data <= line_buffer(char_index);
                        end if;
                        tx_start <= '1';
                        after_tx <= NEXT_PIXEL;
                        printer_state <= WAIT_TX_START;
                    end if;
                when WAIT_TX_START =>
                    if tx_busy = '1' then printer_state <= WAIT_TX_END; end if;
                when WAIT_TX_END =>
                    if tx_busy = '0' then printer_state <= after_tx; end if;
                when NEXT_PIXEL =>
                    if pixel_index > 0 then
                        pixel_index <= pixel_index - 1;
                        printer_state <= SEND_PIXEL;
                    elsif char_index + 1 < line_length then
                        char_index <= char_index + 1;
                        printer_state <= ROM_WAIT;
                    else
                        printer_state <= SEND_CR;
                    end if;
                when SEND_CR =>
                    if tx_busy = '0' then
                        tx_data <= x"0D";
                        tx_start <= '1';
                        after_tx <= SEND_LF;
                        printer_state <= WAIT_TX_START;
                    end if;
                when SEND_LF =>
                    if tx_busy = '0' then
                        tx_data <= x"0A";
                        tx_start <= '1';
                        after_tx <= NEXT_ROW;
                        printer_state <= WAIT_TX_START;
                    end if;
                when NEXT_ROW =>
                    if row_index = 15 then
                        line_length <= 0;
                        printer_state <= COLLECT;
                    else
                        row_index <= row_index + 1;
                        char_index <= 0;
                        printer_state <= ROM_WAIT;
                    end if;
            end case;
        end if;
    end process;

    p_scan : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if scan_count = G_SCAN_DIV - 1 then
                scan_count <= 0;
                if digit = 3 then digit <= 0; else digit <= digit + 1; end if;
            else
                scan_count <= scan_count + 1;
            end if;
        end if;
    end process;

    -- Bity 7..0: A B C D E F G DP; anody i segmenty aktywne zerem.
    p_decode : process(digit, data_rx)
    begin
        led7_an_o <= "1111";
        led7_seg_o <= x"FF";
        case digit is
            when 0 =>
                led7_an_o <= "1110";
                led7_seg_o <= hex_to_segments(data_rx(3 downto 0));
            when 1 =>
                led7_an_o <= "1101";
                led7_seg_o <= hex_to_segments(data_rx(7 downto 4));
            when 2 => led7_an_o <= "1011";
            when 3 => led7_an_o <= "0111";
        end case;
    end process;
end architecture Behavioral;

