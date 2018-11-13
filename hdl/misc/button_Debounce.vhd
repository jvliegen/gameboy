---------------------------------------------------------------------------------------------------
-- ACRO - KHLim - Embedded systems & Security
---------------------------------------------------------------------------------------------------
-- Module Name:    button_Debounce
-- Project Name:   eDiViDe
-- Description:    push button debounce logic
--
-- Revision     Date        Author              Comments
-- v0.1         120229      VaaJo               Adapted version of WoDa
--
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity button_Debounce is
  generic(DELAY_i  : integer := 500); -- ticks
  port( clock     : in  STD_LOGIC; 
        reset     : in  STD_LOGIC;
        input   : in  STD_LOGIC;
        output  : out STD_LOGIC
  );
end button_Debounce;

architecture RTL of button_Debounce is

  --signal DELAY_ctr : integer range 0 to DELAY_i;
  signal DELAY_ctr : integer range 0 to 500;
  signal output_i : std_logic;
  
begin

  p_DELAY_ctr : process(reset, clock)
  begin
    if reset='1' then
      DELAY_ctr <= 0;
    elsif clock'event and clock='1' then
        if input='1' then
          if DELAY_ctr < 500 then
            DELAY_ctr <= DELAY_ctr + 1;
          end if;
        else
          if DELAY_ctr > 0 then
            DELAY_ctr <= DELAY_ctr - 1;
          end if;
        end if;
    end if;
  end process p_DELAY_ctr;

  p_output : process(reset, clock)
  begin
    if reset ='1' then
      output_i <= '0';
    elsif clock'event and clock='1' then
      case DELAY_ctr is
        when 0 => output_i <= '0';
        when 500 => output_i <='1';
        when others => output_i <= output_i;
      end case;
    end if;
  end process p_output;

  output  <= output_i;

end RTL;
