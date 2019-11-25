# Analysis of Tetris ROM

0100    00          NOP
0101    C3 50 01    JUMP 0150
0150    C3 0C 02    JUMP 020C
020C    AF          X0R A
020D    21 FF DF    LD HL, d16 (0xDFFF or 0xFFDF ?)