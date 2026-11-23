library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_framebuffer is
    port (
        clk        : in  std_logic;
        resetn     : in  std_logic;
        bram_addr  : out std_logic_vector(31 downto 0);
        bram_din   : out std_logic_vector(31 downto 0);
        bram_dout  : in  std_logic_vector(31 downto 0);
        bram_en    : out std_logic;
        bram_rst   : out std_logic;
        bram_we    : out std_logic_vector(3 downto 0);
        red_o      : out std_logic_vector(3 downto 0);
        green_o    : out std_logic_vector(3 downto 0);
        blue_o     : out std_logic_vector(3 downto 0);
        hsync_o    : out std_logic;
        vsync_o    : out std_logic
    );
end entity vga_framebuffer;

architecture rtl of vga_framebuffer is
    -- Keep the 640x480 raster from lab 08a. The image starts at its top left.
    constant IMAGE_WIDTH  : positive := 384;
    constant IMAGE_HEIGHT : positive := 341;

    signal pixel_divider : natural range 0 to 3 := 0;
    signal horizontal    : natural range 0 to 799 := 0;
    signal vertical      : natural range 0 to 524 := 0;
    signal in_image      : boolean;
    signal word_address  : unsigned(14 downto 0);
    signal pixel         : std_logic_vector(7 downto 0) := (others => '0');
begin
    bram_addr <= "000000000000000" & std_logic_vector(word_address) & "00";
    bram_din  <= (others => '0');
    bram_en   <= '1';
    bram_rst  <= '0';
    bram_we   <= (others => '0');

    in_image <= horizontal < IMAGE_WIDTH and vertical < IMAGE_HEIGHT;
    word_address <= to_unsigned(vertical * (IMAGE_WIDTH / 4) + horizontal / 4, word_address'length)
                    when in_image else (others => '0');

    red_o   <= pixel(7 downto 5) & '0';
    green_o <= pixel(4 downto 2) & '0';
    blue_o  <= pixel(1 downto 0) & "00";

    raster : process(clk)
        variable lane : natural range 0 to 3;
    begin
        if rising_edge(clk) then
            if resetn = '0' then
                pixel_divider <= 0;
                horizontal <= 0;
                vertical <= 0;
                pixel <= (others => '0');
                hsync_o <= '1';
                vsync_o <= '1';
            elsif pixel_divider = 3 then
                pixel_divider <= 0;

                -- Each address is held for at least four 100 MHz cycles.
                -- The synchronous BRAM read settles before sampling the pixel.
                if in_image then
                    lane := horizontal mod 4;
                    pixel <= bram_dout(8 * lane + 7 downto 8 * lane);
                else
                    pixel <= (others => '0');
                end if;
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
        end if;
    end process raster;
end architecture rtl;
