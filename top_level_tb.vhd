----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek and Collin Kuester
-- Module Name: Top Level - Testbench
-- Project Name: Morse Code Converter 
-- Target Device: Basys 3
-- Description: Top Level
----------------------------------------------------------------------------------
library ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity top_level_tb is
end top_level_tb;

architecture testbench of top_level_tb is

-- Component Declaration for the Unit Under Test (UUT)
component top_level
port(
    clk_ext_port        : in  std_logic;
    sci_data_ext_port   : in  std_logic;
    morse_tx_ext_port   : out  std_logic;
    morse_tx_done_ext_port  : out std_logic;
);
end component;

-- Inputs
signal clk      : std_logic := '0';
signal sci_data     : std_logic := '1'; 

-- Outputs
signal tx       : std_logic;
signal tx_done : std_logic;

-- Clock period definitions
constant clk_period : time := 100 ns;  -- Assuming a 10 MHz clock
signal data : std_logic_vector(7 downto 0) := (others => '1');
    
    
    
begin

    -- Instantiate the Unit Under Test (UUT)
    uut: top_level port map (
        clk_ext_port => clk,
        sci_data_ext_port => sci_data,
        morse_tx_ext_port => tx,
        morse_tx_done_ext_port => tx_done);

    -- Clock process definitions
    clk_process : process
    begin
        clk <= not clk;
        wait for clk_period/2;
    end process;
    
    data_send_process : process 
    begin 
    	data <= "00110000";
        sci_data <= '0'; 
        wait for 392 * clk_period; 
        sci_data <= data(7);
        wait for 392 * clk_period; 
        sci_data <= data(6);
        wait for 392 * clk_period;
        sci_data <= data(5);
        wait for 392 * clk_period;
        sci_data <= data(4);
        wait for 392 * clk_period;
        sci_data <= data(3);
        wait for 392 * clk_period;
        sci_data <= data(2);
        wait for 392 * clk_period;
        sci_data <= data(1);
        wait for 392 * clk_period;
        sci_data <= data(0);
        wait for 392 * clk_period;
        sci_data <= '1';
        wait for 392 * clk_period;
        wait for 10000 * clk_period;
    end process; 

END testbench;