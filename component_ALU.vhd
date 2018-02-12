---------------------------------------------PC+1--and LM./SM---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity adder_PC is 
	generic(PC_SIZE:integer:=16);
	port(PC_in:in std_logic_vector(PC_SIZE-1 downto 0);
		 PC_out:out std_logic_vector(PC_SIZE-1 downto 0));
end entity;


architecture behaviour of adder_PC is 

begin 

PC_out<=PC_in + 1;
end ;

------------------------------------------------ PC + immediate (sign extended)--------------------------------------------
----Sadaf Parwaiz Date 18 March 2017 11:32am

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity adder_PC_plus_imm is 
	generic(PC_SIZE:integer:=16);
	port(PC_in:in std_logic_vector(PC_SIZE-1 downto 0);
             SE_in: in std_logic_vector(PC_SIZE-1 downto 0);
		 PC_out:out std_logic_vector(PC_SIZE-1 downto 0));
end entity;


architecture behaviour of adder_PC_plus_imm is 

begin 

PC_out<=PC_in + SE_in;
end ;

-------------------------------------------------Two Complement--------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity twocomplement is
	generic(NO_OF_BIT :integer :=8);
	port(input :in std_logic_vector(NO_OF_BIT -1 downto 0);
		 output :out std_logic_vector(NO_OF_BIT -1 downto 0));
end entity;


architecture behav of twocomplement is
signal C:std_logic_vector(NO_OF_BIT -1 downto 0);
begin
C <=not input;
output <=C +1;

end;


--One bit left shift--------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
entity left_shift is
	generic(NO_OF_BIT :integer :=8);
	port(input :in std_logic_vector(NO_OF_BIT -1 downto 0);
		 output :out std_logic_vector(NO_OF_BIT -1 downto 0));
end entity;

architecture behav of left_shift is
begin
 output <= std_logic_vector(unsigned(input) sll 1);
 
 end;
 -----------------------------------------------------------------------
 
 ----SIGN_EXTENDER--------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity sign_extender is
	generic(NO_OF_INPUT_BIT:integer:=8;
			NO_OF_OUTPUT_BIT:integer:=16);
	port(input :in std_logic_vector(NO_OF_INPUT_BIT -1 downto 0);
		output :out std_logic_vector(NO_OF_OUTPUT_BIT -1 downto 0)
		);
 end entity;
 
architecture behav of sign_extender is
begin

	output(NO_OF_INPUT_BIT -1 downto 0)<=input;
	
SIGN_EXTEND:for i in  NO_OF_INPUT_BIT to NO_OF_OUTPUT_BIT-1 generate
					SI:output(i)<=input(NO_OF_INPUT_BIT-1);


	    end generate;

end;
-----------------------------------------------------------------------
 
----------Zeropadding---------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

 entity zeropadding is 
	generic(NO_OF_INPUT_BIT:integer:=9;
			NO_OF_OUTPUT_BIT:integer:=16);
	port(input :in std_logic_vector(NO_OF_INPUT_BIT -1 downto 0);
		output :out std_logic_vector(NO_OF_OUTPUT_BIT -1 downto 0)
		);
 end entity;
 
 architecture behav of zeropadding is
 begin
 output(NO_OF_OUTPUT_BIT -1 downto 7)<=input;
 output(6 downto 0 ) <=(others=>'0');
 end;
 
 -------Adder-------------------------------------------------------
 
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity adder is 
port (A:in std_logic;
	  B: in std_logic;
	  cin :in std_logic;
	  sum:out std_logic;
	  carry: out std_logic
			);
	end entity;
architecture behav of adder is 

begin

sum <=A xor B xor cin;
carry<= (A and B)or (A and cin) or (B and cin);
end;

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity nbit_adder is 
	generic(NO_OF_ADDER_BIT:integer:=8);	
	port(reset		 : in std_logic;
		input1 	 	:in std_logic_vector(NO_OF_ADDER_BIT-1 downto 0);
		input2 		 :in std_logic_vector(NO_OF_ADDER_BIT-1 downto 0);
		sum			 :out std_logic_vector(NO_OF_ADDER_BIT-1 downto 0);
		carry_flag	 :out std_logic;
		Zero_flag	 :out std_logic);
end entity;

		
architecture behav of nbit_adder is

signal C		:std_logic_vector(NO_OF_ADDER_BIT downto 0);
signal sum1		:std_logic_vector(NO_OF_ADDER_BIT-1 downto 0);
begin

sum <=sum1;
C(0) <= '0';

nbit_adder_inst:for i in 0 to  NO_OF_ADDER_BIT-1  generate 
					adder_inst: entity work.adder port map (input1(i),input2(i),C(i),sum1(i),C(i+1));
				end generate;
				
	carry_flag <= C(NO_OF_ADDER_BIT);
	Zero_flag <='0' when reset='1'else 
				'1'	when((to_integer(unsigned(sum1))=0) and reset='0') 
					else '0';
		
end; 
----------------------------------------------------------------------------- 
 
 ------------NAND-------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
 entity nand_operation is
	generic(NO_OF_NAND_BIT :integer := 8);
	port (reset		: in std_logic;
		input1 		:in std_logic_vector(NO_OF_NAND_BIT-1 downto 0);
		input2 		:in std_logic_vector(NO_OF_NAND_BIT-1 downto 0);
		output		:out std_logic_vector(NO_OF_NAND_BIT-1 downto 0);
		Zero_flag	:out std_logic);
		
	end entity;
	
architecture behav of nand_operation is
signal output1:std_logic_vector(NO_OF_NAND_BIT-1 downto 0);
begin

output1 <= input1 nand input2;
Zero_flag <='1' when ((to_integer(unsigned(output1))=0)and reset='0') else '0';
output <=output1;

end ;
------------------------------------N_BIT_REGISTER-----------------------------------------------------------------------------
 
 
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
 entity nbit_register is 
	generic(SIZE_OF_REGISTER	:integer :=16);
	port(reset		:in std_logic;
		clk			:in std_logic;
		enable		: in std_logic;
		ip_FF		:in std_logic_vector(SIZE_OF_REGISTER-1 downto 0);
		 op_FF		:out std_logic_vector(SIZE_OF_REGISTER-1 downto 0)
	
			);
			
	end entity;
	
	
architecture behav of nbit_register is 
begin


	process(clk,reset)
		begin
			if(reset='1')then
				op_FF <=(others=>'0');
			elsif(clk'event and clk ='1')then
				if(enable='1')then
					op_FF <=ip_FF;
				end if;
				
			end if;
			
		end process;
end;
--------------------------------------------------------------------------------------------------------------------------------------	
------------------------------------N_BIT_REGISTER_STAGE for the intermediate register in the pipeline--------------------------------
 
 
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
 entity nbit_register_stage is 
	generic(END_OF_NBIT_REGISTER_STAGES	:integer :=24;
			BEGIN_OF_NBIT_REGISTER_STAGES:integer:=16);
	port(reset		:in std_logic;
		clk			:in std_logic;
		enable		: in std_logic;
		ip_FF		:in std_logic_vector(END_OF_NBIT_REGISTER_STAGES-1 downto BEGIN_OF_NBIT_REGISTER_STAGES);
		 op_FF		:out std_logic_vector(END_OF_NBIT_REGISTER_STAGES-1 downto BEGIN_OF_NBIT_REGISTER_STAGES)
	
			);
			
	end entity;
	
	
architecture behav of nbit_register_stage is 
begin


	process(clk,reset)
		begin
			if(reset='1')then
				op_FF <=(others=>'0');
			elsif(clk'event and clk ='1')then
				if(enable='1')then
					op_FF <=ip_FF;
				end if;
				
			end if;
			
		end process;
end;
--------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------Special register for LM/SM-------------------------------------------------------------							
 library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


entity LM_SM_special_reg is
	generic(SIZE_OF_REGISTER		:integer :=16);
	port(clk						:in std_logic;
		 enable 					:in std_logic;
		 FWD_Mux_Select_signal1		:in std_logic;
		 FWD_reg_EX_data1			:in std_logic_vector(SIZE_OF_REGISTER-1 downto 0);
		 din						:in std_logic_vector(SIZE_OF_REGISTER-1 downto 0);
		 dout						:out std_logic_vector(SIZE_OF_REGISTER-1 downto 0)	
			);
	end entity;
	
architecture behav of LM_SM_special_reg is
signal prev_enable	: std_logic;
begin
process(clk)
begin
	if(rising_edge(clk))then
		if(FWD_Mux_Select_signal1='1')then
			dout	<=FWD_reg_EX_data1;
		elsif(prev_enable='0' and enable='1')then
			dout	<=din;
		end if;
		prev_enable	<=enable;
	end if;
end process;
end;
-------------------------------------------------------------------------------------------------------------------------------------


