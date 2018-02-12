library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;


entity AND_trial  is
	port(A: in std_logic_vector(1 downto 0);
		B	:in std_logic_vector(1 downto 0);
		op	:out std_logic_vector(1  downto 0):=(others=>'0'));
end entity;

architecture behav of AND_trial is

begin

op	<=A and B ;
end;



library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;


entity OR_trial  is
	port(A: in std_logic_vector(1 downto 0);
		B	:in std_logic_vector(1 downto 0);
		op	:out std_logic_vector(1  downto 0):=(others=>'0'));
end entity;

architecture behav of OR_trial is

begin

op	<=A or B ;
end;






library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;


entity AND_OR_trial  is
	port(A: in std_logic_vector(1 downto 0);
		B	:in std_logic_vector(1 downto 0);
		C:in std_logic_vector(1 downto 0);
		op_And	:out std_logic_vector(1  downto 0):=(others=>'0');
		op_Or	:out std_logic_vector(1  downto 0):=(others=>'0'));
end entity;

architecture behav of AND_OR_trial is

begin

AND_t:entity work.AND_trial port map(A,B,op_And);
OR_t:entity work.OR_trial port map(C,B,op_Or);
end;









library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity delay is
port(   Clk : in std_logic;
        valid_data : in std_logic; -- goes high when the input is valid.
        data_in : in std_logic; -- the data input
        data_out : out std_logic --the delayed input data.
        );
end delay;

architecture Behaviora of delay is

signal c : integer := 0;
constant d : integer := 0; --number of clock cycles by which input should be delayed.
signal data_temp : std_logic := '0';
type state_type is (idle,delay_c); --defintion of state machine type
signal next_s : state_type; --declare the state machine signal.

begin

process(Clk)
begin
    if(rising_edge(Clk)) then
        case next_s is
            when idle =>
                if(valid_data= '1') then
                    next_s <= delay_c;
                    data_temp <= data_in; --register the input data.
                    c <= 1;
                end if;
            when delay_c =>
                if(c = d) then
                    c <= 1; --reset the count
                    data_out <= data_temp; --assign the output
                    next_s <= idle; --go back to idle state and wait for another valid data.
                else
                    c <= c + 1;
                end if;
            when others =>
                NULL;
        end case;
    end if;
end process;   

   
end Behaviora;


 LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb IS
END tb;

ARCHITECTURE behavior OF tb IS

   signal Clk : std_logic := '0';
   signal valid_data : std_logic := '0';
   signal data_in,data_out : std_logic := '0';
   constant Clk_period : time := 5 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
   uut: entity work.delay PORT MAP (
          Clk => Clk,
          valid_data => valid_data,
          data_in => data_in,
          data_out => data_out
        );

   -- Clock process definitions
   clk <=not clk after 10 ns;
   -- Stimulus process
   stim_proc: process
   begin       
      wait for 110 ns; 
        valid_data <= '1';
        data_in <= '1';
      wait;
   end process;

END;













