----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek and Collin Kuester
-- Module Name: MorseTx - Behavioral
-- Project Name: Morse Code Converter 
-- Target Device: Basys 3
-- Description: Morse Transmitter 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Morse_Tx_ROM is
    Port ( 
        data_in : in std_logic_vector(7 downto 0);
        transmit_en : in std_logic; 
        queue_empty: in std_logic; 
        clk : in std_logic;
        tx: out std_logic; 
        tx_done: out std_logic);
end Morse_Tx_ROM;

architecture Behavioral of Morse_Tx_ROM is
--FSM states 
type state_type is (Idle, Load, Transmit, Check, Done);
signal CS, NS : state_type := Idle;

--FSM signals 
Signal symbol_load : std_logic := '0';
signal length_tc : std_logic := '0';
Signal length_cnt_en  : Std_Logic := '0';

-- ROM signals 
Signal Morse_code : std_logic_vector(20 downto 0);
signal Morse_Code_Length : integer := 0;

-- Datapath signals
constant BAUD_PERIOD : integer := 400;
signal new_bit : std_logic := '0'; 
signal baud_tc : std_logic := '0';
signal bit_cnt : integer := 0;
signal data_register : std_logic_vector(20 downto 0) := (others => '0');
signal baud_cnt: unsigned(8 downto 0) := (others => '0');

begin 
-------------------
-- Baud counter 
-------------------
baud_counter: process(clk, baud_cnt)
begin
    if rising_edge(clk) then
        baud_cnt <= baud_cnt + 1;
        if symbol_load = '1' or baud_tc = '1' then   
            baud_cnt <= (others => '0'); 
        end if;
    end if; 

    new_bit <= '0';
    if baud_cnt = BAUD_PERIOD-1 then
        new_bit <= '1';
    end if;
end process; 

bit_counter: process(clk, bit_cnt, symbol_load)
begin
    if rising_edge(clk) then 
        if new_bit = '1' and Length_cnt_en = '1' then 
            bit_cnt <= bit_cnt - 1; 
        end if; 
    end if; 

    length_tc <= '0'; 
    if bit_cnt = 0 then 
        length_tc <= '1'; 
    end if; 

    if symbol_load = '1' then 
        bit_cnt <= Morse_code_length; 
    end if;
end process; 

shift_register: process(clk, symbol_load)
begin
    if rising_edge(clk) then 
        if new_bit = '1' then 
            data_register <= data_register(19 downto 0) & '0'; 
        end if;
    end if; 

    if symbol_load = '1' then 
        data_register <= Morse_code; 
    end if;
end process;

tx <= data_register(20); 


-------------------
--FSM LOGIC 
-------------------
state_update : process(clk) 
begin 
    if rising_edge(clk) then
        CS <= NS;
    end if;
end process;


NS_Logic : process(CS, queue_empty, transmit_en, length_tc)
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
            if length_tc = '1' then 
                NS <= Check;
            end if; 
        when Check => 
            if queue_empty = '1' then 
                NS <= Done;
            elsif queue_empty = '0' then 
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
    length_cnt_en <= '0';
    tx_done <= '0';
    case CS is 
        when Load => 
            symbol_load <= '1';
        when Transmit => 
           length_cnt_en <= '1';
        when Done => 
            tx_done <= '1';
        when Others => 
    end case;
end process;


----------------------------------------
--ROM 
----------------------------------------
ROM : Process(queue_empty, data_in)
begin 
    Morse_code <= "000000000000000000000";
    Morse_code_length <= 0;
    
    if Queue_empty = '0' then 
        case to_integer(unsigned(data_in)) is 
        -- 0 through 9
            When 48 => 
                Morse_Code <= "111011101110111011100";
                Morse_code_length <= 19;
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
            when others => 
        end case;
    end if;
end process;
end Behavioral;
