library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use ieee.numeric_std.ALL;

library work;
  use work.PKG_gameboy.ALL;

entity processor is
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
end processor;

architecture Behavioural of processor is

  -- clock and reset
  signal reset_i, clock_i : STD_LOGIC;
 
  --CPH memory interface
  signal CPH_en_i : STD_LOGIC;
  signal CPH_address_i : STD_LOGIC_VECTOR(7 downto 0);
  signal CPH_data_in_i : STD_LOGIC_VECTOR(31 downto 0);
  signal CPH_we_i : STD_LOGIC_VECTOR(0 downto 0);

  -- bus interface
  signal bus_data_in_i : STD_LOGIC_VECTOR(7 downto 0);
  signal bus_data_out_i : STD_LOGIC_VECTOR(7 downto 0);
  signal bus_address_i : STD_LOGIC_VECTOR(15 downto 0);
  signal bus_we_i : STD_LOGIC;

  -- register file
  signal regA, regB, regC, regD, regE, regH, regL, regF : STD_LOGIC_VECTOR(7 downto 0);
  signal regA_in, regF_in : STD_LOGIC_VECTOR(7 downto 0);
  --signal regA_in, regB_in, regC_in, regD_in, regE_in, regH_in, regL_in, regF_in : STD_LOGIC_VECTOR(7 downto 0);
  --signal SP, PC, PC_nxt, PC_nxt_sum : STD_LOGIC_VECTOR(15 downto 0);
  signal IR : STD_LOGIC_VECTOR(7 downto 0);
  signal operand1, operand2 : STD_LOGIC_VECTOR(7 downto 0);
  signal PC, PC_nxt, PC_nxt_sum, PC_incremented : STD_LOGIC_VECTOR(15 downto 0);

  -- ALU
  signal ALU_operation : STD_LOGIC_VECTOR(2 downto 0);
  signal ALU_flags_in, ALU_flags_out : STD_LOGIC_VECTOR(3 downto 0);
  signal ALU_op1, ALU_op2, ALU_out : STD_LOGIC_VECTOR(7 downto 0);
  signal CP_op2select : STD_LOGIC_VECTOR(2 downto 0);

  signal CPH_PC_OFFSET : STD_LOGIC_VECTOR(1 downto 0);
  signal PC_offset : integer range 0 to 65535;
  --signal opcode, operand1, operand2 : STD_LOGIC_VECTOR(7 downto 0);




  --signal RCA_PC_RO : STD_LOGIC_VECTOR(15 downto 0);

  ---- FSM signals
  --type Tstates is (sIdle, sFetch, sDecode, sExecute, sDummy, sPreparePC);
  --signal curState, nxtState : Tstates;
  --signal FSM_sel_PC_offset : STD_LOGIC;
  --signal FSM_sel_PC_next : STD_LOGIC_VECTOR(1 downto 0);
  --signal FSM_ld_opcode, FSM_ld_operand1, FSM_ld_operand2 : STD_LOGIC;

  signal FSM_ld_regA, FSM_ld_regF : STD_LOGIC;
  --signal FSM_ld_a_op1, FSM_ld_b_op1, FSM_ld_c_op1, FSM_ld_d_op1 : STD_LOGIC;
  --signal FSM_ld_e_op1, FSM_ld_f_op1, FSM_ld_h_op1, FSM_ld_l_op1 : STD_LOGIC;
  --signal FSM_ld_sp_op1 : STD_LOGIC;

  --signal FSM_execTMR_ld, FSM_execTMR_ce : STD_LOGIC;
  --signal FSM_execTMR : integer range 0 to 24;
  --signal FSM_execTMR_length : integer range 0 to 6;

  --signal interrupt_allowed, interrupt_enable, interrupt_disable : STD_LOGIC;



  -- FSM signals
  type Tstate is (sInit, sIdle, 
      MC0_CC0, MC0_CC1, MC0_CC2, MC0_CC3, 
      MC1_CC0, MC1_CC1, MC1_CC2, MC1_CC3, 
      MC2_CC0, MC2_CC1, MC2_CC2, MC2_CC3, 
      MC3_CC0, MC3_CC1, MC3_CC2, MC3_CC3, 
      MC4_CC0, MC4_CC1, MC4_CC2, MC4_CC3, 
      MC5_CC0, MC5_CC1, MC5_CC2, MC5_CC3, 
      MC6_CC0, MC6_CC1, MC6_CC2, MC6_CC3, 
      MC7_CC0, MC7_CC1, MC7_CC2, MC7_CC3, 
      MC8_CC0, MC8_CC1, MC8_CC2, MC8_CC3, 
      sHalt);
  signal curState, nxtState : Tstate;

  signal FSM_loadIR, FSM_loadARG1, FSM_loadARG2, FSM_loadPC : STD_LOGIC;

  signal CP_HELPER_a : STD_LOGIC_VECTOR(31 downto 0);
  signal CP_HELPER : STD_LOGIC_VECTOR(63 downto 0);
  alias CPH_loadIR : STD_LOGIC is CP_HELPER(63);
  alias CPH_loadARG1 : STD_LOGIC is CP_HELPER(62);
  alias CPH_loadARG2 : STD_LOGIC is CP_HELPER(61);
  alias CPH_MClimit : STD_LOGIC_VECTOR(6 downto 0) is CP_HELPER(60 downto 54);
  alias CPH_affectFlagZ : STD_LOGIC_VECTOR(1 downto 0) is CP_HELPER(53 downto 52);
  alias CPH_affectFlagN : STD_LOGIC_VECTOR(1 downto 0) is CP_HELPER(51 downto 50);
  alias CPH_affectFlagH : STD_LOGIC_VECTOR(1 downto 0) is CP_HELPER(49 downto 48);
  alias CPH_affectFlagC : STD_LOGIC_VECTOR(1 downto 0) is CP_HELPER(47 downto 46);
  alias CPH_PCnext : STD_LOGIC_VECTOR(2 downto 0) is CP_HELPER(45 downto 43);
  alias CPH_PCnext_incr_offset : STD_LOGIC_VECTOR(1 downto 0) is CP_HELPER(42 downto 41);
  alias CPH_affect_regA : STD_LOGIC is CP_HELPER(40);
  alias CPH_ALUoperation : STD_LOGIC_VECTOR(2 downto 0) is CP_HELPER(39 downto 37);

  signal FSM_PCnext : STD_LOGIC;

  type opcode_names is (NOP, JMP, ADC_n, UNDEFINED);
  signal opcode_name : opcode_names;

begin
  
  with to_integer(unsigned(IR)) select
    opcode_name <= NOP when 0,
                   JMP when 195,
                   ADC_n when 206,
                   UNDEFINED when others;

  -------------------------------------------------------------------------------
  -- (DE-)LOCALISING IN/OUTPUTS
  -------------------------------------------------------------------------------
  reset_i <= reset;
  clock_i <= clock;

  CPH_en_i <= CPH_en;
  CPH_address_i <= CPH_address;
  CPH_data_in_i <= CPH_data_in;
  CPH_we_i <= CPH_we;

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
  --    SP <= (others => '0');
    elsif rising_edge(clock_i) then
      if FSM_ld_regA = '1' then regA <= regA_in; end if;
      if FSM_ld_regF = '1' then regF <= regF_in; end if;
  --    if FSM_ld_b_op1 = '1' then regB <= regB_in; end if;
  --    if FSM_ld_c_op1 = '1' then regC <= regC_in; end if;
  --    if FSM_ld_d_op1 = '1' then regD <= regD_in; end if;
  --    if FSM_ld_e_op1 = '1' then regE <= regE_in; end if;
  --    if FSM_ld_f_op1 = '1' then regF <= regF_in; end if;
  --    if FSM_ld_h_op1 = '1' then regH <= regH_in; end if;
  --    if FSM_ld_l_op1 = '1' then regL <= regL_in; end if;
  --    if FSM_ld_sp_op1 = '1' then SP <= operand2 & operand1; end if;
    end if;
  end process; -- ending PREG

  regA_in <= ALU_out;
  --regB_in <= operand1;
  --regC_in <= operand1;
  --regD_in <= operand1;
  --regE_in <= operand1;
  -- CPH_affectFlag.(1..0)
  --   00: set to 0
  --   01: not affected
  --   10: from ALU
  --   11: set to 1
  regF_in(7) <= ( CPH_affectFlagZ(1) and CPH_affectFlagZ(0) )
             or ( CPH_affectFlagZ(1) and ALU_flags_out(3) )
             or ( CPH_affectFlagZ(0) and regF(7) );
  regF_in(6) <= ( CPH_affectFlagN(1) and CPH_affectFlagN(0) )
             or ( CPH_affectFlagN(1) and ALU_flags_out(2) )
             or ( CPH_affectFlagN(0) and regF(6) );
  regF_in(5) <= ( CPH_affectFlagH(1) and CPH_affectFlagH(0) )
             or ( CPH_affectFlagH(1) and ALU_flags_out(1) )
             or ( CPH_affectFlagH(0) and regF(5) );
  regF_in(4) <= ( CPH_affectFlagC(1) and CPH_affectFlagC(0) )
             or ( CPH_affectFlagC(1) and ALU_flags_out(0) )
             or ( CPH_affectFlagC(0) and regF(4) );
  regF_in(3 downto 0) <= "0000";
  --regH_in <= operand1;
  --regL_in <= operand1;

  --bus_data_out_i <= regA; -- maybe this could be tapped from the mux that drives ALU-X

  ---------------------------------------------------------------------------------
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
      if FSM_loadPC = '1' then
        PC <= PC_nxt;
      end if;
    end if;
  end process;

  PMUX_PC: process(FSM_PCnext, CPH_PCnext, PC_incremented, operand1, operand2)--, opcode, operand2, PC_nxt_sum)--, PC), regH, regL)
  begin
    if FSM_PCnext = '1' then 
      PC_nxt <= PC_incremented;
    else
      case CPH_PCnext is
        when "001" =>     PC_nxt <= operand2 & operand1;
        ----when "10" =>
        ----  PC_nxt <= regH & regL; -- JUMP HL
        --when "11" =>
        --  PC_nxt <= PC_nxt_sum;
        when others => PC_nxt <= PC_incremented;
      end case;
    end if;
  end process;

  PC_incremented <= std_logic_vector(to_unsigned(  to_integer(unsigned(PC)) + PC_offset, PC'length));
  
  PMUX_PC_OFFSET: process(PC, CPH_PCnext_incr_offset)
  begin
    case CPH_PCnext_incr_offset is
      when "01" => PC_offset <= 1;
      when others => PC_offset <= 0;
    end case;
  end process; --PMUX_PC_OFFSET


  -------------------------------------------------------------------------------
  -- ALU
  -------------------------------------------------------------------------------
  ALU_op1 <= regA;

  PMUX_ALU_OP2: process(regA, regB, regC, regD, regE, regH, regL, bus_data_in_i, operand1)
  begin
    case CP_op2select is
      when "000"  => ALU_op2 <= regB;
      when "001"  => ALU_op2 <= regC;
      when "010"  => ALU_op2 <= regD;
      when "011"  => ALU_op2 <= regE;
      when "100"  => ALU_op2 <= regH;
      when "101"  => ALU_op2 <= regL;
      when "110"  => ALU_op2 <= bus_data_in_i;
      when others => ALU_op2 <= operand1;
    end case;
  end process;

  ALU_flags_in <= regF(7 downto 4);
  ALU_operation <= CPH_ALUoperation;

  ALU_inst00: component ALU port map(
    A => ALU_op1,
    B => ALU_op2,
    flags_in => ALU_flags_in,
    Z => ALU_out,
    flags_out => ALU_flags_out,
    operation => ALU_operation
  );
  
  -------------------------------------------------------------------------------
  -- CONTROL PATH
  -------------------------------------------------------------------------------

  -- FSM STATE REGISTER
  P_FSM_STATEREG: process(clock_i, reset_i)
  begin
    if reset_i = '1' then 
      curState <= sInit;
    elsif rising_edge(clock_i) then 
      curState <= nxtState;
    end if;
  end process;

  -- FSM NEXT STATE FUNCTION
  P_FSM_NSF: process(curState, CPH_MClimit)
  begin
    case curState is
      when sInit => nxtState <= MC0_CC0;

      when MC0_CC0 => nxtState <= MC0_CC1;
      when MC0_CC1 => nxtState <= MC0_CC2;
      when MC0_CC2 => nxtState <= MC0_CC3;
      when MC0_CC3 => if CPH_MClimit(0) = '1' then nxtState <= MC0_CC0; else nxtState <= MC1_CC0; end if;

      when MC1_CC0 => nxtState <= MC1_CC1;
      when MC1_CC1 => nxtState <= MC1_CC2;
      when MC1_CC2 => nxtState <= MC1_CC3;
      when MC1_CC3 => if CPH_MClimit(1) = '1' then nxtState <= MC0_CC0; else nxtState <= MC2_CC0; end if;

      when MC2_CC0 => nxtState <= MC2_CC1;
      when MC2_CC1 => nxtState <= MC2_CC2;
      when MC2_CC2 => nxtState <= MC2_CC3;
      when MC2_CC3 => if CPH_MClimit(2) = '1' then nxtState <= MC0_CC0; else nxtState <= MC3_CC0; end if;

      when MC3_CC0 => nxtState <= MC3_CC1;
      when MC3_CC1 => nxtState <= MC3_CC2;
      when MC3_CC2 => nxtState <= MC3_CC3;
      when MC3_CC3 => if CPH_MClimit(3) = '1' then nxtState <= MC0_CC0; else nxtState <= MC4_CC0; end if;

      when MC4_CC0 => nxtState <= MC4_CC1;
      when MC4_CC1 => nxtState <= MC4_CC2;
      when MC4_CC2 => nxtState <= MC4_CC3;
      when MC4_CC3 => if CPH_MClimit(4) = '1' then nxtState <= MC0_CC0; else nxtState <= MC5_CC0; end if;

      when MC5_CC0 => nxtState <= MC5_CC1;
      when MC5_CC1 => nxtState <= MC5_CC2;
      when MC5_CC2 => nxtState <= MC5_CC3;
      when MC5_CC3 => if CPH_MClimit(5) = '1' then nxtState <= MC0_CC0; else nxtState <= MC6_CC0; end if;

      when MC6_CC0 => nxtState <= MC6_CC1;
      when MC6_CC1 => nxtState <= MC6_CC2;
      when MC6_CC2 => nxtState <= MC6_CC3;
      when MC6_CC3 => if CPH_MClimit(6) = '1' then nxtState <= MC0_CC0; else nxtState <= MC7_CC0; end if;

      when MC7_CC0 => nxtState <= MC7_CC1;
      when MC7_CC1 => nxtState <= MC7_CC2;
      when MC7_CC2 => nxtState <= MC7_CC3;
      when MC7_CC3 => nxtState <= MC0_CC0;

      when others => nxtState <= sIdle;
    end case;
  end process;

  -- FSM OUTPUT FUNCTION
   --FSM_inc_PC <= '1' when MC0_CC0 else '0';
  FSM_loadIR <= CPH_loadIR when curState = MC0_CC0 else '0';
  FSM_loadARG1 <= CPH_loadARG1 when curState = MC1_CC0 else '0';
  FSM_loadARG2 <= CPH_loadARG2 when curState = MC2_CC0 else '0';

  FSM_loadPC <= '1' when 
        curState = MC0_CC0 
        or curState = MC1_CC0 
        or curState = MC2_CC0 or (curState = MC2_CC3 and CPH_MClimit(2) = '1')
        or curState = MC3_CC0
        or curState = MC4_CC0
        or curState = MC5_CC0
        or curState = MC6_CC0
        else '0';

  -- the instuction might have an influence on the program counter
  -- those instructions, however, might also need multiple operands
  -- therefor the default operation is : increment PC. Until the FSM
  -- decides it's the instruction's influence that is allowed
  -- This signal (when '1') overrules to increment PC
  FSM_PCnext <= '0' when  
        (curState = MC2_CC3) and (CPH_MClimit(2) = '1')
        else '1';


  FSM_ld_rega <= CPH_affect_regA when 
        (curState = MC0_CC3 and CPH_MClimit(0) = '1')
        or (curState = MC1_CC3 and CPH_MClimit(1) = '1')
        or (curState = MC2_CC3 and CPH_MClimit(2) = '1')
        or (curState = MC3_CC3 and CPH_MClimit(3) = '1')
        or (curState = MC4_CC3 and CPH_MClimit(4) = '1')
        or (curState = MC5_CC3 and CPH_MClimit(5) = '1')
        or (curState = MC6_CC3 and CPH_MClimit(6) = '1')
        else '0';

  -- CP_HELPER
  -- In stead of hardcoding a lot of parameters, I'm using a BRAM
  -- This is sort of cheating, but for a first implementation, that 
  -- might just be OK.
  -- With the INSTRUCTION as the address, the memory gives a value
  -- that is coded to assist the control path.
  -- There are 256 different opcodes, so the depth of the memory is 
  -- 256. Given that (small) BRAMs are 18kB, this means the helper 
  -- gives us an additional 64 bits of metadata.

--  FSM_sel_PC_next <= 00; -- PC
--  FSM_sel_PC_next <= 01; -- PC <= op2 & op1
--  FSM_sel_PC_next <= 10; -- PC <= regH & regL
--  FSM_sel_PC_next <= 11; -- PC_nxt_sum


  -- FSM Helper
  FSM_Helper_inst00: component blk_mem_gen_1 port map(
    clka => clock_i,
    ena => CPH_en_i,
    addra => CPH_address_i,
    dina => CPH_data_in_i,
    wea => CPH_we_i,
    clkb => clock_i,
    addrb => IR,
    doutb => CP_HELPER_a);

  CP_HELPER <= CP_HELPER_a & x"00000000";

end Behavioural;
