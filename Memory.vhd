

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity memory is
	generic(ADDR_WITH:integer :=8;
		DATA_WIDTH:integer:=16);
	port(	clk			:in std_logic;
			mem_write	:in std_logic;
			mem_read	:in std_logic;
			addr		:in std_logic_vector(ADDR_WITH -1 downto 0);
			data_in		:in std_logic_vector(DATA_WIDTH -1 downto 0);
			data_out	:out std_logic_vector(DATA_WIDTH -1 downto 0)
		);
end entity;
		
architecture behav of memory is

	
	type mem_array is array (integer range <>)of std_logic_vector (DATA_WIDTH-1 downto 0);
	signal mem:mem_array(255 downto 0):=(others=>(others=>'0'));
	begin
	
	data_out <=mem(to_integer(unsigned(addr(7 DOWNTO 0)))) when mem_read='1';
	
	process(clk)
		begin
			
			if (rising_edge(clk))then
				if(mem_write='1')then
				mem(to_integer(unsigned(addr(7 DOWNTO 0))))<=data_in(DATA_WIDTH -1 downto 0);
				
				end if;					
				end if;
	end process;
	
	
	
	
	end ;

