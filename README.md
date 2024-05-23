----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/22/2024 08:37:32 PM
-- Design Name: 
-- Module Name: Transmitter_with_ROM - Behavioral
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

entity Transmitter_with_ROM is
  Port ( clk_port : in STD_Logic);
end Transmitter_with_ROM;

architecture Behavioral of Transmitter_with_ROM is
--FSM states 
type state_type is (Idle, Load, Transmit, Check, Done);
signal CS, NS : State_type := Idle;

--FSM signals 
Signal transmit_en : Std_Logic := '0';
Signal Queue_empty : Std_Logic := '0';
Signal symbol_load : Std_Logic := '0';
signal length_TC : STD_Logic := '0';
Signal Length_cnt_en  : Std_Logic := '0';
Signal Tx_done : Std_Logic := '0';

-- ROM signals 
signal ascii_char : STD_Logic_vector(7 downto 0);
Signal Morse_code : std_logic_vector(19 downto 0);
signal Morse_Code_Length : integer := 0;


begin

-------------------
--FSM LOGIC 
-------------------
state_update : process(clk_port) 
begin 
    if rising_edge(clk_port) then
        NS <= CS;
    end if;
end process;


NS_Logic : process(CS, Queue_empty, transmit_en, length_TC)
begin
    NS <= CS;
    case CS is 
        when Idle => 
            if transmit_en = '1' then 
                NS <= Load;
            end if;
        when Load => 
            NS <= Transmit;
        when Transmit => 
            if Length_TC = '1' then 
                NS <= Check;
            end if; 
        when Check => 
            if Queue_empty = '1' then 
                NS <= Done;
            elsif Queue_empty = '0' then 
                NS <= Load;
            end if;
        when Done => 
            NS <= Idle; 
        when Others => 
        
    end case; 
end process;


Output_Logic : Process(CS)
begin 
    symbol_load <= '0';
    Length_cnt_en <= '0';
    Tx_done <= '0';
    case CS is 
        when Idle => 
            
        when Load => 
            symbol_load <= '1';
        When Transmit => 
            length_cnt_en <= '1';
        When Check => 
            --Clr_length_cnt <= '1';
        when Done => 
            tx_done <= '1';
        when Others => 
    end case;
end process;


----------------------------------------
--ROM 
----------------------------------------
ROM : Process(Queue_empty, ascii_char)
begin 
    Morse_code <= "000000000000000000000";
    Morse_code_length <= 0;
    
    if Queue_empty = '0' then 
        case to_integer(unsigned(ascii_char)) is 
        -- 0 through 9
            When 48 => 
                Morse_Code <= "111011101110111011100";
                Morse_code_length <= 18;
            when 49 => 
                Morse_code <= "101110111011101110000";
                Morse_code_length <= 16; 
            when 50 => 
                Morse_code <= "101011101110111000000";
                Morse_code_length <= 14; 
            when 51 => 
                Morse_code <= "101010111011100000000";
                Morse_code_length <= 12; 
            when 52 => 
                Morse_code <= "101010101110000000000";
                Morse_code_length <= 10;
            when 53 => 
                Morse_code <= "101010101000000000000";
                Morse_code_length <= 8;
            when 54 => 
                Morse_code <= "111010101010000000000";
                Morse_code_length <= 10;
            when 55 => 
                Morse_code <= "111011101010100000000";
                Morse_code_length <= 12;
            when 56 => 
                Morse_code <= "111011101110101000000";
                Morse_code_length <= 14;
            when 57 => 
                Morse_code <= "111011101110111010000";
                Morse_code_length <= 16;
            -- A through Z 
            when 65 => 
                Morse_code <= "101110000000000000000";
                Morse_code_length <= 4;
            when 66 => 
                Morse_code <= "111010101000000000000";
                Morse_code_length <= 8;
            when 67 => 
                Morse_code <= "111010111010000000000";
                Morse_code_length <= 12;
            when 68 => 
                Morse_code <= "111010100000000000000";
                Morse_code_length <= 6;
            when 69 => 
                Morse_code <= "100000000000000000000";
                Morse_code_length <= 0;
            when 70 => 
                Morse_code <= "101011101000000000000";
                Morse_code_length <= 8;
            when 71 => 
                Morse_code <= "111011101000000000000";
                Morse_code_length <= 8;
            when 72 => 
                Morse_code <= "101010100000000000000";
                Morse_code_length <= 6;
            when 73 => 
                Morse_code <= "101000000000000000000";
                Morse_code_length <= 2;
            when 74 => 
                Morse_code <= "101110111011100000000";
                Morse_code_length <= 12;
            when 75 => 
                Morse_code <= "111010111000000000000";
                Morse_code_length <= 8;
            when 76 => 
                Morse_code <= "101110101000000000000";
                Morse_code_length <= 8;
            when 77 => 
                Morse_code <= "111011100000000000000";
                Morse_code_length <= 6;
            when 78 => 
                Morse_code <= "111010000000000000000";
                Morse_code_length <= 4;
            when 79 => 
                Morse_code <= "111011101110000000000";
                Morse_code_length <= 10;
            when 80 => 
                Morse_code <= "101110111010000000000";
                Morse_code_length <= 10;
            when 81 => 
                Morse_code <= "111011101011100000000";
                Morse_code_length <= 12;
            when 82 => 
                Morse_code <= "101110100000000000000";
                Morse_code_length <= 6;
            when 83 => 
                Morse_code <= "101010000000000000000";
                Morse_code_length <= 4;
            when 84 => 
                Morse_code <= "111000000000000000000";
                Morse_code_length <= 2;
            when 85 => 
                Morse_code <= "101011100000000000000";
                Morse_code_length <= 6;
            when 86 => 
                Morse_code <= "101010111000000000000";
                Morse_code_length <= 8;
            when 87 => 
                Morse_code <= "101110111000000000000";
                Morse_code_length <= 8;
            when 88 => 
                Morse_code <= "111010101110000000000";
                Morse_code_length <= 10;
            when 89 => 
                Morse_code <= "111010111011100000000";
                Morse_code_length <= 12;
            when 90 => 
                Morse_code <= "111011101010000000000";
                Morse_code_length <= 4;
            When Others => 
            
        end case;
    end if;
end process;









            
            
  

end Behavioral;
