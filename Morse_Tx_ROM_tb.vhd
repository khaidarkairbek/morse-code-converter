LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Morse_TX_ROM_tb IS
END Morse_TX_ROM_tb;

ARCHITECTURE testbench OF Morse_TX_ROM_tb IS 

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT Morse_TX_ROM
    PORT(
        data_in : in std_logic_vector(7 downto 0);
        transmit_en : in std_logic; 
        queue_empty: in std_logic; 
        clk : in STD_Logic;
        tx: out std_logic);
    END COMPONENT;
    
    --Inputs
    signal clk     : std_logic := '0';
    signal transmit_en : std_logic := '0';
    signal Data_in : std_logic_vector(7 downto 0) := (others => '0');
    signal empty    : std_logic := '0';

    --Outputs
    signal Tx      : std_logic;

    -- Clock period definitions
    constant clk_period : time := 100 ns; -- 10 MHz

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: Morse_TX_ROM PORT MAP (
        data_in => Data_in,
        transmit_en => transmit_en, 
        queue_empty => empty, 
        clk => clk,
        tx => tx);

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
        transmit_en <= '0';
        data_in <= (others => '0');
        
        wait for clk_period * 10;
        
        -- Scenario 1: Load data "00110000"
        data_in <= "00110000";
        transmit_en <= '1';  -- Load the data

        -- Wait for transmission to complete
        wait for clk_period * 100;
        empty <= '1'; 
        wait for clk_period * 4000;
        wait;
    end process;

END testbench;