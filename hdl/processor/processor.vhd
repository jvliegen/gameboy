library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.PKG_gameboy.ALL;

entity processor is
  port (
    reset : in STD_LOGIC;
    clock : in STD_LOGIC;

    bus_address : out STD_LOGIC_VECTOR(15 downto 0);
    bus_data_in : in STD_LOGIC_VECTOR(7 downto 0);
    bus_data_out : out STD_LOGIC_VECTOR(7 downto 0);
    bus_we : out STD_LOGIC
  );
end processor;

architecture Behavioural of processor is

  -- clock and reset
  signal reset_i, clock_i : STD_LOGIC;

  -- bus interface
  signal bus_data_in_i : STD_LOGIC_VECTOR(7 downto 0);
  signal bus_data_out_i : STD_LOGIC_VECTOR(7 downto 0);
  signal bus_address_i : STD_LOGIC_VECTOR(15 downto 0);
  signal bus_we_i : STD_LOGIC;

  ---- register file
  --signal regA, regB, regC, regD, regE, regH, regL, regF : STD_LOGIC_VECTOR(7 downto 0);
  --signal regA_in, regB_in, regC_in, regD_in, regE_in, regH_in, regL_in, regF_in : STD_LOGIC_VECTOR(7 downto 0);
  --signal SP, PC, PC_nxt, PC_nxt_sum : STD_LOGIC_VECTOR(15 downto 0);
  signal IR : STD_LOGIC_VECTOR(15 downto 0);
  --signal opcode, operand1, operand2 : STD_LOGIC_VECTOR(7 downto 0);


  --signal RCA_PC_RO : STD_LOGIC_VECTOR(15 downto 0);

  ---- FSM signals
  --type Tstates is (sIdle, sFetch, sDecode, sExecute, sDummy, sPreparePC);
  --signal curState, nxtState : Tstates;
  --signal FSM_sel_PC_offset : STD_LOGIC;
  --signal FSM_sel_PC_next : STD_LOGIC_VECTOR(1 downto 0);
  --signal FSM_ld_opcode, FSM_ld_operand1, FSM_ld_operand2 : STD_LOGIC;

  --signal FSM_ld_a_op1, FSM_ld_b_op1, FSM_ld_c_op1, FSM_ld_d_op1 : STD_LOGIC;
  --signal FSM_ld_e_op1, FSM_ld_f_op1, FSM_ld_h_op1, FSM_ld_l_op1 : STD_LOGIC;
  --signal FSM_ld_sp_op1 : STD_LOGIC;

  --signal FSM_execTMR_ld, FSM_execTMR_ce : STD_LOGIC;
  --signal FSM_execTMR : integer range 0 to 24;
  --signal FSM_execTMR_length : integer range 0 to 6;

  --signal interrupt_allowed, interrupt_enable, interrupt_disable : STD_LOGIC;


  --type Topcode is (NOP, LD, ADD, ADC, SUB, SBC, Aen, Axf, Aof, CMP, DI, EI, JP, LDAhash, LDSPn, LDHnA, unknown);
  --signal opcode_s : Topcode;



begin
  
  -------------------------------------------------------------------------------
  -- (DE-)LOCALISING IN/OUTPUTS
  -------------------------------------------------------------------------------
  reset_i <= reset;
  clock_i <= clock;

  bus_data_in_i <= bus_data_in;
  bus_address <= PC;
  bus_data_out <= bus_data_out_i;
  bus_address <= bus_address_i;
  bus_we <= bus_we_i;

  bus_address_i <= PC;
  bus_we_i <= '0';

  -------------------------------------------------------------------------------
  -- REGISTERFILE
  -------------------------------------------------------------------------------
  PREG: process(reset_i, clock_i)
  begin
    if reset_i = '1' then 
      regA <= x"00"; regB <= x"00"; regC <= x"00"; regD <= x"00";
      regE <= x"00"; regF <= x"00"; regH <= x"00"; regL <= x"00";
      SP <= (others => '0');
    elsif rising_edge(clock_i) then
      if FSM_ld_a_op1 = '1' then regA <= regA_in; end if;
      if FSM_ld_b_op1 = '1' then regB <= regB_in; end if;
      if FSM_ld_c_op1 = '1' then regC <= regC_in; end if;
      if FSM_ld_d_op1 = '1' then regD <= regD_in; end if;
      if FSM_ld_e_op1 = '1' then regE <= regE_in; end if;
      if FSM_ld_f_op1 = '1' then regF <= regF_in; end if;
      if FSM_ld_h_op1 = '1' then regH <= regH_in; end if;
      if FSM_ld_l_op1 = '1' then regL <= regL_in; end if;
      if FSM_ld_sp_op1 = '1' then SP <= operand2 & operand1; end if;
    end if;
  end process; -- ending PREG

  regA_in <= operand1;
  regB_in <= operand1;
  regC_in <= operand1;
  regD_in <= operand1;
  regE_in <= operand1;
  regF_in <= operand1;
  regH_in <= operand1;
  regL_in <= operand1;

  bus_data_out_i <= regA; -- maybe this could be tapped from the mux that drives ALU-X

  -------------------------------------------------------------------------------
  -- INSTRUCTION REGISTER
  -------------------------------------------------------------------------------
  PREG_opcode: process(reset_i, clock_i)
  begin
    if reset_i = '1' then 
      IR <= x"00";
      operand1 <= x"00";
      operand2 <= x"00";
    elsif rising_edge(clock_i) then 
      if FSM_loadIR = '1' then 
        IR <= bus_data_in_i;
      end if;
      if FSM_loadARG1 = '1' then 
        operand1 <= bus_data_in_i;
      end if;
      if FSM_loadARG2 = '1' then 
        operand2 <= bus_data_in_i;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------------
  -- PROGRAM COUNTER
  -------------------------------------------------------------------------------
  PREG_PC: process(reset_i, clock_i)
  begin
    if reset_i = '1' then 
      PC <= C_programcounter_reset; -- PC is inited on x"0100"
    elsif rising_edge(clock_i) then 
      PC <= PC_nxt;
    end if;
  end process;

  PMUX_PC: process(FSM_sel_PC_next, opcode, operand2, PC_nxt_sum, PC, regH, regL)
  begin
    case FSM_sel_PC_next is
      when "01" =>
        PC_nxt <= operand2 & operand1;   -- absolute jump
      when "10" =>
        PC_nxt <= regH & regL; -- JUMP HL
      when "11" =>
        PC_nxt <= PC_nxt_sum;
      when others => 
        PC_nxt <= PC;
    end case;
  end process;

end Behavioural;
