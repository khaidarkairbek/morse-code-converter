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
    morse_data_ext_port : in  std_logic;
    rx_tx_sw_ext_port   : in  std_logic;
    morse_sci_rx_sw_ext_port : in std_logic; 
    
    morse_tx_ext_port   : out  std_logic;
    morse_tx_done_ext_port  : out std_logic;
    morse_audio_ext_port: out std_logic; 
    sci_tx_osc_port : out std_logic;
	sci_tx_ext_port : out std_logic; 
    sci_tx_done_ext_port : out std_logic;
    morse_tx_osc_port : out std_logic; 
    receive_en_ext_port : out std_logic;
    transmit_en_ext_port : out std_logic);
end component;


-- Device 1 Signals
-- Inputs
signal clk_1      : std_logic := '0';
signal sci_rx_data_1     : std_logic := '1'; 
signal rx_tx_switch_1 : std_logic := '0';
signal device_switch_1 : std_logic := '0'; 
signal morse_rx_data_1 : std_logic := '0'; 
-- Outputs
signal sci_tx_1       : std_logic;
signal morse_tx_1     : std_logic;
signal sci_tx_done_1  : std_logic;
signal morse_tx_done_1 : std_logic;
signal morse_audio_1  : std_logic;

-- Device 2 Signals
-- Inputs
signal clk_2      : std_logic := '0';
signal sci_rx_data_2  : std_logic := '1'; 
signal rx_tx_switch_2 : std_logic := '0';
signal device_switch_2 : std_logic := '0'; 
signal morse_rx_data_2 : std_logic := '0'; 
-- Outputs
signal sci_tx_2       : std_logic;
signal morse_tx_2     : std_logic;
signal sci_tx_done_2  : std_logic;
signal morse_tx_done_2 : std_logic;
signal morse_audio_2  : std_logic;

-- Clock period definitions
constant clk_period : time := 10 ns;  -- Assuming a 10 MHz clock
constant SCI_BAUD_PERIOD : integer := 10416;
constant MORSE_BAUD_PERIOD : integer := 10416;
signal device_2_sci_data : std_logic_vector(57 downto 0) := (others => '1');


begin

    -- Instantiate the Unit Under Test (UUT)
    device1: top_level port map (
        clk_ext_port => clk_1,
        sci_data_ext_port => sci_rx_data_1,
        rx_tx_sw_ext_port => rx_tx_switch_1,
        morse_data_ext_port => morse_rx_data_1,
        morse_sci_rx_sw_ext_port => device_switch_1,
        
        morse_tx_ext_port => morse_tx_1,
        morse_tx_done_ext_port => morse_tx_done_1,
        morse_audio_ext_port => morse_audio_1, 
        sci_tx_ext_port => sci_tx_1,
        sci_tx_done_ext_port => sci_tx_done_1);
        
    device2: top_level port map (
        clk_ext_port => clk_2,
        sci_data_ext_port => sci_rx_data_2,
        rx_tx_sw_ext_port => rx_tx_switch_2,
        morse_data_ext_port => morse_rx_data_2,
        morse_sci_rx_sw_ext_port => device_switch_2,
        
        morse_tx_ext_port => morse_tx_2,
        morse_tx_done_ext_port => morse_tx_done_2,
        morse_audio_ext_port => morse_audio_2, 
        sci_tx_ext_port => sci_tx_2,
        sci_tx_done_ext_port => sci_tx_done_2);
        
    morse_rx_data_1 <= morse_tx_2;  --hardwire device 2's morse output to device 1's morse input

    -- Clock process definitions
    clk_1_process : process
    begin
        clk_1 <= not clk_1;
        wait for clk_period/2;
    end process;
    
    clk_2_process : process(clk_1)
    begin
        clk_2 <= not clk_1;    -- second clock is the inverse of the first one to make tb close to real life, by unsyncing the clocks
    end process;
    
    stim_process : process
    begin
        wait for 50 * clk_period; --initialize the process
        device_switch_1 <= '1';   --first device is morse rx and sci tx
        device_switch_2 <= '0';   -- sercond device is sci rx and morse tx
        
        --sci data for device 2
        device_2_sci_data <= "1111101000001010001100101000110010100011001010001100101111";
        wait for 5 * clk_period;
        for i in 57 downto 0 loop
            sci_rx_data_2 <= device_2_sci_data(i);
            wait for SCI_BAUD_PERIOD * clk_period;
        end loop;
        
        wait for 100 * clk_period;
        rx_tx_switch_2 <= '1'; --transmit morse data from device 2
        
        wait for 100 * MORSE_BAUD_PERIOD * clk_period; -- receive the morse data from device 2 on device 1
        rx_tx_switch_1 <= '1'; -- transmit the sci data from device 1 to device 2
        
        
        wait; 
    end process; 

END testbench;