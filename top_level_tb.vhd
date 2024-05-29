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
    sci_tx_ext_port : out std_logic; 
    receive_en_ext_port : out std_logic;
    transmit_en_ext_port : out std_logic);
end component;

-- Inputs
signal clk      : std_logic := '0';
signal sci_data     : std_logic := '1'; 

-- Outputs
signal tx       : std_logic;
signal tx_done : std_logic;

-- Clock period definitions
constant clk_period : time := 10 ns;  -- Assuming a 10 MHz clock
constant SCI_BAUD_PERIOD : integer := 10416;
signal data : std_logic_vector(57 downto 0) := (others => '1');
type my_array is array (0 to 23) of std_logic_vector(7 downto 0);
signal test_case_id : integer := 0;
signal test_case : my_array := (
    "01000001",--a
    "01001000",--h
    "01001011", --k
    "01001001",--i
    "01000100",--d
    "01000001",--a
    "01010010",--r
    "00100000",--space
    "01000011",--c
    "01001111",--o
    "01001100",--l
    "01001100",--l
    "01001001",--i
    "01001110",--n
    "00100000",--space
    "01010000",--p
    "01001100",--l
    "01000001",--a
    "01011001",--y
    "00100000",--space
    "01000010",--b
    "01000001",--a
    "01001100",--l
    "01001100");--l
    
    
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
        wait for 1000 * clk_period;
        data <= "1111101000001010001100101000110010100011001010001100101111";
        wait for 5 * clk_period; 
        for i in 57 downto 0 loop
            sci_data <= data(i); 
            wait for SCI_BAUD_PERIOD * clk_period; 
        end loop;
        wait;
    end process; 

END testbench;