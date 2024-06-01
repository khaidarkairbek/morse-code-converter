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

ENTITY Sci_RX_tb IS
END Sci_RX_tb;

ARCHITECTURE testbench OF Sci_RX_tb IS 

---------------------------
--Component declaration for uut
---------------------------
    COMPONENT Sci_RX
    generic(
        BAUD_PERIOD : integer);
    PORT(
        receive_en : in std_logic; 
        clk : in STD_Logic;
        rx : in std_logic;
        sci_ready : out std_logic;
        sci_output : out std_logic_vector(7 downto 0));
    END COMPONENT;
    
---------------------------
--Inputs
---------------------------
    signal clk : std_logic := '0';
    signal rx : std_logic := '1';
    signal receive_en : std_logic := '0';

---------------------------
--Outputs
---------------------------
    signal sci_output      : std_logic_vector(7 downto 0);
    signal sci_ready       : std_logic;

---------------------------
--Clock period definitions
---------------------------
    constant clk_period : time := 100 ns; -- 10 MHz

BEGIN

---------------------------
--Instantiate uut
---------------------------
    uut: Sci_RX 
    generic map(
    BAUD_PERIOD => 392)
    PORT MAP (
        receive_en => receive_en,
        rx => rx,
        sci_output => sci_output, 
        sci_ready => sci_ready, 
        clk => clk);

---------------------------
--Clock process
---------------------------
    clk_process :process
    begin
        clk <= not clk;
        wait for clk_period/2;
    end process;

---------------------------
--Stimulus process
---------------------------
    stim_proc: process
    begin        
        -- Initialize Inputs
        rx <= '1';
        receive_en <= '1'; 
        wait for clk_period * 1000;
        
        rx <= '0'; 
        wait for clk_period * 392; 
        
        rx <= '1'; 
        wait for clk_period * 3 * 392; 
        
        rx <= '0'; 
        wait for clk_period * 2 * 392; 
        
        rx <= '1'; 
        wait for clk_period * 3 * 392;
        
        rx <= '1'; 
        wait for clk_period * 392;
        
        rx <= '1';
        wait for clk_period * 50;
        
        receive_en <= '0';     -- no signal should be received after
        wait for clk_period * 100;
        
        rx <= '0'; 
        wait for clk_period * 392; 
        
        rx <= '1'; 
        wait for clk_period * 3 * 392; 
        
        rx <= '0'; 
        wait for clk_period * 2 * 392; 
        
        rx <= '1'; 
        wait for clk_period * 3 * 392;
        
        rx <= '1'; 
        wait for clk_period * 392;
        
        rx <= '1';
        wait;
        
    end process;

END testbench;