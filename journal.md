# Development journal

## November 13th 2018
I spend a couple days reading (now and again) the specifications and other online resources. While doing so an attempt was made to map opcode addresses to selection signals of muxes. These muxes determine source and destination registers in the registerfile. With this effort, the instruction "LD r1,r2" should be working now. At least, that is what the simulation shows.

The next step is to 'thoroughly' test this. Therefore, it would be convenient to run a small program that only consists of the (two) implemented assembly instruction (JP and LD r1, r2). As was pointed out by the _brainbaker_, there are tools available on the Internet for this. At this point, the implementation of the processor is put to rest for now.

To see some visual progress on the project, the work focus is shifted to the graphics part. To get the ground work done, an implementation to make visualisations through VGA is done first. This part, due to earlier experience (read: having VHDL code for this) this was a short job. A 'window' with the resolution of the gameboy can be shown on a VGA monitor with any desireable colour (that is, any colour that be encoded using 12 bits, 4 bits for each R, G and B):
![alt text](http://jo.jkl52.be/images/gameboy_journal/20181113_122558.jpg "First graphics result")

Next, a design which would be able to display background tiles is made. Because I learned at school that (for some reason) sleep is important, the design will remain "ink on paper" for now. This is where it should be picked up: description of this design in HDL, because no tool yet exists that generates HDL from my doodlings.


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