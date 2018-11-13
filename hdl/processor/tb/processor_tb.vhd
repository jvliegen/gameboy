library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.PKG_gameboy.ALL;

entity processor_tb is
end processor_tb;

architecture Behavioural of processor_tb is

  signal reset, clock : STD_LOGIC;

  signal ROM_address : STD_LOGIC_VECTOR(15 downto 0);
  signal ROM_dataout_i, ROM_dataout : STD_LOGIC_VECTOR(7 downto 0);

  constant clock_period : time := 250 ns;

begin

  -------------------------------------------------------------------------------
  -- STIMULI
  -------------------------------------------------------------------------------
  PSTIM: process
  begin
    reset <= '1';
    wait for clock_period*2;

    reset <= '0';
    wait for clock_period*2;



    wait;
  end process;

  -------------------------------------------------------------------------------
  -- MEMORY MODEL
  -------------------------------------------------------------------------------
  PMUX: process(ROM_address)
  begin
    case ROM_address is
      -- resets and interrupts
      when x"0000" => ROM_dataout_i <= x"FF";
      -- entry point
      when x"0100" => ROM_dataout_i <= x"00";
      when x"0101" => ROM_dataout_i <= x"c3";
      when x"0102" => ROM_dataout_i <= x"50"; 
      when x"0103" => ROM_dataout_i <= x"01";
      -- Nintendo stuff

      -- start of program
      when x"0150" => ROM_dataout_i <= x"3E";
      when x"0151" => ROM_dataout_i <= x"AA";

      when others => ROM_dataout_i <= x"00";
    end case;
  end process;

  --PREG: process(reset, clock)
  --begin
  --  if reset = '1' then 
  --    ROM_dataout <= x"00";
  --  elsif rising_edge(clock) then 
  --    ROM_dataout <= ROM_dataout_i;
  --  end if;
  --end process;
  ROM_dataout <= ROM_dataout_i;

  -------------------------------------------------------------------------------
  -- DEVICE UNDER TEST
  -------------------------------------------------------------------------------
  DUT: component processor port map(
    reset => reset,
    clock => clock,
    ROM_address => ROM_address,
    ROM_dataout => ROM_dataout);

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
