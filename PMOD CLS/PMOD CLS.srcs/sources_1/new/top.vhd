-------------------------------------------------------------------------------
-- Title      : ECE 524L PMOD CLS Demo
-- Project    : ECE 524L Final Project
-------------------------------------------------------------------------------
-- File       : top.vhd
-- Author     : Daniel Beltran
-- Company    : CSUN
-- Created    : 2024-9-27
-- Last update: 2024-11-3
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity top is
    Port ( 
        XCLK        : in  std_logic;
        XLOCKED     : out std_logic;
        XRESET      : in  std_logic;

        --CLS PMOD CONTROL
        SS_CLS      :out std_logic;
        MOSI        :out std_logic;
        MISO        :in  std_logic;
        SCK         :out std_logic;
        START_CLS   :in  std_logic;
        CLEAR_CLS   :in  std_logic;
        LED         :out std_logic);
end top;

architecture Behavioral of top is



        component system_controller is
            generic (RESET_COUNT : integer := 32
            );
            port(
                clk_in    : in  std_logic;
                reset_in  : in  std_logic;
                clk_out : out std_logic;
                locked    : out std_logic;
                reset_out : out std_logic
            );
        end component;

		component master_interface
			port ( begin_transmission : out std_logic;
					 end_transmission : in std_logic;
					 clk : in std_logic;
					 rst : in std_logic;
					 start : in std_logic;
					 clear : in std_logic;
					 slave_select : out std_logic;
					 sel : out integer range 0 to 33;
					 temp_data : in std_logic_vector(7 downto 0);
					 send_data : out std_logic_vector(7 downto 0));
		end component;


		component spi_interface
			port ( begin_transmission : in std_logic;
					 slave_select : in std_logic;
					 send_data : in std_logic_vector(7 downto 0);
					 miso : in std_logic;
					 clk : in std_logic;
					 rst : in std_logic;
					 --recieved_data : out std_logic_vector(7 downto 0);
					 end_transmission : out std_logic;
					 mosi : out std_logic;
					 sclk : out std_logic);
		end component;


		component command_lookup
			port( sel : in integer range 0 to 33;
					data_out : out std_logic_vector(7 downto 0));
		end component;



    signal clk    : std_logic;
    signal reset        : std_logic;
	-- Active low signal for writing data to PmodCLS
	signal slave_select : std_logic;
	-- Initializes data transfer with PmodCLS
	signal begin_transmission : std_logic;
	-- Handshake signal to signify data transfer done
	signal end_transmission : std_logic;
	-- Selects which ASCII value to send to PmodCLS
	signal sel : integer range 0 to 33;
	-- Output data from C2 to C0
	signal temp_data : std_logic_vector(7 downto 0);
	-- Output data from C0 to C1
	signal send_data : std_logic_vector(7 downto 0);



begin

        --INSANTIATE SYSTEM_CONTROLLER TO DEAL WITH THE CLOCK AND RESET
        syscon : system_controller
            generic map(
            RESET_COUNT => 32
            )
            port map (
                clk_in    => XCLK,
                reset_in  => XRESET,
                clk_out => clk,
                locked    => XLOCKED,
                reset_out => reset
            );    
	-- Produces signals for controlling SPI interface, and selecting output data.
	lcd: master_interface port map( 
			begin_transmission => begin_transmission,
			end_transmission => end_transmission,
			clk => clk,
			rst => reset,
			start => START_CLS,
			clear => CLEAR_CLS,
			slave_select => slave_select,
			temp_data => temp_data,
			send_data => send_data,
			sel => sel
	);

	-- Interface between the PmodCLS and FPGA, proeduces SCLK signal, etc.
	spi : spi_interface port map(
			begin_transmission => begin_transmission,
			slave_select => slave_select,
			send_data => send_data,
			--recieved_data => recieved_data,
			miso => MISO,
			clk => clk,
			rst => reset,
			end_transmission => end_transmission,
			mosi => MOSI,
			sclk => SCK
	);

	-- Contains the ASCII characters for commands
	lookup : command_lookup port map (
			sel => sel,
			data_out => temp_data
	);

	--  Active low slave select signal
	SS_CLS <= slave_select;
    --  Assign Led<0> the value of SW(0)
	LED <= '1' when SS_CLS = '1' else '0';
end Behavioral;


