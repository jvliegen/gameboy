library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package PKG_gameboy is

  -------------------------------------------------------------------------------
  -- CONSTANTS
  -------------------------------------------------------------------------------
  constant C_VCC: STD_LOGIC_VECTOR(15 downto 0) := x"FFFF";
  constant C_ground : STD_LOGIC_VECTOR(15 downto 0) := x"0000";
  constant C_programcounter_reset : STD_LOGIC_VECTOR(15 downto 0) := x"0100";

  -------------------------------------------------------------------------------
  -- COMPONENT DECLARATIONS
  -------------------------------------------------------------------------------
  component processor is
    port (
      reset : in STD_LOGIC;
      clock : in STD_LOGIC;

      CPH_en : in STD_LOGIC;
      CPH_data_in : in STD_LOGIC_VECTOR(31 downto 0);
      CPH_address : in STD_LOGIC_VECTOR(7 downto 0);
      CPH_we : in STD_LOGIC_VECTOR(0 downto 0);

      bus_address : out STD_LOGIC_VECTOR(15 downto 0);
      bus_data_in : in STD_LOGIC_VECTOR(7 downto 0);
      bus_data_out : out STD_LOGIC_VECTOR(7 downto 0);
      bus_we : out STD_LOGIC
    );
  end component;

  component blk_mem_gen_0 is
    Port ( 
      clka : in STD_LOGIC;
      ena : in STD_LOGIC;
      wea : in STD_LOGIC_VECTOR ( 0 to 0 );
      addra : in STD_LOGIC_VECTOR ( 15 downto 0 );
      dina : in STD_LOGIC_VECTOR ( 7 downto 0 );
      clkb : in STD_LOGIC;
      addrb : in STD_LOGIC_VECTOR ( 15 downto 0 );
      doutb : out STD_LOGIC_VECTOR ( 7 downto 0 )
    );
  end component;

  component blk_mem_gen_1 IS
    port (
      clka : in STD_LOGIC;
      ena : in STD_LOGIC;
      wea : in STD_LOGIC_VECTOR (0 to 0 );
      addra : in STD_LOGIC_VECTOR (7 downto 0 );
      dina : in STD_LOGIC_VECTOR (31 downto 0 );
      clkb : IN STD_LOGIC;
      addrb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
  end component;

  component RCA is
    generic (width : integer := 16);
    port (
      a : in STD_LOGIC_VECTOR(width-1 downto 0);
      b : in STD_LOGIC_VECTOR(width-1 downto 0);
      ci : in STD_LOGIC;
      s : out STD_LOGIC_VECTOR(width-1 downto 0);
      co : out STD_LOGIC
    );
  end component;

end package PKG_gameboy;

package body PKG_gameboy is

end package body PKG_gameboy;
