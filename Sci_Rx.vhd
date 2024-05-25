----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/22/2024 07:38:14 PM
-- Design Name: 
-- Module Name: Sci_Receiver - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


use IEEE.NUMERIC_STD.ALL;

entity Sci_RX is
  Port ( 
  	clk_port : in STD_Logic;
  	rx : in std_logic;
    sci_ready : out std_logic;
    sci_output : out std_logic_vector(7 downto 0));
end Sci_RX;

architecture Behavioral of Sci_RX is
-- FSM states 
type state_type is (Idle, Shift, Ready);
signal CS, NS : State_type := Idle;

-- FSM Control Signlas
signal Baud_CNT_EN : STD_Logic := '0';
Signal Bit_CNT_en : Std_Logic := '0';

-- Datapath signals
constant BAUD_PERIOD : integer := 392;
constant HALF_BAUD_PERIOD : integer := 196;
signal baud_count: unsigned(8 downto 0) := (others => '0');
signal baud_TC : Std_Logic := '0';
signal half_baud_tc : std_logic := '0';
signal Bit_Tc : Std_Logic := '0';
signal bit_count : integer := 0;
signal data_register : std_logic_vector(9 downto 0) := (others => '0');

begin

baud_counter: process(clk_port, baud_count)
begin
	if rising_edge(clk_port) then
    	if baud_cnt_en = '1' then 
        	baud_count <= baud_count + 1;
        end if; 
        if baud_tc = '1' or baud_cnt_en = '0' then   --resets the count when tc
            baud_count <= (others => '0');
        end if;
    end if; 
    
    --asynchronous TC
    baud_tc <= '0';
    if baud_count = BAUD_PERIOD-1 then
        baud_tc <= '1';
    end if;
    
    half_baud_tc <= '0'; 
    if baud_count = HALF_BAUD_PERIOD - 1 then 
    	half_baud_tc <= '1'; 
    end if;
end process; 

bit_counter: process(clk_port, bit_count)
begin
	if rising_edge(clk_port) then
    	if bit_cnt_en = '1' and half_baud_tc = '1' then 
        	bit_count <= bit_count + 1; 
        end if;
        
        if bit_cnt_en = '0' then 
        	bit_count <= 0;
        end if; 
    end if; 
    
    -- asynchronous bit count TC
    bit_tc <= '0'; 
    if bit_count = 10 then 
    	bit_tc <= '1'; 
    end if;
end process;

shift_register: process(clk_port)
begin
    if rising_edge(clk_port) then 
        if half_baud_tc = '1' then 
            data_register <= data_register(8 downto 0) & rx; 
        end if;
    end if; 
end process;

sci_output <= data_register(8 downto 1);

----------------------------------------
--FSM Logic 
----------------------------------------

state_update : Process(clk_port)
begin
    if rising_edge(clk_port) then
        CS <= NS;
    end if;
end process;

NS_Logic : process(CS, Rx, Bit_Tc)
begin
    case CS is 
        when Idle => 
            if Rx = '0' then
                NS <= Shift;
            end if;
        when Shift =>
            if Bit_TC = '1' then
                NS <= Ready;
            end if;
        when Ready =>
            NS <= Idle;
        when Others =>
        	NS <= Idle;
        end case;
end process;


Output_Logic : Process(CS)
begin
    Baud_CNT_EN <= '0';
    Bit_CNT_en <= '0';
    Sci_ready <= '0';
    case CS is 
        when Ready => 
            Sci_ready <= '1';
        when Shift =>
            Baud_CNT_EN <= '1';
            Bit_CNT_en <= '1';
        when Others => 
    end case;
end process;    

end Behavioral;