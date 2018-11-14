library IEEE;

use IEEE.STD_LOGIC_1164.ALL;

entity ALU is
  port (
    A : in STD_LOGIC_VECTOR(7 downto 0);
    B : in STD_LOGIC_VECTOR(7 downto 0);
    C : in STD_LOGIC;
    Z : out STD_LOGIC_VECTOR(7 downto 0);
    Zfl : out STD_LOGIC;
    Nfl : out STD_LOGIC;
    Hfl : out STD_LOGIC;
    Cfl : out STD_LOGIC;

    operation: in STD_LOGIC_VECTOR(4 downto 0)
  );
end ALU;

architecture Behavioural of ALU is

  signal A_i, B_i, Z_i : STD_LOGIC_VECTOR(7 downto 0);
  signal C_i : STD_LOGIC;
  signal sum, carry : STD_LOGIC_VECTOR(7 downto 0);
  signal logicalAnd, logicalOr, logicalXor : STD_LOGIC_VECTOR(7 downto 0);

  signal Zfl_i, Nfl_i, Hfl_i, Cfl_i : STD_LOGIC;
  
  signal sumIsZero, sumIsNegative : STD_LOGIC;
  signal logicalAndIsZero, logicalOrIsZero, logicalXorIsZero : STD_LOGIC;

begin
  
  -------------------------------------------------------------------------------
  -- (DE-)LOCALISING IN/OUTPUTS
  -------------------------------------------------------------------------------
  A_i <= A;
  B_i <= B;
  C_i <= C;
  Z <= Z_i;
  Zfl <= Zfl_i;
  Nfl <= Nfl_i;
  Hfl <= Hfl_i;
  Cfl <= Cfl_i;


  
  
  -------------------------------------------------------------------------------
  -- Arithmetic operations
  -------------------------------------------------------------------------------
  RCA: for i in 0 to 7 generate
    LSB: if i=0 generate
      sum(i) <= A_i(i) xor B_i(i) xor C_i;
      carry(i) <= (A_i(i) and B_i(i)) or (C_i and (A_i(i) xor B_i(i)));
    end generate LSB;

    OTHER: if i>0 generate
      sum(i) <= A_i(i) xor B_i(i) xor carry(i-1);
      carry(i) <= (A_i(i) and B_i(i)) or (carry(i-1) and (A_i(i) xor B_i(i)));
    end generate OTHER;
  end generate RCA;
  
  -------------------------------------------------------------------------------
  -- Logical operations
  -------------------------------------------------------------------------------
  logicalAnd <= A_i and B_i;
  logicalOr <= A_i or B_i;
  logicalXor <= A_i xor B_i;

  -------------------------------------------------------------------------------
  -- FLAG DETERMINATION
  -------------------------------------------------------------------------------
  sumIsZero <= '1' when sum = x"00" else '0';
  sumIsNegative <= '1' when sum(7) = '1' else '0';

  logicalAndIsZero <= '1' when logicalAnd = x"00" else '0';
  logicalOrIsZero <= '1' when logicalOr = x"00" else '0';
  logicalXorIsZero <= '1' when logicalXor = x"00" else '0';


  -------------------------------------------------------------------------------
  -- OUTPUT MULTIPLEXER
  -------------------------------------------------------------------------------
  PMUX: process(operation, sumIsZero, logicalAndIsZero, logicalOrIsZero, logicalXorIsZero, sumIsNegative, sum, carry, logicalAnd, logicalOr, logicalXor)
  begin
    case operation is
      when "10000" | "11000" | "10001" | "11001" =>  -- ADD, ADC
        Z_i <= sum; Zfl_i <= sumIsZero; Nfl_i <= sumIsNegative; Hfl_i <= carry(3); Cfl_i <= carry(7);
      
      when "10100" | "11100" => -- AND
        Z_i <= logicalAnd; Zfl_i <= logicalAndIsZero; Nfl_i <= '0'; Hfl_i <= '1'; Cfl_i <= '0';

      when "10110" | "11110" => -- OR
        Z_i <= logicalOr; Zfl_i <= logicalOrIsZero; Nfl_i <= '0'; Hfl_i <= '0'; Cfl_i <= '0';

      when "10110" | "11110" => -- XOR
        Z_i <= logicalXor; Zfl_i <= logicalXorIsZero; Nfl_i <= '0'; Hfl_i <= '0'; Cfl_i <= '0';



      when others =>
        Z_i <= x"00"; Zfl_i <= '0'; Nfl_i <= '0'; Hfl_i <= '0'; Cfl_i <= '0';
    end case;
  end process;

  

end Behavioural;