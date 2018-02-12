
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
-------------Defined package-------------------------
use work.Package_component_Pipeline.all;
--------------------------------------------------------


entity register_file is 
		generic(SIZE_OF_INPUT_BIT				:integer:=3;
				SIZE_OF_REGISTER_FILE			:integer:=8
			    );
		port (	
				clk				:in std_logic;
				A1			:in std_logic_vector(SIZE_OF_INPUT_BIT-1 downto 0);
				A2			:in std_logic_vector(SIZE_OF_INPUT_BIT-1 downto 0);
				A3			:in std_logic_vector(SIZE_OF_INPUT_BIT-1 downto 0);
				data_out1		:out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				data_out2		:out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				data_in3		:in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				reg_file_write	:in std_logic;
				R7_in			:in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R7_write		:in std_logic;
				
				R0              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R1              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R2              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R3              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R4              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R5              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R6              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R7              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0)
			);
		end entity;
		
architecture behav of register_file is

type reg_array is array (integer range <>) of std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal reg_file :reg_array(SIZE_OF_REGISTER_FILE-1 downto 0):=(others=>(others=>'0'));
signal R7_enable:std_logic;
signal R7_input	:std_logic_vector(INSTRUCTION_SIZE-1 downto 0);


begin
	R7_input <=R7_in when R7_write='1' else data_in3;
	R7_enable<='1' when ((A3 ="111" and reg_file_write='1') or R7_write='1') else '0';
process(clk)
	begin
	
	if(rising_edge(clk))then
			if(reg_file_write='1'and A3 /="111" )then
				reg_file(to_integer(unsigned(A3(SIZE_OF_INPUT_BIT-1 DOWNTO 0)))) <=data_in3;
			end if;
			
			if(R7_enable='1')then
				reg_file(7) <=R7_input;
			end if;
		end if;
end process;
	
	
	data_out1 <=reg_file(to_integer(unsigned(A1(SIZE_OF_INPUT_BIT-1 DOWNTO 0))));
	data_out2<=reg_file(to_integer(unsigned(A2(SIZE_OF_INPUT_BIT-1 DOWNTO 0))));
	
	---------------------------- External Reg-------------------------------------------
	R0   <=  reg_file(0);    
	R1   <=  reg_file(1);         
	R2   <=  reg_file(2);        
	R3   <=  reg_file(3);       
	R4   <=  reg_file(4);         
	R5   <=  reg_file(5);      
	R6   <=  reg_file(6);      
	R7   <=  reg_file(7);         
	
	end;
			
		


					
				
		
