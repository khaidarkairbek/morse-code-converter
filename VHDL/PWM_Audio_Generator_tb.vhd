----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek and Collin Kuester
-- Module Name: PWM_Audio_Generator - Testbench
-- Project Name: Morse Code Converter 
-- Target Device: Basys 3
-- Description: PWM Audio Generator
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY PWM_Audio_Generator_tb IS
END PWM_Audio_Generator_tb;

ARCHITECTURE testbench OF PWM_Audio_Generator_tb IS 

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT PWM_Audio_Generator
    generic(
        AUDIO_SAMPLE_RATE	: integer;
		PWM_TC				: unsigned(7 downto 0));
    PORT(
        audio_signal : in std_logic; 
		clk : in STD_Logic;
		pwm_audio_signal : out std_logic);
    END COMPONENT;
    
    --Inputs
    signal clk : std_logic := '0';
    signal audio_signal : std_logic := '0';

    --Outputs
    signal pwm_audio_signal      : std_logic;

    -- Clock period definitions
    constant clk_period : time := 100 ns; -- 10 MHz

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: PWM_Audio_Generator 
    generic map(
    AUDIO_SAMPLE_RATE => 51200, 
	PWM_TC => to_unsigned(128, 8))
    PORT MAP (
        audio_signal => audio_signal,
        pwm_audio_signal => pwm_audio_signal, 
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
        wait for 100* clk_period; 
		audio_signal <= '1'; 
		wait for 51200 * clk_period;
		audio_signal <= '0';
		wait for 51200 * clk_period; 
		audio_signal <= '1';
		wait; 
    end process;

END testbench;