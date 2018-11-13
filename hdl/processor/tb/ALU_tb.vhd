library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALU_tb is
end ALU_tb;

architecture Behavioural of ALU_tb is

  signal clock : STD_LOGIC;

  component ALU is
    port (
      A : in STD_LOGIC_VECTOR(7 downto 0);
      B : in STD_LOGIC_VECTOR(7 downto 0);
      Z : out STD_LOGIC_VECTOR(7 downto 0);
      Zfl : out STD_LOGIC;
      Nfl : out STD_LOGIC;
      Hfl : out STD_LOGIC;
      Cfl : out STD_LOGIC;
      operation: in STD_LOGIC_VECTOR(3 downto 0)
    );
  end component;

  signal a, b, z : STD_LOGIC_VECTOR(7 downto 0);
  signal Zfl, Nfl, Hfl, Cfl : STD_LOGIC;
  signal operation : STD_LOGIC_VECTOR(3 downto 0);

  constant clock_period : time := 10 ns;

begin

  -------------------------------------------------------------------------------
  -- STIMULI
  -------------------------------------------------------------------------------
  PSTIM: process
  begin
    -------------------------------------------------------------------------------
    -- TESTING ADDITION WITH FLAGS
    -------------------------------------------------------------------------------
    A <= x"00";
    B <= x"00";
    operation <= x"0";
    wait for clock_period;
    assert(Z = x"00") report "error in result" severity failure;
    assert(Zfl = '1') report "error in result" severity failure;
    assert(Nfl = '0') report "error in result" severity failure;
    assert(Hfl = '0') report "error in result" severity failure;
    assert(Cfl = '0') report "error in result" severity failure;
    wait for clock_period;

    A <= x"20";
    B <= x"22";
    operation <= x"0";
    wait for clock_period;
    assert(Z = x"42") report "error in result" severity failure;
    assert(Zfl = '0') report "error in result" severity failure;
    assert(Nfl = '0') report "error in result" severity failure;
    assert(Hfl = '0') report "error in result" severity failure;
    assert(Cfl = '0') report "error in result" severity failure;
    wait for clock_period;

    A <= x"0F";
    B <= x"01";
    operation <= x"0";
    wait for clock_period;
    assert(Z = x"10") report "error in result" severity failure;
    assert(Zfl = '0') report "error in result" severity failure;
    assert(Nfl = '0') report "error in result" severity failure;
    assert(Hfl = '1') report "error in result" severity failure;
    assert(Cfl = '0') report "error in result" severity failure;
    wait for clock_period;

    A <= x"FF";
    B <= x"02";
    operation <= x"0";
    wait for clock_period;
    assert(Z = x"01") report "error in result" severity failure;
    assert(Zfl = '0') report "error in result" severity failure;
    assert(Nfl = '0') report "error in result" severity failure;
    assert(Hfl = '1') report "error in result" severity failure;
    assert(Cfl = '1') report "error in result" severity failure;
    wait for clock_period;

    wait for clock_period*1000;
  end process;


  -------------------------------------------------------------------------------
  -- DEVICE UNDER TEST
  -------------------------------------------------------------------------------

  DUT: component ALU port map(
    A => A,
    B => B,
    Z => Z,
    Zfl => Zfl,
    Nfl => Nfl,
    Hfl => Hfl,
    Cfl => Cfl,
    operation => operation);

  
  -------------------------------------------------------------------------------
  -- CLOCK
  -------------------------------------------------------------------------------
  PCLK: process
  begin
    clock <= '1';
    wait for clock_period/2;
    clock <= '0';
    wait for clock_period/2;
  end process;

  

end Behavioural;
