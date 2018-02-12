

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
-------------Defined package-------------------------
use work.Package_component_Pipeline.all;
--------------------------------------------------------


entity Datapath is 
	port(clk :in std_logic;
		 reset:in std_logic;
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
	
architecture  Structural of Datapath is

signal	opcode			: std_logic_vector(INSTRUCTION_SIZE -1 downto INSTRUCTION_SIZE -4);
--------------------Enable of the intermediate registers of various stages----------------------------------------------------------------
signal enable_PC					:std_logic;
signal enable_IF_ID_reg				:std_logic;
signal enable_ID_RR_reg				:std_logic;
signal enable_RR_EX_reg				:std_logic;
signal enable_EX_MEM_reg			:std_logic;
signal enable_MEM_WB_reg			:std_logic;
------------------------------------------------------------------------------------------------------------------------------------------
		-----	IF/ID intermediate signal------------------ 
signal IF_ID_mem_out_reg_in_alias	:std_logic_vector(INSTRUCTION_SIZE-1  downto 0);	
signal IF_ID_mem_sig				:std_logic_vector(INSTRUCTION_SIZE-1  downto 0);
signal IF_ID_PC_sig					:std_logic_vector(2*PC_SIZE-1		  downto 0);
signal IF_ID_mem_jump				:std_logic_vector(INSTRUCTION_SIZE-1  downto 0);

-------------------------------------------------------------------------------------------------------------------------------------------
signal op_to_register_file 	:std_logic_vector(PRIORITY_OUTPUT_SIZE-1 downto 0);
signal priority_zero		:std_logic;
signal	ID_RR_Priority_in	:std_logic_vector(PRIORITY_OUTPUT_SIZE downto 0);
		-----	ID/RR intermediate signal------------------ 
signal	ID_RR_control_logic_sig		:std_logic_vector(CONTROLLER_OUT_SIZE-1  downto RR_STAGE_BEGIN);
signal	ID_RR_Priority_sig			:std_logic_vector( PRIORITY_OUTPUT_SIZE downto 0):=(others=>'0');
signal	ID_RR_first_stage_mem_sig	:std_logic_vector(INSTRUCTION_SIZE-1  downto 0);
signal	ID_RR_first_stage_PC_sig	:std_logic_vector(2*PC_SIZE-1  downto 0);

signal	ID_RR_control_logic_jump	:std_logic_vector(CONTROLLER_OUT_SIZE-1  downto RR_STAGE_BEGIN);
------------------------------------------------------------------------------------------------------------------------------------------
		---	RR/EX intermediate signal------------------ 
signal	RR_EX_second_stage_control_logic_sig		:std_logic_vector(CONTROLLER_OUT_SIZE-1	downto EX_STAGE_BEGIN);
signal	RR_EX_second_stage_control_logic_sig_alias	:std_logic_vector(CONTROLLER_OUT_SIZE-1	downto EX_STAGE_BEGIN);
signal	RR_EX_second_stage_control_logic_sig2		:std_logic_vector(CONTROLLER_OUT_SIZE-1	downto EX_STAGE_BEGIN);
signal	RR_EX_reg_file_and_SE_ZP_sig				:std_logic_vector(4*INSTRUCTION_SIZE-1  downto 0);
signal 	RR_EX_PC_sig								:std_logic_vector(3*PC_SIZE-1  downto 0);
signal 	RR_EX_Priority_Zero_sig						:std_logic_vector(PRIORITY_OUTPUT_SIZE downto 0);
signal	LM_SM_reg_sig								:std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
--------------------------------------------------------------------------------------------------------------------------------------------
		------EX/MM intermediate signal------------------ 
signal	EX_MEM_CZ_ALU_Ctrl_in		:std_logic_vector(4 downto 0);
signal 	EX_MEM_CZ_ALU_Ctrl_sig 		:std_logic_vector(4 downto 0); 	
signal	EX_MEM_CZ_ALU_Ctrl_sig_load	:std_logic_vector(4 downto 0);	
signal 	EX_MEM_ALU_output_sig		:std_logic_vector(INSTRUCTION_SIZE-1  downto 0);
signal 	EX_MEM_ZP_D2_sig			:std_logic_vector(2*INSTRUCTION_SIZE-1 downto 0);
signal 	EX_MEM_PC_sig				:std_logic_vector(3*PC_SIZE-1  downto 0);
signal 	EX_MEM_CONTROL_SIGNAL_sig	:std_logic_vector(CONTROLLER_OUT_SIZE-1	downto MM_STAGE_BEGIN);
signal	EX_MEM_Priority_Zero_sig	:std_logic_vector(PRIORITY_OUTPUT_SIZE downto 0);
signal  zero_update_sig             :std_logic;
signal  MUX_ALU_ZP_D2_sig           :std_logic_vector(INSTRUCTION_SIZE-1  downto 0);

----------------------------------------------------------------------------------------------------------------------------------------------
		------MM/WB intermediate signal
		
signal MEM_WB_ZP_sig					:std_logic_vector(INSTRUCTION_SIZE-1  downto 0);
signal MEM_WB_ALU_output_sig			:std_logic_vector(INSTRUCTION_SIZE-1  downto 0);
signal MEM_WB_ReadData_sig				:std_logic_vector(INSTRUCTION_SIZE-1  downto 0);
signal MEM_WB_CZ_ALU_Ctrl_sig			:std_logic_vector(4 downto 0);
signal MEM_WB_PC_1_imm_RB_sig			:std_logic_vector(PC_SIZE-1  downto 0);
signal MEM_WB_PC_and_PC_plus1_sig		:std_logic_vector(2*PC_SIZE-1  downto 0);
signal MEM_WB_CONTROL_SIGNAL_sig 		:std_logic_vector(CONTROLLER_OUT_SIZE-1 downto WR_STAGE_BEGIN);
signal MEM_WB_Priority_Zero_sig			:std_logic_vector(PRIORITY_OUTPUT_SIZE downto 0);
signal zero_flag_mem_update_sig			:std_logic;

-----------------------------------------------------------------------------------------------------------------------------------------------
--signal	enable_CZ_reg					:std_logic			:='1';
signal 	WB_Data_to_Reg					:std_logic_vector(INSTRUCTION_SIZE-1 downto 0);     --- Data_from_memory, ALU_output, (PC+1/PC+imm/RB)
signal	WB_RegA3_out         			:std_logic_vector(2 downto 0);	  
signal	WB_RegWrite           			:std_logic;  
signal  WB_RegR7_in          			:std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal	WB_R7_write           			:std_logic;
signal  WB_carry_zero_out				:std_logic_vector(1 downto 0);
signal	WB_Priority_Zero_out			:std_logic_vector(PRIORITY_OUTPUT_SIZE downto 0 );
------------------------From RR to IF PC signal for Jump----------------------------------------------------------------------------------------

signal	PC_imm_JAL						:std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal	PC_JLR							:std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal	PC_LHI							:std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal	PC_ADD_NAND_R7_Jump				:std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal	PC_ADC_NDC_R7_Jump				:std_logic_vector(PC_SIZE-1 downto 0);
signal	PC_ADZ_NDZ_R7_Jump				:std_logic_vector(PC_SIZE-1 downto 0);
------------------------From EX to IF PC for BEQ-------------------------------------------------------------------------------------------------
signal	PC_BEQ							:std_logic_vector(INSTRUCTION_SIZE-1 downto 0);


-----------------------------CZ forwarded signal------------------------------------------------------------------------------------------------
signal	CZ_forward						:std_logic_vector(1 downto 0);
 
signal EX_MEM_CZ_flag_control			:std_logic_vector(4 downto 0);


-----------------------------------DataForwarding Signals----------------------------------------------------------------------------------------
signal	EX_stage_reg_addr								:std_logic_vector(7 downto 0);
signal	RR_stage_reg_addr								:std_logic_vector(7 downto 0);
signal	MEM_stage_reg_addr								:std_logic_vector(2 downto 0);	
signal 	EX_MEM_CONTROL_SIGNAL							:std_logic_vector(1 downto 0);
signal 	MEM_WB_CONTROL_SIGNAL							:std_logic_vector(1 downto 0);
signal 	EX_MEM_reg_addr									:std_logic_vector(SIZE_OF_INPUT_BIT-1 downto 0);
signal	MEM_WB_reg_addr									:std_logic_vector(SIZE_OF_INPUT_BIT-1 downto 0);----

signal	  FWD_reg_EX_addr1								:std_logic_vector(SIZE_OF_INPUT_BIT-1 downto 0);
signal	  FWD_reg_EX_data1								:std_logic_vector(DATA_WIDTH-1 downto 0);
signal	  FWD_Mux_Select_signal1						:std_logic;
	  
signal	  FWD_reg_EX_addr2								:std_logic_vector(SIZE_OF_INPUT_BIT-1 downto 0);
signal	  FWD_reg_EX_data2								:std_logic_vector(DATA_WIDTH-1 downto 0);
signal	  FWD_Mux_Select_signal2						:std_logic;	  
signal	  load_stalls									:std_logic;


signal	FWD_reg_RR_addr1								:std_logic_vector(SIZE_OF_INPUT_BIT-1 downto 0);
signal 	FWD_reg_RR_data1								:std_logic_vector(DATA_WIDTH-1 downto 0);
signal	FWD_Mux_RR_Select_signal1						:std_logic;	

signal	FWD_reg_RR_addr2								:std_logic_vector(SIZE_OF_INPUT_BIT-1 downto 0);
signal	FWD_reg_RR_data2								:std_logic_vector(DATA_WIDTH-1 downto 0);
signal 	FWD_Mux_RR_Select_signal2						:std_logic;	

signal EX_MEM_data										:std_logic_vector(2*PC_SIZE	-1 downto 0);
signal MEM_WB_data										:std_logic_vector(2*PC_SIZE	-1 downto 0);

signal	  FWD_reg_MEM_addr2								:std_logic_vector(SIZE_OF_INPUT_BIT-1 downto 0);
signal	  FWD_reg_MEM_data2								:std_logic_vector(DATA_WIDTH-1 downto 0);
signal	  FWD_Mux_MEM_Select_signal2					:std_logic;
		
---------------------------------------------------------------------------------------------------------------------------
signal EX_stage_reg_addr2								:std_logic_vector(2 downto 0);
signal	load_stall_LM_out								:std_logic;		
signal	ID_RR_control_logic_out							:std_logic_vector(CONTROLLER_OUT_SIZE-1  downto RR_STAGE_BEGIN);					
begin
-----------------------------------------------------IF Stage--------------------------------------------------------------
IF_inst:IF_stage 
					port map(reset=>reset,
							clk=>clk,
							---------------------------------------
							enable_PC	=>enable_PC,
							enable_IF_ID_reg=>enable_IF_ID_reg,
							---------------------------------------
							IF_ID_mem_out_reg_in_alias	=>IF_ID_mem_out_reg_in_alias,
							IF_ID_mem_out=>IF_ID_mem_sig,
							IF_ID_PC_out=>IF_ID_PC_sig,
							-----------------------------
							PC_LHI				=>PC_LHI,
							PC_BEQ 				=>PC_BEQ,										---BEQ PC + imm6 
							PC_imm_JAL			=>PC_imm_JAL,								-----JAL PC + imm9
							PC_JLR 				=>PC_JLR,										 -----JLR PC <= RB
							PC_ADD_NAND_R7_Jump	=>PC_ADD_NAND_R7_Jump,							---ADD R7 Jump
							PC_ADC_NDC_R7_Jump						=>PC_ADC_NDC_R7_Jump,		---ADC/NDC
						    PC_ADZ_NDZ_R7_Jump						=>PC_ADZ_NDZ_R7_Jump,		---ADZ/NDZ
							ID_RR_control_logic_opcode				=>ID_RR_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9),
							ID_RR_control_logic_A3					=>ID_RR_control_logic_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5),
							RR_EX_second_stage_control_logic_in=>RR_EX_second_stage_control_logic_sig,----------For jump		
							RR_EX_control_logic_A3					=>RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5),
							EX_MEM_Zero_flag	=>EX_MEM_CZ_flag_control(0),
							CZ_forward			=>CZ_forward);	--For BEQ					
							
							

					
---------------------------------------------------ID Stage-------------------------------------------------------------------

ID_RR_Priority_in				<=op_to_register_file & priority_zero;




-------------------------Jump related------------------------------------------------------------------------------------------------------
----Makes the opcode 1111 so all the control signal are automatically disabled 

IF_ID_mem_jump	<=(others =>'1')when 	
			------------------------------JAL------------------------------------------------------
		(ID_RR_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9) = "1000" or			--RR
		RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="1000")or--EX
			----------------LHI_Jump----------------------------------											
		((ID_RR_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9) = "0011" 
												and ID_RR_control_logic_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5) = "111")or			--RR
		(RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0011" 
												and RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111" ))	--EX
------------------------------JLR------------------------------------------------------
		or (RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)= "1001" or		
			EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="1001" )	
			---------------------BEQ-----------------------------------------------------------------------------------------------------------				
			or ((RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="1100" and EX_MEM_CZ_ALU_Ctrl_in(0)='1')
			or (EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="1100"	and EX_MEM_CZ_ALU_Ctrl_sig_load(0)='1'))
		--	or 	(MEM_WB_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="1100" and MEM_WB_CZ_ALU_Ctrl_sig(0)='1' )
		
----------------------------ADD_R7-------------------------------------------------------------------------------------------------------------	

		or((RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0000" and  
			RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111" and 
			RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="00")
			
			
				or (EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0000"	and
					EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"and
					EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="00"))	
---------------------------------NDU_R7-------------------------------------------------------------------------------------------------------------	

		or((RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0010" and  
			RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111" and
			RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="00")
			
			
				or (EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0010"	and
					EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"and
					EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="00"))	
					
----------------------------ADC_R7-------------------------------------------------------------------------------------------------------------	

		or(
		(RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0000" and  
			RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111" and 
			RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="10"
			and CZ_forward(1)='1')or
				 (EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0000"	and
					EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"and
					EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="10"
				--	and CZ_forward(1)='1')
					))	
---------------------------------NDC_R7-------------------------------------------------------------------------------------------------------------	

		or((RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0010" and  
			RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111" and
			RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="10"
			and CZ_forward(1)='1')
			
			
				or (EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0010"	and
					EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"and
					EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="10"
				--	and CZ_forward(1)='1'
				))	
----------------------------ADZ_R7-------------------------------------------------------------------------------------------------------------	

		or((RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0000" and  
			RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111" and 
			RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="01" 
			and CZ_forward(0)='1')
			
			
				or (EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0000"	and
					EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"and
					EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="01"
					and CZ_forward(0)='1'))	
---------------------------------NDZ_R7-------------------------------------------------------------------------------------------------------------	

		or((RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0010" and  
			RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111" and
			RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="01"
			and CZ_forward(0)='1')
			
			
				or (EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0010"	and
					EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"and
					EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="01"
					and CZ_forward(0)='1'))						
-------------------------------ADI_R7------------------------------------------------------------------------------------------------------------------																		
			or((RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0001" and  
				RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111")
				
				or (EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0001"	and
					EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"))	
			
			
										 
			else IF_ID_mem_sig;

--------------------------------------------------------------------------------------------------------------------------------------------------------

ID_inst :ID_stage 
						port map(reset=>reset,
								clk=>clk,
								opcode		=>opcode,
								---------------------------
								IF_ID_mem_in=>IF_ID_mem_jump,
								IF_ID_PC_in	=>IF_ID_PC_sig,
								------------------------------
								enable_ID_RR_reg=>enable_ID_RR_reg,	
								ID_RR_Priority_in	=>ID_RR_Priority_in,
								op_to_register_file	=>op_to_register_file,
								priority_zero		=>priority_zero,		
								-------------------------------
								ID_RR_control_logic_out=>ID_RR_control_logic_sig,
								ID_RR_Priority_out=>ID_RR_Priority_sig,
								ID_RR_first_stage_mem_out=>ID_RR_first_stage_mem_sig,
								ID_RR_first_stage_PC_out=>ID_RR_first_stage_PC_sig,
								load_stalls				=>load_stalls,
								load_stall_LM_out		=>load_stall_LM_out);

--------------------------------------------------Register Read----------------------------------------------------------------


-------------------------------------------------Jump related-----------------------------------
									-------------BEQ-------------------------------------------
							---Makes the opcode 1111 and disables all the control signal manually
 ID_RR_control_logic_jump	<=(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9=>'1',others=>'0')when 
									(
									
									RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="1001" or
									
									--------------------BEQ----------------------------------------------------
									(RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="1100" 
																										and EX_MEM_CZ_ALU_Ctrl_in(0)='1')
																													--Content of the zero flag
							------------------------ADD_R7-----------------------------
								or	(RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0000" and
											RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"and
											RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="00")
							--------------------------NDU_R7----------------------------				
								or (RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0010" and
											RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"and
											RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="00")
									-----ADI-----		
								or (RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0001" and
											RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"
											)
								------------------------ADC_R7-----------------------------
								or	(RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0000" and
									RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"and
									RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="10"
									and CZ_forward(1)='1')
							--------------------------NDC_R7----------------------------				
								or (RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0010" and
									RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"and
									RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="10"
									and CZ_forward(1)='1')
								
							------------------------ADZ_R7-----------------------------
								or	(RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0000" and
									RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"and
									RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="01"
									and CZ_forward(0)='1')
							--------------------------NDZ_R7----------------------------				
								or (RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0010" and
									RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"and
									RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="01"
									and CZ_forward(0)='1'))
											
							else																	
								ID_RR_control_logic_sig;	
			
-------------------------------------------------------------------
RR_inst:RR_stage	
						port map(reset=>reset,
								clk=>clk,
								----------------------
								enable_RR_EX_reg	=>enable_RR_EX_reg,
								----------Comming from previous stage-------------
								ID_RR_control_logic_in=>ID_RR_control_logic_jump,
								ID_RR_Priority_in=>ID_RR_Priority_sig,
								ID_RR_first_stage_mem_in=>ID_RR_first_stage_mem_sig,
								ID_RR_first_stage_PC_in=>ID_RR_first_stage_PC_sig,
								----------Going to the next stage----------------
								RR_EX_reg_file_and_SE_ZP_out			=>RR_EX_reg_file_and_SE_ZP_sig,
								RR_EX_second_stage_control_logic_out=>RR_EX_second_stage_control_logic_sig(CONTROLLER_OUT_SIZE-1 downto EX_STAGE_BEGIN ),
								RR_EX_PC_out						=>RR_EX_PC_sig,
								RR_EX_Priority_Zero_out				=>RR_EX_Priority_Zero_sig,
								LM_SM_reg_out						=>LM_SM_reg_sig,
								----------Writeback stage signals--------------------
								A3					=>WB_RegA3_out,
								data_in3 			=>WB_Data_to_Reg,
								reg_file_write_sig 	=>WB_RegWrite,
								
								R7_write			=>WB_R7_write,
								R7_in				=>WB_RegR7_in,
								----------Jump related ports-----------------------
							--	PC_JLR			=>PC_JLR,								
								PC_imm_JAL		=>PC_imm_JAL,
								PC_LHI			=>PC_LHI,
								----------Register in Register file------------------
								R0             	=>R0,
								R1              =>R1,
								R2              =>R2,
								R3              =>R3,
								R4             	=>R4,
								R5             	=>R5,
								R6              =>R6,
								R7              =>R7,
								------------------DataForwarded signal------------------------------------------------
								ID_RR_control_logic_out		=>ID_RR_control_logic_out,	---Include jump and stall								
								FWD_reg_RR_data1			=>FWD_reg_RR_data1,
								FWD_Mux_RR_Select_signal1	=>FWD_Mux_RR_Select_signal1,
								FWD_reg_RR_data2			=>FWD_reg_RR_data2,
								FWD_Mux_RR_Select_signal2	=>FWD_Mux_RR_Select_signal2,
								
								FWD_Mux_Select_signal1		=>FWD_Mux_Select_signal1,						
								FWD_reg_EX_data1			=>FWD_reg_EX_data1,
								FWD_reg_EX_data2			=>FWD_reg_EX_data2,
								FWD_Mux_Select_signal2		=>FWD_Mux_Select_signal2,
								load_stalls				=>load_stalls										
		
					
								);

----------------------------------------------------EX Stage---------------------------------------------------------------------
RR_EX_second_stage_control_logic_sig_alias<=RR_EX_second_stage_control_logic_sig;
--Improper output without an alias
--Proper output with alias


---Check for ADC/NDC and ADZ/NDZ if the previous carry =0 then it is flused out else data is passed .
--The R7 was  updated in this cycle 
--Even if R7 was not updated in this clock cycle the value of R7 in next clock cycle would be correct as it is dependent on PC which is updated in 
--this clock cycle.

--RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+4 )='1' specifically for the ADC inst.
--RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+3 )='1' specifically for the ADZ inst.
--WR_STAGE_BEGIN+8 is the R7_write
RR_EX_second_stage_control_logic_sig2<=
					((WR_STAGE_BEGIN+8)=>'1',others=>'0')when (( (RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+4 )='1') and (CZ_forward(1)='0'))or
										((RR_EX_second_stage_control_logic_sig(WR_STAGE_BEGIN+3 )='1') and (CZ_forward(0)='0')	)) else
									
										RR_EX_second_stage_control_logic_sig_alias;
											--ADC
															
										
										




EX_inst:Execute_stage 
							port map(clk=>clk,
									 reset=>reset,
									 -------------------------
									RR_EX_reg_file_and_SE_ZE_in				=>RR_EX_reg_file_and_SE_ZP_sig,--RR_EX_reg_file_and_SE_ZP_sig_temp,
									RR_EX_PC_in			 					=>RR_EX_PC_sig,
									RR_EX_second_stage_control_logic_in		=>RR_EX_second_stage_control_logic_sig2,
									RR_EX_Priority_Zero_in					=>RR_EX_Priority_Zero_sig,
									LM_SM_reg_in							=>LM_SM_reg_sig,	
									---------------------------------------
									enable_EX_MEM_reg						=>enable_EX_MEM_reg,
									-----------------------------------------
									 EX_MEM_CZ_ALU_Ctrl_in					=>EX_MEM_CZ_ALU_Ctrl_in,
									 EX_MEM_ALU_output_out					=>EX_MEM_ALU_output_sig,
									 EX_MEM_ZP_D2_out						=>EX_MEM_ZP_D2_sig,
									 EX_MEM_CZ_ALU_Ctrl_out					=>EX_MEM_CZ_ALU_Ctrl_sig,
									 EX_MEM_PC_out							=>EX_MEM_PC_sig,
									 EX_MEM_CONTROL_SIGNAL_OUT				=>EX_MEM_CONTROL_SIGNAL_sig,
									 EX_MEM_Priority_Zero_out				=>EX_MEM_Priority_Zero_sig,
									 --------------Forwarded data from the Memory and WriteBack_stage-------------------
									 FWD_reg_EX_data1						=>FWD_reg_EX_data1,
									 FWD_Mux_Select_signal1					=>FWD_Mux_Select_signal1,
									 FWD_reg_EX_data2						=>FWD_reg_EX_data2,
									 FWD_Mux_Select_signal2					=>FWD_Mux_Select_signal2,
									 load_stalls							=>load_stalls,
									  CZ_forward								=>CZ_forward,
									 ---------------------Jump_BEQ-------------------------------------------------------
									 PC_JLR									=>PC_JLR,	
									 PC_BEQ									=>PC_BEQ,
									 PC_ADD_NAND_R7_Jump					=>PC_ADD_NAND_R7_Jump,
									 PC_ADC_NDC_R7_Jump						=>PC_ADC_NDC_R7_Jump,
									 PC_ADZ_NDZ_R7_Jump						=>PC_ADZ_NDZ_R7_Jump
									 );
									 
									 
EX_MEM_CZ_flag_control			<=EX_MEM_CZ_ALU_Ctrl_in;


---The zero_flag_update is for the load signal
----It comes out of the Data Memory stage .This signal is then passed to the input of EX_MEM_CZ_ALU_Ctrl_sig_load which is the input of the MEM/WB_CZ stage. 

---The zero_flag in memory_stage(EX_MEM_CZ_ALU_Ctrl_sig_load(0)) is updated only if zero_flag_select(EX_MEM_CONTROL_SIGNAL_sig(MM_STAGE_BEGIN+5 downto MM_STAGE_BEGIN+4))=0 and
--	ALU_Ctrl(0)(EX_MEM_CZ_ALU_Ctrl_sig(2))=1 OR  when 	zero_flag_select(EX_MEM_CONTROL_SIGNAL_sig( MM_STAGE_BEGIN+4))=1	
EX_MEM_CZ_ALU_Ctrl_sig_load(0) <=  EX_MEM_CZ_ALU_Ctrl_sig(0) when (EX_MEM_CONTROL_SIGNAL_sig(MM_STAGE_BEGIN+4) = '0' and
										EX_MEM_CZ_ALU_Ctrl_sig(2) = '1'  ) else 
								   zero_flag_mem_update_sig when EX_MEM_CONTROL_SIGNAL_sig(MM_STAGE_BEGIN+4) = '1' else
								   zero_update_sig;
                                
EX_MEM_CZ_ALU_Ctrl_sig_load(4 downto 1)<=EX_MEM_CZ_ALU_Ctrl_sig(4 downto 1);

process(clk,reset)
begin
if(reset='1')then
	zero_update_sig<='0';
elsif rising_edge(clk) then
	zero_update_sig <= EX_MEM_CZ_ALU_Ctrl_sig_load(0);
end if;
end process;




--------------------------------------------------Memory Stage------------------------------------------------------------------
DM_inst:Memory_stage 
							port map(clk=>clk,
									reset=>reset,
									-------------------------
									EX_MEM_ALU_output_in		=>EX_MEM_ALU_output_sig,
									EX_MEM_ZP_D2_in				=>EX_MEM_ZP_D2_sig,			----Zero padded and D2 for LHI and JLR respecively
									EX_MEM_CZ_ALU_Ctrl_in		=>EX_MEM_CZ_ALU_Ctrl_sig_load,
									EX_MEM_PC_in				=>EX_MEM_PC_sig,
									EX_MEM_CONTROL_SIGNAL_in	=>EX_MEM_CONTROL_SIGNAL_sig,
									EX_MEM_Priority_Zero_in		=>EX_MEM_Priority_Zero_sig,
									----------------------------------
									enable_MEM_WB_reg			=>enable_MEM_WB_reg,
									zero_flag_mem_update_sig	=>zero_flag_mem_update_sig,
									------------------------------------
									MEM_WB_ZP_out				=>MEM_WB_ZP_sig,
									MEM_WB_ALU_output_out		=>MEM_WB_ALU_output_sig,
									MEM_WB_ReadData_out			=>MEM_WB_ReadData_sig,
									MEM_WB_CZ_ALU_Ctrl_out		=>MEM_WB_CZ_ALU_Ctrl_sig,
									MEM_WB_PC_1_imm_RB_out		=>MEM_WB_PC_1_imm_RB_sig,
									MEM_WB_PC_and_PC_plus1_out	=>MEM_WB_PC_and_PC_plus1_sig,
									MEM_WB_CONTROL_SIGNAL_OUT 	=>MEM_WB_CONTROL_SIGNAL_sig,
									MEM_WB_Priority_Zero_out	=>MEM_WB_Priority_Zero_sig,
								---------------------Load followed by store dependency without stall forwarding-------------------------
									FWD_reg_MEM_addr2			=>FWD_reg_MEM_addr2,
									FWD_reg_MEM_data2			=>FWD_reg_MEM_data2,
									FWD_Mux_MEM_Select_signal2	=>FWD_Mux_MEM_Select_signal2
									
									);
									
								
									
------------------------------------------------WriteBack Stage------------------------------------------------------------------



WB_inst:WriteBack_stage port map(reset=>reset,
									  clk=>clk,
									  MEM_WB_ZP_in				=>MEM_WB_ZP_sig,
									  MEM_WB_ALU_output_in		=>MEM_WB_ALU_output_sig,
									  MEM_WB_ReadData_in  		=>MEM_WB_ReadData_sig,
									  MEM_WB_CZ_ALU_Ctrl_in		=>MEM_WB_CZ_ALU_Ctrl_sig,
									  MEM_WB_PC_1_imm_RB_in		=>MEM_WB_PC_1_imm_RB_sig,
									  MEM_WB_PC_and_PC_plus1_in	=>MEM_WB_PC_and_PC_plus1_sig,
									  MEM_WB_CONTROL_SIGNAL_in	=>MEM_WB_CONTROL_SIGNAL_sig,
									  MEM_WB_Priority_Zero_in	=>MEM_WB_Priority_Zero_sig,
									  ------------------------------------------------------
									  enable_CZ_reg				=>enable_MEM_WB_reg,
									  WB_Data_to_Reg			=>WB_Data_to_Reg,		
									  WB_carry_zero_out			=>WB_carry_zero_out,
									  WB_RegA3_out				=>WB_RegA3_out,
									  WB_RegWrite				=>WB_RegWrite,
									  WB_RegR7_in				=>WB_RegR7_in,
									  WB_R7_write				=>WB_R7_write,
									  WB_Priority_Zero_out		=>WB_Priority_Zero_out,
									  -----------------Flag forwarded-------------------
									  CZ_forward			=>CZ_forward
									  );
									  
									  
							  
									  
			  
									  
									  
PP_inter_reg_inst	:Pipeline_intermediate_register_enable		 port map(clk=>clk,
																		reset=>reset,
																		load_stalls	=>load_stalls,
																		opcode=>IF_ID_mem_sig(INSTRUCTION_SIZE-1 downto INSTRUCTION_SIZE-4),
																		enable_PC			=>enable_PC,
																		enable_IF_ID_reg	=>enable_IF_ID_reg,
																		enable_ID_RR_reg	=>enable_ID_RR_reg,
																		enable_RR_EX_reg	=>enable_RR_EX_reg,
																		enable_EX_MEM_reg	=>enable_EX_MEM_reg,
																		enable_MEM_WB_reg	=>enable_MEM_WB_reg,
																		priority_zero	=>priority_zero,
																		load_stall_LM_out		=>load_stall_LM_out);								  
									  
									  
									  
									  
		
		
Flag_inst	:Flag_contrrol port map(reset				=>reset,
									ALU_Ctrl_EX_MEM		=>EX_MEM_CZ_flag_control(4 downto 2),
									ALU_Ctrl_MEM_WB		=>EX_MEM_CZ_ALU_Ctrl_sig_load(4 downto 2),
									EX_MEM_carry_zero_out=>EX_MEM_CZ_flag_control(1 downto 0),
									MEM_WB_carry_zero_out=>EX_MEM_CZ_ALU_Ctrl_sig_load(1 downto 0),
									CZ_forward			=>CZ_forward,
									CZ_reg				=>WB_carry_zero_out,
									zero_flag_select	=>EX_MEM_CONTROL_SIGNAL_sig(MM_STAGE_BEGIN+5 downto MM_STAGE_BEGIN+4),--zero_flag_select from decoder
									zero_flag_mem_update_sig=>zero_flag_mem_update_sig);

-----------------------------------------Signals for the DataForwarding---------------------------------------------------------------------------
EX_stage_reg_addr2		<=	RR_EX_Priority_Zero_sig(PRIORITY_OUTPUT_SIZE downto 1)	when 
								RR_EX_second_stage_control_logic_sig2(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0111"else
							RR_EX_second_stage_control_logic_sig2(EX_STAGE_BEGIN+13 downto EX_STAGE_BEGIN+11);

EX_stage_reg_addr		<=	'0' & EX_stage_reg_addr2 &
							'0' &	RR_EX_second_stage_control_logic_sig2(EX_STAGE_BEGIN+10 downto EX_STAGE_BEGIN+8);
RR_stage_reg_addr		<=	'0' & ID_RR_control_logic_out(EX_STAGE_BEGIN+13 downto EX_STAGE_BEGIN+11) &
							'0' & ID_RR_control_logic_out(EX_STAGE_BEGIN+10 downto EX_STAGE_BEGIN+8);
MEM_stage_reg_addr		<=	 EX_MEM_CONTROL_SIGNAL_sig	(MM_STAGE_BEGIN+7 downto MM_STAGE_BEGIN+5);						

EX_MEM_CONTROL_SIGNAL	<=EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+2)&EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+8);
MEM_WB_CONTROL_SIGNAL	<=MEM_WB_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+2)&MEM_WB_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+8);
---------------------------------------Forwarding either the Zero_padded(LHI) or the ALU_Output
MUX_ALU_ZP_D2_sig       <=EX_MEM_ZP_D2_sig(31 downto 16) when EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9) = "0011" else  -- Opcode for LHI
                          EX_MEM_ALU_output_sig ;
                          
                          
----------------------A3 is the destination address or the priority o/p in case of LM------------------------------------------              
EX_MEM_reg_addr	<=	EX_MEM_Priority_Zero_sig(PRIORITY_OUTPUT_SIZE downto 1)	
											when EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0110" else
											-- or
												--  EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0111" )else
					EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5);
					
MEM_WB_reg_addr	<=	MEM_WB_Priority_Zero_sig(PRIORITY_OUTPUT_SIZE downto 1)
											when MEM_WB_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0110" else
					MEM_WB_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5);
-----------------------------------------------------------------------------------------------------------------------------------	


---Forwarding PC+1
EX_MEM_data		<=	EX_MEM_PC_sig(2*PC_SIZE-1 downto PC_SIZE)	& MUX_ALU_ZP_D2_sig;
MEM_WB_data		<=	WB_RegR7_in							& WB_Data_to_Reg;
		  
DATA_FWD_inst:DataForwarding port map
					(reset						=>reset,
					  RR_stage_opcode			=>ID_RR_control_logic_out(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9),
					  EX_stage_opcode 			=>RR_EX_second_stage_control_logic_sig2(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9),
					  EX_stage_reg_addr			=>EX_stage_reg_addr,
					  RR_stage_reg_addr			=>RR_stage_reg_addr,
					  MEM_stage_reg_addr		=>MEM_stage_reg_addr,	
							  -----------------------------------------------------
					  EX_MEM_opcode				=>EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9),
					  EX_MEM_reg_addr			=>EX_MEM_reg_addr,--A3
					  EX_MEM_data				=>EX_MEM_data, --EX_MEM_ZP_D2_sig(31 downto 16),  --EX_MEM_ALU_output_sig,----will be ALU_Output
					  EX_MEM_CONTROL_SIGNAL		=>EX_MEM_CONTROL_SIGNAL,--EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+2)&EX_MEM_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+8),
					  ------------------------------------------------------
					  MEM_WB_opcode				=>MEM_WB_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9),
					  MEM_WB_reg_addr			=>MEM_WB_reg_addr,
					  MEM_WB_data				=>MEM_WB_data,		  --R7_data and MUX_OUTPUT
					  MEM_WB_CONTROL_SIGNAL		=>MEM_WB_CONTROL_SIGNAL,--MEM_WB_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+2)&MEM_WB_CONTROL_SIGNAL_sig(WR_STAGE_BEGIN+8),
					  -------------------EX stage A1 forward----------------------------------
					  FWD_reg_EX_addr1			=>FWD_reg_EX_addr1,
					  FWD_reg_EX_data1			=>FWD_reg_EX_data1,
					  FWD_Mux_Select_signal1	=>FWD_Mux_Select_signal1,
					  -------------------EX stage A2 forward----------------------------------
					  FWD_reg_EX_addr2			=>FWD_reg_EX_addr2,
					  FWD_reg_EX_data2			=>FWD_reg_EX_data2,
					  FWD_Mux_Select_signal2	=>FWD_Mux_Select_signal2,
					  load_stalls				=>load_stalls,
					  
					 -------------------RR stage A1 forward----------------------------------  
					FWD_reg_RR_addr1			=>FWD_reg_RR_addr1,
					FWD_reg_RR_data1			=>FWD_reg_RR_data1,
					FWD_Mux_RR_Select_signal1	=>FWD_Mux_RR_Select_signal1,
					
					 -------------------RR stage A2 forward----------------------------------
					FWD_reg_RR_addr2			=>FWD_reg_RR_addr2,
					FWD_reg_RR_data2			=>FWD_reg_RR_data2,
					FWD_Mux_RR_Select_signal2	=>FWD_Mux_RR_Select_signal2,
					----------------------Load followed by store without stall forwarding in MEM stage----
					FWD_reg_MEM_addr2			=>FWD_reg_MEM_addr2,
					FWD_reg_MEM_data2			=>FWD_reg_MEM_data2,
					FWD_Mux_MEM_Select_signal2	=>FWD_Mux_MEM_Select_signal2
					    );
--------------------------------------------------------------------------------------------------------------------------------------------------------																			 									  
end;



library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-------------Defined package-------------------------
use work.Package_component_Pipeline.all;
--------------------------------------------------------

entity Pipeline_intermediate_register_enable is
		port(clk				:in std_logic;
			reset				:in std_logic;
			load_stalls			:in std_logic;
			load_stall_LM_out	:in std_logic;
			priority_zero		:in std_logic;
			opcode				:in std_logic_vector(3 downto 0);
			enable_PC			:out std_logic:='1';
			enable_IF_ID_reg	:out std_logic:='1';
			enable_ID_RR_reg	:out std_logic:='1';
			enable_RR_EX_reg	:out std_logic:='1';
			enable_EX_MEM_reg	:out std_logic:='1';
			enable_MEM_WB_reg	:out std_logic:='1'
			
			);
end entity;

architecture behav of Pipeline_intermediate_register_enable is
begin
	
	
	process(reset,opcode,load_stalls,priority_zero,priority_zero)
	begin
	
		if(reset='1')then
			enable_PC			<='0';
			enable_IF_ID_reg	<='0';
			enable_ID_RR_reg	<='0';
			enable_RR_EX_reg	<='0';
			enable_EX_MEM_reg	<='0';
			enable_MEM_WB_reg	<='0';
			-------------------------------------------------------------------
			
		elsif(load_stall_LM_out='1')then
			enable_PC			<='0';
			enable_IF_ID_reg	<='0';
			enable_ID_RR_reg	<='1';
			enable_RR_EX_reg	<='1';
			enable_EX_MEM_reg	<='1';
			enable_MEM_WB_reg	<='1';
		
		--------------------------LM/SM enable control----------------------------	
		elsif(opcode="0110")then
							if(priority_zero ='1')then
								enable_IF_ID_reg	<='1';
								enable_PC	<='1';
							else	
								enable_IF_ID_reg	<='0';enable_PC	<='0';
							end if;
		
		elsif(opcode="0111")then
						if(priority_zero ='1')then
								enable_IF_ID_reg	<='1';enable_PC	<='1';
						else	
								enable_IF_ID_reg	<='0';enable_PC	<='0';
						end if;
		-------------------Creating a stall for the signal following the load signal.	
		elsif(load_stalls ='1')then
			enable_PC			<='0';
			enable_IF_ID_reg	<='0';
			enable_ID_RR_reg	<='0';
			enable_RR_EX_reg	<='1';-------------------Change enable_RR_EX_reg as moved stall to RR_stage ---Disable  enable_RR_EX_reg when in EX_stage
			enable_EX_MEM_reg	<='1';
			enable_MEM_WB_reg	<='1';
			
			
		else
			enable_PC			<='1';
			enable_IF_ID_reg	<='1';
			enable_ID_RR_reg	<='1';
			enable_RR_EX_reg	<='1';
			enable_EX_MEM_reg	<='1';
			enable_MEM_WB_reg	<='1';
		end if;
			
	end process;
end;



