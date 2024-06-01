----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek and Collin Kuester
-- Module Name: MorseTx - TestBench
-- Project Name: Morse Code Converter 
-- Target Device: Basys 3
-- Description: Morse Transmitter 
----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Morse_TX_ROM_tb IS
END Morse_TX_ROM_tb;

ARCHITECTURE testbench OF Morse_TX_ROM_tb IS

---------------------------
--Component Declaration
---------------------------
    COMPONENT Morse_Tx_ROM
    generic(
        BAUD_PERIOD : integer);
    PORT(
        data_in : in std_logic_vector(7 downto 0);
        transmit_en : in std_logic; 
        queue_empty: in std_logic; 
        clk : in STD_Logic;
        tx: out std_logic;
        tx_done: out std_logic; 
        new_symbol: out std_logic);
    END COMPONENT;
    
---------------------------
--Inputs
---------------------------
    signal clk     : std_logic := '0';
    signal transmit_en : std_logic := '0';
    signal Data_in : std_logic_vector(7 downto 0) := (others => '0');
    signal empty    : std_logic := '0';

---------------------------
--Outputs
---------------------------
    signal Tx      : std_logic;
    signal tx_done : std_logic; 
    signal new_symbol : std_logic; 

---------------------------
--Clock period definition
---------------------------
    constant clk_period : time := 100 ns; -- 10 MHz
    
---------------------------
--Queue simulation
---------------------------
    signal address : integer := 0; 

BEGIN

---------------------------
--Instantiate uut
---------------------------
    uut: Morse_Tx_ROM 
    generic map (
        BAUD_PERIOD => 400)
    PORT MAP (
        data_in => Data_in,
        transmit_en => transmit_en, 
        queue_empty => empty, 
        clk => clk,
        tx => tx,
        tx_done => tx_done, 
        new_symbol => new_symbol);

---------------------------
--Clock process
---------------------------
    clk_process : process
    begin
        clk <= not clk;
        wait for clk_period/2;
    end process;
    
---------------------------
--Process imitating queue
---------------------------
    queue_process : process(new_symbol)
    begin 
    	if new_symbol = '1' then
        	case address is 	
            	when 0 => 
                	data_in <= "00110000";  -- 0
                    empty <= '0';  
                when 1 => 
                	data_in <= "01000001";  -- A
                    empty <= '0';
                when 2 => 
                	data_in <= "01011010";  -- Z
                    empty <= '1';
                when others => 
                	data_in <= "00000000";
            end case;
            address <= address + 1;
        end if; 
    end process;
    
    

---------------------------
--Stimulus Process
---------------------------
    stim_proc: process
    begin        
        -- Initialize Inputs
        transmit_en <= '0';
        wait for clk_period * 10;
        
        -- Scenario 1: Load data
        transmit_en <= '1';  -- Load the data

        -- Wait for transmission to complete 
        wait for clk_period * 10000;
        wait;
    end process;

END testbench;