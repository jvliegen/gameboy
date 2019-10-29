library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;

library work;
  use work.PKG_gameboy.ALL;

entity gameboy_v1 is
  port (
    reset : in STD_LOGIC;
    clock : in STD_LOGIC;

    -- ROM UPDATE PORT
    ROM_address : in STD_LOGIC_VECTOR(15 downto 0);
    ROM_data_in : in STD_LOGIC_VECTOR(7 downto 0);
    ROM_we : in STD_LOGIC
  );
end gameboy_v1;

architecture Behavioural of gameboy_v1 is

  signal reset_i, clock_i : STD_LOGIC;


  signal ROM_address_i : STD_LOGIC_VECTOR(15 downto 0);
  signal ROM_data_in_i : STD_LOGIC_VECTOR(7 downto 0);
  signal ROM_we_v : STD_LOGIC_VECTOR(0 downto 0);

  signal PROC_bus_address, ROM_pA_addr : STD_LOGIC_VECTOR(15 downto 0);
  signal PROC_bus_data_in, PROC_bus_data_out : STD_LOGIC_VECTOR(7 downto 0);
  signal PROC_bus_we : STD_LOGIC;

begin
  
  -------------------------------------------------------------------------------
  -- (DE-)LOCALISING IN/OUTPUTS
  -------------------------------------------------------------------------------
  reset_i <= reset;
  clock_i <= clock;
  ROM_data_in_i <= ROM_data_in;
  ROM_address_i <= ROM_address;
  ROM_we_v(0) <= ROM_we;
  
  -------------------------------------------------------------------------------
  -- processor
  -------------------------------------------------------------------------------
  processor_inst00: component processor port map(
    reset => reset_i,
    clock => clock_i,
    bus_address => PROC_bus_address,
    bus_data_in => PROC_bus_data_in,
    bus_data_out => PROC_bus_data_out,
    bus_we  => PROC_bus_we);

  -------------------------------------------------------------------------------
  -- ROM
  -------------------------------------------------------------------------------
  GAMEROM_inst00: component blk_mem_gen_0 port map(
    clka => clock_i,
    wea => ROM_we_v,
    addra => ROM_address_i,
    dina => ROM_data_in_i,
    douta => open,
    clkb => clock_i,
    addrb => PROC_bus_address,
    doutb => PROC_bus_data_in);

  -------------------------------------------------------------------------------
  -- RAM
  -------------------------------------------------------------------------------

end Behavioural;