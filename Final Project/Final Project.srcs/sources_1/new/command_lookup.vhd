
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- *******************************************************************************
--  								Define block inputs and outputs
-- *******************************************************************************
entity command_lookup is
    Port ( sel : in integer range 0 to 33;
		   data_in  : in integer range 0 to 34;
           data_out : out  STD_LOGIC_VECTOR (7 downto 0));
end command_lookup;

architecture Behavioral of command_lookup is

-- *******************************************************************************
--  								Signals, Constants, and Types
-- *******************************************************************************

	-- Define data type to hold bytes of data to be written to PmodCLS
	type LOOKUP is array ( 0 to 10 ) of std_logic_vector (7 downto 0);
	type ASCII is array(0 to 34) of std_logic_vector(15 downto 0);
	-- Hexadecimal values below represent ASCII characters
	signal command : LOOKUP  := (  X"1B",
											X"5B",
											X"6A",
											X"1B",
											X"5B",
											X"30",
											X"3B",
											X"33",
											X"48",
											X"30",
											X"30");
	constant ascii_table : ASCII	:= (X"3030",
										X"3031",
										X"3032",
										X"3033",
										X"3034",
										X"3035",
										X"3036",
										X"3037",
										X"3038",
										X"3039",
										X"3130",
										X"3131",
										X"3132",
										X"3133",
										X"3134",
										X"3135",
										X"3136",
										X"3137",
										X"3138",
										X"3139",
										X"3230",
										X"3231",
										X"3232",
										X"3233",
										X"3234",
										X"3235",
										X"3236",
										X"3237",
										X"3238",
										X"3239",
										X"3330",
										X"3331",
										X"3332",
										X"3333",
										X"3334");
-- *******************************************************************************
--  										Implementation
-- *******************************************************************************
begin
	command(9) <= ascii_table(data_in)(15 downto 8);
	command(10) <= ascii_table(data_in)(7 downto 0);
	-- Assign byte to output
	data_out <= command( sel );

end Behavioral;

