--------------------------------------------------------------------------------
-- KULeuven - ESAT/COSIC- Embedded Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     pixelStream_generator - behavioral
-- Project Name:     
-- Description:     DVI video out timing
--
-- Revision     Date       Author     Comments
-- v0.1         20140804   VlJo     Initial version
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- using packages
--library WORK;
--use WORK.PKG_hippocrates.ALL;

entity pixelStream_generator is


  port ( 
    pixelClock   : in std_logic;
	VSYNC_pin : OUT STD_LOGIC;
	HSYNC_pin : OUT STD_LOGIC;
    lastByteOfLine : OUT STD_LOGIC;
    quadrant : OUT STD_LOGIC_vector(1 downto 0);
    visible : OUT STD_LOGIC;
    visible_gb : OUT STD_LOGIC );
end pixelStream_generator;

architecture Behavioral of pixelStream_generator is

constant C_DEBOUNCE_DELAY : integer := 5000000;  -- 50 ms = 50'000'000 ns = 5'000'000 CC
	constant p: std_logic_vector(127 downto 0):= x"00000000000000000000000000000087";
	
	constant C_key : std_logic_vector(127 downto 0):= x"0123456789ABCDEFFEDCBA9876543210";
	constant C_iv : std_logic_vector(95 downto 0):= x"BA98765432100123456789AB";
	
	constant C_columnIndexTrigger : integer := 350; -- 400 + 100
	
-------------------------------------------------------------------------------
-- 800x600 @72 Hz
-- pixel clock 50 MHz
-------------------------------------------------------------------------------
	constant HSL : integer := 120; -- H sync length
	constant HFP : integer := 56; -- H front porch
	constant HBP : integer := 64;  -- H back porch
	constant HActive : integer := 800;
	constant HTotal : integer := 1040; -- HSL + HFP + HActive + HBP

	-- the V_sync values are similar but we trigger a count on the falling H_sync edge
	constant VSL : integer := 6;   -- V sync length
	constant VFP : integer := 37;	 -- H front porch
	constant VBP : integer := 23;   -- H back porch
	constant VActive : integer := 600;
	constant VTotal : integer := 666; -- VSL + VFP + VActive + VBP

-------------------------------------------------------------------------------
-- 800x600 @60 Hz
-- providing a 40 MHz pixelclock
-------------------------------------------------------------------------------
	constant parser_HSL : integer := 128; -- H sync length
	constant parser_HFP : integer := 40; -- H front porch
	constant parser_HBP : integer := 88;  -- H back porch
	constant parser_HActive : integer := 800;
	constant parser_HTotal : integer := 1056; -- HSL + HFP + HActive + HBP

	-- the V_sync values are similar but we trigger a count on the falling H_sync edge
	constant parser_VSL : integer := 4;   -- V sync length
	constant parser_VFP : integer := 1;	 -- V front porch
	constant parser_VBP : integer := 23;   -- V back porch		THIS IS SUPPOSED TO BE THE STANDARD
	constant parser_VActive : integer := 600;
	constant parser_VTotal : integer := 628; -- VSL + VFP + VActive + VBP

	signal v_count : integer range 0 to 1023 := 0;
	signal h_count : integer range 0 to 2047 := 0;
	signal video_out_h, video_out_v : std_logic;
	signal red_temp, blue_temp, green_temp : std_logic;
	signal horiz_sync, vert_sync : std_logic;
	signal H_trigger, V_trigger : std_logic;

	constant max_color_value : integer := 7;

	signal red_count     : integer range 0 to max_color_value;
	signal green_count   : integer range 0 to max_color_value;
	signal blue_count    : integer range 0 to max_color_value;
	signal red_H_start   : integer range 0 to max_color_value;
	signal green_H_start : integer range 0 to max_color_value;
	signal blue_H_start  : integer range 0 to max_color_value;
	signal red_V_start   : integer range 0 to max_color_value;
	signal green_V_start : integer range 0 to max_color_value;
	signal blue_V_start  : integer range 0 to max_color_value;
	signal red_count_enable   : std_logic;
	signal green_count_enable : std_logic;
	signal blue_count_enable  : std_logic;
	signal red_H_start_enable   : std_logic;
	signal green_H_start_enable : std_logic;
	signal blue_H_start_enable  : std_logic;
	signal h_ref, v_ref : integer range 0 to 1024 := 100;
	signal LineJumpCounter, LineJump : integer range 0 to 1024 := 100;

	signal color_count, base_count : std_logic_vector(8 downto 0) := (others=>'0');

	signal Red, Green, Blue : std_logic_vector(2 downto 0);
	signal HSync, VSync : std_logic;

	signal visible_i : std_logic;

	type pactype is array (127 downto 0) of std_logic_vector(511 downto 0);                                       
	signal ReCoBusTXT : pactype := (others => (others => '0'));                                           

	signal Video : std_logic_vector(31 downto 0);
	signal pixel_i : std_logic_vector(11 downto 0);
	signal vert_sync_buffered : std_logic;
	
	signal upperHalf, leftHalf : std_logic;
	signal video_out_h_gb, video_out_v_gb, visible_gb_i : std_logic;
begin

	Quadrant <= upperHalf & leftHalf;

	VSYNC_pin <= vert_sync;
	HSYNC_pin <= horiz_sync;
	
	visible_i <= (video_out_h and video_out_v);
	visible_gb_i <= (video_out_h_gb and video_out_v_gb);
	visible <= visible_i;
	visible_gb <= visible_gb_i;

	sync: process(pixelClock)
	begin
		if pixelClock'event and pixelClock = '1' then
			
			if h_count >= HTotal-1 then 	                  -- horizontal counter
				  h_count <= 0;
			else 
				  h_count <= h_count + 1;
			end if;

			if h_count >= 0 AND h_count < HSL then 
				  horiz_sync <= '0';	
			else 
				  horiz_sync <= '1';	
			end if;

			if h_count=0 then
			  if v_count >= VTotal-1 then                 -- vertical counter
				  v_count <= 0; --(others=>'0'); 
			  else
				  v_count <= v_count + 1;
			  end if;
			end if;

			if v_count >= 0 and v_count < VSL then 
				  vert_sync <= '0';
			else 
				  vert_sync <= '1';
			end if;

			-- visible
			if h_count >= HSL + HFP AND h_count < HSL + HFP + HActive then 
				  video_out_h <= '1';
			else 
				  video_out_h <= '0';
			end if;

			if v_count >= VSL + VFP AND v_count < VSL + VFP + VActive then 
				  video_out_v <= '1';
			else 
				  video_out_v <= '0';
			end if;
			
			-- Gameboy visible
            if h_count >= HSL + HFP + 320 AND h_count < HSL + HFP + 320 + 160 then 
                  video_out_h_gb <= '1';
            else 
                  video_out_h_gb <= '0';
            end if;

            if v_count >= VSL + VFP + 228 AND v_count < VSL + VFP + 228 + 144 then 
                  video_out_v_gb <= '1';
            else 
                  video_out_v_gb <= '0';
            end if;

			-- quadrant
			--if h_count >= HSL + HFP AND h_count < HSL + HFP + HActive/2 then 
			if h_count < HSL + HFP + HActive/2 OR h_count >= HSL + HFP + HActive then 
				  leftHalf <= '0';
			else 
				  leftHalf <= '1';
			end if;
			
			--if v_count >= VSL + VFP AND v_count < VSL + VFP + VActive/2 then 
			if v_count < VSL + VFP + VActive/2 OR v_count >= VSL + VFP + VActive then 
				  upperHalf <= '0';
			else 
				  upperhalf <= '1';
			end if;
			
			if h_count = HSL + HFP + HActive - 1 then
				lastByteOfLine <= '1';
			else 
				lastByteOfLine <= '0';
			end if;
			
			HSync <= horiz_sync;
			VSync <= vert_sync;

		end if;	--clk
	end process sync;

end Behavioral;
