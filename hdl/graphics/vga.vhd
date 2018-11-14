library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vga is
  port (
    reset_n : in STD_LOGIC;
    clock : in STD_LOGIC;
    
    GPIO_DIPS : in STD_LOGIC_VECTOR(15 downto 0);
    GPIO_LEDS : out STD_LOGIC_VECTOR(15 downto 0);
    GPIO_PBS : in STD_LOGIC_VECTOR(4 downto 0);
    
    Hsync : out STD_LOGIC;
    Vsync : out STD_LOGIC;
    vgaRed : out STD_LOGIC_VECTOR(3 downto 0);
    vgaBlue : out STD_LOGIC_VECTOR(3 downto 0);
    vgaGreen : out STD_LOGIC_VECTOR(3 downto 0)
  );
end vga;

architecture Behavioral of vga is

  component clk_wiz_0 is 
    port (
      resetn : in STD_LOGIC;
      clk_in1 : in STD_LOGIC;
      locked : out STD_LOGIC;
      clk_out1 : out STD_LOGIC;
      clk_out2 : out STD_LOGIC
    );
  end component; 

  component pixelStream_generator is
    port (
      pixelClock   : in std_logic;
      VSYNC_pin : OUT STD_LOGIC;
      HSYNC_pin : OUT STD_LOGIC;
      lastByteOfLine : OUT STD_LOGIC;
      quadrant : OUT STD_LOGIC_vector(1 downto 0);
      visible : OUT STD_LOGIC;
      visible_gb : OUT STD_LOGIC ;
      visible_gb_x : OUT STD_LOGIC_vector(2 downto 0);
      visible_gb_y : OUT STD_LOGIC_vector(2 downto 0);
      visible_gb_xx : OUT STD_LOGIC_vector(2 downto 0);
      visible_gb_yy : OUT STD_LOGIC_vector(2 downto 0));
  end component;

  signal reset_ni, reset_i, locked_i : STD_LOGIC;
  signal clock_i, clock100, clock50 : STD_LOGIC;
  signal Hsync_i, Vsync_i : STD_LOGIC;
  
  signal GPIO_DIPS_i : STD_LOGIC_VECTOR(15 downto 0);
  
  signal visible, visible_gb : STD_LOGIC;
  signal visible_gb_x, visible_gb_y, visible_gb_xx, visible_gb_yy : STD_LOGIC_VECTOR(2 downto 0);

  type T_subtile is array (7 downto 0) of STD_LOGIC_VECTOR(7 downto 0);
  type T_tile is array (1 downto 0) of T_subtile;
  signal tile0_m, tile0_l : T_subtile;
  signal scanline_m, scanline_l : STD_LOGIC_VECTOR(7 downto 0);
  signal pixel_m, pixel_l : STD_LOGIC;
  signal pixel : STD_LOGIC_VECTOR(3 downto 0);

begin

  Hsync <= Hsync_i;
  Vsync <= Vsync_i;
  reset_ni <= reset_n;
  clock_i <= clock;
  GPIO_DIPS_i <= GPIO_DIPS;
  GPIO_LEDS <= x"000" & "000" & reset_i;
  
  --vgaRed <= GPIO_DIPS_i(3 downto 0) when visible_gb = '1' else "0000";
  --vgaGreen <= GPIO_DIPS_i(7 downto 4) when visible_gb = '1' else "0000";
  --vgaBlue <= GPIO_DIPS_i(11 downto 8) when visible_gb = '1' else "0000";
  
  vgaRed <= pixel when visible_gb = '1' else "0000";
  vgaGreen <= pixel when visible_gb = '1' else "0000";
  vgaBlue <= pixel when visible_gb = '1' else "0000";

  pixelStream_generator_inst00: component pixelStream_generator port map(
    pixelClock => clock50,
    VSYNC_pin => Vsync_i,
    HSYNC_pin => Hsync_i,
    lastByteOfLine => open,
    Quadrant => open,
    visible => visible,
    visible_gb => visible_gb, 
    visible_gb_x => visible_gb_x,
    visible_gb_y => visible_gb_y,
    visible_gb_xx => visible_gb_xx,
    visible_gb_yy => visible_gb_yy
  );


  reset_i <= not(locked_i);
  clk_wiz_0_inst00: component clk_wiz_0 port map(
    resetn => reset_ni,
    clk_in1 => clock_i,
    locked => locked_i,
    clk_out1 => clock100,
    clk_out2 => clock50
  ); 


  -------------------------------------------------------------------------------
  -- display content
  -------------------------------------------------------------------------------
  
  -- 1. use visible_gb_x and visible_gb_y to choose the tile

  -- 2. use visible_gb_yy to pick the scanline from the tile
  PMUX_step2: process(visible_gb_yy, tile0_m, tile0_l)
  begin
    case visible_gb_yy is
      when "000"  => scanline_m <= tile0_m(0); scanline_l <= tile0_l(0);
      when "001"  => scanline_m <= tile0_m(1); scanline_l <= tile0_l(1);
      when "010"  => scanline_m <= tile0_m(2); scanline_l <= tile0_l(2);
      when "011"  => scanline_m <= tile0_m(3); scanline_l <= tile0_l(3);
      when "100"  => scanline_m <= tile0_m(4); scanline_l <= tile0_l(4);
      when "101"  => scanline_m <= tile0_m(5); scanline_l <= tile0_l(5);
      when "110"  => scanline_m <= tile0_m(6); scanline_l <= tile0_l(6);
      when others => scanline_m <= tile0_m(7); scanline_l <= tile0_l(7);
    end case;
  end process;

  -- 3. use visible_gb_xx to pick the pixel from the scanline
  PMUX_step3: process(visible_gb_xx, scanline_m, scanline_l)
  begin
    case visible_gb_xx is
      when "000"  => pixel_m <= scanline_m(0); pixel_l <= scanline_l(0);
      when "001"  => pixel_m <= scanline_m(1); pixel_l <= scanline_l(1);
      when "010"  => pixel_m <= scanline_m(2); pixel_l <= scanline_l(2);
      when "011"  => pixel_m <= scanline_m(3); pixel_l <= scanline_l(3);
      when "100"  => pixel_m <= scanline_m(4); pixel_l <= scanline_l(4);
      when "101"  => pixel_m <= scanline_m(5); pixel_l <= scanline_l(5);
      when "110"  => pixel_m <= scanline_m(6); pixel_l <= scanline_l(6);
      when others => pixel_m <= scanline_m(7); pixel_l <= scanline_l(7);
    end case;
  end process;



  -- 4. use pixels to define which of the four colours to show
  PMUX_step1: process(pixel_m, pixel_l)
  begin
    if pixel_m = '1' then 
      if pixel_l = '1' then 
        -- pixel value 3
        pixel <= "1111";
      else
        pixel <= "1011";
      end if;
    else
      if pixel_l = '1' then 
        pixel <= "0110";
      else
        pixel <= "0001";
      end if;
    end if;
  end process;


  -------------------------------------------------------------------------------
  -- background tile database
  -------------------------------------------------------------------------------
  tile0_m(0) <= "11111111";
  tile0_m(1) <= "00100000";
  tile0_m(2) <= "00100000";
  tile0_m(3) <= "00100000";
  tile0_m(4) <= "11111111";
  tile0_m(5) <= "00000100";
  tile0_m(6) <= "00000100";
  tile0_m(7) <= "00000100";
  tile0_l(0) <= "11111111";
  tile0_l(1) <= "00100000";
  tile0_l(2) <= "00100000";
  tile0_l(3) <= "00100000";
  tile0_l(4) <= "11111111";
  tile0_l(5) <= "00000100";
  tile0_l(6) <= "00000100";
  tile0_l(7) <= "00000100";



end Behavioral;
