
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.std_logic_unsigned.all;
-------------Defined package-------------------------
use work.Package_component_Pipeline.all;
--------------------------------------------------------
entity	LM_SM_logic is
	generic(INSTRUCTION_SIZE:integer :=16);
	port(clk			:in std_logic;
		reset			:in std_logic;
		priority_zero	:in std_logic_vector(0 downto 0);
		enable_displacement	:in std_logic;
		displacement_out	:out std_logic_vector(INSTRUCTION_SIZE-1 downto 0)
			);
			
	end entity;
	
architecture behaviour of  LM_SM_logic is 
signal displacement_sig		:std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal resultant_displacement	:std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal new_displacement_sig	:std_logic_vector(INSTRUCTION_SIZE-1 downto 0);


signal displacement_mux_select			:std_logic;
begin

process(clk)
	begin
	if(rising_edge(clk))then
		if((enable_displacement='1')and (priority_zero="0")) then
			displacement_mux_select			<='1';
		else
			displacement_mux_select			<='0';
		end if;
	end if;
end process;
		

INCR_inst:adder_PC generic map (PC_SIZE=>16) port map(PC_in=>displacement_sig,
													PC_out=>new_displacement_sig);
													

resultant_displacement <=new_displacement_sig when displacement_mux_select='1' else "0000000000000000";



REG_inst	:nbit_register generic map(SIZE_OF_REGISTER	=>16) port map(reset=>reset,
																		clk=>clk,
																		enable=>enable_displacement,
																		ip_FF=>resultant_displacement,
																		op_FF=>displacement_sig);
displacement_out	<=resultant_displacement;

end;



--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;
---------------Defined package-------------------------
--use work.Package_component_Pipeline.all;
--------------------------------------------------------

--entity LM_SM_logic_and_priority is
	--generic(PRIORITY_INPUT_SIZE:integer :=8;PRIORITY_OUTPUT_SIZE:integer:=3;INSTRUCTION_SIZE:integer :=16);
	--port (reset					:in std_logic;
		--clk 					:in std_logic;
		--enable_priority_disp			:in std_logic;
		--priority_disp_mux_sel			:in std_logic;
		--priority_ip_immediate 	:in std_logic_vector(PRIORITY_INPUT_SIZE -1 downto 0);
		--priority_zero			:out std_logic;
		--op_to_register_file		:out std_logic_vector(PRIORITY_OUTPUT_SIZE-1 downto 0);
		--displacement_out	:out std_logic_vector(INSTRUCTION_SIZE-1 downto 0)
			--);
	--end entity;


--architecture Structural of LM_SM_logic_and_priority is

--signal enable_displacement		:std_logic;
--signal enable_priority			:std_logic;
--signal priory_mux_sel			:std_logic;	
--signal displacement_mux_select	:std_logic;
--signal priority_zero_sig		:std_logic;
--signal displacement_out_sig		:std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
--begin


--enable_displacement			<=enable_priority_disp;
--enable_priority				<=enable_priority_disp;
--priory_mux_sel				<=priority_disp_mux_sel;
--displacement_mux_select		<=priority_disp_mux_sel;
--priority_zero				<=priority_zero_sig;


--priority_logic_inst:priority_logic port map (reset=>reset,
											--clk=>clk,
											--enable_priority=>enable_priority,
											--priory_mux_sel=>priory_mux_sel,
											--priority_zero=>priority_zero_sig,
											--priority_ip_immediate=>priority_ip_immediate,
											--op_to_register_file=>op_to_register_file);

--LM_SM_logic_inst:LM_SM_logic port map(reset=>reset,
										--clk=>clk,
										--enable_displacement		=>enable_displacement,
										--displacement_mux_select=>displacement_mux_select,
										--displacement_out		=>displacement_out_sig);

										
--displacement_out		<=displacement_out_sig when priority_zero_sig='0' else std_logic_vector(to_unsigned(16#0000#, 16));---Before# specify the base and after comma specify the number of bits


--end;



