----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek and Collin Kuester
-- Module Name: PWM_Audio_Generator - Behavioral
-- Project Name: Morse Code Converter 
-- Target Device: Basys 3
-- Description: Generates PWM Audio Signal
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


use IEEE.NUMERIC_STD.ALL;

entity PWM_Audio_Generator is
  generic(
    AUDIO_SAMPLE_RATE	: integer;
	PWM_TC				: unsigned(7 downto 0));
  Port ( 
    audio_signal : in std_logic; 
  	clk : in STD_Logic;
    pwm_audio_signal : out std_logic);
end PWM_Audio_Generator;

architecture Behavioral of PWM_Audio_Generator is
-- FSM states 
type state_type is (Idle, PWMOn, PWMOff);
signal CS, NS : State_type := Idle;

-- FSM Control Signlas
signal pwm_cnt_en : std_logic := '0';

-- Datapath signals
signal baud_cnt: integer := 0;
signal baud_tc : std_logic := '0';
signal pwm_cnt : unsigned(7 downto 0) := (others => '0');
signal pwm_on_tc : std_logic := '0'; 
signal pwm_off_tc : std_logic := '0';

begin

baud_counter: process(clk, baud_cnt)
begin
	if rising_edge(clk) then
    	if pwm_cnt_en = '1' then 
        	baud_cnt <= baud_cnt + 1;
        end if; 
        if baud_tc = '1' or pwm_cnt_en = '0' then   --resets the count when tc
            baud_cnt <= 0;
        end if;
    end if; 
    
    --asynchronous TC
    baud_tc <= '0';
    if baud_cnt = (AUDIO_SAMPLE_RATE-1)/256 then
        baud_tc <= '1';
    end if;
end process; 

pwm_counter: process(clk, pwm_cnt)
begin
	if rising_edge(clk) then
    	if pwm_cnt_en = '1' and baud_tc = '1' then 
        	pwm_cnt <= pwm_cnt + 1; 
        end if;
        
        if pwm_cnt_en = '0' or pwm_off_tc = '1' then 
        	pwm_cnt <= (others => '0');
        end if; 
    end if; 
    
    -- asynchronous bit count TC
    pwm_on_tc <= '0'; 
    if pwm_cnt = PWM_TC - 1 then 
    	pwm_on_tc <= '1'; 
    end if;
	
	pwm_off_tc <= '0';
	if pwm_cnt = 255 then 
    	pwm_off_tc <= '1'; 
    end if;
	
end process;

----------------------------------------
--FSM Logic 
----------------------------------------

state_update : process(clk)
begin
    if (rising_edge(clk)) then
        CS <= NS;
    end if;
end process;

NS_Logic : process(CS, audio_signal, pwm_on_tc, pwm_off_tc)
begin
    NS <= CS; 
    case CS is 
        when Idle => 
            if audio_signal = '1' then 
				NS <= PWMOn;
			end if;
		when PWMOn => 
			if audio_signal = '0' then 
				NS <= Idle;
			elsif pwm_on_tc = '1' then 
				NS <= PWMOff;
			end if;
		when PWMOff => 
			if audio_signal = '0' or pwm_off_tc = '1' then 
				NS <= Idle;
			end if;
        when Others =>
        	NS <= Idle;
        end case;
end process;


Output_Logic : Process(CS)
begin
    pwm_cnt_en <= '1';
    pwm_audio_signal <= '0';
    case CS is 
        when Idle => 
            pwm_cnt_en <= '0';
        when PWMOn => 
            pwm_audio_signal <= '1';
        when Others => null;
    end case;
end process;    

end Behavioral;