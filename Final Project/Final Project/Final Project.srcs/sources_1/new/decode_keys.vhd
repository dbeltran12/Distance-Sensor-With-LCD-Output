-------------------------------------------------------------------------------
-- Title      : ECE 524L Lab 8
-- Project    : 
-------------------------------------------------------------------------------
-- File       : decode_keys.vhd
-- Author     : Daniel Beltran
-- Company    : CSUN
-- Created    : 2024-11-13
-- Last update: 2024-11-13
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity decode_keys is
    Port (
        clk         : in std_logic;
        reset       : in std_logic;
        keys        : in std_logic_vector(0 to 15);
        key_data    : out integer range 0 to 15
    );
end decode_keys;

architecture Behavioral of decode_keys is

begin
    determine_keys:process (clk)
    begin
        if(reset = '1') then
            key_data <= 0;
        elsif(rising_edge(clk)) then
            --All values of keys are checked to determine which key was pressed
            loop_keys : for i in 0 to 15 loop
                if(keys(i) = '1') then
                    key_data <= i;
                end if;
            end loop;
        end if;
    end process;
end Behavioral;
