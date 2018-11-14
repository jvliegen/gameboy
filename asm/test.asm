* this is comment for the assembler
      ; this is comment as well
;

SECTION "start", HOME[$0100]
nop
jp begin

; main: 
;   jp $150
;   ld a, 10
;   ld b, 11
;   ld c, 12
;   ld d, 13
;   ld e, 14
;   ld h, 30
;   ld l, AA
;   ld a, b
;   ld b, c
;   ld c, d
;   ld d, e
;   ld e, h
;   ld h, i
;   ld i, a

begin:
  nop
  di