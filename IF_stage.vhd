
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-------------Defined package-------------------------
use work.Package_component_Pipeline.all;
--------------------------------------------------------
entity IF_stage is 
	
	port(reset: in std_logic;
		clk:in std_logic;
		enable_IF_ID_reg			:in std_logic;
		enable_PC					:in std_logic;
		IF_ID_mem_out				:out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
		IF_ID_PC_out				:out std_logic_vector(2*PC_SIZE-1 downto 0);
		
		
		IF_ID_mem_out_reg_in_alias	:out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
		-------------------Updating the PC from the writeback stage----------------------------------------
		 PC_LHI									 :in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
		 PC_BEQ    								 : in 	std_logic_vector(3*PC_SIZE-1 downto 2*PC_SIZE); ---BEQ PC + imm6 from EX_stage
		 PC_imm_JAL								 : in	std_logic_vector(PC_SIZE-1 downto 0);   	  -----JAL PC + imm9	from RR_stage
		 PC_JLR 								 : in	std_logic_vector(PC_SIZE-1 downto 0);    	-----JLR PC <= RB		from RR_stage
		 PC_ADD_NAND_R7_Jump					 : in  std_logic_vector(PC_SIZE-1 downto 0);		---------ADD_NAND R7 desitination
		 PC_ADC_NDC_R7_Jump						 : in  std_logic_vector(PC_SIZE-1 downto 0);
		 PC_ADZ_NDZ_R7_Jump						 : in  std_logic_vector(PC_SIZE-1 downto 0);
		 ID_RR_control_logic_opcode			 	 : in 	std_logic_vector(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9);
		 RR_EX_second_stage_control_logic_in	 : in 	std_logic_vector(CONTROLLER_OUT_SIZE-1	downto EX_STAGE_BEGIN);
		 EX_MEM_Zero_flag						 : in std_logic;
		 ID_RR_control_logic_A3					 :in std_logic_vector(2 downto 0);
		 RR_EX_control_logic_A3					 :in std_logic_vector(2 downto 0);
		 CZ_forward								 :in std_logic_vector(1 downto 0)			  
		---------------------------------------------------------------------------------------------------
		
			);
	end entity;
	
	
architecture Structural of IF_stage is
signal updated_PC_frm_mux :std_logic_vector(PC_SIZE-1 downto 0);
signal current_PC		  :std_logic_vector(PC_SIZE-1 downto 0);
signal increamented_PC	  :std_logic_vector(PC_SIZE-1 downto 0);
signal inst_mem_out		  :std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
constant constant_memory  :std_logic_vector(INSTRUCTION_SIZE -1 downto 0):=(others=>'0');



signal opcode_check			:std_logic_vector(3  downto 0);
signal A3_check				:std_logic_vector(2 downto 0);	
signal CZ_check				:std_logic_vector(1 downto 0);
signal	ADC_check			:std_logic_vector(1 downto 0);
----------------------------------------------------------------------------------------------------
signal IF_ID_mem_out_reg_in			:std_logic_vector(INSTRUCTION_SIZE-1 downto 0);

--Consist of PC and PC+1----------------------------------------------------------------------------
signal	IF_ID_PC_in			:std_logic_vector(2*PC_SIZE-1 downto 0);	
------------------------------------------------------------------------------------------------
-------------------------


begin



	IF_ID_mem_out_reg_in_alias<=IF_ID_mem_out_reg_in;

	PC_reg:nbit_register 	generic map(SIZE_OF_REGISTER=>16)
							port map(reset=>reset,
									enable=>enable_PC,
									clk =>clk,
									ip_FF=>updated_PC_frm_mux,
									op_FF=>current_PC
									);
									
	IM		:memory generic map(ADDR_WITH=>16,
					DATA_WIDTH=>16)
						port map (clk=>clk,
								mem_write=>'0',
								mem_read=>'1',
								addr=>current_PC,
								data_in=>constant_memory,
								data_out=>inst_mem_out
								);
			
			
		
							
	Adder_incr_pc:adder_PC port map (PC_in	=>current_PC,
								PC_out	=>increamented_PC
								);
									
									

	------------------------Sending the data to the next stage------------------------------------------------------------


	IF_ID_mem_out_reg_in			<=inst_mem_out;
	IF_ID_PC_in(15 downto 0)			<=current_PC;
	IF_ID_PC_in(31 downto 16)		<=increamented_PC;
	
	Inst_mem_inst:nbit_register generic map(SIZE_OF_REGISTER=>16)
								port map	(reset=>reset,
											 clk=>clk,
											 enable=>enable_IF_ID_reg,
											 ip_FF=>IF_ID_mem_out_reg_in,
											 op_FF=>IF_ID_mem_out);
	
	
	PC_inst:nbit_register generic map(SIZE_OF_REGISTER=>32)
								port map	(reset=>reset,
											 clk=>clk,
											 enable=>enable_IF_ID_reg,
											 ip_FF=>IF_ID_PC_in,
											 op_FF=>IF_ID_PC_out);
											 
	------------------------- Update PC from MUX ------------------------------------------------------------------------
updated_PC_frm_mux<=
				---------------------------------Jump_in RR_stage------------------------------------------------
			PC_LHI		 when (ID_RR_control_logic_opcode(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0011" and ID_RR_control_logic_A3 ="111" )else
	        PC_imm_JAL	 when ID_RR_control_logic_opcode(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9) = "1000" else     ---JAL (from RR_stage) PC + imm9
			
			------------------------------------Jump in EX stage--------------------------------------------------
			PC_JLR 		when RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9) = "1001" else      ---JLR (from RR_stage) RB
			PC_ADC_NDC_R7_Jump when --ADC
								(RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9) = "0000" 
								and RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3 )="10"	
								and RR_EX_control_logic_A3="111"
								and CZ_forward(1)='1'
								 ) else
			
			PC_ADZ_NDZ_R7_Jump when ---ADZ
								(RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9) = "0000" 
								and RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="01"	
								and RR_EX_control_logic_A3="111"
								and CZ_forward(0)='1' 
								)else
			
			
			PC_ADD_NAND_R7_Jump when 
										
									(RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9) = "0000" 
									and RR_EX_control_logic_A3="111"
									and RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="00"	)or
									
									(RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9) = "0001" 
									and RR_EX_control_logic_A3="111"
									and RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="00"	)or
									
									(RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9) = "0010" 
																												and RR_EX_control_logic_A3="111")
																												
																												
																																			 else
			--	BEQ																																	 
			PC_BEQ when (RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9) = "1100" and EX_MEM_Zero_flag='1')
			else     ---BEQ (from EX_stage)
			---------------------------------------------------------------------------------------------------------------------------------------
			increamented_PC ; 
	              
	
	opcode_check	<=RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9);
	A3_check		<=RR_EX_control_logic_A3;
	CZ_check		<=CZ_forward;
	ADC_check		<=RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3 );
end;
	
	
	
