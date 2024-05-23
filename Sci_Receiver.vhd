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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Sci_Receiver is
  Port ( clk_port : in STD_Logic);
end Sci_Receiver;

architecture Behavioral of Sci_Receiver is
-- FSM states 
type state_type is (Idle, Shift, Ready);
signal CS, NS : State_type := Idle;

-- FSM Control Signlas
Signal Rx : Std_Logic := '0';
Signal Receive_en : Std_Logic := '0';
Signal Baud_TC : Std_Logic := '0';
signal Baud_CNT_EN : STD_Logic := '0';
-Signal Clr_Baud : Std_Logic := '0';
Signal Bit_Tc : Std_Logic := '0';
Signal Bit_CNT_en : Std_Logic := '0';
--Signal Clr_bit : Std_Logic := '0';
Signal shift_en : Std_Logic := '0';
Signal SCi_ready : Std_Logic := '0';




begin


----------------------------------------
--FSM Logic 
----------------------------------------

state_update : Process(clk_port)
begin
    if rising_edge(clk_port) then
        CS <= NS;
    end if;
end process;

NS_Logic : process(CS, Rx, Shift, Ready, Bit_Tc)
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
            
        end case;
end process;


Output_Logic : Process(clk_port)
begin
    Baud_CNT_EN <= '0';
    Clr_Baud <= '0';
    Bit_CNT_en <= '0';
    Clr_Bit <= '0';
    Sci_ready <= '0';
    case CS is 
        when Idle => 
            --Clr_Baud <= '1';
            --Clr_Bit <= '1';
        when Ready => 
            Sci_ready <= '1';
        when Shift =>
            shift_en <= '1';
            Baud_CNT_EN <= '1';
            Bit_CNT_en <= '1';
        when Others => 
    end case;
end process;    





end Behavioral;
