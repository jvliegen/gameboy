library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RCA is
  generic (width : integer := 16);
  port (
    a : in STD_LOGIC_VECTOR(width-1 downto 0);
    b : in STD_LOGIC_VECTOR(width-1 downto 0);
    ci : in STD_LOGIC;
    s : out STD_LOGIC_VECTOR(width-1 downto 0);
    co : out STD_LOGIC
  );
end RCA;

architecture Behavioural of RCA is

  signal reset_i, clock_i : STD_LOGIC;
  signal a_i, b_i, s_i, c_i : STD_LOGIC_VECTOR(width-1 downto 0);

begin
  
  -------------------------------------------------------------------------------
  -- (DE-)LOCALISING IN/OUTPUTS
  -------------------------------------------------------------------------------
  a_i <= a;
  b_i <= b;
  s <= s_i;
  co <= c_i(c_i'high);
  
  RCA_PC: for i in 0 to width-1 generate
    LSB: if i=0 generate
      s_i(i) <= a_i(i) xor b_i(i) xor ci;
      c_i(i) <= (a_i(i) and b_i(i)) or (ci and (a_i(i) xor b_i(i)));
    end generate LSB;

    OTHER: if i>0 generate
      s_i(i) <= a_i(i) xor b_i(i) xor c_i(i-1);
      c_i(i) <= (a_i(i) and b_i(i)) or (c_i(i-1) and (a_i(i) xor b_i(i)));
    end generate OTHER;
  end generate RCA_PC;

end Behavioural;
