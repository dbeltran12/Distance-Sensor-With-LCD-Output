----------------------------------------------------------------------------------
-- Company: Digilent Inc.
-- Engineer: Andrew Skreen
-- 
-- Create Date:    17:25:25 03/01/2012 
-- Module Name:    master_interface
-- Project Name: 	 PmodCLS_Demo
-- Target Devices: Nexys3
-- Tool versions:  ISE 14.1
-- Description: 
--
-- Revision: 1.00 - Added debouncing, comments, fixed reset issue.
-- Revision: 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- *******************************************************************************
--  								Define block inputs and outputs
-- *******************************************************************************
entity master_interface is
    Port ( begin_transmission : out  STD_LOGIC;
           end_transmission : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           start : in  STD_LOGIC;
			  clear : in  STD_LOGIC;
           slave_select : out  STD_LOGIC;
			  sel : out integer range 0 to 33;
           temp_data : in  STD_LOGIC_VECTOR (7 downto 0);
           send_data : out  STD_LOGIC_VECTOR (7 downto 0));
end master_interface;

architecture Behavioral of master_interface is
	
-- *******************************************************************************
--  								Signals, Constants, and Types
-- *******************************************************************************

	-- FSM states
	type stateType is ( idle , clearing , display , wait_run , wait_ss , finished );
	signal STATE : stateType;
	signal prevSTATE : stateType;

	-- Used to select data sent to SPI Interface component and used for FSM control
	signal count_sel : integer range 0 to 33;
	-- Counts up to COUNT_SS_MAX, once reached the SS is asserted (i.e. shut off)
	signal count_ss : std_logic_vector( 11 downto 0 );
	-- Determines the duration that SS is deasserted (i.e. turned on)
	constant COUNT_SS_MAX : std_logic_vector( 11 downto 0 ) := X"FFF";

	-- Signal to execute a reset on the PmodCLS
	signal exeRst : std_logic := '0';
	
-- *******************************************************************************
--  										Implementation
-- *******************************************************************************
begin


	-- Master Interface FSM
	master_interface : process( clk ) begin

	if rising_edge( clk ) then 
		-- Reset
		if rst = '1' then
			STATE <= idle;
			prevSTATE <= idle;
			count_sel <= 0;
			send_data <= ( others => '0' );
			slave_select <= '1';
			count_ss <= ( others => '0' );
			begin_transmission <= '0';
			exeRst <= '1';
		else
			-- FSM
			case STATE is
			
				-- Idle State
				when idle =>

					count_sel <= 0;
					slave_select <= '1';

					if start = '1' and clear = '0' and exeRst = '0' then
						slave_select <= '0';
						STATE <= display;
						prevSTATE <= idle;
					elsif clear = '1' OR exeRst = '1' then
						slave_select <= '0';
						STATE <= clearing;
						prevSTATE <= idle;
					else
						null;
					end if;
				
				-- Clearing State
				when clearing =>
					prevSTATE <= clearing;
					send_data <= temp_data;
					begin_transmission <= '1';
					if count_sel = 3 then
						STATE <= wait_ss;
						count_sel <= 0;
					else
						STATE <= wait_run;
					end if;
					
				-- Display State
				when display =>
					prevSTATE <= display;
					send_data <= temp_data;
					begin_transmission <= '1';
					if count_sel = 18 then
						STATE <= wait_ss;
						count_sel <= 0;
					else 
						STATE <= wait_run;
					end if;
					
				-- wait_run State
				when wait_run=>
					begin_transmission <= '0';
					if end_transmission = '1' then
						STATE <= prevSTATE;
						count_sel <= count_sel + 1;
					else 
						null;
					end if;
					
				-- wait_ss State
				when wait_ss =>
					begin_transmission <= '0';
					if count_ss = COUNT_SS_MAX then
						STATE <= finished;
						count_ss <= ( others => '0' );
						slave_select <= '1';
					else
						count_ss <= count_ss + 1;
					end if;
						
				-- finished State				
				when finished =>

					exeRst <= '0';

					if start = '0' and clear = '0' then
						STATE <= idle;
						prevSTATE <= finished;
					end if;
				
				-- When signals indicate an invalid state
				when others => 
					null;
					
			end case;
		end if;
	end if;

	end process;
	-- End Master Interface FSM

	--  Signal to select the data to be sent to the PmodCLS
	SEL <= count_sel;

end Behavioral;
