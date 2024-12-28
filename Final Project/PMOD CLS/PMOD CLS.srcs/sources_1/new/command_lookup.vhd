

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- *******************************************************************************
--  								Define block inputs and outputs
-- *******************************************************************************
entity command_lookup is
    Port ( sel : in integer range 0 to 33;
           data_out : out  STD_LOGIC_VECTOR (7 downto 0));
end command_lookup;

architecture Behavioral of command_lookup is

-- *******************************************************************************
--  								Signals, Constants, and Types
-- *******************************************************************************

	-- Define data type to hold bytes of data to be written to PmodCLS
	type LOOKUP is array ( 0 to 18 ) of std_logic_vector (7 downto 0);

	-- Hexadecimal values below represent ASCII characters
	constant command : LOOKUP  := (  X"1B",
												X"5B",
												X"6A",
												X"1B",
												X"5B",
												X"30",
												X"3B",
												X"33",
												X"48",
												X"48",
												X"65",
												X"6C",
												X"6C",
												X"6F",
												X"57",
												X"6F",
												X"72",
												X"6C",
												X"64",
											);

-- *******************************************************************************
--  										Implementation
-- *******************************************************************************
begin

	-- Assign byte to output
	data_out <= command( sel );

end Behavioral;

