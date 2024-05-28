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
        tx_done: out std_logic;
        new_symbol: out std_logic);
end Morse_Tx_ROM;

architecture Behavioral of Morse_Tx_ROM is
--FSM states 
type state_type is (Idle, Load, Read_ROM, Transmit, Check, Done);
signal CS, NS : state_type := Idle;

--FSM signals 
Signal symbol_load : std_logic := '0';
signal length_tc : std_logic := '0';
Signal length_cnt_en  : std_Logic := '0';
signal rom_read : std_logic := '0'; 

-- ROM signals 
Signal Morse_code : std_logic_vector(21 downto 0) := (others => '0');
signal Morse_Code_Length : integer := 0;

-- Datapath signals
constant BAUD_PERIOD : integer := 400;
signal new_bit : std_logic := '0';
signal bit_cnt : integer := 0;
signal data_register : std_logic_vector(21 downto 0) := (others => '0');
signal baud_cnt: unsigned(8 downto 0) := (others => '0');

begin 
-------------------
-- Baud counter 
-------------------
baud_counter: process(clk, baud_cnt)
begin
    if rising_edge(clk) then
        baud_cnt <= baud_cnt + 1;
        if rom_read = '1' or new_bit = '1' then   
            baud_cnt <= (others => '0'); 
        end if;
    end if; 

    new_bit <= '0';
    if baud_cnt = BAUD_PERIOD-1 then
        new_bit <= '1';
    end if;
end process; 

-------------------
-- Bit counter 
-------------------
bit_counter: process(clk, bit_cnt, rom_read)
begin
    if rising_edge(clk) then 
        if new_bit = '1' and Length_cnt_en = '1' then 
            bit_cnt <= bit_cnt - 1; 
        end if; 
    end if; 
    
    if rom_read = '1' then 
        bit_cnt <= Morse_code_length; 
    end if;
    
    length_tc <= '0'; 
    if bit_cnt = 0 then 
        length_tc <= '1'; 
    end if;
end process; 

-------------------
-- Shift Register 
-------------------
shift_register: process(clk, rom_read)
begin
    if rising_edge(clk) then 
        if new_bit = '1' then 
            data_register <= data_register(20 downto 0) & '0'; 
        end if;
    end if; 
    
    if rom_read = '1' then 
       data_register <= Morse_code; 
    end if;
end process;

tx <= data_register(21); 
new_symbol <= symbol_load; 


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
            NS <= Read_ROM;
        when Read_ROM => 
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
    rom_read <= '0'; 
    length_cnt_en <= '0';
    tx_done <= '0';
    case CS is 
        when Load => 
            symbol_load <= '1';
        when Read_ROM => 
        	rom_read <= '1'; 
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
ROM : process(clk)
begin 
    if rising_edge(clk) then 
        case to_integer(unsigned(data_in)) is 
            when 32 =>  -- space
                Morse_Code <= "0000000000000000000000"; 
                Morse_code_length <= 4;   -- 3 0s between words, 1 is from prev symbol and 2 from space itself
            -- 0 through 9
            When 48 => 
                Morse_Code <= "1110111011101110111000";
                Morse_code_length <= 22;
            when 49 => 
                Morse_code <= "1011101110111011100000";
                Morse_code_length <= 20; 
            when 50 => 
                Morse_code <= "1010111011101110000000";
                Morse_code_length <= 18; 
            when 51 => 
                Morse_code <= "1010101110111000000000";
                Morse_code_length <= 16; 
            when 52 => 
                Morse_code <= "1010101011100000000000";
                Morse_code_length <= 14;
            when 53 => 
                Morse_code <= "1010101010000000000000";
                Morse_code_length <= 12;
            when 54 => 
                Morse_code <= "1110101010100000000000";
                Morse_code_length <= 14;
            when 55 => 
                Morse_code <= "1110111010101000000000";
                Morse_code_length <= 16;
            when 56 => 
                Morse_code <= "1110111011101010000000";
                Morse_code_length <= 18;
            when 57 => 
                Morse_code <= "1110111011101110100000";
                Morse_code_length <= 20;
            -- A through Z 
            when 65 => 
                Morse_code <= "1011100000000000000000";
                Morse_code_length <= 8;
            when 66 => 
                Morse_code <= "1110101010000000000000";
                Morse_code_length <= 12;
            when 67 => 
                Morse_code <= "1110101110100000000000";
                Morse_code_length <= 14;
            when 68 => 
                Morse_code <= "1110101000000000000000";
                Morse_code_length <= 10;
            when 69 => 
                Morse_code <= "1000000000000000000000";
                Morse_code_length <= 4;
            when 70 => 
                Morse_code <= "1010111010000000000000";
                Morse_code_length <= 12;
            when 71 => 
                Morse_code <= "1110111010000000000000";
                Morse_code_length <= 12;
            when 72 => 
                Morse_code <= "1010101000000000000000";
                Morse_code_length <= 10;
            when 73 => 
                Morse_code <= "1010000000000000000000";
                Morse_code_length <= 6;
            when 74 => 
                Morse_code <= "1011101110111000000000";
                Morse_code_length <= 16;
            when 75 => 
                Morse_code <= "1110101110000000000000";
                Morse_code_length <= 12;
            when 76 => 
                Morse_code <= "1011101010000000000000";
                Morse_code_length <= 12;
            when 77 => 
                Morse_code <= "1110111000000000000000";
                Morse_code_length <= 10;
            when 78 => 
                Morse_code <= "1110100000000000000000";
                Morse_code_length <= 8;
            when 79 => 
                Morse_code <= "1110111011100000000000";
                Morse_code_length <= 14;
            when 80 => 
                Morse_code <= "1011101110100000000000";
                Morse_code_length <= 14;
            when 81 => 
                Morse_code <= "1110111010111000000000";
                Morse_code_length <= 16;
            when 82 => 
                Morse_code <= "1011101000000000000000";
                Morse_code_length <= 10;
            when 83 => 
                Morse_code <= "1010100000000000000000";
                Morse_code_length <= 8;
            when 84 => 
                Morse_code <= "1110000000000000000000";
                Morse_code_length <= 6;
            when 85 => 
                Morse_code <= "1010111000000000000000";
                Morse_code_length <= 10;
            when 86 => 
                Morse_code <= "1010101110000000000000";
                Morse_code_length <= 12;
            when 87 => 
                Morse_code <= "1011101110000000000000";
                Morse_code_length <= 12;
            when 88 => 
                Morse_code <= "1110101011100000000000";
                Morse_code_length <= 14;
            when 89 => 
                Morse_code <= "1110101110111000000000";
                Morse_code_length <= 16;
            when 90 => 
                Morse_code <= "1110111010100000000000";
                Morse_code_length <= 8; 
            when others => 
            	Morse_code <= "0000000000000000000000";
    			Morse_code_length <= 0;
        end case;
    end if;
end process;
end Behavioral;
