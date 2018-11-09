# gameboy

## Processor
The processor is a mix of the Intel 8080 and the Zilog80.

1 machine cycle = 4 clock cycles

### Boot process
https://web.archive.org/web/20141105020940/http://problemkaputt.de/pandocs.htm

0100-0103 - Entry Point
After displaying the Nintendo Logo, the built-in boot procedure jumps to this address (100h), which should then jump to the actual main program in the cartridge. Usually this 4 byte area contains a NOP instruction, followed by a JP 0150h instruction. But not always.

### Registers:
A: 8-bit accumulator
B, c, D, E, H, L : 8-bit GPIO registers
F: status register
7: zero flag
6: subtract flag
5: half-carry flag - It is set when a carry from bit 3 is produced in arithmetical instructions.  Otherwise it is cleared.  It has a very common use, that is, for the DAA (decimal adjust) instruction.  Games used it extensively for displaying decimal values on the screen.
4: carry flag - It is set when a carry from bit 7 is produced in arithmetical instructions.  Otherwise it is cleared.
3..0: unused

Bit 5 represents the half-carry flag.  
Bit 6 represents the subtract flag.  When the instruction is a subtraction this bit is set.  Otherwise (the instruction is an addition) it is cleared.
Bit 7 represents the zero flag.  It is set when the instruction results in a value of 0.  Otherwise (result different to 0) it is cleared.


### Instructions

ADD A,n 
  with nA,B,C,D,E,H,L,(HL),#

#### Logical instructions
RLCA - 07 - rotate A left Old bit 7 to carry flag
  Z_i <= A_i(6 downto 0) & A_i(7);
  Zfl <= '1' if Z_i = x"00" else '0';
  Nfl <= '0';
  Hfl <= '0';
  Cfl <= A_i(7);

RLA - 17 - rotate A left through Carry flag
  Z_i <= A_i(6 downto 0) & C_i;
  Zfl <= '1' if Z_i = x"00" else '0';
  Nfl <= '0';
  Hfl <= '0';
  Cfl <= A_i(7);

RRCA - 0F - rotate A right Old bit 7 to carry flag
  Z_i <= A_i(0) & A_i(7 downto 1);
  Zfl <= '1' if Z_i = x"00" else '0';
  Nfl <= '0';
  Hfl <= '0';
  Cfl <= A_i(0);

RRA_i - 1F - rotate A right through Carry flag
  Z_i <= C_i & A_i(7 downto 1);
  Zfl <= '1' if Z_i = x"00" else '0';
  Nfl <= '0';
  Hfl <= '0';
  Cfl <= A_i(0);

RLC n - identical to RLCA, but also with B, D, D, E, H, L (, HL)

RL n - identical to RLA, but also with B, D, D, E, H, L (, HL)

RRC n - identical to RRCA, but also with B, D, D, E, H, L (, HL)

RR n - identical to RRA, but also with B, D, D, E, H, L (, HL)

SLA n - shift n left into Carry, LSB of n set to 0
  Z_i <= n_i(6 downto 0) & '0';
  Zfl <= '1' if Z_i = x"00" else '0';
  Nfl <= '0';
  Hfl <= '0';
  Cfl <= n_i(7);

SRA n - shift n right into Carry, MSB doesn't change
  Z_i <= n_i(7) & n_i(7 downto 1);
  Zfl <= '1' if Z_i = x"00" else '0';
  Nfl <= '0';
  Hfl <= '0';
  Cfl <= n_i(0);

SRL n - shift n right into carry MSB set to 0
  Z_i <= '0' & n_i(7 downto 1);
  Zfl <= '1' if Z_i = x"00" else '0';
  Nfl <= '0';
  Hfl <= '0';
  Cfl <= n_i(0);

