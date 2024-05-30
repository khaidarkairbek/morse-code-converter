----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek and Collin Kuester
-- Module Name: Sci_Tx_ROM - Behavioral
-- Project Name: Morse Code Converter 
-- Target Device: Basys 3
-- Description: SCI Transmitter
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Sci_Tx_ROM is
    generic (
        BAUD_PERIOD : integer);
    Port ( 
        data_in : in std_logic_vector(21 downto 0);
        transmit_en : in std_logic; 
        queue_empty: in std_logic; 
        clk : in std_logic;
        tx: out std_logic; 
        tx_done: out std_logic;
        new_symbol: out std_logic);
end Sci_Tx_ROM;

architecture Behavioral of Sci_Tx_ROM is
--FSM states 
type state_type is (Idle, Load, Read_ROM, Transmit, Check, Done);
signal CS, NS : state_type := Idle;

--FSM signals 
Signal symbol_load : std_logic := '0';
signal length_tc : std_logic := '0';
Signal length_cnt_en  : std_Logic := '0';
signal rom_read : std_logic := '0'; 

-- ROM signals 
Signal sci_code : std_logic_vector(9 downto 0) := (others => '0');

-- Datapath signals
signal new_bit : std_logic := '0';
signal bit_cnt : integer := 0;
signal data_register : std_logic_vector(9 downto 0) :=(others => '1');
signal baud_cnt: integer := 0;

begin 
-------------------
-- Baud counter 
-------------------
baud_counter: process(clk, baud_cnt)
begin
    if rising_edge(clk) then
        baud_cnt <= baud_cnt + 1;
        if rom_read = '1' or new_bit = '1' then   
            baud_cnt <= 0; 
        end if;
    end if; 

    new_bit <= '0';
    if baud_cnt = BAUD_PERIOD-1 then
        new_bit <= '1';
    end if;
end process; 

-------------------
-- Bit counter and shift register
-------------------
bit_counter: process(clk, bit_cnt)
begin
    if rising_edge(clk) then 
        if symbol_load = '1' then
            bit_cnt <= 10; 
            data_register <= sci_code;
        elsif new_bit = '1' then 
            data_register <= data_register(8 downto 0) & '1'; 
            if length_cnt_en = '1' then 
                bit_cnt <= bit_cnt - 1;
            end if; 
        end if;
    end if; 
    
    length_tc <= '0'; 
    if bit_cnt = 0 then 
        length_tc <= '1'; 
    end if;
end process; 

tx <= data_register(9); 
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
            if transmit_en = '0' then 
                NS <= Idle; 
            end if;
        when Others => null;
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
        when Others => null;
    end case;
end process;

----------------------------------------
--ROM 
----------------------------------------
ROM : process(data_in)
begin  
        case data_in is
            when "0000000000000000000000" =>  -- space
                sci_code <= "0000001001";
            -- 0 through 9
            When "1110111011101110111000" => 
                sci_code <= "0000011001";
            when "1011101110111011100000" => 
                sci_code <= "0100011001";
            when "1010111011101110000000" => 
                sci_code <= "0010011001";
            when "1010101110111000000000" => 
                sci_code <= "0110011001";
            when "1010101011100000000000" => 
                sci_code <= "0001011001";
            when "1010101010000000000000" => 
                sci_code <= "0101011001";
            when "1110101010100000000000" => 
                sci_code <= "0011011001";
            when "1110111010101000000000" => 
                sci_code <= "0111011001";
            when "1110111011101010000000" => 
                sci_code <= "0000111001";
            when "1110111011101110100000" => 
                sci_code <= "0100111001";
            -- A through Z 
            when "1011100000000000000000" => 
                sci_code <= "0100000101";
            when "1110101010000000000000" => 
                sci_code <= "0010000101";
            when "1110101110100000000000" => 
                sci_code <= "0110000101";
            when "1110101000000000000000" => 
                sci_code <= "0001000101";
            when "1000000000000000000000" => 
                sci_code <= "0101000101";
            when "1010111010000000000000" => 
                sci_code <= "0011000101";
            when "1110111010000000000000" => 
                sci_code <= "0111000101";
            when "1010101000000000000000" => 
                sci_code <= "0000100101";
            when "1010000000000000000000" => 
                sci_code <= "0100100101";
            when "1011101110111000000000" => 
                sci_code <= "0010100101";
            when "1110101110000000000000" => 
                sci_code <= "0110100101";
            when "1011101010000000000000" => 
                sci_code <= "0001100101";
            when "1110111000000000000000" => 
                sci_code <= "0101100101";
            when "1110100000000000000000" => 
                sci_code <= "0011100101";
            when "1110111011100000000000" => 
                sci_code <= "0111100101";
            when "1011101110100000000000" => 
                sci_code <= "0000010101";
            when "1110111010111000000000" => 
                sci_code <= "0100010101";
            when "1011101000000000000000" => 
                sci_code <= "0010010101";
            when "1010100000000000000000" => 
                sci_code <= "0110010101";
            when "1110000000000000000000" => 
                sci_code <= "0001010101";
            when "1010111000000000000000" => 
                sci_code <= "0101010101";
            when "1010101110000000000000" => 
                sci_code <= "0011010101";
            when "1011101110000000000000" => 
                sci_code <= "0111010101";
            when "1110101011100000000000" => 
                sci_code <= "0000110101";
            when "1110101110111000000000" => 
                sci_code <= "0100110101";
            when "1110111010100000000000" => 
                sci_code <= "0010110101";
            when others => 
            	sci_code <= "1111111111";
        end case;
end process;
end Behavioral;