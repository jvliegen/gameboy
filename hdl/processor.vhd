library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.PKG_gameboy.ALL;

entity processor is
  port (
    reset : in STD_LOGIC;
    clock : in STD_LOGIC;

    ROM_address : out STD_LOGIC_VECTOR(15 downto 0);
    ROM_dataout : in STD_LOGIC_VECTOR(7 downto 0)
  );
end processor;

architecture Behavioural of processor is

  signal reset_i, clock_i : STD_LOGIC;

  signal regA, regB, regC, regD, regE, regH, regL, regF : STD_LOGIC_VECTOR(7 downto 0);

  signal SP, PC, PC_nxt, PC_nxt_sum : STD_LOGIC_VECTOR(15 downto 0);
  signal IR : STD_LOGIC_VECTOR(15 downto 0);
  signal opcode, operand1 : STD_LOGIC_VECTOR(7 downto 0);
  signal ROM_dataout_i : STD_LOGIC_VECTOR(7 downto 0);
  signal RCA_PC_RO : STD_LOGIC_VECTOR(15 downto 0);

  -- FSM signals
  type Tstates is (sIdle, sIncrPC, sFetch, sDecode, sExecute, sWriteback);
  signal curState, nxtState : Tstates;
  signal FSM_sel_PC_offset : STD_LOGIC;
  signal FSM_sel_PC_next : STD_LOGIC_VECTOR(1 downto 0);
  signal FSM_ld_opcode, FSM_ld_operand1 : STD_LOGIC;


begin
  
  -------------------------------------------------------------------------------
  -- (DE-)LOCALISING IN/OUTPUTS
  -------------------------------------------------------------------------------
  reset_i <= reset;
  clock_i <= clock;

  ROM_dataout_i <= ROM_dataout;
  ROM_address <= PC;

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
        opcode <= ROM_dataout_i;
      end if;
      if FSM_ld_operand1 = '1' then 
        operand1 <= ROM_dataout_i;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------------
  -- PROGRAM COUNTER
  -------------------------------------------------------------------------------

  -- initial opcodes from tetris:
  -- @ x0100 - x0103: 00c3 5001 => 00 is opcode for NOP, C3 is opcode for jp nn => JUMP address 0150 (LSByte first)
  -- @ x0104 - x0133: Nintendo logo
  --       CE ED 66 66 CC 0D 00 0B 03 73 00 83 00 0C 00 0D
  --       00 08 11 1F 88 89 00 0E DC CC 6E E6 DD DD D9 99
  --       BB BB 67 63 6E 0E EC CC DD DC 99 9F BB B9 33 3E

  -- @ x0150 ;
  --       41e6 => E6 => AND #
  --       0320 => JR NZ = jump if non zero, relativly  03
  --       fa7e
  --       a0c9 

  PREG_PC: process(reset_i, clock_i)
  begin
    if reset_i = '1' then 
      PC <= C_programcounter_reset; -- PC is inited on x"0100"
    elsif rising_edge(clock_i) then 
      PC <= PC_nxt;
    end if;
  end process;

  PMUX_PC: process(FSM_sel_PC_next, opcode, ROM_dataout_i, PC_nxt_sum, PC, regH, regL)
  begin
    case FSM_sel_PC_next is
      when "01" =>
        PC_nxt <= ROM_dataout_i & operand1;   -- absolute jump
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
        --case opcode is
        --  when x"00" =>
        --    nxtState <= sIncrPC;
        --  when others => 
        --    nxtState <= sIdle;
        --end case;
      when sExecute => nxtState <= sFetch;
      --when sWriteback => nxtState <= sFetch;

      --when sIncrPC => nxtState <= sIdle;

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


    case curState is
      when sFetch => 
        FSM_ld_opcode <= '1'; FSM_sel_PC_offset <= '1';   FSM_sel_PC_next <= "11";  -- default PC increment
      when sDecode =>
        if opcode = x"C3" then 
          -- do another read from ROM
          FSM_ld_operand1 <= '1'; FSM_sel_PC_offset <= '1';   FSM_sel_PC_next <= "11";  -- default PC increment
        end if;

      when sExecute => 
        if opcode = x"C3" then 
          FSM_sel_PC_next <= "01"; -- PC will be set by opcode
        end if;
      when others =>
        -- keep the defaults
    end case;
  end process;

end Behavioural;
