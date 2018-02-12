
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity register1 is
	generic(NO_OF_BIT:integer:=8);
	port (clk	:in std_logic;
		  input :in std_logic_vector(NO_OF_BIT -1 downto 0);
		  output:out std_logic_vector(NO_OF_BIT -1 downto 0)
		  );
	end entity;	  
architecture behav of register1 is


begin

	process(clk)
		begin 
		 if(rising_edge(clk))then
			output <=input;
		end if;
	end process;
	
end;
