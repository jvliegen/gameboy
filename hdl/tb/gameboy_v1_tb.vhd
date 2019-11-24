library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use STD.textio.all;
  use ieee.std_logic_textio.all;
  use ieee.numeric_std.all;       -- for the signed, unsigned types and arithmetic ops


entity gameboy_v1_tb is
end gameboy_v1_tb;

architecture Behavioural of gameboy_v1_tb is

  component gameboy_v1 is
    port (
      reset : in STD_LOGIC;
      clock : in STD_LOGIC;

      CPH_en : in STD_LOGIC;
      CPH_address : in STD_LOGIC_VECTOR(7 downto 0);
      CPH_data_in : in STD_LOGIC_VECTOR(31 downto 0);
      CPH_we : in STD_LOGIC;

      ROM_en : in STD_LOGIC;
      ROM_address : in STD_LOGIC_VECTOR(15 downto 0);
      ROM_data_in : in STD_LOGIC_VECTOR(7 downto 0);
      ROM_we : in STD_LOGIC
    );
  end component;

  signal reset, clock : STD_LOGIC;

  signal CPH_address : STD_LOGIC_VECTOR(7 downto 0);
  signal CPH_data_in : STD_LOGIC_VECTOR(31 downto 0);
  signal CPH_we, CPH_en : STD_LOGIC;

  signal ROM_address : STD_LOGIC_VECTOR(15 downto 0);
  signal ROM_data_in : STD_LOGIC_VECTOR(7 downto 0);
  signal ROM_we, ROM_en : STD_LOGIC;

  constant clock_period : time := 10 ns;

  signal TriggerInit, InitDone : bit;

  file fh : text;

begin

  -------------------------------------------------------------------------------
  -- STIMULI
  -------------------------------------------------------------------------------
  PSTIM: process
  begin
    reset <= '1';
    ROM_en <= '0';
    ROM_address <= (others => '0');
    ROM_data_in <= (others => '0');
    ROM_we <= '0';
    wait for clock_period*10;
    
    TriggerInit <= '1';
    wait until InitDone = '1';
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
    CPH_en => CPH_en,
    CPH_address => CPH_address,
    CPH_data_in => CPH_data_in,
    CPH_we => CPH_we,
    ROM_en => ROM_en,
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

  -------------------------------------------------------------------------------
  -- CONTROL PATH FILLER
  -------------------------------------------------------------------------------
  PCPHELPER: process
    variable v_lineIn : line;
    variable v_temp : STD_LOGIC_VECTOR(31 downto 0);
    variable v_counter : integer range 0 to 255;
  begin
    
    InitDone <= '0';
    CPH_data_in <= (others => '0');
    CPH_address <= (others => '0');
    CPH_we <= '0';
    CPH_en <= '0';
    wait until TriggerInit = '1';

    file_open(fh, "CPHelper.dat", read_mode);
    v_counter := 0;
    CPH_en <= '1';
    CPH_we <= '1';

    while not endfile(fh) loop      
      readline(fh, v_lineIn);
      read(v_lineIn, v_temp); 
      CPH_data_in <= v_temp;
      CPH_address <= std_logic_vector(to_unsigned(v_counter, 8));
      wait until clock = '1';
      wait until clock = '0';
      v_counter := v_counter + 1;
    end loop;

    CPH_we <= '0';
    CPH_en <= '0';
    file_close(fh);
    InitDone <= '1';
    wait;
  end process;
  
end Behavioural;
