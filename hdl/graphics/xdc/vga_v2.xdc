
## Clock signal
##Bank = 35, Pin name = IO_L12P_T1_MRCC_35,         Sch name = CLK100MHZ
set_property PACKAGE_PIN E3 [get_ports clock]              
set_property IOSTANDARD LVCMOS33 [get_ports clock]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clock]
 
 ## Switches
##Bank = 34, Pin name = IO_L21P_T3_DQS_34,          Sch name = SW0
set_property PACKAGE_PIN U9 [get_ports {GPIO_DIPS[0]}]          
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_DIPS[0]}]
##Bank = 34, Pin name = IO_25_34,             Sch name = SW1
set_property PACKAGE_PIN U8 [get_ports {GPIO_DIPS[1]}]          
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_DIPS[1]}]
##Bank = 34, Pin name = IO_L23P_T3_34,            Sch name = SW2
set_property PACKAGE_PIN R7 [get_ports {GPIO_DIPS[2]}]          
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_DIPS[2]}]
##Bank = 34, Pin name = IO_L19P_T3_34,            Sch name = SW3
set_property PACKAGE_PIN R6 [get_ports {GPIO_DIPS[3]}]          
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_DIPS[3]}]
##Bank = 34, Pin name = IO_L19N_T3_VREF_34,         Sch name = SW4
set_property PACKAGE_PIN R5 [get_ports {GPIO_DIPS[4]}]          
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_DIPS[4]}]
##Bank = 34, Pin name = IO_L20P_T3_34,            Sch name = SW5
set_property PACKAGE_PIN V7 [get_ports {GPIO_DIPS[5]}]          
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_DIPS[5]}]
##Bank = 34, Pin name = IO_L20N_T3_34,            Sch name = SW6
set_property PACKAGE_PIN V6 [get_ports {GPIO_DIPS[6]}]          
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_DIPS[6]}]
##Bank = 34, Pin name = IO_L10P_T1_34,            Sch name = SW7
set_property PACKAGE_PIN V5 [get_ports {GPIO_DIPS[7]}]          
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_DIPS[7]}]
##Bank = 34, Pin name = IO_L8P_T1-34,           Sch name = SW8
set_property PACKAGE_PIN U4 [get_ports {GPIO_DIPS[8]}]          
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_DIPS[8]}]
##Bank = 34, Pin name = IO_L9N_T1_DQS_34,         Sch name = SW9
set_property PACKAGE_PIN V2 [get_ports {GPIO_DIPS[9]}]          
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_DIPS[9]}]
##Bank = 34, Pin name = IO_L9P_T1_DQS_34,         Sch name = SW10
set_property PACKAGE_PIN U2 [get_ports {GPIO_DIPS[10]}]         
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_DIPS[10]}]
##Bank = 34, Pin name = IO_L11N_T1_MRCC_34,         Sch name = SW11
set_property PACKAGE_PIN T3 [get_ports {GPIO_DIPS[11]}]         
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_DIPS[11]}]
##Bank = 34, Pin name = IO_L17N_T2_34,            Sch name = SW12
set_property PACKAGE_PIN T1 [get_ports {GPIO_DIPS[12]}]         
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_DIPS[12]}]
##Bank = 34, Pin name = IO_L11P_T1_SRCC_34,         Sch name = SW13
set_property PACKAGE_PIN R3 [get_ports {GPIO_DIPS[13]}]         
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_DIPS[13]}]
##Bank = 34, Pin name = IO_L14N_T2_SRCC_34,         Sch name = SW14
set_property PACKAGE_PIN P3 [get_ports {GPIO_DIPS[14]}]         
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_DIPS[14]}]
##Bank = 34, Pin name = IO_L14P_T2_SRCC_34,         Sch name = SW15
set_property PACKAGE_PIN P4 [get_ports {GPIO_DIPS[15]}]         
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_DIPS[15]}]
 

## LEDs
##Bank = 34, Pin name = IO_L24N_T3_34,            Sch name = LED0
set_property PACKAGE_PIN T8 [get_ports {GPIO_LEDS[0]}]         
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_LEDS[0]}]
##Bank = 34, Pin name = IO_L21N_T3_DQS_34,          Sch name = LED1
set_property PACKAGE_PIN V9 [get_ports {GPIO_LEDS[1]}]         
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_LEDS[1]}]
##Bank = 34, Pin name = IO_L24P_T3_34,            Sch name = LED2
set_property PACKAGE_PIN R8 [get_ports {GPIO_LEDS[2]}]         
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_LEDS[2]}]
##Bank = 34, Pin name = IO_L23N_T3_34,            Sch name = LED3
set_property PACKAGE_PIN T6 [get_ports {GPIO_LEDS[3]}]         
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_LEDS[3]}]
##Bank = 34, Pin name = IO_L12P_T1_MRCC_34,         Sch name = LED4
set_property PACKAGE_PIN T5 [get_ports {GPIO_LEDS[4]}]         
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_LEDS[4]}]
##Bank = 34, Pin name = IO_L12N_T1_MRCC_34,         Sch name = LED5
set_property PACKAGE_PIN T4 [get_ports {GPIO_LEDS[5]}]         
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_LEDS[5]}]
##Bank = 34, Pin name = IO_L22P_T3_34,            Sch name = LED6
set_property PACKAGE_PIN U7 [get_ports {GPIO_LEDS[6]}]         
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_LEDS[6]}]
##Bank = 34, Pin name = IO_L22N_T3_34,            Sch name = LED7
set_property PACKAGE_PIN U6 [get_ports {GPIO_LEDS[7]}]         
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_LEDS[7]}]
##Bank = 34, Pin name = IO_L10N_T1_34,            Sch name = LED8
set_property PACKAGE_PIN V4 [get_ports {GPIO_LEDS[8]}]         
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_LEDS[8]}]
##Bank = 34, Pin name = IO_L8N_T1_34,           Sch name = LED9
set_property PACKAGE_PIN U3 [get_ports {GPIO_LEDS[9]}]         
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_LEDS[9]}]
##Bank = 34, Pin name = IO_L7N_T1_34,           Sch name = LED10
set_property PACKAGE_PIN V1 [get_ports {GPIO_LEDS[10]}]          
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_LEDS[10]}]
##Bank = 34, Pin name = IO_L17P_T2_34,            Sch name = LED11
set_property PACKAGE_PIN R1 [get_ports {GPIO_LEDS[11]}]          
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_LEDS[11]}]
##Bank = 34, Pin name = IO_L13N_T2_MRCC_34,         Sch name = LED12
set_property PACKAGE_PIN P5 [get_ports {GPIO_LEDS[12]}]          
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_LEDS[12]}]
##Bank = 34, Pin name = IO_L7P_T1_34,           Sch name = LED13
set_property PACKAGE_PIN U1 [get_ports {GPIO_LEDS[13]}]          
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_LEDS[13]}]
##Bank = 34, Pin name = IO_L15N_T2_DQS_34,          Sch name = LED14
set_property PACKAGE_PIN R2 [get_ports {GPIO_LEDS[14]}]          
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_LEDS[14]}]
##Bank = 34, Pin name = IO_L15P_T2_DQS_34,          Sch name = LED15
set_property PACKAGE_PIN P2 [get_ports {GPIO_LEDS[15]}]          
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_LEDS[15]}]

##VGA Connector
##Bank = 35, Pin name = IO_L8N_T1_AD14N_35,         Sch name = VGA_R0
set_property PACKAGE_PIN A3 [get_ports {vgaRed[0]}]        
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[0]}]
##Bank = 35, Pin name = IO_L7N_T1_AD6N_35,          Sch name = VGA_R1
set_property PACKAGE_PIN B4 [get_ports {vgaRed[1]}]        
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[1]}]
##Bank = 35, Pin name = IO_L1N_T0_AD4N_35,          Sch name = VGA_R2
set_property PACKAGE_PIN C5 [get_ports {vgaRed[2]}]        
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[2]}]
##Bank = 35, Pin name = IO_L8P_T1_AD14P_35,         Sch name = VGA_R3
set_property PACKAGE_PIN A4 [get_ports {vgaRed[3]}]        
set_property IOSTANDARD LVCMOS33 [get_ports {vgaRed[3]}]
##Bank = 35, Pin name = IO_L2P_T0_AD12P_35,         Sch name = VGA_B0
set_property PACKAGE_PIN B7 [get_ports {vgaBlue[0]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[0]}]
##Bank = 35, Pin name = IO_L4N_T0_35,           Sch name = VGA_B1
set_property PACKAGE_PIN C7 [get_ports {vgaBlue[1]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[1]}]
##Bank = 35, Pin name = IO_L6N_T0_VREF_35,          Sch name = VGA_B2
set_property PACKAGE_PIN D7 [get_ports {vgaBlue[2]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[2]}]
##Bank = 35, Pin name = IO_L4P_T0_35,           Sch name = VGA_B3
set_property PACKAGE_PIN D8 [get_ports {vgaBlue[3]}]       
set_property IOSTANDARD LVCMOS33 [get_ports {vgaBlue[3]}]
##Bank = 35, Pin name = IO_L1P_T0_AD4P_35,          Sch name = VGA_G0
set_property PACKAGE_PIN C6 [get_ports {vgaGreen[0]}]        
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[0]}]
##Bank = 35, Pin name = IO_L3N_T0_DQS_AD5N_35,        Sch name = VGA_G1
set_property PACKAGE_PIN A5 [get_ports {vgaGreen[1]}]        
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[1]}]
##Bank = 35, Pin name = IO_L2N_T0_AD12N_35,         Sch name = VGA_G2
set_property PACKAGE_PIN B6 [get_ports {vgaGreen[2]}]        
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[2]}]
##Bank = 35, Pin name = IO_L3P_T0_DQS_AD5P_35,        Sch name = VGA_G3
set_property PACKAGE_PIN A6 [get_ports {vgaGreen[3]}]        
set_property IOSTANDARD LVCMOS33 [get_ports {vgaGreen[3]}]
##Bank = 15, Pin name = IO_L4P_T0_15,           Sch name = VGA_HS
set_property PACKAGE_PIN B11 [get_ports Hsync]           
set_property IOSTANDARD LVCMOS33 [get_ports Hsync]
##Bank = 15, Pin name = IO_L3N_T0_DQS_AD1N_15,        Sch name = VGA_VS
set_property PACKAGE_PIN B12 [get_ports Vsync]           
set_property IOSTANDARD LVCMOS33 [get_ports Vsync]




##Bank = 34, Pin name = IO_L5P_T0_34,           Sch name = LED16_R
#set_property PACKAGE_PIN K5 [get_ports RGB1_Red]         
  #set_property IOSTANDARD LVCMOS33 [get_ports RGB1_Red]
##Bank = 15, Pin name = IO_L5P_T0_AD9P_15,          Sch name = LED16_G
#set_property PACKAGE_PIN F13 [get_ports RGB1_Green]        
  #set_property IOSTANDARD LVCMOS33 [get_ports RGB1_Green]
##Bank = 35, Pin name = IO_L19N_T3_VREF_35,         Sch name = LED16_B
#set_property PACKAGE_PIN F6 [get_ports RGB1_Blue]          
  #set_property IOSTANDARD LVCMOS33 [get_ports RGB1_Blue]
##Bank = 34, Pin name = IO_0_34,                Sch name = LED17_R
#set_property PACKAGE_PIN K6 [get_ports RGB2_Red]         
  #set_property IOSTANDARD LVCMOS33 [get_ports RGB2_Red]
##Bank = 35, Pin name = IO_24P_T3_35,           Sch name =  LED17_G
#set_property PACKAGE_PIN H6 [get_ports RGB2_Green]         
  #set_property IOSTANDARD LVCMOS33 [get_ports RGB2_Green]
##Bank = CONFIG, Pin name = IO_L3N_T0_DQS_EMCCLK_14,      Sch name = LED17_B
#set_property PACKAGE_PIN L16 [get_ports RGB2_Blue]         
  #set_property IOSTANDARD LVCMOS33 [get_ports RGB2_Blue]


##7 segment display
##Bank = 34, Pin name = IO_L2N_T0_34,           Sch name = CA
#set_property PACKAGE_PIN L3 [get_ports {seg[0]}]         
  #set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
##Bank = 34, Pin name = IO_L3N_T0_DQS_34,         Sch name = CB
#set_property PACKAGE_PIN N1 [get_ports {seg[1]}]         
  #set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
##Bank = 34, Pin name = IO_L6N_T0_VREF_34,          Sch name = CC
#set_property PACKAGE_PIN L5 [get_ports {seg[2]}]         
  #set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
##Bank = 34, Pin name = IO_L5N_T0_34,           Sch name = CD
#set_property PACKAGE_PIN L4 [get_ports {seg[3]}]         
  #set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
##Bank = 34, Pin name = IO_L2P_T0_34,           Sch name = CE
#set_property PACKAGE_PIN K3 [get_ports {seg[4]}]         
  #set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
##Bank = 34, Pin name = IO_L4N_T0_34,           Sch name = CF
#set_property PACKAGE_PIN M2 [get_ports {seg[5]}]         
  #set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
##Bank = 34, Pin name = IO_L6P_T0_34,           Sch name = CG
#set_property PACKAGE_PIN L6 [get_ports {seg[6]}]         
  #set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]

##Bank = 34, Pin name = IO_L16P_T2_34,            Sch name = DP
#set_property PACKAGE_PIN M4 [get_ports dp]             
  #set_property IOSTANDARD LVCMOS33 [get_ports dp]

##Bank = 34, Pin name = IO_L18N_T2_34,            Sch name = AN0
#set_property PACKAGE_PIN N6 [get_ports {an[0]}]          
  #set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
##Bank = 34, Pin name = IO_L18P_T2_34,            Sch name = AN1
#set_property PACKAGE_PIN M6 [get_ports {an[1]}]          
  #set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
##Bank = 34, Pin name = IO_L4P_T0_34,           Sch name = AN2
#set_property PACKAGE_PIN M3 [get_ports {an[2]}]          
  #set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
##Bank = 34, Pin name = IO_L13_T2_MRCC_34,          Sch name = AN3
#set_property PACKAGE_PIN N5 [get_ports {an[3]}]          
  #set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]
##Bank = 34, Pin name = IO_L3P_T0_DQS_34,         Sch name = AN4
#set_property PACKAGE_PIN N2 [get_ports {an[4]}]          
  #set_property IOSTANDARD LVCMOS33 [get_ports {an[4]}]
##Bank = 34, Pin name = IO_L16N_T2_34,            Sch name = AN5
#set_property PACKAGE_PIN N4 [get_ports {an[5]}]          
  #set_property IOSTANDARD LVCMOS33 [get_ports {an[5]}]
##Bank = 34, Pin name = IO_L1P_T0_34,           Sch name = AN6
#set_property PACKAGE_PIN L1 [get_ports {an[6]}]          
  #set_property IOSTANDARD LVCMOS33 [get_ports {an[6]}]
##Bank = 34, Pin name = IO_L1N_T034,              Sch name = AN7
#set_property PACKAGE_PIN M1 [get_ports {an[7]}]          
  #set_property IOSTANDARD LVCMOS33 [get_ports {an[7]}]



##Buttons
##Bank = 15, Pin name = IO_L3P_T0_DQS_AD1P_15,        Sch name = CPU_RESET
set_property PACKAGE_PIN C12 [get_ports reset_n]       
set_property IOSTANDARD LVCMOS33 [get_ports reset_n]
##Bank = 15, Pin name = IO_L11N_T1_SRCC_15,         Sch name = BTNC
set_property PACKAGE_PIN E16 [get_ports GPIO_PBS[0]]            
set_property IOSTANDARD LVCMOS33 [get_ports GPIO_PBS[0]]
##Bank = 15, Pin name = IO_L14P_T2_SRCC_15,         Sch name = BTNU
set_property PACKAGE_PIN F15 [get_ports GPIO_PBS[1]]            
set_property IOSTANDARD LVCMOS33 [get_ports GPIO_PBS[1]]
##Bank = CONFIG, Pin name = IO_L15N_T2_DQS_DOUT_CSO_B_14, Sch name = BTNL
set_property PACKAGE_PIN T16 [get_ports GPIO_PBS[2]]            
set_property IOSTANDARD LVCMOS33 [get_ports GPIO_PBS[2]]
##Bank = 14, Pin name = IO_25_14,             Sch name = BTNR
set_property PACKAGE_PIN R10 [get_ports GPIO_PBS[3]]            
set_property IOSTANDARD LVCMOS33 [get_ports GPIO_PBS[3]]
##Bank = 14, Pin name = IO_L21P_T3_DQS_14,          Sch name = BTND
set_property PACKAGE_PIN V10 [get_ports GPIO_PBS[4]]            
set_property IOSTANDARD LVCMOS33 [get_ports GPIO_PBS[4]]