----------------------------------------------------------------------------------
-- Company: Digilent Inc.
-- Engineer: Andrew Skreen
-- 
-- Create Date:    17:25:25 03/01/2012 
-- Module Name:    spi_interface
-- Project Name: 	 PmodCLS_Demo
-- Target Devices: Nexys3
-- Tool versions:  ISE 14.1
-- Description: Interfaces the PmodCLS by producing a serial clock, providing
-- 				 data to write, and receiving data.
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
entity spi_interface is
	port ( send_data : in std_logic_vector(7 downto 0);
			 begin_transmission : in std_logic;
			 slave_select : in std_logic;
			 miso : in std_logic;
			 clk : in std_logic;
			 rst : in std_logic;
			 end_transmission : out std_logic;
			 mosi : out std_logic;
			 sclk : out std_logic);
end spi_interface;

architecture Behavioral of spi_interface is


-- *******************************************************************************
--  									Signals and Constants
-- *******************************************************************************

	-- Toggle sclk when count reaches SPI_CLK_COUNT_MAX
	signal spi_clk_count : std_logic_vector(11 downto 0);
	-- Amount to divide 100 Mhz onboard clock by
	constant SPI_CLK_COUNT_MAX : std_logic_vector(11 downto 0) := X"1F4";	-- 500
	-- Leads sclk_previous to detect rising/falling edges for data read/write
	signal sclk_buffer : std_logic;
	signal sclk_previous : std_logic;
	-- The number of data bits sent/received during data transmission
	signal rx_count : std_logic_vector(3 downto 0);
	-- Determines the number of bits to send/receive
	constant RX_COUNT_MAX : std_logic_vector(3 downto 0) := X"8";
	-- Holds the data being sent/received
	signal shift_register : std_logic_vector(7 downto 0);

	-- SPI Interface FSM States
	type RxTxTYPE is (idle , rx_tx , hold);
	signal RxTxSTATE : RxTxTYPE;


-- *******************************************************************************
--  										Implementation
-- *******************************************************************************
begin

	-- Assign SPI Clock Signal
	sclk <= sclk_previous;

	-- SPI Interface FSM, operates in SPI mode3
	tx_rx_process : process( clk ) begin
	if rising_edge( clk ) then
		-- Reset
		if rst = '1' then 
			mosi <= '1';
			RxTxSTATE <= idle;
			--recieved_data <= ( others => '0' );
			shift_register <= ( others => '0' );
			end_transmission <= '0';
		else
			case RxTxSTATE is

				-- Idle state
				when idle =>
				end_transmission <= '0';
					if begin_transmission = '1' then
						RxTxSTATE <= rx_tx;
						rx_count <= ( others => '0' );
						shift_register <= send_data;
					end if;

				-- rx_tx state
				when rx_tx =>
					if rx_count < RX_COUNT_MAX then
						--send bit
						if sclk_previous = '1' and sclk_buffer = '0' then
							mosi <= shift_register(7);
						--recieve bit
						elsif sclk_previous = '0' and sclk_buffer = '1' then
							shift_register(7 downto 1) <= shift_register(6 downto 0) ;
							shift_register(0) <= miso;
							rx_count <= rx_count + 1;
						end if;
					else 
						RxTxSTATE <= hold;
						end_transmission <='1';
					end if;

				-- Hold state
				when hold =>
					end_transmission <= '0';
					if slave_select = '1' then
						mosi <= '1';
						RxTxSTATE <= idle;
					elsif begin_transmission = '1' then
						RxTxSTATE <= rx_tx;
						rx_count <= ( others => '0' );
						shift_register <= send_data;
					end if;

				-- When signals indicate an invalid state
				when others =>
					null;
			end case;
		end if;
	end if;
	end process;
	-- End SPI Interface FSM

	-- SPI Clock Generator
	spi_clk_generation : process( clk ) begin
	if rising_edge( clk ) then 
		-- Reset
		if rst = '1' then
			sclk_previous <= '1';
			sclk_buffer <= '0';
			spi_clk_count <= ( others => '0' );
		
		-- If in the transmission state
		elsif RxTxSTATE = rx_tx then
			if spi_clk_count = SPI_CLK_COUNT_MAX then
				sclk_buffer <= not sclk_buffer;
				spi_clk_count <= ( others => '0' );
			else
				sclk_previous <= sclk_buffer;
				spi_clk_count <= spi_clk_count + 1;
			end if;
	   -- Not in transmission state, do not generate serial clock signal
		else 
			sclk_previous <= '1';
		end if;
	end if;
	end process;
	-- End SPI Clock Generator

end Behavioral;

