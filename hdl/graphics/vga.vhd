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
      visible_gb : OUT STD_LOGIC );
  end component;

  signal reset_ni, reset_i, locked_i : STD_LOGIC;
  signal clock_i, clock100, clock50 : STD_LOGIC;
  signal Hsync_i, Vsync_i : STD_LOGIC;
  
  signal GPIO_DIPS_i : STD_LOGIC_VECTOR(15 downto 0);
  
  signal visible, visible_gb : STD_LOGIC;

begin

  Hsync <= Hsync_i;
  Vsync <= Vsync_i;
  reset_ni <= reset_n;
  clock_i <= clock;
  GPIO_DIPS_i <= GPIO_DIPS;
  
  vgaRed <= GPIO_DIPS_i(3 downto 0) when visible_gb = '1' else "0000";
  vgaGreen <= GPIO_DIPS_i(7 downto 4) when visible_gb = '1' else "0000";
  vgaBlue <= GPIO_DIPS_i(11 downto 8) when visible_gb = '1' else "0000";
  GPIO_LEDS <= x"000" & "000" & reset_i;
  
  pixelStream_generator_inst00: component pixelStream_generator port map(
    pixelClock => clock50,
    VSYNC_pin => Vsync_i,
    HSYNC_pin => Hsync_i,
    lastByteOfLine => open,
    Quadrant => open,
    visible => visible,
    visible_gb => visible_gb
  );
  
  reset_i <= not(locked_i);
  clk_wiz_0_inst00: component clk_wiz_0 port map(
    resetn => reset_ni,
    clk_in1 => clock_i,
    locked => locked_i,
    clk_out1 => clock100,
    clk_out2 => clock50
  ); 

end Behavioral;
