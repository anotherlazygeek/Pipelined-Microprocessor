

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
entity ALU is 	
generic(NO_OF_ALU_BIT:integer:=8;SIZE_OF_ALU_CONTROL_SIGNAL :integer:=3);	
	port(reset		: in std_logic;
		Alu_op		:in std_logic_vector(SIZE_OF_ALU_CONTROL_SIGNAL-1 downto 0);
		input1 		:in std_logic_vector(NO_OF_ALU_BIT-1 downto 0);
		input2 		:in std_logic_vector(NO_OF_ALU_BIT-1 downto 0);
		output		:out std_logic_vector(NO_OF_ALU_BIT-1 downto 0);
		carry_flag	 :out std_logic;
		Zero_flag	 :out std_logic);
	end entity;

architecture behav of ALU is 

component nbit_adder is 
	generic(NO_OF_ADDER_BIT:integer:=8);	
	port(reset		 : in std_logic;
		input1 	 	:in std_logic_vector(NO_OF_ADDER_BIT-1 downto 0);
		input2 		 :in std_logic_vector(NO_OF_ADDER_BIT-1 downto 0);
		sum			 :out std_logic_vector(NO_OF_ADDER_BIT-1 downto 0);
		carry_flag	 :out std_logic;
		Zero_flag	 :out std_logic);
end component;


component nand_operation is
	generic(NO_OF_NAND_BIT :integer := 8);
	port (	reset		 : in std_logic;
			input1 		:in std_logic_vector(NO_OF_NAND_BIT-1 downto 0);
			input2 		:in std_logic_vector(NO_OF_NAND_BIT-1 downto 0);
			output		:out std_logic_vector(NO_OF_NAND_BIT-1 downto 0);
			Zero_flag	:out std_logic);
end component;


signal output_nbitadder		:std_logic_vector(NO_OF_ALU_BIT-1 downto 0);
signal output_nand 		:std_logic_vector(NO_OF_ALU_BIT-1 downto 0);
signal Zero_flag_adder	:std_logic;
signal Zero_flag_nand	:std_logic;
signal carry_flag_sig	:std_logic;


begin 

nbit_adder_inst:nbit_adder	generic map(NO_OF_ADDER_BIT=>NO_OF_ALU_BIT)
								port map (reset=>reset,
									input1=>input1,
									input2=>input2, 
									sum=>output_nbitadder,
									carry_flag=>carry_flag_sig,
									Zero_flag=>Zero_flag_adder);

nand_operation_inst:nand_operation generic map(NO_OF_NAND_BIT=>NO_OF_ALU_BIT)
									port map (		reset=>reset,
												input1=>input1,
												input2=>input2, 
												output=>output_nand,
												Zero_flag=>Zero_flag_nand);
												
												
												
		output 		<= (others=>'0')when reset	='1'else
						output_nbitadder when Alu_op (2)='0' else
						output_nand;
		Zero_flag	<=	'0' when reset	='1'  else
						Zero_flag_adder   when (Alu_op(2) ='0' and Alu_op(0) ='1') else
						Zero_flag_nand 	when (Alu_op(2) ='1' and Alu_op(0) ='1'  ) ;
						 
					  
						
		Carry_flag <= '0' when reset='1' else
						carry_flag_sig  	when (Alu_op(2) ='0' and Alu_op(1) ='1') ; 
									
end;

