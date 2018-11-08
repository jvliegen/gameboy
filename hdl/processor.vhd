library IEEE;

use IEEE.STD_LOGIC_1164.ALL;

entity processor is
  port (
    reset : in STD_LOGIC;
    clock : in STD_LOGIC;

  );
end processor;

architecture Behavioural of processor is

  signal reset_i, clock_i : STD_LOGIC;

  signal regA, regB, regC, regD, regE, regH, regL, regF : STD_LOGIC_VECTOR(7 downto 0);
  signal stackpointer, programcounter : STD_LOGIC_VECTOR(15 downto 0)

begin
  
  -------------------------------------------------------------------------------
  -- (DE-)LOCALISING IN/OUTPUTS
  -------------------------------------------------------------------------------
  reset_i <= reset;
  clock_i <= clock;

  

end Behavioural;