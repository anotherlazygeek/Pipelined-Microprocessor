library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-------------Defined package-------------------------
use work.Package_component_Pipeline.all;
--------------------------------------------------------
 

entity Memory_stage is
port ( reset	:in std_logic;
	   clk		:in std_logic;

		-------------------- Coming from previous stage --------------------------------------------------------
	   
	  EX_MEM_ALU_output_in 		: in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
	  EX_MEM_ZP_D2_in 			: in std_logic_vector(2*INSTRUCTION_SIZE-1 downto 0);
	  EX_MEM_CZ_ALU_Ctrl_in 	: in std_logic_vector(4 downto 0);
	  EX_MEM_PC_in				: in std_logic_vector(3*PC_SIZE-1 downto 0);
	  EX_MEM_CONTROL_SIGNAL_in 	: in std_logic_vector(CONTROLLER_OUT_SIZE-1 downto MM_STAGE_BEGIN);
	  EX_MEM_Priority_Zero_in	: in std_logic_vector(PRIORITY_OUTPUT_SIZE downto 0);
	   
	   -----------------------------Enable to this stage------------------------------------------------------------
		enable_MEM_WB_reg			: in std_logic;
		zero_flag_mem_update_sig	: out std_logic;	
	  --------------------- Going to Next Stage(i.e Data Memory Access Stage) ---------------------
	  -----------The ZP is the zero padded which is used for the LHI  instruction.It is being passed from the register read stage----------------
	  MEM_WB_ZP_out					:out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
	  MEM_WB_ALU_output_out 		:out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
	  MEM_WB_ReadData_out 			:out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
	  MEM_WB_CZ_ALU_Ctrl_out 		:out std_logic_vector(4 downto 0);
	  MEM_WB_PC_1_imm_RB_out		:out std_logic_vector(PC_SIZE-1 downto 0);
	  MEM_WB_PC_and_PC_plus1_out 	:out std_logic_vector(2*PC_SIZE-1 downto 0);
	  MEM_WB_CONTROL_SIGNAL_OUT 	:out std_logic_vector(CONTROLLER_OUT_SIZE-1 downto WR_STAGE_BEGIN);
	  MEM_WB_Priority_Zero_out		:out std_logic_vector(PRIORITY_OUTPUT_SIZE downto 0);
	  
	  ---------------------Taking for the MEM stage------------------------------------------------------------------------------
	  FWD_reg_MEM_addr2									:in std_logic_vector(SIZE_OF_INPUT_BIT-1 downto 0);
	  FWD_reg_MEM_data2									:in std_logic_vector(DATA_WIDTH-1 downto 0);
	  FWD_Mux_MEM_Select_signal2						:in std_logic
	  --------------------------------------------------------------------------------------------------------------------------
	  
     );
end entity;

architecture Memory_stage_arch of Memory_stage is 

signal data_out_sig 				:std_logic_vector(DATA_WIDTH-1 downto 0);
signal PC_1_imm_RB_sig 				:std_logic_vector(PC_SIZE-1 downto 0); 
signal	trial_EX_MEM_CONTROL		:std_logic_vector(1 downto 0);
signal	opcode_MEM					:std_logic_vector(3 downto 0);
signal	data_in						:std_logic_vector(DATA_WIDTH-1 downto 0);
begin

opcode_MEM  <=EX_MEM_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9);
-----------PC+1 or PC+immediate or RB for the instruction Others,BEQ and JLR respectively--------------------------------------------------
trial_EX_MEM_CONTROL	<=EX_MEM_CONTROL_SIGNAL_in(MM_STAGE_BEGIN+3 downto MM_STAGE_BEGIN+2);
PC_1_imm_RB_sig <= EX_MEM_PC_in(31 downto 16) when EX_MEM_CONTROL_SIGNAL_in(MM_STAGE_BEGIN+3 downto MM_STAGE_BEGIN+2) ="00" else
					EX_MEM_PC_in(47 downto 32) when EX_MEM_CONTROL_SIGNAL_in(MM_STAGE_BEGIN+3 downto MM_STAGE_BEGIN+2) ="01" else	
					EX_MEM_ZP_D2_in(15 downto 0) when EX_MEM_CONTROL_SIGNAL_in(MM_STAGE_BEGIN+3 downto MM_STAGE_BEGIN+2) ="10";
		
		
----------The load instruction will modify the zero flag .If the content of the memory location is zero then the zero flag will be set otherwise reset.
zero_flag_mem_update_sig	<= '1' when (data_out_sig="0000000000000000" and EX_MEM_CONTROL_SIGNAL_in(MM_STAGE_BEGIN+4)='1') else '0' ;					




data_in		<=FWD_reg_MEM_data2 when FWD_Mux_MEM_Select_signal2='1' else EX_MEM_ZP_D2_in(15 downto 0);
----------------Data memory--------------------------------------------------------------------------------------------
Memory_inst	 : memory generic map(ADDR_WITH=>ADDRESS_WIDTH, DATA_WIDTH => DATA_WIDTH) 
					port map(	clk	      =>	clk,
							mem_write =>	EX_MEM_CONTROL_SIGNAL_in(MM_STAGE_BEGIN),
							mem_read  =>    EX_MEM_CONTROL_SIGNAL_in(MM_STAGE_BEGIN+1),
							addr	  =>	EX_MEM_ALU_output_in,
							data_in	  =>	data_in,
							data_out  =>	data_out_sig
						);
---------------------------ALU_ Output-----------------------------------------------------------------------------------
						
MEM_WB_ALU_output_inst: nbit_register generic map(SIZE_OF_REGISTER=>INSTRUCTION_SIZE)
								port map	(reset=>reset,
											 clk=>clk,
											 enable=>enable_MEM_WB_reg,
											 ip_FF=>EX_MEM_ALU_output_in,
											 op_FF=>MEM_WB_ALU_output_out);
----------------------------------Sending data from Memory into MEM/WB reg-----------------------------------------------
MEM_WB_ReadData_inst: nbit_register generic map(SIZE_OF_REGISTER=>INSTRUCTION_SIZE)
								port map	(reset=>reset,
											 clk=>clk,
											 enable=>enable_MEM_WB_reg,
											 ip_FF=>data_out_sig,
											 op_FF=>MEM_WB_ReadData_out);
-----------------------------------CZ sent to the MEM/WB register---------------------------------------------------------
MEM_WB_carry_zero_flag_inst : nbit_register generic map(SIZE_OF_REGISTER=>5) 
								port map	(reset=>reset,
											 clk=>clk,
											 enable=>enable_MEM_WB_reg,
											 ip_FF=>EX_MEM_CZ_ALU_Ctrl_in,
											 op_FF=>MEM_WB_CZ_ALU_Ctrl_out);
											 
-----------------------------------	Zero padded for the LHI  instruction --------------------------------------------------------										 
MEM_WB_ZP		:nbit_register generic map(SIZE_OF_REGISTER=>16) 
								port map	(reset=>reset,
											 clk=>clk,
											 enable=>enable_MEM_WB_reg,
											 ip_FF=>EX_MEM_ZP_D2_in(31 downto 16),
											 op_FF=>MEM_WB_ZP_out);											 
											 


----------------------------------Sending the data to be sored into Rb in JLR------------------------------------------------------
MEM_WB_PC_1_imm_RB_inst: nbit_register generic map(SIZE_OF_REGISTER=>PC_SIZE)
								port map	(reset=>reset,
											 clk=>clk,
											 enable=>enable_MEM_WB_reg,
											 ip_FF=> PC_1_imm_RB_sig,
											 op_FF=>MEM_WB_PC_1_imm_RB_out);


-------------------------------------------PC AND PC+1 into the MEM/WB_reg------------------------------------------------------											 
MEM_WB_PC_and_PC_plus1_inst: nbit_register generic map(SIZE_OF_REGISTER=>2*PC_SIZE)
								port map	(reset=>reset,
											 clk=>clk,
											 enable=>enable_MEM_WB_reg,
											 ip_FF=>EX_MEM_PC_in(2*PC_SIZE-1 downto 0),
											 op_FF=>MEM_WB_PC_and_PC_plus1_out);
--------------------------------------------Control Signals--------------------------------------------------------------------
MEM_WB_CONTROL_SIGNAL_OUT_inst: nbit_register_stage  generic map(END_OF_NBIT_REGISTER_STAGES=>CONTROLLER_OUT_SIZE,
																BEGIN_OF_NBIT_REGISTER_STAGES=>WR_STAGE_BEGIN)
													port map	(reset=>reset,
																 clk=>clk,
																 enable=>enable_MEM_WB_reg,
																 ip_FF=>EX_MEM_CONTROL_SIGNAL_in(CONTROLLER_OUT_SIZE-1 downto WR_STAGE_BEGIN),
																 op_FF=>MEM_WB_CONTROL_SIGNAL_OUT(CONTROLLER_OUT_SIZE-1 downto WR_STAGE_BEGIN));
																
----------------------------------------------- Sadaf Date : 27 March ---------------------------------------
MEM_WB_Priority_Zero_inst: nbit_register generic map(SIZE_OF_REGISTER=>4)
								port map	(reset=>reset,
											 clk=>clk,
											 enable=>enable_MEM_WB_reg,
											 ip_FF=>EX_MEM_Priority_Zero_in,
											 op_FF=>MEM_WB_Priority_Zero_out);


					
end architecture;





