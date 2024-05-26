LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY top_level_tb IS
END top_level_tb;

ARCHITECTURE testbench OF top_level_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT top_level
    PORT(
        clk_ext_port        : in  std_logic;
        sci_data_ext_port   : in  std_logic;
        morse_tx_ext_port   : out  std_logic;
        morse_tx_done_ext_port  : out std_logic;
    );
    END COMPONENT;

    -- Inputs
    signal clk      : std_logic := '0';
    signal sci_data     : std_logic := '1'; 

    -- Outputs
    signal tx       : std_logic;
    signal tx_done : std_logic;

    -- Clock period definitions
    constant clk_period : time := 100 ns;  -- Assuming a 10 MHz clock
	signal data : std_logic_vector(7 downto 0) := (others => '1');
BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: top_level PORT MAP (
        clk_ext_port => clk,
        sci_data_ext_port => sci_data,
        morse_tx_ext_port => tx,
        morse_tx_done_ext_port => tx_done);

    -- Clock process definitions
    clk_process : process
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
        wait for 10 * clk_period; 
        
        wait for 100 * clk_period; 
        wait for 1000 * clk_period; 
        wait; 
    end process;

END testbench;