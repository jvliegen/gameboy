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

## Vivado project generation

create_project project_2 /home/jvliegen/personal/projects/gameboy/project_2 -part xc7vx485tffg1761-2
set_property board_part xilinx.com:vc707:part0:1.3 [current_project]
set_property target_language VHDL [current_project]

add_files -norecurse {/home/jvliegen/vc/bitbucket/gameboy/hdl/PKG_gameboy.vhd /home/jvliegen/vc/bitbucket/gameboy/hdl/processor/ALU.vhd /home/jvliegen/vc/bitbucket/gameboy/hdl/processor/processor.vhd /home/jvliegen/vc/bitbucket/gameboy/hdl/processor/RCA.vhd /home/jvliegen/vc/bitbucket/gameboy/hdl/gameboy_v1.vhd}
add_files -fileset sim_1 -norecurse /home/jvliegen/vc/bitbucket/gameboy/hdl/tb/gameboy_v1_tb.vhd
update_compile_order -fileset sources_1
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name blk_mem_gen_0
set_property -dict [list CONFIG.Memory_Type {Simple_Dual_Port_RAM} CONFIG.Write_Width_A {8} CONFIG.Write_Depth_A {65536} CONFIG.Read_Width_A {8} CONFIG.Operating_Mode_A {NO_CHANGE} CONFIG.Enable_A {Always_Enabled} CONFIG.Write_Width_B {8} CONFIG.Read_Width_B {8} CONFIG.Enable_B {Always_Enabled} CONFIG.Register_PortA_Output_of_Memory_Primitives {false} CONFIG.Register_PortB_Output_of_Memory_Primitives {true} CONFIG.Load_Init_File {true} CONFIG.Coe_File {/home/jvliegen/vc/bitbucket/gameboy/roms/tetris.coe} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100}] [get_ips blk_mem_gen_0]
