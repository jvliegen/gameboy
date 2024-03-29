# Development journal

## December 1st 2019
All hail the pipeline !!! Fixed the additional delay due to the BRAM. (Psst, I'm afraid it'll come back and it'll bite me in the **kuch**). Next up ... XOR A.
... and done. I have taken care that the addressing of operands and the operations comes from the IR. Hopefully this will help in many other situations. This will however not be sufficient for all instructions. We'll see how far it carries me.

## November 25th 2019
While verifying simulation results, (after implementing some form of register file and ALU) I noticed the JUMP of the previous instruction was executed. That should be fixed first !!
Hmm, it turned to be an out-of-date issue between my CPHelper file in Google and the file on my machine.
However, with that minor issue fixed, another issue arose. I forgot about the additional CC of delay due to the BRAM. Back to the drawing board, it seems.

## November 24th 2019
Wow, this took me some time. With routing everything out, things broke down. Long story short, hread() and read() are not the same !! Duhu !! Nonetheless, that's only a single character over which I've read maybe 100 times. :@

With that issue fixed, the **JUMP(0xC3)** instruction is implemented. The ROM I'm using to verify the design, has as next instruction **ADC,n(0xCE)**. I revisted the ALU and eliminated some unneeded (for now) parts. Two registers are added: **regA** and **regF**. The design is reaching simulation but verification whether it works is for the next time.

## November 11th 2019
Apparently I'm a bit confused with this program counter things. I've routed the CPH to the outside so I can more easily update it.

## November 9th 2019
When I left things, I expected to work on the PC. This I'm doing today. As a guide line, I'm using a ROM of an existing game (TETRIS) to guide me. The first operation after **NOP(0x00)** is a **JUMP(0xC3)**. Let's get to it !!

## October 29th 2019
I've taken another approach. Because of the irregular number of clock cycles I made a dumb FSM that passes through sets of 4 states. Depending on the IR it is decided if another set is required or not.
These parameters (eg. doing another round of 4), are fixed and can be (lazy as I am) store in RAM. With the IR as address, and a 64-bit output, we already have quite a number of FSM signals housed.
Let's see if this is approach passes simulation. (a moment later) Yes, it simulates. Next up. correct behaviour of the PC.

## October 24th 2019
After a year ... WTH **ONE YEAR** has past ... I took it up again. Before starting to write code, I've decided to analyse the opcodes first. The control path was misaligned due to 1 machine cycle is 4 clock cycles. Maybe thinking before typing (like I preach to my students) DOES help :-) Who would have guessed ;-)


## November 20th 2018
The Fetch-Decode-Execute cycle in the control path of the processor has been adapted. Now, the execute state can live longer than a single clock cycle. The exact length is determined by the opcode.

Now, the trick now is to drive the correct outputs in the correct cycle of Execute.


While _studying blueprints_ (LOL: Command and Conquer) a detailed understanding of the ALU is achieved. While pondering over the controlpath, the ALU is being implemented.


## November 19th 2018
Stuck ... that is the word. The fact that here are a multiple number of cycles for an instruction is, inconvenient let's say. A _load_ takes 4 cycles, unless the left operand XOR the right operand are "110", then it is a 8 cycle operation. But, in the case of where both left and right operand are "110", it's a special command: _halt_. (Hammerzeit !!)

Redesigning the control path is required. *BRB*


## November 15th 2018
With a _simple_ example ROM compiled, it's studying time. 
 ... *OR* ...
Wait a minute ...
If I use this machine code, to test the hardware implementation, it could act as pointer to which instruction is to be implemented next. Additionally, it'll give some insight on how "grown-ups" do software development. 

Sounds like a plan, doesn't it ?

After half an hour or so, two additional commands are implemented: DI, which disables the interrupts; and LD SP, nn, which loads a 16-bit value into the stackpointer. Apparently the next instruction is an LD A. This already was implemented and also seemed to work ... *hoozah* for me :)


## November 14th 2018
After converting the "ink on paper" into HDL, the first results with (improvised) background tiles are visible :)
![alt text](http://jo.jkl52.be/images/gameboy_journal/20181114_142044.jpg "First graphics result")

So, back to the processor. Now where were we ... oooooh yes ... there was an attempt of writing an example _program_ that would only use the implemented operations. After some browsing around, RGBDS has come up on top. An evening of browsing led to a way of getting a first .gb file compiled. Investigation and a thorough study of this example is up next.

... and this is where I leave it (for now) !



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