# Development journal

## November xth 2018


## November 9th 2018
The ALU isn't too complex, but it IS large. Although there are only 8 registers, there are a lot of operations that can be applied to (some of) them. Because I will want to run testbenches, it might be handy to start with the "program flow" first. This way I can gradually implement all the assembly instructions and test them.

It took some time to figure out how to implement the fetch-decode-execute cycle. Because the manual states every machine cycle takes up 4 clock cyles, a fourth instruction is add: dummy. Something tells me I'm gonna need that one later, don't know why.

First simulation seems to be working:
![alt text](http://jo.jkl52.be/images/gameboy_journal/20181109.png "First running simulation")

So ... I can start jumping (uncondionally, immediately and absolutly, that is), but it will be some time before Mario will start jumping.

What's next ... see what Tetris did ? ... investigate the "LDA nn" instruction ... maybe sleep on it first.

I added the acucumulator register A to the design, but only with the LDA instruction. This works, but there is not actual opcode decoding yet. Because the info is in the opcode, why not use it. That's the reason is there after all. Maybe it IS better to get some sleep first.


## November 8th 2018
Brilliant idea to rebuild a gameboy on an FPGA. Started with reading around on the internet. A valuable source seems to be the [GameBoy manual](http://marc.rawer.de/Gameboy/Docs/GBCPUman.pdf), who would have thought ?

Started with what seemed to be the simplest component: the ALU.