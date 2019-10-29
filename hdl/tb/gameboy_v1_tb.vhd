library IEEE;

use IEEE.STD_LOGIC_1164.ALL;

entity gameboy_v1_tb is
end gameboy_v1_tb;

architecture Behavioural of gameboy_v1_tb is

  component gameboy_v1 is
    port (
      reset : in STD_LOGIC;
      clock : in STD_LOGIC;
      ROM_address : in STD_LOGIC_VECTOR(15 downto 0);
      ROM_data_in : in STD_LOGIC_VECTOR(7 downto 0);
      ROM_we : in STD_LOGIC
    );
  end component;

  signal reset, clock : STD_LOGIC;
  signal ROM_address : STD_LOGIC_VECTOR(15 downto 0);
  signal ROM_data_in : STD_LOGIC_VECTOR(7 downto 0);
  signal ROM_we : STD_LOGIC

  constant clock_period : time := 10 ns;

begin

  -------------------------------------------------------------------------------
  -- STIMULI
  -------------------------------------------------------------------------------
  PSTIM: process
  begin
    reset <= '1';
    ROM_address <= (others => '0');
    ROM_data_in <= (others => '0');
    ROM_we <= '0';
    wait for clock_period*10;

    reset <= '0';
    wait for clock_period*10;

    wait;
  end process;

  -------------------------------------------------------------------------------
  -- DEVICE UNDER TEST
  -------------------------------------------------------------------------------

  DUT: component gameboy_v1 port map(
    reset => reset,
    clock => clock,
    ROM_address => ROM_address,
    ROM_data_in => ROM_data_in,
    ROM_we => ROM_we
  );


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