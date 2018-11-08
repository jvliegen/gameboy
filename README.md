# gameboy

## Processor
The processor is a mix of the Intel 8080 and the Zilog80.

1 machine cycle = 4 clock cycles


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