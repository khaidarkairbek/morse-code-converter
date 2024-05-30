----------------------------------------------------------------------------------
-- Company: Dartmouth College
-- Engineers: Khaidar Kairbek and Collin Kuester
-- Module Name: Top Level - Behavioral
-- Project Name: Morse Code Converter 
-- Target Device: Basys 3
-- Description: Top Level
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_level is 
port(
    clk_ext_port : in std_logic; 
    sci_data_ext_port : in std_logic; 
    rx_tx_sw_ext_port : in std_logic;

    morse_tx_ext_port : out std_logic; 
    morse_tx_done_ext_port : out std_logic;
    morse_audio_ext_port: out std_logic; 
    sci_tx_ext_port : out std_logic; 
    receive_en_ext_port : out std_logic;
    transmit_en_ext_port : out std_logic); 
end top_level;


architecture Behavioral of top_level is 

---------------------------
--System Clock Generation:
---------------------------
component system_clock_generator is
	generic (
	   CLOCK_DIVIDER_RATIO : integer);
    port (
        input_clk_port		: in  std_logic;
        system_clk_port	    : out std_logic;
		fwd_clk_port		: out std_logic);
end component;

-------------------
-- SCI Receiver 
-------------------
component Sci_Rx is 
    generic(
        BAUD_PERIOD : integer);
    port(
        receive_en : in std_logic;
        clk : in std_logic; 
        rx : in std_logic; 
        sci_ready : out std_logic; 
        sci_output : out std_logic_vector(7 downto 0));
end component; 

-------------------
-- Morse Transmitter
-------------------
component Morse_Tx_ROM is 
    generic (
        BAUD_PERIOD : integer);
    port ( 
        data_in : in std_logic_vector(7 downto 0);
        transmit_en : in std_logic; 
        queue_empty: in std_logic; 
        clk : in std_logic;
        tx: out std_logic; 
        tx_done: out std_logic;
        new_symbol: out std_logic);
end component;

-------------------
-- Queue
-------------------
component Queue is 
    generic (
        QUEUE_LENGTH : integer);
    port (
        clk		:	in	STD_LOGIC; --10 MHz clock
		Write	: 	in 	STD_LOGIC;
		Read	: 	in 	STD_LOGIC;
        Data_in	:	in	STD_LOGIC_VECTOR(7 downto 0);
		Data_out:	out	STD_LOGIC_VECTOR(7 downto 0);
        Empty	:	out	STD_LOGIC;
        Full	:	out	STD_LOGIC);
end component; 


----------------------------
-- Local Signal Declarations
----------------------------
signal system_clk : std_logic := '0';
signal audio_clk : std_logic := '0';
signal audio_output : std_logic := '0'; 
--signal rx_done : std_logic := '0'; 
signal sci_ready : std_logic := '0';
signal sci_output : std_logic_vector(7 downto 0) := (others => '0'); 
signal queue_output : std_logic_vector(7 downto 0) := (others => '0');
signal tx_output : std_logic := '0';
signal tx_done : std_logic := '0'; 
signal new_symbol : std_logic := '0'; 
signal queue_empty : std_logic := '0'; 
signal queue_full : std_logic := '0'; 
--signal sci_done_tc : std_logic := '0'; 
--signal sci_done_cnt : integer := 0; 
constant SCI_BAUD_PERIOD : integer := 1042;
constant MORSE_BAUD_PERIOD : integer := 500000;
constant SCI_INACTIVE_THRESHOLD : integer := 50 * SCI_BAUD_PERIOD; 

-- FSM Signals 
type state_type is (Receive, Transmit);
signal CS, NS : state_type := Receive;

--FSM signals 
signal transmit_en : std_logic := '0'; 
signal receive_en : std_logic := '0';

-----------------------------
-- Port Mapping and Processes 
-----------------------------
begin
-------------------
-- Clocking 
-------------------
clocking: system_clock_generator 
generic map(
	CLOCK_DIVIDER_RATIO => 10)               
port map(
	input_clk_port 		=> clk_ext_port,
	system_clk_port 	=> system_clk,
	fwd_clk_port		=> open);
	
-------------------
-- Audio Out Clocking 
-------------------
audio_clocking: system_clock_generator 
generic map(
	CLOCK_DIVIDER_RATIO => 100000)               
port map(
	input_clk_port 		=> clk_ext_port,
	system_clk_port 	=> audio_clk,
	fwd_clk_port		=> open);

-------------------
-- Audio Out Clocking 
-------------------
audio_frequency_generator: process(audio_clk)
begin
    if rising_edge(audio_clk) then 
        if tx_output = '1' then 
            audio_output <= not audio_output;
        else audio_output <= '0';
        end if;
    end if; 
end process; 
-------------------
-- SCI Receiver 
-------------------
receiver: Sci_Rx
generic map(
    BAUD_PERIOD => SCI_BAUD_PERIOD)
port map(
    receive_en => receive_en,
    clk  => system_clk, 
    rx   => sci_data_ext_port, 
    sci_ready => sci_ready,
    sci_output => sci_output);

-------------------
-- Morse Transmitter
-------------------
transmitter: Morse_Tx_ROM
generic map(
    BAUD_PERIOD => MORSE_BAUD_PERIOD)
port map(
    data_in => queue_output, 
    transmit_en => transmit_en, 
    queue_empty => queue_empty,
    clk => system_clk, 
    tx => tx_output, 
    tx_done => tx_done, 
    new_symbol => new_symbol);
morse_tx_ext_port <= tx_output; 
morse_tx_done_ext_port <= tx_done;
morse_audio_ext_port <= audio_output; 

-------------------
-- Queue
-------------------
queue_mem: Queue
generic map(
    QUEUE_LENGTH => 64)
port map(
    clk => system_clk, 
    write => sci_ready,
    read => new_symbol,
    data_in => sci_output,
    data_out => queue_output,
    empty => queue_empty,
    full => queue_full);

-----------------------------
-- Top Level Controller Logic
-----------------------------
state_update : process(system_clk) 
begin 
    if rising_edge(system_clk) then
        CS <= NS;
    end if;
end process;


ns_logic : process(CS,rx_tx_sw_ext_port)
begin
    NS <= CS;
    case CS is 
        when Receive => 
            if rx_tx_sw_ext_port = '1' then 
                NS <= Transmit;
            end if;
        when Transmit => 
            if rx_tx_sw_ext_port = '0' then 
                NS <= Receive;
            end if;
        when others => 
    end case; 
end process;


output_logic : process(CS)
begin 
    receive_en <= '0'; 
    transmit_en <= '0'; 
    case CS is 
        when Receive => 
            receive_en <= '1';
        when Transmit => 
        	transmit_en <= '1';
        when Others => 
    end case;
end process;

-----------------------------
-- Top Level Datapath Logic
-----------------------------
--sci_done_counter : process(system_clk, transmit_en, sci_ready, sci_done_cnt)
--begin 
    --if rising_edge(system_clk) then 
        --if receive_en = '1' then 
            --sci_done_cnt <= sci_done_cnt + 1;
        --end if; 

        --if transmit_en = '1' or sci_ready = '1' or sci_done_tc = '1' then 
            --sci_done_cnt <= 0; 
        --end if;
    --end if;  

    --sci_done_tc <= '0'; 
    --if sci_done_cnt = SCI_INACTIVE_THRESHOLD - 1 then 
        --sci_done_tc <= '1'; 
    --end if; 
--end process; 

--rx_done <= (sci_done_tc or queue_full) and (not queue_empty); 
receive_en_ext_port <= receive_en;
transmit_en_ext_port <= transmit_en;
sci_tx_ext_port <= sci_data_ext_port;
end Behavioral; 