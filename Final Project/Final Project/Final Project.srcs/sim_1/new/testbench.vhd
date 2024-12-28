----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/06/2024 09:25:17 PM
-- Design Name: 
-- Module Name: testbench - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.testing_pkg.all;

entity testbench is
--  Port ( );
end testbench;

architecture Behavioral of testbench is
    component top is
    Port (
        XCLK        : in  std_logic;
        XLOCKED     : out std_logic;
        XRESET      : in  std_logic;
        --CLS PMOD CONTROL
        SS_CLS      :out std_logic;
        MOSI        :out std_logic;
        MISO        :in  std_logic;
        SCK         :out std_logic;
        --ToF PMOD CONTROL
        SDA         :inout std_logic;
        SCL         :inout std_logic;
        SS_ToF      :out   std_logic;
        IRQ         :in    std_logic
    );
    end component;
    signal clk_tb    : std_logic;
    signal locked_tb : std_logic;
    signal reset_tb  : std_logic;
    signal ss_cls_tb : std_logic;
    signal mosi_tb   : std_logic;
    signal miso_tb   : std_logic;
    signal sck_tb    : std_logic;
    signal sda_tb    : std_logic;
    signal scl_tb    : std_logic;
    signal ss_tof_tb : std_logic;
    signal irq_tb    : std_logic;

    
begin

dut: top
    Port map(
        XCLK      => clk_tb,   
        XLOCKED   => locked_tb,
        XRESET    => reset_tb, 
        SS_CLS    => ss_cls_tb,
        MOSI      => mosi_tb,  
        MISO      => miso_tb,  
        SCK       => sck_tb,   
        SDA       => sda_tb,  
        SCL       => scl_tb,   
        SS_ToF    => ss_tof_tb,
        IRQ       => irq_tb   
        );

    create_clock(clk_tb, 125.0e6);

    process
    begin
        reset_pulse(reset_tb);
        wait for 100 ms;
        end_tests(0);
    end process;
end Behavioral;
