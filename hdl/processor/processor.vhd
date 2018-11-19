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

  signal reset_i, clock_i : STD_LOGIC;

  -- register file
  signal regA, regB, regC, regD, regE, regH, regL, regF : STD_LOGIC_VECTOR(7 downto 0);
  signal regA_in, regB_in, regC_in, regD_in, regE_in, regH_in, regL_in, regF_in : STD_LOGIC_VECTOR(7 downto 0);

  signal SP, PC, PC_nxt, PC_nxt_sum : STD_LOGIC_VECTOR(15 downto 0);
  signal IR : STD_LOGIC_VECTOR(15 downto 0);
  signal opcode, operand1 : STD_LOGIC_VECTOR(7 downto 0);
  signal RCA_PC_RO : STD_LOGIC_VECTOR(15 downto 0);

  -- bus interface
  signal bus_data_in_i : STD_LOGIC_VECTOR(7 downto 0);
  signal bus_data_out_i : STD_LOGIC_VECTOR(7 downto 0);
  signal bus_address_i : STD_LOGIC_VECTOR(15 downto 0);
  signal bus_we_i : STD_LOGIC;


  -- FSM signals
  type Tstates is (sIdle, sFetch, sDecode, sExecute, sDummy);
  signal curState, nxtState : Tstates;
  signal FSM_sel_PC_offset : STD_LOGIC;
  signal FSM_sel_PC_next : STD_LOGIC_VECTOR(1 downto 0);
  signal FSM_ld_opcode, FSM_ld_operand1 : STD_LOGIC;

  signal FSM_ld_a_op1, FSM_ld_b_op1, FSM_ld_c_op1, FSM_ld_d_op1 : STD_LOGIC;
  signal FSM_ld_e_op1, FSM_ld_f_op1, FSM_ld_h_op1, FSM_ld_l_op1 : STD_LOGIC;
  signal FSM_ld_sp_op1 : STD_LOGIC;


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
    elsif rising_edge(clock_i) then 
      if FSM_ld_opcode = '1' then 
        opcode <= bus_data_in_i;
      end if;
      if FSM_ld_operand1 = '1' then 
        operand1 <= bus_data_in_i;
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

  PMUX_PC: process(FSM_sel_PC_next, opcode, bus_data_in_i, PC_nxt_sum, PC, regH, regL)
  begin
    case FSM_sel_PC_next is
      when "01" =>
        PC_nxt <= bus_data_in_i & operand1;   -- absolute jump
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
  -- CONTROL PATH
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



  -- FSM STATE REGISTER
  P_FSM_STATEREG: process(clock_i, reset_i)
  begin
    if reset_i = '1' then 
      curState <= sIdle;
    elsif rising_edge(clock_i) then 
      curState <= nxtState;
    end if;
  end process;

  -- FSM NEXT STATE FUNCTION
  P_FSM_NSF: process(curState, opcode)
  begin
    nxtState <= curState;
    case curState is
      when sIdle => nxtState <= sFetch;

      when sFetch => nxtState <= sDecode;
      when sDecode => nxtState <= sExecute;
      when sExecute => nxtState <= sDummy;
      when sDummy => nxtState <= sFetch;

      when others => nxtState <= sIdle;
    end case;
  end process;

  -- FSM OUTPUT FUNCTION
  P_FSM_OF: process(curState, opcode)
  begin
    -- the defaults
    FSM_ld_opcode <= '0'; -- don't sample the incoming byte from ROM into opcode
    FSM_ld_operand1 <= '0'; -- don't sample the incoming byte from ROM into operand1
    FSM_sel_PC_offset <= '1'; -- RCA_PC adds x0001
    FSM_sel_PC_next <= "00"; -- 00: PC will not be updated;  11: PC will be loaded with result of RCA_PC

    FSM_ld_a_op1 <= '0';

    FSM_ld_f_op1 <= '0';
    FSM_ld_h_op1 <= '0';
    FSM_ld_l_op1 <= '0';

    case curState is
      when sFetch => 
        FSM_ld_opcode <= '1'; FSM_sel_PC_offset <= '1';   FSM_sel_PC_next <= "11";  -- default PC increment

      when sDecode =>
        if opcode = x"C3" or opcode = x"3E" or opcode = x"31" or opcode = x"3D" then 
          -- do another read from ROM
          FSM_ld_operand1 <= '1'; FSM_sel_PC_offset <= '1';   FSM_sel_PC_next <= "11";  -- default PC increment
        end if;


      when sExecute => 
        if opcode = x"C3" then 
          FSM_sel_PC_next <= "01"; -- PC will be set by opcode
        end if;
        if opcode = x"3E" then 
          -- FSM_ld_a_op1 <= '1';
          FSM_sel_PC_next <= "00"; -- PC will remain untouched
        end if;
        if opcode = x"31" then 
          FSM_ld_operand1 <= '1'; FSM_sel_PC_offset <= '1';   FSM_sel_PC_next <= "11";  -- default PC increment
        end if;
      when sDummy =>
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

  

end Behavioural;
