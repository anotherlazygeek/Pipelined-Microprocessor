library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-------------Defined package-------------------------
use work.Package_component_Pipeline.all;
--------------------------------------------------------

entity RR_stage is 
port (reset					:in std_logic;
      clk 					: in std_logic;
      enable_RR_EX_reg		: in std_logic;
		-----------------------------------------Comming from previous stage------------------------------------------------
		ID_RR_control_logic_in		:in  std_logic_vector(CONTROLLER_OUT_SIZE-1	downto RR_STAGE_BEGIN);
		ID_RR_Priority_in			:in std_logic_vector(PRIORITY_OUTPUT_SIZE downto 0);--includes op_to_register_file and priority_zero
		ID_RR_first_stage_mem_in	:in std_logic_vector(INSTRUCTION_SIZE-1	downto 0);
		ID_RR_first_stage_PC_in		:in std_logic_vector(2*PC_SIZE-1 downto 0);
		------------------------------------------Going to the next stage----------------------------------------------------
		RR_EX_second_stage_control_logic_out	 		:out std_logic_vector(CONTROLLER_OUT_SIZE-1	downto EX_STAGE_BEGIN);
		RR_EX_reg_file_and_SE_ZP_out					:out std_logic_vector(4*INSTRUCTION_SIZE-1 downto 0);
		RR_EX_PC_out									:out std_logic_vector(3*PC_SIZE-1 downto 0);
		RR_EX_Priority_Zero_out							:out std_logic_vector(PRIORITY_OUTPUT_SIZE downto 0);
		LM_SM_reg_out									:out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
		------------------------------------------Writeback stage signals----------------------------------------------------
		 A3											:in std_logic_vector(SIZE_OF_INPUT_BIT-1 downto 0);
		 data_in3 									:in  std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
		 reg_file_write_sig 						:in std_logic;
		 R7_in										:in  std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
		 R7_write									:in std_logic;
		 -----------------------------------------Jump related ports------------------------------------------------------
		-- PC_JLR										:out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
		 PC_imm_JAL									:out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
		 PC_LHI										:out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
		 
		----------------------Register in Register file-------------------------------------------------------------------
				R0              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R1              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R2              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R3              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R4              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R5              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R6              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R7              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
----------------------------------------------Data forwarded--------------------------------------------------------------------------------
		ID_RR_control_logic_out							:out std_logic_vector(CONTROLLER_OUT_SIZE-1	downto RR_STAGE_BEGIN);
		FWD_reg_RR_data1								: in std_logic_vector(DATA_WIDTH-1 downto 0);
		FWD_Mux_RR_Select_signal1						: in std_logic;	
		FWD_reg_RR_data2								: in std_logic_vector(DATA_WIDTH-1 downto 0);
		FWD_Mux_RR_Select_signal2						: in std_logic;
		
		FWD_Mux_Select_signal1							:in std_logic;
		FWD_Mux_Select_signal2							:in std_logic;
		FWD_reg_EX_data1								:in std_logic_vector(DATA_WIDTH-1 downto 0);
		FWD_reg_EX_data2								:in std_logic_vector(DATA_WIDTH-1 downto 0);
		load_stalls										:in std_logic
		
	 );
end entity;

architecture RR_stage_arch of RR_stage is 

signal A2		  		: std_logic_vector(2 downto 0);
signal data_out1 		: std_logic_vector(15 downto 0);
signal data_out2 		: std_logic_vector(15 downto 0);


signal Zero_padding_out				:std_logic_vector(15 downto 0);
signal SE6_output 					:std_logic_vector(15 downto 0);
signal SE9_output 					:std_logic_vector(15 downto 0);
signal SE_output 					:std_logic_vector(15 downto 0);
signal PC_imm_BEQ					:std_logic_vector(15 downto 0):=(others =>'0');
signal PC_imm_out 					:std_logic_vector(15 downto 0);
signal RR_EX_reg_file_and_SE_ZP_in	:std_logic_vector(4*INSTRUCTION_SIZE-1 downto 0);
signal RR_EX_PC_in					:std_logic_vector(3*PC_SIZE-1 downto 0);
signal opcode_RR_check				:std_logic_vector(3 downto 0);
--signal	JLR_with_FWD				:std_logic_vector(15 downto 0);
--------------------Stall signals---------------------------------------------------------------------------
signal	ID_RR_control_logic_alias	:std_logic_vector(CONTROLLER_OUT_SIZE-1	downto RR_STAGE_BEGIN);
signal	ID_RR_control_logic			:std_logic_vector(CONTROLLER_OUT_SIZE-1	downto RR_STAGE_BEGIN);
signal	RR_EX_second_stage_control_logic:std_logic_vector(CONTROLLER_OUT_SIZE-1	downto EX_STAGE_BEGIN);
------------------------------------Check---------------------------------------------
signal	d1_RR_check						:std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal	d2_RR_check						:std_logic_vector(INSTRUCTION_SIZE-1 downto 0);

begin 

------------------------------------------------Component in this stage--------------------------------------------------------------------
opcode_RR_check		<=	ID_RR_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9);		

A2	<=ID_RR_Priority_in(PRIORITY_OUTPUT_SIZE downto 1)	when	ID_RR_first_stage_mem_in(INSTRUCTION_SIZE -1 downto INSTRUCTION_SIZE -4)="0111" else
	  ID_RR_control_logic_in(RR_STAGE_BEGIN+5 downto RR_STAGE_BEGIN+3);
	
			
			
			
RF_inst	 : register_file 
						port map  (clk	=> CLK,		
							A1	=> ID_RR_control_logic_in(RR_STAGE_BEGIN+2 downto  RR_STAGE_BEGIN),
							A2	=> A2,		
							A3	=> A3,
							data_out1 => data_out1,	
						    data_out2 => data_out2,		
							data_in3  => data_in3,		
							reg_file_write => reg_file_write_sig,
							R7_in		=>R7_in,	
							R7_write	=>R7_write,
						    R0 =>R0,           
							R1 =>R1,             
							R2 =>R2,             
							R3 =>R3,            
							R4 =>R4,           
							R5 =>R5,             
							R6 =>R6,            
							R7 =>R7);






--------------LW,SW,BEQ and ADI instruction-------------------------------------------------------------------												
SE6_inst: sign_extender generic map(NO_OF_INPUT_BIT=>6,NO_OF_OUTPUT_BIT=>16) 
						port map ( input => ID_RR_control_logic_in(RR_STAGE_BEGIN+11 downto RR_STAGE_BEGIN+6),
                                                      output => SE6_output
                                                    );
-----------------LHI,JAL instruction-------------------------------------------------------------------------	
SE9_inst: sign_extender generic map(NO_OF_INPUT_BIT=>9,NO_OF_OUTPUT_BIT=>16)  
					port map ( input => ID_RR_control_logic_in(RR_STAGE_BEGIN+20 downto RR_STAGE_BEGIN+12),
                                                      output => SE9_output
                                                    );
---------------------Zero Padding for LHI instruction -----------------------------------------------------

Zero_LHI_inst:zeropadding port map(input=>ID_RR_control_logic_in(RR_STAGE_BEGIN+20 downto RR_STAGE_BEGIN+12),
										output=>Zero_padding_out);





	
SE_output <= 	SE6_output when ID_RR_control_logic_in(RR_STAGE_BEGIN+21) ='0' else
                SE9_output ;
                
					
adder_PC_plus_imm_inst : adder_PC_plus_imm port map ( PC_in => ID_RR_first_stage_PC_in(15 downto 0), 
                                                     SE_in => SE_output,
													PC_out => PC_imm_out);
													
													
---------------------------------------------------------Jump related instruction-------------------------------------------------------------------
					  
--JLR_with_FWD	<=	FWD_reg_RR_data2 when FWD_Mux_RR_Select_signal2='1' else 	data_out2;										
--PC_JLR			<=JLR_with_FWD when ID_RR_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="1001";
PC_imm_JAL		<=PC_imm_out when ID_RR_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="1000" ;
PC_imm_BEQ		<=PC_imm_out when ID_RR_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="1100" ;
PC_LHI			<=Zero_padding_out when (ID_RR_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0011" and ID_RR_control_logic_in(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111");
----------------------------------------Next stage signals-------------------------------------------------------------------------------------------
RR_EX_reg_file_and_SE_ZP_in(15 downto 0)	<= FWD_reg_RR_data1 when FWD_Mux_RR_Select_signal1='1' else data_out1;--data_out1;
RR_EX_reg_file_and_SE_ZP_in(31 downto 16)	<= FWD_reg_RR_data2 when FWD_Mux_RR_Select_signal2='1' else 
											   --~ FWD_reg_RR_data1 when (FWD_Mux_RR_Select_signal1='1'and
																						--~ ID_RR_control_logic_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0111" )else
											   data_out2;--data_out2;
											   
d1_RR_check			<=	RR_EX_reg_file_and_SE_ZP_in(15 downto 0);					   
d2_RR_check	   		<=	RR_EX_reg_file_and_SE_ZP_in(31 downto 16);
											   
RR_EX_reg_file_and_SE_ZP_in(47 downto 32)	<=SE6_output;
RR_EX_reg_file_and_SE_ZP_in(63 downto 48)	<=Zero_padding_out;


								
RR_EX_PC_in(2*PC_SIZE-1 downto 0)			<=ID_RR_first_stage_PC_in;	---PC and PC+1
RR_EX_PC_in(3*PC_SIZE-1 downto 2*PC_SIZE)	<= PC_imm_BEQ;							
								
								
								
-------------------------------LM_SM_pecial_reg--------------------------------------------------------------------------							
	LM_SM_special_reg_inst	:LM_SM_special_reg generic map(SIZE_OF_REGISTER=>16) 
													port map(clk=>clk,					--comming from Data forwarding unit
															FWD_Mux_Select_signal1		=>FWD_Mux_Select_signal1,
															FWD_reg_EX_data1			=>FWD_reg_EX_data1,
															enable=>ID_RR_control_logic_in(EX_STAGE_BEGIN+7),
															din	  =>RR_EX_reg_file_and_SE_ZP_in(15 downto 0),
															dout  =>LM_SM_reg_out);							
								
								
--------------------------------Creating stalls-----------------------------------
ID_RR_control_logic_alias(WR_STAGE_BEGIN+4 downto EX_STAGE_BEGIN)<=RR_EX_second_stage_control_logic(WR_STAGE_BEGIN+4 downto EX_STAGE_BEGIN);
ID_RR_control_logic_alias(WR_STAGE_BEGIN+8 downto WR_STAGE_BEGIN+5)<= '0' & RR_EX_second_stage_control_logic(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5);
ID_RR_control_logic_alias(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)<=RR_EX_second_stage_control_logic(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9);


ID_RR_control_logic	<= ID_RR_control_logic_alias when  load_stalls ='1'else		
														ID_RR_control_logic_in;	
--ID_RR_control_logic<=	ID_RR_control_logic_in;								
ID_RR_control_logic_out	<=ID_RR_control_logic;						
-----------------Control signal sent to the next stage---------------------------------------------------------------------------------------
RR_EX_control_inst: nbit_register_stage generic map(END_OF_NBIT_REGISTER_STAGES=>CONTROLLER_OUT_SIZE,
													BEGIN_OF_NBIT_REGISTER_STAGES=>EX_STAGE_BEGIN)
										port map	(reset=>reset,
													 clk=>clk,
													 enable=>enable_RR_EX_reg,
													 ip_FF=>ID_RR_control_logic(CONTROLLER_OUT_SIZE-1 downto EX_STAGE_BEGIN),
													 op_FF=>RR_EX_second_stage_control_logic(CONTROLLER_OUT_SIZE-1	downto EX_STAGE_BEGIN));
	
RR_EX_second_stage_control_logic_out<=RR_EX_second_stage_control_logic;
---Consist of data_out1,data_out2,SE6_output and Zero_padding_out
RR_EX_reg_file_and_SE_inst:nbit_register generic map(SIZE_OF_REGISTER=>64) 
								port map	(reset=>reset,
											 clk=>clk,
											 enable=>enable_RR_EX_reg,
											 ip_FF=>RR_EX_reg_file_and_SE_ZP_in,
											 op_FF=>RR_EX_reg_file_and_SE_ZP_out);
---------Priority zero sent here------------------------------------------
Priority_Zero:nbit_register generic map(SIZE_OF_REGISTER=>4) 
								port map	(reset=>reset,
											 clk=>clk,
											 enable=>enable_RR_EX_reg,
											 ip_FF=>ID_RR_Priority_in,
											 op_FF=>RR_EX_Priority_Zero_out);



-----------------PC,PC+1,PC+immediate
RR_EX_PC_inst:nbit_register generic map(SIZE_OF_REGISTER=>48) 
								port map	(reset=>reset,
											 clk=>clk,
											 enable=>enable_RR_EX_reg,
											 ip_FF=>RR_EX_PC_in,
											 op_FF=>RR_EX_PC_out);

---------------------------------------------------------------------------------------------------------------------------------------------------												

end architecture;




