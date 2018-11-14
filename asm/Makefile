#Makefile

ASM=/home/jvliegen/vc/bitbucket/gameboy/rgbds/./rgbasm
LNK=/home/jvliegen/vc/bitbucket/gameboy/rgbds/./rgblink
FIX=/home/jvliegen/vc/bitbucket/gameboy/rgbds/./rgbfix

ASM_OPTS=
LNK_OPTS=
FIX_OPTS=-v -p 0


test.o: test.asm gbhw.inc ibmpc1.inc memory.asm
	${ASM} ${ASM_OPTS} -o test.o test.asm

test.gb: test.o
	${LNK} ${LNK_OPTS} -o test.gb test.o

fix: test.gb
	${FIX} ${FIX_OPTS} test.gb

clean:
	rm -f *.o *.gb

example:
	${ASM} ${ASM_OPTS} -o example.o example.asm
	${LNK} ${LNK_OPTS} -o example.gb example.o
	${FIX} ${FIX_OPTS} example.gb

