
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-------------Defined package-------------------------
use work.Package_component_Pipeline.all;
--------------------------------------------------------

entity ID_stage is
		port(reset		:in std_logic;
		clk				:in std_logic;
		opcode			:inout std_logic_vector(INSTRUCTION_SIZE -1 downto INSTRUCTION_SIZE -4);
		--------------------Comming from previous stage---------------------------------------------------------------
		IF_ID_mem_in			:in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
		IF_ID_PC_in				:in std_logic_vector(2*PC_SIZE-1 downto 0);
		---------------------------------------------------------------------------------------------------------------
		-----------------------------Enable to this stage and ports------------------------------------------------------------
		enable_ID_RR_reg		: in std_logic;
		ID_RR_Priority_in		:in std_logic_vector(PRIORITY_OUTPUT_SIZE downto 0);
		op_to_register_file 	:out std_logic_vector(PRIORITY_OUTPUT_SIZE-1 downto 0);
		 priority_zero			:out std_logic;
		
		-------------------Going to the next stage---------------------------------------------------------------------
		ID_RR_control_logic_out		:out std_logic_vector(CONTROLLER_OUT_SIZE-1	downto RR_STAGE_BEGIN);
		ID_RR_Priority_out			:out std_logic_vector(PRIORITY_OUTPUT_SIZE downto 0);--includes op_to_register_file and priority_zero
		ID_RR_first_stage_mem_out	:out std_logic_vector(INSTRUCTION_SIZE-1	downto 0);
		ID_RR_first_stage_PC_out	:out std_logic_vector(2*PC_SIZE-1 downto 0);
		------------------------------enable_priority =0 when load_stall_LM_Out =1
		load_stalls					:in std_logic;
		load_stall_LM_out			:out std_logic
		);
end entity;

architecture structural of ID_stage is
--signal op_to_register_file 		:std_logic_vector(PRIORITY_OUTPUT_SIZE-1 downto 0);
--signal ID_RR_control_logic_in	:std_logic_vector(CONTROLLER_OUT_SIZE-1 downto RR_STAGE_BEGIN);

-----------------------------Priority_Signals begins------------------------------------------------
----Includes op_to_register_file and priority_zero----------------------------------
--signal	ID_RR_Priority_in		:std_logic_vector(3 downto 0);
-------------------------------------------------------------------------------------
signal enable_priority	        :std_logic;
--signal priority_zero		    :std_logic;
signal priority_mux_sel			:std_logic			:='0';
signal priority_ip_immediate 	:std_logic_vector(PRIORITY_INPUT_SIZE -1 downto 0);


----------------------------Priority_Signals ends--------------------------------------------------------

signal	ID_RR_first_stage_mem_in	:std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal	ID_RR_first_stage_PC_in		:std_logic_vector(2*PC_SIZE-1 downto 0);
signal	CONTROL_SIGNAL_OUT			:std_logic_vector(CONTROLLER_OUT_SIZE-1	downto 0);
signal	CONTROL_SIGNAL_OUT_alias	:std_logic_vector(CONTROLLER_OUT_SIZE-1	downto 0);
signal	CONTROL_SIGNAL_in			:std_logic_vector(CONTROLLER_OUT_SIZE-1	downto 0);


signal ID_RR_control_logic_t		:std_logic_vector(CONTROLLER_OUT_SIZE-1	downto RR_STAGE_BEGIN);
signal	load_stall_LM				:std_logic;
begin



ID_inst	:Decoder port map(reset		=>reset,
						clk			=>clk,	
						INSTRUCTION=>IF_ID_mem_in,
						 opcode_out		=>opcode,	
						CONTROL_SIGNAL_OUT=>CONTROL_SIGNAL_OUT);
						
------------------------------------Introducing stall for load followed by LM
CONTROL_SIGNAL_OUT_alias(ID_STAGE_BEGIN)							<='0';	
CONTROL_SIGNAL_OUT_alias(WR_STAGE_BEGIN+4 downto RR_STAGE_BEGIN)	<=(others=>'0');--ID_RR_control_logic_t(WR_STAGE_BEGIN+4 downto RR_STAGE_BEGIN);
CONTROL_SIGNAL_OUT_alias(WR_STAGE_BEGIN+8 downto WR_STAGE_BEGIN+5)	<='0' & CONTROL_SIGNAL_OUT(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5);
CONTROL_SIGNAL_OUT_alias(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)	<="1111";


CONTROL_SIGNAL_in	<=CONTROL_SIGNAL_OUT_alias when (load_stall_LM='1') else CONTROL_SIGNAL_OUT;	
--CONTROL_SIGNAL_in	<=CONTROL_SIGNAL_OUT;			
------------------------------------ Priority Logic --------------------------------------											 
priority_mux_sel		 <= not CONTROL_SIGNAL_in(ID_STAGE_BEGIN) when rising_edge(clk);
priority_ip_immediate	 <=CONTROL_SIGNAL_OUT(RR_STAGE_BEGIN+20-1 downto RR_STAGE_BEGIN+12) when 
							CONTROL_SIGNAL_OUT(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0110" or
							CONTROL_SIGNAL_OUT(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0111"  else
							(others=>'0'); ---- immediate 8 bits

-----------------Stalling for Load followed by LM with R_A3=R_A1----------------------------------------------------------

load_stall_LM	<='1' when 
		((ID_RR_control_logic_t(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0100" 
			 
		and CONTROL_SIGNAL_OUT(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0110" 
		and (ID_RR_control_logic_t(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)= CONTROL_SIGNAL_OUT(RR_STAGE_BEGIN+2 downto  RR_STAGE_BEGIN))
		and CONTROL_SIGNAL_OUT(WR_STAGE_BEGIN+2)='1')
			
			)
			else 
			'0';

load_stall_LM_out	<=	load_stall_LM;



															

priority_logic_inst : priority_logic generic map (PRIORITY_INPUT_SIZE =>PRIORITY_INPUT_SIZE,PRIORITY_OUTPUT_SIZE =>PRIORITY_OUTPUT_SIZE) 
	
								port map (reset	 =>	reset,			
									clk 		 =>	clk	,	
									enable_priority		=>	CONTROL_SIGNAL_in(ID_STAGE_BEGIN),
									priory_mux_sel =>		priority_mux_sel,	
									priority_zero =>priority_zero,
									priority_ip_immediate => priority_ip_immediate,
									op_to_register_file	=>op_to_register_file
									);
									
									

--------------------------------------------------------------------------------------------------------------------------






ID_RR_first_stage_mem_in 	<=IF_ID_mem_in;
	
ID_RR_first_stage_PC_in		<=IF_ID_PC_in;



ID_RR_control_inst: nbit_register_stage generic map (END_OF_NBIT_REGISTER_STAGES => CONTROLLER_OUT_SIZE,
			                                         BEGIN_OF_NBIT_REGISTER_STAGES => RR_STAGE_BEGIN)
								port map	(reset=>reset,
											 clk=>clk,
											 enable=>enable_ID_RR_reg,
											 ip_FF=>CONTROL_SIGNAL_in(CONTROLLER_OUT_SIZE-1 downto RR_STAGE_BEGIN),
											 op_FF=>ID_RR_control_logic_t);
											 
											 
ID_RR_control_logic_out	<=ID_RR_control_logic_t;

ID_RR_Priority_inst: nbit_register generic map(SIZE_OF_REGISTER=>4)
								port map	(reset=>reset,
											 clk=>clk,
											 enable=>enable_ID_RR_reg,
											 ip_FF=>ID_RR_Priority_in,
											 op_FF=>ID_RR_Priority_out);

ID_RR_first_stage_mem_inst: nbit_register generic map(SIZE_OF_REGISTER=>16) 
								port map	(reset=>reset,
											 clk=>clk,
											 enable=>enable_ID_RR_reg,
											 ip_FF=>ID_RR_first_stage_mem_in,
											 op_FF=>ID_RR_first_stage_mem_out);

ID_RR_first_stage_PC_inst: nbit_register generic map(SIZE_OF_REGISTER=>32) 
								port map	(reset=>reset,
											 clk=>clk,
											 enable=>enable_ID_RR_reg,
											 ip_FF=>ID_RR_first_stage_PC_in,
											 op_FF=>ID_RR_first_stage_PC_out);

	
end;					
						





