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

entity top_level_inv_tb is
end top_level_inv_tb;

architecture testbench of top_level_inv_tb is

-- Component Declaration for the Unit Under Test (UUT)
component top_level_inv
port(
    clk_ext_port        : in  std_logic;
    morse_data_ext_port : in  std_logic;
    rx_tx_sw_ext_port   : in  std_logic;
    
    sci_tx_ext_port   : out  std_logic;
    sci_tx_done_ext_port  : out std_logic;
    morse_tx_ext_port : out std_logic; 
    receive_en_ext_port : out std_logic;
    transmit_en_ext_port : out std_logic);
end component;

-- Inputs
signal clk      : std_logic := '0';
signal morse_data     : std_logic := '1'; 
signal rx_tx_switch : std_logic := '0';

-- Outputs
signal tx       : std_logic;
signal tx_done : std_logic;

-- Clock period definitions
constant clk_period : time := 10 ns;  -- Assuming a 10 MHz clock
constant MORSE_BAUD_PERIOD : integer := 10416;
signal data : std_logic_vector(49 downto 0) := (others => '0');
    
    
begin

    -- Instantiate the Unit Under Test (UUT)
    uut: top_level_inv port map (
        clk_ext_port => clk,
        morse_data_ext_port => morse_data,
        rx_tx_sw_ext_port => rx_tx_switch,
        sci_tx_ext_port => tx,
        sci_tx_done_ext_port => tx_done);
		
    -- Clock process definitions
    clk_process : process
    begin
        clk <= not clk;
        wait for clk_period/2;
    end process;
    
    data_send_process : process
    begin
        wait for 1000 * clk_period;
        data <= "00001011100011101010100000001110101110100000000000";
        wait for 5 * clk_period; 
        for i in 49 downto 0 loop
            morse_data <= data(i); 
            wait for MORSE_BAUD_PERIOD * clk_period; 
        end loop;
        wait for 100 * clk_period;
        rx_tx_switch <= '1'; 
        wait;
    end process; 

END testbench;