library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-------------Defined package-------------------------
use work.Package_component_Pipeline.all;
--------------------------------------------------------

entity Execute_stage is
port ( reset	:in std_logic;
	   clk		:in std_logic;
		-------------------- Coming from previous stage --------------------------------------------------------
	   
	   RR_EX_reg_file_and_SE_ZE_in						: in std_logic_vector(4*INSTRUCTION_SIZE-1 downto 0);
	   RR_EX_PC_in										: in std_logic_vector(3*PC_SIZE-1 downto 0);
	   RR_EX_second_stage_control_logic_in 				: in std_logic_vector(CONTROLLER_OUT_SIZE-1	downto EX_STAGE_BEGIN);
	   RR_EX_Priority_Zero_in							: in std_logic_vector(PRIORITY_OUTPUT_SIZE downto 0 );
	   LM_SM_reg_in										: in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
	   -----------------------------Enable to this stage------------------------------------------------------------
		enable_EX_MEM_reg								: in std_logic;
	  
	  --------------------- Going to Next Stage(i.e Data Memory Access Stage) ---------------------
	  EX_MEM_CZ_ALU_Ctrl_in				: inout std_logic_vector(4 downto 0);
	  EX_MEM_ALU_output_out 			: out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
	  EX_MEM_ZP_D2_out 					: out std_logic_vector(2*INSTRUCTION_SIZE-1 downto 0);
	  EX_MEM_CZ_ALU_Ctrl_out			: out std_logic_vector(4 downto 0);
	  EX_MEM_PC_out						: out std_logic_vector(3*PC_SIZE-1 downto 0);
	  EX_MEM_CONTROL_SIGNAL_OUT			: out std_logic_vector(CONTROLLER_OUT_SIZE-1	downto MM_STAGE_BEGIN);
	  EX_MEM_Priority_Zero_out			: out std_logic_vector(PRIORITY_OUTPUT_SIZE downto 0 );
	  -------------------------------Forwarded signal from the EX/MEM and MEM/WB------------------------------------
	
		FWD_reg_EX_data1							:in std_logic_vector(DATA_WIDTH-1 downto 0);
		FWD_reg_EX_data2							:in std_logic_vector(DATA_WIDTH-1 downto 0);
		FWD_Mux_Select_signal1						:in std_logic;
		FWD_Mux_Select_signal2						:in std_logic;
		load_stalls									:in std_logic;
		CZ_forward									:in std_logic_vector(1 downto 0);
	-------------------------------------Jump related instruction-----------------------------------------------------	
		PC_JLR									:out std_logic_vector(PC_SIZE-1 downto 0);
		PC_BEQ									:out std_logic_vector(PC_SIZE-1 downto 0);
		PC_ADD_NAND_R7_Jump						:out std_logic_vector(PC_SIZE-1 downto 0);
		PC_ADC_NDC_R7_Jump						:out std_logic_vector(PC_SIZE-1 downto 0);
		PC_ADZ_NDZ_R7_Jump						:out std_logic_vector(PC_SIZE-1 downto 0);
		----------------------------------------For stall--------------------------------------------------
		RR_stage_CONTROL_SIGNAL_stall			:out std_logic_vector(CONTROLLER_OUT_SIZE-1	downto EX_STAGE_BEGIN)
		
     );
end entity;

architecture Execute_stage_arch of Execute_stage is 
-------------------------------------------------ALU_signals---------------------------------------------
signal input1_sig 			: std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal input2_sig 			: std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal output_sig 			: std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal two_complement_BEQ	: std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal CZ_flag_sig 			: std_logic_vector(1 downto 0);
signal opcode_EX_check				:std_logic_vector(3 downto 0);
signal input1_sig_FWD 		: std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal input2_sig_FWD 		: std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal input2_sig_FWD_BEQ	: std_logic_vector(INSTRUCTION_SIZE-1 downto 0);

--signal EX_MEM_CZ_ALU_Ctrl_in	: std_logic_vector(4 downto 0);
--------------------------------------------------------------------------------------------------------
signal	EX_MEM_CONTROL_SIGNAL: std_logic_vector(CONTROLLER_OUT_SIZE-1	downto MM_STAGE_BEGIN);
------------------LM_SM_logic_signal--------------------------------------------------------------------
signal		enable_displacement			:std_logic;
signal		displacement_mux_select		: std_logic;
signal		displacement_out			: std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
---------------------------------------------------------------------------------------------------------
signal EX_MEM_CONTROL_SIGNAL_in			:std_logic_vector(CONTROLLER_OUT_SIZE-1 downto EX_STAGE_BEGIN);	
signal EX_MEM_CONTROL_SIGNAL_alias		:std_logic_vector(CONTROLLER_OUT_SIZE-1 downto EX_STAGE_BEGIN);	
signal EX_MEM_ZP_D2_in 					: std_logic_vector(2*INSTRUCTION_SIZE-1 downto 0);
signal PC_sig 							: std_logic_vector(3*PC_SIZE-1 downto 0);
signal	PC_ADD_NAND_R7_check			: std_logic_vector(PC_SIZE-1 downto 0);
signal	JLR_with_FWD					:std_logic_vector(15 downto 0);

--------------------Check-------------------------

signal	d2_EX_check						:std_logic_vector(INSTRUCTION_SIZE-1 downto 0);

begin

opcode_EX_check		<=	RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9);		



----------------------------Jump_BEQ operation------------------------------------------------------------------------------
JLR_with_FWD	<=FWD_reg_EX_data2 when (FWD_Mux_Select_signal2='1' and RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="1001")
				else  RR_EX_reg_file_and_SE_ZE_in(31 downto 16); 


PC_JLR		<=JLR_with_FWD when RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="1001" else (others =>'0');
PC_BEQ	<=RR_EX_PC_in(3*PC_SIZE-1 downto 2*PC_SIZE) when RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="1100"
			else (others=>'0');
PC_ADD_NAND_R7_Jump	<=output_sig when
									
									--------------------------------------------NDU---------------------------------------------------
									(RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0010"
										and RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"
										and RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="00")or
									-------------------------------------------ADI----------------------------------------------------	
									(RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0001"
										and RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111")or
									
									--------------------------------------------ADD-----------------------------------------------
									(RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0000"
										and RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"
										and RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="00")	
										;
			

PC_ADC_NDC_R7_Jump	<=output_sig when	--------------------------------------ADC----------------------------------------------------------
									(RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0000"
										and RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"
										and RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3 )="10" 
										and CZ_forward(1)='1');		
			


PC_ADZ_NDZ_R7_Jump	<=	output_sig when --------------------------------------ADZ----------------------------------------------------------
									(RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0000"
									and RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"		
									 and RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3 )="01"
									 and CZ_forward(0)='1');					
							
							
										
PC_ADD_NAND_R7_check	<=output_sig when (RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0000"
										and RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111");	
------------------------------------------------------------------------------------------------------------------------
EX_MEM_CZ_ALU_Ctrl_in<=RR_EX_second_stage_control_logic_in(EX_STAGE_BEGIN+6 downto EX_STAGE_BEGIN+4) & CZ_flag_sig;
enable_displacement	<=RR_EX_second_stage_control_logic_in(EX_STAGE_BEGIN+7);
----RR_EX_reg_file_and_SE_ZE_in(15 downto 0) =data_out1-------------------
----RR_EX_second_stage_control_logic_in(EX_STAGE_BEGIN+1 downto EX_STAGE_BEGIN)<=ALU_Op1
input1_sig <= LM_SM_reg_in  when RR_EX_second_stage_control_logic_in(EX_STAGE_BEGIN+1 downto EX_STAGE_BEGIN) ="01" 
				else RR_EX_reg_file_and_SE_ZE_in(15 downto 0) ;
				
input1_sig_FWD	<= FWD_reg_EX_data1 when FWD_Mux_Select_signal1='1' else input1_sig;            
 
  
-----------RR_EX_reg_file_and_SE_ZE_in(31 downto 16) =data_out2 ;
-----------RR_EX_reg_file_and_SE_ZE_in(47 downto 32) =SE6_output;
---RR_EX_second_stage_control_logic_in(EX_STAGE_BEGIN+3 downto EX_STAGE_BEGIN+2)	<=ALU_Op2;
input2_sig <= RR_EX_reg_file_and_SE_ZE_in(31 downto 16) when RR_EX_second_stage_control_logic_in(EX_STAGE_BEGIN+3 downto EX_STAGE_BEGIN+2) ="00" else
			  RR_EX_reg_file_and_SE_ZE_in(47 downto 32) when  RR_EX_second_stage_control_logic_in(EX_STAGE_BEGIN+3 downto EX_STAGE_BEGIN+2) ="01" else
			  displacement_out  when  RR_EX_second_stage_control_logic_in(EX_STAGE_BEGIN+3 downto EX_STAGE_BEGIN+2) ="10" ;
			  

input2_sig_FWD	<= FWD_reg_EX_data2 when (FWD_Mux_Select_signal2='1' and
										(RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)/="0101" and  
										 RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)/="0111")) 
									else input2_sig;

-----------------------------------------Creating stall---------------------------------------------------------------------------------------------
EX_MEM_CONTROL_SIGNAL_alias(WR_STAGE_BEGIN+4 downto EX_STAGE_BEGIN)<=RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+4 downto EX_STAGE_BEGIN);
EX_MEM_CONTROL_SIGNAL_alias(WR_STAGE_BEGIN+8 downto WR_STAGE_BEGIN+5)<= '0' & RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5);--EX_MEM_CONTROL_SIGNAL(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5);
EX_MEM_CONTROL_SIGNAL_alias(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)<=RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9);

EX_MEM_CONTROL_SIGNAL_in	<= EX_MEM_CONTROL_SIGNAL_alias when  load_stalls ='1'else
														RR_EX_second_stage_control_logic_in(CONTROLLER_OUT_SIZE-1 downto EX_STAGE_BEGIN);



--EX_MEM_CONTROL_SIGNAL_in			<=RR_EX_second_stage_control_logic_in(CONTROLLER_OUT_SIZE-1 downto MM_STAGE_BEGIN);



--EX_MEM_CONTROL_SIGNAL_in	<=(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9=>'1',others =>'0') when  load_stalls ='1'else
	--													RR_EX_second_stage_control_logic_in(CONTROLLER_OUT_SIZE-1 downto MM_STAGE_BEGIN);
						
						
RR_stage_CONTROL_SIGNAL_stall	<=EX_MEM_CONTROL_SIGNAL_in;





				
						
Two_complement:twocomplement generic map (NO_OF_BIT=>16)port map(input=>input2_sig_FWD ,
																output=>two_complement_BEQ)	;									 
-----------------------------------------LM_SM_logic for storing in the memory location-------------------------------------------------	
	
LM_SM_logic_inst:LM_SM_logic port map(clk						=>clk,
									  reset						=>reset,
									  priority_zero				=>RR_EX_Priority_Zero_in(0 downto 0 ),
									  enable_displacement		=>enable_displacement,
									  displacement_out			=>displacement_out);



input2_sig_FWD_BEQ	<=two_complement_BEQ when RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="1100" 
					 else input2_sig_FWD;
------------------------------------ALU operation ----------------------------------------------------------------------------

ALU_inst : ALU generic map(NO_OF_ALU_BIT=>INSTRUCTION_SIZE) 
					port map (	reset  	=>reset,
								Alu_op 	=>     RR_EX_second_stage_control_logic_in(EX_STAGE_BEGIN+6 downto EX_STAGE_BEGIN+4),
								input1 	=> 	input1_sig_FWD,
								input2  =>	input2_sig_FWD_BEQ,
								output	=>	output_sig,
								carry_flag	=> CZ_flag_sig(1),
								Zero_flag => CZ_flag_sig(0)
					          );

----------------------------------- Data and Control Signals going to EX_MEM Register --------------------------------

PC_sig <= RR_EX_PC_in;
---Consist of Zero padded and Sign Extender
EX_MEM_ZP_D2_in(2*INSTRUCTION_SIZE-1 downto INSTRUCTION_SIZE)<= RR_EX_reg_file_and_SE_ZE_in(63 downto 48) ;

																
EX_MEM_ZP_D2_in(INSTRUCTION_SIZE-1 downto 0)<=FWD_reg_EX_data2 when (FWD_Mux_Select_signal2='1' and
																	(RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0101" 
																	or RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0111"
																	  ))
																	--~ else
											 --~ FWD_reg_EX_data1 when FWD_Mux_Select_signal1='1' and
																		--~ RR_EX_second_stage_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0111"
																	
																	
																	
																	else	
												RR_EX_reg_file_and_SE_ZE_in(31 downto 16); 


d2_EX_check				<=EX_MEM_ZP_D2_in(INSTRUCTION_SIZE-1 downto 0);
----------------------------------------------O/P of the ALU---------------------------------------------------------------------------
EX_MEM_ALU_output_inst: nbit_register generic map(SIZE_OF_REGISTER=>INSTRUCTION_SIZE)
								port map	(reset=>reset,
											 clk=>clk,
											 enable=>enable_EX_MEM_reg,
											 ip_FF=>output_sig,
											 op_FF=>EX_MEM_ALU_output_out);
---------------------------------------------------------------------------------------------------------------------------------------

EX_MEM_RegD2_inst: nbit_register generic map(SIZE_OF_REGISTER=>2*INSTRUCTION_SIZE)
								port map	(reset=>reset,
											 clk=>clk,
											 enable=>enable_EX_MEM_reg,
											 ip_FF=>EX_MEM_ZP_D2_in,
											 op_FF=>EX_MEM_ZP_D2_out);
											 
-----------------------------Passing the Carry/Zero Flag and ALU_Ctrl to the next stages-------------------------------------------------------------										 

EX_MEM_CZ_flag_ALU_Ctrl_inst : nbit_register generic map(SIZE_OF_REGISTER=>5) 
								port map	(reset=>reset,
											 clk=>clk,
											 enable=>enable_EX_MEM_reg,
											 ip_FF=>EX_MEM_CZ_ALU_Ctrl_in,
											 op_FF=>EX_MEM_CZ_ALU_Ctrl_out);
----------------------------------------------------------------------------------------------------------------------------------------


EX_MEM_PC_inst: nbit_register generic map(SIZE_OF_REGISTER=>3*PC_SIZE)
								port map	(reset=>reset,
											 clk=>clk,
											 enable=>enable_EX_MEM_reg,
											 ip_FF=>PC_sig,
											 op_FF=>EX_MEM_PC_out);

EX_MEM_CONTROL_SIGNAL_OUT_inst: 
							nbit_register_stage generic map(END_OF_NBIT_REGISTER_STAGES=>CONTROLLER_OUT_SIZE,
																BEGIN_OF_NBIT_REGISTER_STAGES=>MM_STAGE_BEGIN)
													port map	(reset=>reset,
																 clk=>clk,
																 enable=>enable_EX_MEM_reg,
																 ip_FF=>EX_MEM_CONTROL_SIGNAL_in(CONTROLLER_OUT_SIZE-1 downto MM_STAGE_BEGIN),
																 op_FF=>EX_MEM_CONTROL_SIGNAL(CONTROLLER_OUT_SIZE-1	downto MM_STAGE_BEGIN));
	
	EX_MEM_CONTROL_SIGNAL_OUT		<=EX_MEM_CONTROL_SIGNAL;
																 
----------------------------------------------- Sadaf Date : 27 March ---Priority Signals------------------------------------
EX_MEM_Priority_Zero_inst: nbit_register generic map(SIZE_OF_REGISTER=>4)
								port map	(reset=>reset,
											 clk=>clk,
											 enable=>enable_EX_MEM_reg,
											 ip_FF=>RR_EX_Priority_Zero_in,
											 op_FF=>EX_MEM_Priority_Zero_out);

end architecture;
