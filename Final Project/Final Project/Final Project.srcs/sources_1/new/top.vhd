-------------------------------------------------------------------------------
-- Title      : ECE 524L Final Project
-- Project    : 
-------------------------------------------------------------------------------
-- File       : top.vhd
-- Author     : Daniel Beltran
-- Company    : CSUN
-- Created    : 2024-9-27
-- Last update: 2024-12-6
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;


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
        START_CLS   :in  std_logic; --USED ONLY FOR INITIAL TESTING (Push button 1)
        CLEAR_CLS   :in  std_logic; --USED ONLY FOR INITIAL TESTING (Push button 2)
        --ToF PMOD CONTROL
        SDA         :inout std_logic;
        SCL         :inout std_logic;
        SS_ToF      :out   std_logic;
        IRQ         :in    std_logic;
        
        --KEYPAD CONTROL
        XROWS       : in std_logic_vector(1 to 4);
        XCOLUMNS    : buffer std_logic_vector(1 to 4)

    );
end top;

architecture Behavioral of top is

component ToF_Master is
        generic(sys_clk_freq : INTEGER := 50_000_000);            
        Port(   clk      :in    std_logic;
                reset    :in    std_logic;
                SDA      :inout std_logic;
                SCL      :inout std_logic;
                SS       :out   std_logic;
                IRQ      :in    std_logic;
                start    :out   std_logic;
                clear    :out   std_logic;
                keys     :in    integer;
                data_out :out   integer
                );
    end component;
component system_controller is
    generic (RESET_COUNT : integer := 32
    );
    port(
        clk_in    : in  std_logic;
        reset_in  : in  std_logic;
        clk_out_1 : out std_logic;
        clk_out_2 : out std_logic;
        locked    : out std_logic;
        reset_out : out std_logic
    );
end component;

component pmod_keypad is
  generic(
    clk_freq    : integer := 50_000_000;  --system clock frequency in hz
    stable_time : integer := 10);         --time pressed key must remain stable in ms
  port(
    clk     :  in     std_logic;                           --system clock
    reset_n :  in     std_logic;                           --asynchornous active-low reset
    rows    :  in     std_logic_vector(1 to 4);            --row connections to keypad
    columns :  buffer std_logic_vector(1 to 4) := "1111";  --column connections to keypad
    keys    :  out    std_logic_vector(0 to 15));          --resultant key presses
end component;

component decode_keys is
    Port (
        clk         : in std_logic;
        reset       : in std_logic;
        keys        : in std_logic_vector(0 to 15);
        key_data    : out integer range 0 to 15
    );
end component;

component master_interface
	port (  begin_transmission : out std_logic;
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
	port (  begin_transmission : in std_logic;
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
	port(   sel : in integer range 0 to 33;
		    data_out : out std_logic_vector(7 downto 0));
end component;

	--SIGNALS FOR CLS PMOD
	signal slave_select : std_logic;
	signal begin_transmission : std_logic;
	signal end_transmission : std_logic;
	signal sel : integer range 0 to 33;
	signal temp_data : std_logic_vector(7 downto 0);
	signal send_data : std_logic_vector(7 downto 0);

    --SIGNALS FOR SYSTEM_CONTROLLER
    signal clk_100Mhz    : std_logic;
    signal clk_50MHz    : std_logic;
    signal reset        : std_logic;

    --SIGNALS FOR KEYPAD
    signal keys     : std_logic_vector(0 to 15);
    signal key_data : integer range 0 to 15;

    --SIGNALS FOR ToF PMOD
    signal start    : std_logic;
    signal clear    : std_logic;
    signal ToF_data : integer;
begin

    --INSANTIATE SYSTEM_CONTROLLER TO DEAL WITH THE CLOCK AND RESET
    syscon : system_controller
        generic map(
          RESET_COUNT => 32
        )
        port map (
          clk_in    => XCLK,
          reset_in  => XRESET,
          clk_out_1 => clk_100Mhz,
          clk_out_2 => clk_50Mhz,
          locked    => XLOCKED,
          reset_out => reset
        );    

    --KEYPAD PMOD CONTROLLER
    keypad : pmod_keypad 
        generic map(
          clk_freq    => 100_000_000,
          stable_time => 10
        )
        port map(
          clk       => clk_100Mhz,
          reset_n   => not reset,
          rows      => XROWS,
          columns   => XCOLUMNS,
          keys      => keys 
        );

    --DECODES KEYPAD PRESSES
    decode: decode_keys
        port map(
            clk      => clk_100Mhz,
            reset    => reset,
            keys     => keys,
            key_data => key_data
        );

	-- Produces signals for controlling SPI interface, and selecting output data.
	lcd: master_interface 
        port map( 
			begin_transmission => begin_transmission,
			end_transmission => end_transmission,
			clk => clk_100Mhz,
			rst => reset,
			start => start,
			clear => clear,
			slave_select => slave_select,
			temp_data => temp_data,
			send_data => send_data,
			sel => sel
	    );

	-- Interface between the PmodCLS and FPGA, proeduces SCLK signal, etc.
	spi : spi_interface 
        port map(
			begin_transmission => begin_transmission,
			slave_select => slave_select,
			send_data => send_data,
			--recieved_data => recieved_data,
			miso => MISO,
			clk => clk_100Mhz,
			rst => reset,
			end_transmission => end_transmission,
			mosi => MOSI,
			sclk => SCK
	    );

	-- Contains the ASCII characters for commands
	lookup : command_lookup 
        port map (
			sel => sel,
			data_out => temp_data
	    );
    ToF: ToF_Master
        Port map(
            clk      => clk_50Mhz,
            reset    => reset,
            SDA      => SDA,
            SCL      => SCL,
            SS       => SS_ToF,
            IRQ      => IRQ,
            start    => start,
            clear    => clear,
            keys     => key_data,
            data_out => ToF_data
        );
	--  Active low slave select signal
	SS_CLS <= slave_select;
end Behavioral;
