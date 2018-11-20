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

  -- register file
  signal regA, regB, regC, regD, regE, regH, regL, regF : STD_LOGIC_VECTOR(7 downto 0);
  signal regA_in, regB_in, regC_in, regD_in, regE_in, regH_in, regL_in, regF_in : STD_LOGIC_VECTOR(7 downto 0);
  signal SP, PC, PC_nxt, PC_nxt_sum : STD_LOGIC_VECTOR(15 downto 0);
  signal IR : STD_LOGIC_VECTOR(15 downto 0);
  signal opcode, operand1, operand2 : STD_LOGIC_VECTOR(7 downto 0);


  signal RCA_PC_RO : STD_LOGIC_VECTOR(15 downto 0);

  -- FSM signals
  type Tstates is (sIdle, sFetch, sDecode, sExecute, sDummy, sPreparePC);
  signal curState, nxtState : Tstates;
  signal FSM_sel_PC_offset : STD_LOGIC;
  signal FSM_sel_PC_next : STD_LOGIC_VECTOR(1 downto 0);
  signal FSM_ld_opcode, FSM_ld_operand1, FSM_ld_operand2 : STD_LOGIC;

  signal FSM_ld_a_op1, FSM_ld_b_op1, FSM_ld_c_op1, FSM_ld_d_op1 : STD_LOGIC;
  signal FSM_ld_e_op1, FSM_ld_f_op1, FSM_ld_h_op1, FSM_ld_l_op1 : STD_LOGIC;
  signal FSM_ld_sp_op1 : STD_LOGIC;

  signal FSM_execTMR_ld, FSM_execTMR_ce : STD_LOGIC;
  signal FSM_execTMR : integer range 0 to 24;
  signal FSM_execTMR_length : integer range 0 to 6;

  signal interrupt_allowed, interrupt_enable, interrupt_disable : STD_LOGIC;


  type Topcode is (NOP, LD, ADD, ADC, SUB, SBC, Aen, Axf, Aof, CMP, DI, EI, JP, LDAhash, LDSPn, LDHnA, unknown);
  signal opcode_s : Topcode;



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
      if FSM_ld_sp_op1 = '1' then SP <= operand1 & bus_data_in_i; end if;
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
      opcode <= x"00";
      operand1 <= x"00";
      operand2 <= x"00";
    elsif rising_edge(clock_i) then 
      if FSM_ld_opcode = '1' then 
        opcode <= bus_data_in_i;
      end if;
      if FSM_ld_operand1 = '1' then 
        operand1 <= bus_data_in_i;
      end if;
      if FSM_ld_operand2 = '1' then 
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

  -- Arithmetic operations
  PMUX_RCA_PC_RO: process(FSM_sel_PC_offset, opcode)
  begin
    case FSM_sel_PC_offset is
      when '0' =>     RCA_PC_RO <= x"00" & opcode(15 downto 8); -- relative jump
      when others =>  RCA_PC_RO <= x"0001";         -- default PC increment
    end case;
  end process;

  RCA_PC: component RCA generic map( width => 16) port map(
    a => PC,
    b => RCA_PC_RO,
    ci => C_ground(0),
    s => PC_nxt_sum,
    co => open );

  -------------------------------------------------------------------------------
  -- INTERRUPTS
  -------------------------------------------------------------------------------
  PREG_STATES: process(reset_i, clock_i)
  begin
    if reset_i = '1' then 
      interrupt_allowed <= '1';
    elsif rising_edge(clock_i) then
      if interrupt_enable = '1' then 
        interrupt_allowed <= '1';
      elsif interrupt_disable = '1' then 
        interrupt_allowed <= '0';
      end if;
    end if;
  end process; -- ending PREG_STATES


  -------------------------------------------------------------------------------
  -- CONTROL PATH
  -------------------------------------------------------------------------------

  -- FSM STATE REGISTER
  P_FSM_STATEREG: process(clock_i, reset_i)
  begin
    if reset_i = '1' then 
      curState <= sIdle;
      FSM_execTMR <= 0;
    elsif rising_edge(clock_i) then 
      curState <= nxtState;
      if FSM_execTMR_ld = '1' then 
        FSM_execTMR <= (FSM_execTMR_length-1)*4;
      elsif FSM_execTMR_ce = '1' then 
        FSM_execTMR <= FSM_execTMR - 1;
      end if;
    end if;
  end process;

  -- FSM NEXT STATE FUNCTION
  P_FSM_NSF: process(curState, FSM_execTMR)
  begin
    nxtState <= curState;
    case curState is
      when sIdle => nxtState <= sFetch;
      when sFetch => nxtState <= sDecode;
      when sDecode => nxtState <= sExecute;
      when sExecute => 
        -- some operations are done quicker in this implementation than on the original hardware
        -- therefore, the EXECUTE cycle might need interruption 
        -- this results in the processor sitting on is ass, doing nothing
        -- simply catching some well deserverd sleep cycles :)
        if opcode = x"c3" then
          if FSM_execTMR = 11 then 
            nxtState <= sDummy;
          end if; 
        elsif FSM_execTMR = 0 then 
          nxtState <= sPreparePC;
        end if;
      when sDummy => 
        if FSM_execTMR = 0 then 
          nxtState <= sPreparePC;
        end if;      when sPreparePC => nxtState <= sFetch;
      when others => nxtState <= sIdle;
    end case;
  end process;

  -- FSM OUTPUT FUNCTION
  P_FSM_OF: process(curState, opcode)
  begin
    -- the defaults
    FSM_ld_opcode <= '0'; -- don't sample the incoming byte from ROM into opcode
    FSM_ld_operand1 <= '0'; -- don't sample the incoming byte from ROM into operand1
    FSM_ld_operand2 <= '0'; -- don't sample the incoming byte from ROM into operand1
    FSM_sel_PC_offset <= '1'; -- RCA_PC adds x0001
    FSM_sel_PC_next <= "00"; -- 00: PC will not be updated;  11: PC will be loaded with result of RCA_PC

    FSM_ld_a_op1 <= '0';

    FSM_ld_f_op1 <= '0';
    FSM_ld_h_op1 <= '0';
    FSM_ld_l_op1 <= '0';

    FSM_execTMR_ld <= '0';
    FSM_execTMR_ce <= '0';

    case curState is
      when sFetch => 
        -- 1) load the opcode of the next instruction
        FSM_ld_opcode <= '1'; 
        -- 2) adjust the PC to point to the next instruction
        FSM_sel_PC_offset <= '1';   FSM_sel_PC_next <= "11";

      when sDecode =>
        -- 1) determine the cycle length according to the opcode
        FSM_execTMR_ld <= '1';
        -- 2) if this instruction requires an argument, load it and increment the PC
        if opcode = x"C3" or opcode = x"3E" or opcode = x"31" or opcode = x"3D" then 
          FSM_ld_operand1 <= '1';
          FSM_sel_PC_offset <= '1';   FSM_sel_PC_next <= "11";
        end if;

      when sExecute => 
        if opcode = x"C3" then 
          FSM_ld_operand2 <= '1';
          FSM_sel_PC_next <= "01"; -- PC will be set by opcode
        end if;
        if opcode = x"3E" then 
          -- FSM_ld_a_op1 <= '1';
          FSM_sel_PC_next <= "00"; -- PC will remain untouched
        end if;
        if opcode = x"31" then 
          FSM_ld_operand1 <= '1'; FSM_sel_PC_offset <= '1';   FSM_sel_PC_next <= "11";  -- default PC increment
        end if;
        FSM_execTMR_ce <= '1';

      when sDummy =>
        FSM_execTMR_ce <= '1';
        -- keep the defaults
      when others =>
        -- keep the defaults
    end case;
  end process;


  process(curState, opcode)
  begin
    FSM_ld_b_op1 <= '0';
    FSM_ld_c_op1 <= '0';
    FSM_ld_d_op1 <= '0';
    FSM_ld_e_op1 <= '0';
    interrupt_enable <= '0';
    interrupt_disable <= '0';
    FSM_ld_sp_op1 <= '0';

    if curState = sExecute then

      -- LD r1, r2
      if opcode(7 downto 6) = "01" then 
        case opcode(5 downto 3) is
          when "000" => FSM_ld_b_op1 <= '1';
          when "001" => FSM_ld_c_op1 <= '1';
          when "010" => FSM_ld_d_op1 <= '1';
          when "011" => FSM_ld_e_op1 <= '1';
--          when "100" => FSM_ld_h_op1 <= '1';
--          when "101" => FSM_ld_l_op1 <= '1';
          when others => -- use the defaults
        end case;
      end if;

      -- DI
      if opcode = x"F3" then interrupt_disable <= '1'; end if;

      -- EI
      if opcode = x"FB" then interrupt_enable <= '1'; end if;

      -- LD SP, nn
      if opcode = x"31" then FSM_ld_sp_op1 <= '1'; end if;

    end if;
  end process;

  -- this is only for simuation
  -- it translates the opcode to a mnemonic
  -- is (NOP, LD, ADD, ADC, SUB, SBC, Aen, Axf, Aof, CMP, DI, EI, JP, LDAhash, LDSPn, LDHnA )
  process(opcode)
  begin
    if opcode = x"00" then opcode_s <= NOP;
    elsif opcode(7 downto 6) = "01" then opcode_s <= LD;
    elsif opcode(7 downto 6) = "10" then
      -- alu
      case opcode(5 downto 3) is
        when "000" => opcode_s <= ADD;
        when "001" => opcode_s <= ADC;
        when "010" => opcode_s <= SUB;
        when "011" => opcode_s <= SBC;
        when "100" => opcode_s <= Aen;
        when "101" => opcode_s <= Axf;
        when "110" => opcode_s <= Aof;
        when others => opcode_s <= CMP;
      end case;
    elsif opcode = x"F3" then opcode_s <= DI;
    elsif opcode = x"FB" then opcode_s <= EI;
    elsif opcode = x"C3" then opcode_s <= JP;
    elsif opcode = x"3E" then opcode_s <= LDAhash;
    elsif opcode = x"31" then opcode_s <= LDSPn;
    elsif opcode = x"E0" then opcode_s <= LDHnA;
    else
      opcode_s <= unknown;
    end if;
  end process;

  -- not all instructions have the same length, this look-up table maps the opcde to a certain cycle-length
  -- BEWARE: some instructions have 'variable' run lenght. This is so a.o. for conditional jumps.
  --   20  JR NZ,r8  2   12/8
  --   28  JR Z,r8 2     12/8
  --   30  JR NC,r8  2   12/8
  --   38  JR C,r8 2     12/8
  --   C2  JP NZ,a16 3   16/12
  --   CA  JP Z,a16  3   16/12
  --   D2  JP NC,a16 3   16/12
  --   DA  JP C,a16  3   16/12
  --   C0  RET NZ  1     20/8
  --   C8  RET Z 1       20/8
  --   D0  RET NC  1     20/8
  --   D8  RET C 1       20/8
  --   C4  CALL NZ,a16 3 24/12
  --   CC  CALL Z,a16  3 24/12
  --   D4  CALL NC,a16 3 24/12
  --   DC  CALL C,a16  3 24/12
  PMUX_OPCODELENGTH: process(opcode)
  begin
    case (opcode) is
      when x"CD" => FSM_execTMR_length <= 6;
      when x"20" => FSM_execTMR_length <= 5;
      when x"C3" | x"C5" | x"C7" | x"C9" | x"CF" | x"D5" | x"D7" | x"D9" | x"DF" | x"E5" | x"E7" | x"E8" | x"EA" | x"EF" | x"F5" | x"F7" | x"FA" | x"FF" =>
        FSM_execTMR_length <= 4;
      when x"01" | x"11" | x"18" | x"21" | x"31" | x"34" | x"35" | x"36" | x"C1" | x"D1" | x"E0" | x"E1" | x"F0" | x"F1" | x"F8" => 
        FSM_execTMR_length <= 3;
      when x"02" | x"03" | x"06" | x"09" | x"0A" | x"0B" | x"0E" | x"12" | x"13" | x"16" | x"19" | x"1A" | x"1B" | x"1E" | x"22" | x"23" | 
          x"26" | x"29" | x"2A" | x"2B" | x"2E" | x"32" | x"33" | x"39" | x"3A" | x"3B" | x"3E" | x"46" | x"4E" | x"56" | x"5E" | x"66" | 
          x"6E" | x"70" | x"71" | x"72" | x"73" | x"74" | x"75" | x"77" | x"7E" | x"86" | x"8E" | x"96" | x"9E" | x"A6" | x"AE" | x"B6" | 
          x"BE" | x"C6" | x"CE" | x"D6" | x"DE" | x"E2" | x"E6" | x"EE" | x"F2" | x"F6" | x"F9" | x"FE" =>
        FSM_execTMR_length <= 2;
      when others => FSM_execTMR_length <= 1;
    end case;
  end process; --PMUX_OPCODELENGTH

end Behavioural;
