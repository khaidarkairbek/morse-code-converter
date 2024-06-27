----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek and Collin Kuester
-- Module Name: Morse_Rx - Behavioral
-- Project Name: Morse Code Converter 
-- Target Device: Basys 3
-- Description: Morse Receiver
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Morse_RX is
  generic(
    BAUD_PERIOD : integer);
  Port ( 
    receive_en : in std_logic; 
  	clk : in STD_Logic;
  	rx : in std_logic;
    morse_ready : out std_logic;
    morse_output : out std_logic_vector(21 downto 0));
end Morse_RX;

architecture Behavioral of Morse_RX is
---------------------------
--FSM States
---------------------------
type state_type is (Idle, Shift, Ready, CheckSpace, SpaceReady, NotLegit, ClearReg);
signal CS, NS : State_type := Idle;

---------------------------
--FSM Control Signals
---------------------------
signal baud_cnt_en : std_logic := '0';
Signal bit_cnt_en : std_logic := '0';
signal zero_cnt_en : std_logic := '0';
signal reg_clr : std_logic := '0';
signal bit_cnt_clr : std_logic := '0';

---------------------------
--Datapath Signals
---------------------------
constant HALF_BAUD_PERIOD : integer := BAUD_PERIOD / 2;
signal baud_cnt: integer := 0;
signal baud_tc : std_logic := '0';
signal half_baud_tc : std_logic := '0';
signal bit_tc : std_logic := '0'; 
signal not_legit_tc : std_logic := '0';
signal zero_cnt : integer := 0;
signal two_zero_tc : std_logic := '0'; 
signal three_zero_tc : std_logic := '0'; 
signal seven_zero_tc  : std_logic := '0';
signal bit_cnt : integer := 0;
signal data_register : std_logic_vector(21 downto 0) := (others => '0');

begin
---------------------------
--Baud Counter
---------------------------
baud_counter: process(clk, baud_cnt)
begin
	if rising_edge(clk) then
    	if baud_cnt_en = '1' then 
        	baud_cnt <= baud_cnt + 1;
        end if; 
        if baud_tc = '1' or baud_cnt_en = '0' then   --resets the count when tc
            baud_cnt <= 0;
        end if;
    end if; 
    
    --asynchronous TC
    baud_tc <= '0';
    if baud_cnt = BAUD_PERIOD-1 then
        baud_tc <= '1';
    end if;
    
    half_baud_tc <= '0'; 
    if baud_cnt = HALF_BAUD_PERIOD - 1 then 
    	half_baud_tc <= '1'; 
    end if;
end process; 

---------------------------
--Bit counter
---------------------------
bit_counter: process(clk, bit_cnt)
begin
	if rising_edge(clk) then
    	if bit_cnt_en = '1' and half_baud_tc = '1' then 
        	bit_cnt <= bit_cnt + 1; 
        end if;
        
        if bit_cnt_clr = '1' or not_legit_tc = '1' then 
        	bit_cnt <= 0;
        end if; 
    end if; 
    
    -- asynchronous bit count TC
    not_legit_tc <= '0'; 
    if bit_cnt = 23 then 
    	not_legit_tc <= '1'; 
    end if;
end process;

---------------------------
--Zero Counter
---------------------------
zero_counter: process(clk, zero_cnt)
begin
	if rising_edge(clk) then
    	if zero_cnt_en = '1' and half_baud_tc = '1' then 
        	zero_cnt <= zero_cnt + 1; 
        end if;
        
        if rx = '1' then 
        	zero_cnt <= 0;
        end if; 
    end if; 
    
    -- asynchronous zero coumt TCs
    two_zero_tc <= '0'; 
    if zero_cnt = 2 then 
    	two_zero_tc <= '1'; 
    end if;

    three_zero_tc <= '0'; 
    if zero_cnt = 3 then 
    	three_zero_tc <= '1'; 
    end if;

    seven_zero_tc <= '0'; 
    if zero_cnt = 7 then 
    	seven_zero_tc <= '1'; 
    end if;

end process;
---------------------------
--Shift Register
---------------------------
shift_register: process(clk)
begin
    if rising_edge(clk) then 
        if half_baud_tc = '1' and bit_cnt_en = '1' then 
            data_register <= data_register(20 downto 0) & rx; 
        end if;

        if reg_clr = '1' then 
            data_register <= (others => '0');
        end if; 
    end if; 
end process;

morse_output <= data_register;

----------------------------------------
--FSM Logic 
----------------------------------------

state_update : process(clk)
begin
    if (rising_edge(clk)) then
        CS <= NS;
    end if;
end process;

NS_Logic : process(CS, receive_en, rx, three_zero_tc, two_zero_tc, not_legit_tc, seven_zero_tc)
begin
    NS <= CS; 
    case CS is 
        when Idle => 
            if receive_en = '1' and rx = '1' then
                NS <= Shift;
            end if;
        when Shift =>
			if receive_en = '1' then 
				if three_zero_tc = '1' then 
					NS <= Ready;
				elsif (two_zero_tc = '1' and rx = '1') or (not_legit_tc = '1') then
					NS <= NotLegit;
				end if;
			else NS <= Idle; 
			end if;
        when Ready =>
            if seven_zero_tc = '1' or rx = '1' then  
                NS <= ClearReg; 
            end if;
        when ClearReg => 
            if seven_zero_tc = '1' then 
                NS <= CheckSpace;
            else NS <= Idle;
            end if; 
        when CheckSpace => 
            if seven_zero_tc = '0' then 
                NS <= Idle;
            elsif rx = '1' then 
                NS <= SpaceReady;
            end if;
        when SpaceReady =>
            NS <= Idle; 
        when NotLegit => 
            NS <= ClearReg; 
        when Others =>
        	NS <= Idle;
        end case;
end process;


Output_Logic : Process(CS)
begin
    bit_cnt_clr <= '0'; 
    zero_cnt_en <= '0'; 
    baud_cnt_en <= '0';
    bit_cnt_en <= '0';
    morse_ready <= '0';
    reg_clr <= '0';
    case CS is 
        when Idle => 
            bit_cnt_clr <= '1';
        when Shift =>
            baud_cnt_en <= '1';
            bit_cnt_en <= '1';
            zero_cnt_en <= '1';
        when Ready => 
            morse_ready <= '1'; 
            zero_cnt_en <= '1'; 
            baud_cnt_en <= '1';
            bit_cnt_en <=  '1';
        when CheckSpace => 
            zero_cnt_en <= '1';
            baud_cnt_en <= '1';
        when SpaceReady => 
            morse_ready <= '1'; 
        when NotLegit => null;
        when ClearReg => 
             reg_clr <= '1';
             baud_cnt_en <= '1';
        when Others => null;
    end case;
end process;    

end Behavioral;