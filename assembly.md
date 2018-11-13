# GameBoy Assembly 

## 8-bit loads
* LD nn, n
  src = n (8-bit immediate value)
  dst = B, C, D, E, H, L, BC, DE, HL, SP

* LD r1, r2
  src = A, B, C, D, E, H, L, (HL)
  dst = A, B, C, D, E, H, L, (HL)

* LD A, n
  src = A, B, C, D, E, H, L, (BC), (DE), (HL), (nn), #
  dst = A

* LD n, A
  src = A
  dst = A, B, C, D, E, H, L, (BC), (DE), (HL), (nn)

* LD A, (C) [0xF2]
  src = value at $FF00 + regC
  dst = A
    equal to: LD A, ($FF00 + C)

* LD (C), A [0xE2]
  src = A
  dst = address $FF00 + regC

* LD A, (HLD)    LD A, (HL-)    LDD A, (HL) [0x3A]
  src = (HL) - DEC HL
  dst = A

* LD (HLD), A    LD (HL-), A    LDD (HL), A [0x32]
  src = A - DEC HL
  dst = (HL)

* LD A, (HLI)    LD A, (HL+)    LDI A, (HL) [0x2A]
  src = (HL) - INC HL
  dst = A

* LD (HLI), A    LD (HL+), A    LDI (HL), A [0x22]
  src = A - DEC HL
  dst = (HL)

* LDH (n), A  [0xE0]
  src = A
  dst = @ address $FF00+n

* LDH A, (n)  [0xF0]
  src = @ address ($FF00+n)
  dst = A


## 16-bit loads

* LD n, nn
  src = 16-bit immediate value
  dst = BC, DE, HL, SP

* LD SP, HL [0xF9]
  src = HL
  dst = SP

* LDHL SP, n      LD HL, SP+n    [0xF8]
  src = SP + n
  dst = HL

* LD (nn), SP   [0x08]
  src = SP
  dst = @ address nn

* PUSH nn 
  src = AF, BC, DE, HL
  dst = stack (and DEC(DEC(SP)))

* POP nn
  src = stack (and INC(INC(SP)))
  dst = AF, BC, DE, HL

# Assembly instructions

| Instruction | Parameters | Opcode | # cycles |
|------------------------------|----------------|----------------------------------------------------|-------------------------|
| ADD | A,A | 87 | 4 |
| ADD | A,A | 87 | 4 |
| ADD | A,B | 80 | 4 |
| ADD | A,C | 81 | 4 |
| ADD | A,D | 82 | 4 |
| ADD | A,E | 83 | 4 |
| ADD | A,H | 84 | 4 |
| ADD | A,L | 85 | 4 |
| ADD | A,(HL) | 86 | 8 |
| ADD | A,# | C6 | 8 |