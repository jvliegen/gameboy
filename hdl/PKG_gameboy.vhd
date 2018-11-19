library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package PKG_gameboy is

  -------------------------------------------------------------------------------
  -- CONSTANTS
  -------------------------------------------------------------------------------
  constant C_ground : STD_LOGIC_VECTOR(15 downto 0) := x"0000";
  constant C_programcounter_reset : STD_LOGIC_VECTOR(15 downto 0) := x"0100";

  -------------------------------------------------------------------------------
  -- COMPONENT DECLARATIONS
  -------------------------------------------------------------------------------
  component processor is
    port (
      reset : in STD_LOGIC;
      clock : in STD_LOGIC;

      bus_address : out STD_LOGIC_VECTOR(15 downto 0);
      bus_data_in : in STD_LOGIC_VECTOR(7 downto 0);
      bus_data_out : out STD_LOGIC_VECTOR(7 downto 0);
      bus_we : out STD_LOGIC
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
