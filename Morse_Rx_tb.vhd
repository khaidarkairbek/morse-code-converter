----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek and Collin Kuester
-- Module Name: Sci_Receiver - Testbench
-- Project Name: Morse Code Converter 
-- Target Device: Basys 3
-- Description: SCI Receiver
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Morse_RX_tb IS
END Morse_RX_tb;

ARCHITECTURE testbench OF Morse_RX_tb IS 

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT Morse_RX
    generic(
        BAUD_PERIOD : integer);
    PORT(
        --receive_en : in std_logic;
        clk : in STD_Logic;
        rx : in std_logic;
        morse_ready : out std_logic;
        morse_output : out std_logic_vector(21 downto 0));
    END COMPONENT;
    
    --Inputs
    signal clk : std_logic := '0';
    signal rx : std_logic := '1';

    --Outputs
    signal morse_output      : std_logic_vector(21 downto 0);
    signal morse_ready       : std_logic;

    -- Clock period definitions
    constant clk_period : time := 100 ns; -- 10 MHz

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: Morse_RX 
    generic map(
    BAUD_PERIOD => 392)
    PORT MAP (
        rx => rx,
        morse_output => morse_output, 
        morse_ready => morse_ready, 
        clk => clk);

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin        
        -- Initialize Inputs
        rx <= '0';
        wait for clk_period * 1000; 
        
        rx <= '0'; 
        wait for clk_period * 1 * 392; 
        
        rx <= '1'; 
        wait for clk_period * 3 * 392; 
        
        rx <= '0'; 
        wait for clk_period * 1 * 392; 
        
        rx <= '1'; 
        wait for clk_period * 3 * 392;
        
        rx <= '0'; 
        wait for clk_period * 1 * 392; 
        
        rx <= '1'; 
        wait for clk_period * 3 * 392;
        
        rx <= '0'; 
        wait for clk_period * 1 * 392; 
        
        rx <= '1'; 
        wait for clk_period * 3 * 392;
        
        rx <= '0'; 
        wait for clk_period * 1 * 392; 
        
        rx <= '1'; 
        wait for clk_period * 3 * 392;
        
        rx <= '0';
        wait;
        
    end process;

END testbench;