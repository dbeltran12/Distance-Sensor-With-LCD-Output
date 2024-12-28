-------------------------------------------------------------------------------
-- Title      : ECE 524L Homework 5
-- Project    : 
-------------------------------------------------------------------------------
-- File       : testing_pkg.vhd
-- Author     : Daniel Beltran
-- Company    : CSUN
-- Created    : 2024-10-3
-- Last update: 2024-10-3
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use std.env.finish;

package testing_pkg is
    shared variable pass_fail       : boolean;
    shared variable tests_failed    : natural;
    shared variable tests_passed    : natural;
    shared variable tests_ran       : natural;
    shared variable tests_to_run    : natural;
    shared variable period          : time;

    procedure print(msg : string);

    procedure create_clock(signal clk : out std_logic; constant frequency : real);

    procedure reset_pulse(signal reset : out std_logic);

    procedure start_tests(constant tests : natural);

    procedure end_tests(constant value : natural);

    procedure compare(constant str : string; --Provides info to print when test passes or fails
                      constant loud_pass : boolean; --If true, a loud pass will be displays. If false, no pass statement will print
                      constant expected : std_logic_vector (7 downto 0);  -- Expected value
                      constant measured : std_logic_vector (7 downto 0)); -- Measured value
    procedure compare_bit(constant str : string; 
                      constant loud_pass : boolean; 
                      constant expected : std_logic;
                      constant measured : std_logic);
    procedure write_sram(
        signal clk       : in  std_logic;
        signal ena       : out std_logic;
        signal wea       : out std_logic_vector(0 downto 0);
        signal addra     : out std_logic_vector(3 downto 0);
        signal dina      : out std_logic_vector(15 downto 0);
        constant address : in  std_logic_vector(3 downto 0);
        constant data    : in  std_logic_vector(15 downto 0));

    procedure read_sram(
        signal clk       : in  std_logic;
        signal ena       : out std_logic;
        signal wea       : out std_logic_vector(0 downto 0);
        signal addra     : out std_logic_vector(3 downto 0);
        signal douta     : in  std_logic_vector(15 downto 0);
        constant address : in  std_logic_vector(3 downto 0);
        signal data      : out std_logic_vector(15 downto 0));
end testing_pkg;

package body testing_pkg is
--==============================================================================
--     Prints "msg" on a new line in editor terminal
--     Source: https://vhdlwhiz.com/define-and-print-multiline-string-literals-in-vhdl/
--==============================================================================
    procedure print(msg : string) is
        variable l : line;
    begin
        write(l, msg);
        writeline(output, l);
    end procedure;
     
--==============================================================================
--  Outputs a clock at the given frequency
--==============================================================================
    procedure create_clock(signal clk : out std_logic; constant frequency : real) is
    begin 
        period := 1 sec / frequency;
        loop
            clk <= '1';
            wait for period/2;
            clk <= '0';
            wait for period/2;
        end loop;
    end procedure;

--==============================================================================
--  Toggles a reset pulse for 3 clock cycles
--==============================================================================
    procedure reset_pulse(signal reset : out std_logic) is
    begin
        reset <= '1';
        wait for 50 ns;
        reset <= '0';
    end procedure;

--==============================================================================
--  Starts testing and sets shared variables
--==============================================================================
    procedure start_tests(constant tests : natural) is
    begin
        tests_to_run := tests;
        pass_fail := true;
        tests_ran := 0;
        tests_failed := 0;
        tests_passed := 0;
        print("TESTING STARTED");
        print("=======================================================================");

    end procedure;

--==============================================================================
--  Ends testing and Prints overall pass and fail information
--==============================================================================
    procedure end_tests(constant value : natural) is
    begin
        if(pass_fail = false) then
            print("TEST FAILED");
            print("Number of tests failed: " & to_string(tests_failed));
        elsif(tests_ran /= tests_to_run) then
            print("TEST FAILED");
            print("Number of tests expected: " & to_string(tests_to_run));
            print("Number of tests ran: " & to_string(tests_ran));
        else
            print("TEST PASSED");
            print("Number of tests passed: " & to_string(tests_passed));
        end if;
        finish;
    end procedure;
--==============================================================================
--  Compares expected and measured values then determines whether it is a pass of fail
--==============================================================================
    procedure compare_bit(constant str : string; 
                      constant loud_pass : boolean; 
                      constant expected : std_logic;
                      constant measured : std_logic) is 
    begin
        if(expected /= measured) then
            pass_fail := false;
            tests_failed := tests_failed + 1;
            print(str & " | FAILED | Expected: " & to_string(expected) & " | Measured: " & to_string(measured));
        elsif(loud_pass = true and expected = measured) then
            print(str & " | PASSED | Expected: " & to_string(expected) & " | Measured: " & to_string(measured));
            tests_passed := tests_passed + 1;
        else 
            tests_passed := tests_passed + 1;
        end if;
        tests_ran := tests_ran + 1;
    end procedure;
--==============================================================================
--  Compares expected and measured values then determines whether it is a pass of fail
--==============================================================================
    procedure compare(constant str : string; 
                      constant loud_pass : boolean; 
                      constant expected : std_logic_vector (7 downto 0);
                      constant measured : std_logic_vector (7 downto 0)) is 
    begin
        if(expected /= measured) then
            pass_fail := false;
            tests_failed := tests_failed + 1;
            print(str & " | FAILED | Expected: " & to_hstring(expected) & " | Measured: " & to_hstring(measured));
        elsif(loud_pass = true and expected = measured) then
            print(str & " | PASSED | Expected: " & to_hstring(expected) & " | Measured: " & to_hstring(measured));
            tests_passed := tests_passed + 1;
        else 
            tests_passed := tests_passed + 1;
        end if;
        tests_ran := tests_ran + 1;
    end procedure;

--==============================================================================
--  Writes Values to memory at the given address
--  Source: Professor Tracton's 420 Example Code
--==============================================================================
  procedure write_sram(
    signal clk       : in  std_logic;
    signal ena       : out std_logic;
    signal wea       : out std_logic_vector(0 downto 0);
    signal addra     : out std_logic_vector(3 downto 0);
    signal dina      : out std_logic_vector(15 downto 0);
    constant address : in  std_logic_vector(3 downto 0);
    constant data    : in  std_logic_vector(15 downto 0))
  is
  begin

    wait until rising_edge(clk);
    ena   <= '1';
    wea   <= "1";
    addra <= address;
    dina  <= data;
    wait until rising_edge(clk);
    ena   <= '0';
    wea   <= "0";
  --addra <= (others => '0');
  --dina  <= (others => '0');
  end procedure;

--==============================================================================
--  Read Values from memory at the given address
--  Source: Professor Tracton's 420 Example Code
--==============================================================================
  procedure read_sram(
    signal clk       : in  std_logic;
    signal ena       : out std_logic;
    signal wea       : out std_logic_vector(0 downto 0);
    signal addra     : out std_logic_vector(3 downto 0);
    signal douta     : in  std_logic_vector(15 downto 0);
    constant address : in  std_logic_vector(3 downto 0);
    signal data      : out std_logic_vector(15 downto 0)
    ) is
  begin

    wait until rising_edge(clk);
    ena   <= '1';
    wea   <= "0";
    addra <= address;
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);    
    ena   <= '0';
    wea   <= "0";
    data  <= douta;

  end procedure;

end testing_pkg;
