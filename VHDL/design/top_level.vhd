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
    sci_data_ext_port : in std_logic;    -- USB UART Bridge Rx (B18)
	morse_data_ext_port : in std_logic;    -- JB3 (B15)
    rx_tx_sw_ext_port : in std_logic;          -- 0 - receive data; 1 - transmit data   SW15(R2)
    morse_sci_rx_sw_ext_port : in std_logic;   --0 - sci rx and morse tx; 1 - morse rx and sci_tx SW0(V17)

    morse_tx_ext_port : out std_logic;   -- JA1 (J1)
    morse_tx_done_ext_port : out std_logic; -- LED L1
    morse_audio_ext_port: out std_logic;  -- JC1 (K17)
	sci_tx_ext_port : out std_logic;    -- USB UART Bridge Tx (A18)
    sci_tx_done_ext_port : out std_logic;  -- LED U16
    morse_tx_led_port : out std_logic;  -- LED8 (V13)
    receive_en_ext_port : out std_logic;   -- LED E19
    transmit_en_ext_port : out std_logic);  -- LED P1
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
-- Morse Receiver 
-------------------
component Morse_Rx is 
    generic(
        BAUD_PERIOD : integer);
    port(
        receive_en : in std_logic;
        clk : in std_logic; 
        rx : in std_logic; 
        morse_ready : out std_logic; 
        morse_output : out std_logic_vector(21 downto 0));
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
-- SCI Transmitter
-------------------
component Sci_Tx_ROM is 
    generic (
        BAUD_PERIOD : integer);
    port ( 
        data_in : in std_logic_vector(21 downto 0);
        transmit_en : in std_logic; 
        queue_empty: in std_logic; 
        clk : in std_logic;
        tx: out std_logic; 
        tx_done: out std_logic;
        new_symbol: out std_logic);
end component;
-------------------
-- PWM Audio Generator
-------------------
component PWM_Audio_Generator
    generic(
        AUDIO_SAMPLE_RATE	: integer;
	    PWM_TC				: unsigned(7 downto 0));
    Port ( 
        audio_signal : in std_logic; 
  	    clk : in STD_Logic;
        pwm_audio_signal : out std_logic);
end component;

-------------------
-- Queue
-------------------
component Queue is 
    generic (
        QUEUE_LENGTH : integer; 
        QUEUE_DEPTH  : integer);
    port (
        clk		:	in	STD_LOGIC; --10 MHz clock
		Write	: 	in 	STD_LOGIC;
		Read	: 	in 	STD_LOGIC;
        Data_in	:	in	STD_LOGIC_VECTOR(QUEUE_DEPTH-1 downto 0);
		Data_out:	out	STD_LOGIC_VECTOR(QUEUE_DEPTH-1 downto 0);
        Empty	:	out	STD_LOGIC;
        Full	:	out	STD_LOGIC);
end component; 


------------------------------------
-- Local Common Signal Declarations
------------------------------------
signal system_clk : std_logic := '0';  

---------------------------------------------------------------
-- Local SCI Receiver and Morse Transmitter Signal Declarations
---------------------------------------------------------------
signal morse_tx_new_symbol : std_logic := '0';
signal morse_tx_output : std_logic := '0';
signal morse_tx_done : std_logic := '0';
signal audio_clk : std_logic := '0';
signal audio_output : std_logic := '0'; 
signal sci_rx_ready : std_logic := '0';
signal sci_rx_output : std_logic_vector(7 downto 0) := (others => '0'); 
signal sci_rx_queue_output : std_logic_vector(7 downto 0) := (others => '0');
signal sci_rx_queue_empty : std_logic := '0'; 
signal sci_rx_queue_full : std_logic := '0'; 
constant SCI_RX_BAUD_PERIOD : integer := 1042;
constant MORSE_TX_BAUD_PERIOD : integer := 512000; --FOR SYNTHESIS
--constant MORSE_TX_BAUD_PERIOD : integer := 1042;   -- FOR SIMULATION

---------------------------------------------------------------
-- Local Morse Receiver and SCI Transmitter Signal Declarations
---------------------------------------------------------------
signal sci_tx_new_symbol : std_logic := '0';
signal sci_tx_output : std_logic := '1';
signal sci_tx_done : std_logic := '0';
signal morse_rx_ready : std_logic := '0';
signal morse_rx_ready_old : std_logic := '0';
signal morse_rx_output : std_logic_vector(21 downto 0) := (others => '0'); 
signal morse_rx_queue_output : std_logic_vector(21 downto 0) := (others => '0'); 
signal morse_rx_queue_empty : std_logic := '0'; 
signal morse_rx_queue_full : std_logic := '0'; 
signal morse_rx_queue_write : std_logic := '0';
constant SCI_TX_BAUD_PERIOD : integer := 1042;
constant MORSE_RX_BAUD_PERIOD : integer := 512000; -- FOR SYNTHESIS
--constant MORSE_RX_BAUD_PERIOD : integer := 1042;  -- FOR SIMULATION

---------------------------------------------------------------
-- FSM States
---------------------------------------------------------------
type state_type is (SciReceive, MorseTransmit, MorseReceive, SciTransmit);
signal CS, NS : state_type := SciReceive;

---------------------------------------------------------------
-- FSM Signals
---------------------------------------------------------------
signal morse_transmit_en : std_logic := '0'; 
signal sci_receive_en : std_logic := '0';
signal sci_transmit_en : std_logic := '0'; 
signal morse_receive_en : std_logic := '0';

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
-----------------------------
-- Audio Out Signal Generator 
-----------------------------
pwm_audio_signal_generator: PWM_Audio_Generator
generic map(
        AUDIO_SAMPLE_RATE	=>  MORSE_TX_BAUD_PERIOD/10,
	    PWM_TC				=> "10000000")
Port map( 
        audio_signal => morse_tx_output,
  	    clk => system_clk,
        pwm_audio_signal => audio_output);
-------------------
-- SCI Receiver 
-------------------
sci_receiver: Sci_Rx
generic map(
    BAUD_PERIOD => SCI_RX_BAUD_PERIOD)
port map(
    receive_en => sci_receive_en,
    clk  => system_clk, 
    rx   => sci_data_ext_port, 
    sci_ready => sci_rx_ready,
    sci_output => sci_rx_output);
    
-------------------
-- Morse Receiver 
-------------------
morse_receiver: Morse_Rx
generic map(
    BAUD_PERIOD => MORSE_RX_BAUD_PERIOD)
port map(
    receive_en => morse_receive_en,
    clk  => system_clk, 
    rx   => morse_data_ext_port, 
    morse_ready => morse_rx_ready,
    morse_output => morse_rx_output);

-------------------
-- Morse Transmitter
-------------------
morse_transmitter: Morse_Tx_ROM
generic map(
    BAUD_PERIOD => MORSE_TX_BAUD_PERIOD)
port map(
    data_in => sci_rx_queue_output, 
    transmit_en => morse_transmit_en, 
    queue_empty => sci_rx_queue_empty,
    clk => system_clk, 
    tx => morse_tx_output, 
    tx_done => morse_tx_done, 
    new_symbol => morse_tx_new_symbol); 

-------------------
-- Sci Transmitter
-------------------
sci_transmitter: Sci_Tx_ROM
generic map(
    BAUD_PERIOD => SCI_TX_BAUD_PERIOD)
port map(
    data_in => morse_rx_queue_output, 
    transmit_en => sci_transmit_en, 
    queue_empty => morse_rx_queue_empty,
    clk => system_clk, 
    tx => sci_tx_output, 
    tx_done => sci_tx_done, 
    new_symbol => sci_tx_new_symbol);

-----------------------------------------
-- Morse Rx Queue Write Signal Monopulser
-----------------------------------------
morse_rx_queue_write_mp_proc: process(system_clk)
begin
    if rising_edge(system_clk) then 
        morse_rx_queue_write <= (not morse_rx_ready_old) and morse_rx_ready;
        morse_rx_ready_old <= morse_rx_ready;
    end if; 
end process;

-------------------
-- Morse RX Queue
-------------------
morse_rx_queue_mem: Queue
generic map(
    QUEUE_LENGTH => 64,
	QUEUE_DEPTH => 22)
port map(
    clk => system_clk, 
    write => morse_rx_queue_write,
    read => sci_tx_new_symbol,
    data_in => morse_rx_output,
    data_out => morse_rx_queue_output,
    empty => morse_rx_queue_empty,
    full => morse_rx_queue_full);
-------------------
-- SCI RX Queue
-------------------
sci_rx_queue_mem: Queue
generic map(
    QUEUE_LENGTH => 64,
    QUEUE_DEPTH => 8)
port map(
    clk => system_clk, 
    write => sci_rx_ready,
    read => morse_tx_new_symbol,
    data_in => sci_rx_output,
    data_out => sci_rx_queue_output,
    empty => sci_rx_queue_empty,
    full => sci_rx_queue_full);

-----------------------------
-- Top Level Controller Logic
-----------------------------
state_update : process(system_clk) 
begin 
    if rising_edge(system_clk) then
        CS <= NS;
    end if;
end process;

ns_logic : process(CS,rx_tx_sw_ext_port, morse_sci_rx_sw_ext_port)
begin
    NS <= CS;
    case CS is 
        when SciReceive => 
            if morse_sci_rx_sw_ext_port = '1' then
                NS <= MorseReceive; 
            elsif rx_tx_sw_ext_port = '1' then 
                NS <= MorseTransmit;
            end if;
        when MorseTransmit => 
            if morse_sci_rx_sw_ext_port = '1' then 
                NS <= SciTransmit;
            elsif rx_tx_sw_ext_port = '0' then 
                NS <= SciReceive; 
            end if;
        when MorseReceive => 
            if morse_sci_rx_sw_ext_port = '0' then
                NS <= SciReceive; 
            elsif rx_tx_sw_ext_port = '1' then 
                NS <= SciTransmit;
            end if;
        when SciTransmit => 
            if morse_sci_rx_sw_ext_port = '0' then 
                NS <= MorseTransmit;
            elsif rx_tx_sw_ext_port = '0' then 
                NS <= MorseReceive; 
            end if;
        when others => 
    end case; 
end process;


output_logic : process(CS)
begin 
    sci_receive_en <= '0'; 
    morse_transmit_en <= '0'; 
    morse_receive_en <= '0'; 
    sci_transmit_en <= '0';
    case CS is 
        when SciReceive => 
            sci_receive_en <= '1';
        when MorseTransmit => 
        	morse_transmit_en <= '1';
        when MorseReceive => 
            morse_receive_en <= '1';
        when SciTransmit => 
        	sci_transmit_en <= '1';
        when Others => 
    end case;
end process; 

receive_en_ext_port <= sci_receive_en or morse_receive_en;
transmit_en_ext_port <= morse_transmit_en or sci_transmit_en;
sci_tx_ext_port <= sci_data_ext_port when CS = SciReceive else sci_tx_output; 
sci_tx_done_ext_port <= sci_tx_done;
morse_tx_ext_port <= morse_tx_output; 
morse_tx_done_ext_port <= morse_tx_done;
morse_audio_ext_port <= audio_output; 
morse_tx_led_port <= morse_tx_output;

end Behavioral; 