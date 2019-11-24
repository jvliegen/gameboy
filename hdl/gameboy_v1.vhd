library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;

library work;
  use work.PKG_gameboy.ALL;

entity gameboy_v1 is
  port (
    reset : in STD_LOGIC;
    clock : in STD_LOGIC;

    -- CONTROL PATH HELPER UPDATE PORT
    CPH_en : in STD_LOGIC;
    CPH_address : in STD_LOGIC_VECTOR(7 downto 0);
    CPH_data_in : in STD_LOGIC_VECTOR(31 downto 0);
    CPH_we : in STD_LOGIC;

    -- ROM UPDATE PORT
    ROM_en : in STD_LOGIC;
    ROM_address : in STD_LOGIC_VECTOR(15 downto 0);
    ROM_data_in : in STD_LOGIC_VECTOR(7 downto 0);
    ROM_we : in STD_LOGIC
  );
end gameboy_v1;

architecture Behavioural of gameboy_v1 is

  signal reset_i, clock_i : STD_LOGIC;

  signal CPH_en_i : STD_LOGIC;
  signal CPH_address_i : STD_LOGIC_VECTOR(7 downto 0);
  signal CPH_data_in_i : STD_LOGIC_VECTOR(31 downto 0);
  signal CPH_we_i : STD_LOGIC_VECTOR(0 downto 0);

  signal ROM_en_i : STD_LOGIC;
  signal ROM_address_i : STD_LOGIC_VECTOR(15 downto 0);
  signal ROM_data_in_i : STD_LOGIC_VECTOR(7 downto 0);
  signal ROM_we_v : STD_LOGIC_VECTOR(0 downto 0);
  signal PROC_bus_address : STD_LOGIC_VECTOR(15 downto 0);
  signal PROC_bus_data_in, PROC_bus_data_out : STD_LOGIC_VECTOR(7 downto 0);
  signal PROC_bus_we : STD_LOGIC;

begin
  
  -------------------------------------------------------------------------------
  -- (DE-)LOCALISING IN/OUTPUTS
  -------------------------------------------------------------------------------
  reset_i <= reset;
  clock_i <= clock;
  CPH_address_i <= CPH_address;
  CPH_data_in_i <= CPH_data_in;
  CPH_we_i(0) <= CPH_we;
  CPH_en_i <= CPH_en;
  ROM_en_i <= ROM_en;
  ROM_data_in_i <= ROM_data_in;
  ROM_address_i <= ROM_address;
  ROM_we_v(0) <= ROM_we;
  
  -------------------------------------------------------------------------------
  -- processor
  -------------------------------------------------------------------------------
  processor_inst00: component processor port map(
    reset => reset_i,
    clock => clock_i,
    CPH_en => CPH_en_i,
    CPH_data_in => CPH_data_in_i,
    CPH_address => CPH_address_i,
    CPH_we => CPH_we_i,

    bus_address => PROC_bus_address,
    bus_data_in => PROC_bus_data_in,
    bus_data_out => PROC_bus_data_out,
    bus_we  => PROC_bus_we);

  -------------------------------------------------------------------------------
  -- ROM
  -------------------------------------------------------------------------------
  GAMEROM_inst00: component blk_mem_gen_0 port map(
    clka => clock_i,
    ena => CPH_en_i,
    wea => ROM_we_v,
    addra => ROM_address_i,
    dina => ROM_data_in_i,
    clkb => clock_i,
    addrb => PROC_bus_address,
    doutb => PROC_bus_data_in);

  -------------------------------------------------------------------------------
  -- RAM
  -------------------------------------------------------------------------------

end Behavioural;