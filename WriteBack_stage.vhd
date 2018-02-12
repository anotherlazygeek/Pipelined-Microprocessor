library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-----------------------------------------
use work.Package_component_Pipeline.ALL; 
-----------------------------------------

entity WriteBack_stage is
port ( reset	:in std_logic;
	   clk		:in std_logic;

	  -------------------- Coming from previous stage --------------------------------------------------------
	  MEM_WB_ZP_in				: in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
	  MEM_WB_ALU_output_in 		: in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
	  MEM_WB_ReadData_in 		: in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
	  MEM_WB_CZ_ALU_Ctrl_in 	: in std_logic_vector(4 downto 0);
	  MEM_WB_PC_1_imm_RB_in		: in std_logic_vector(PC_SIZE-1 downto 0);
	  MEM_WB_PC_and_PC_plus1_in : in std_logic_vector(2*PC_SIZE-1 downto 0);
	  MEM_WB_CONTROL_SIGNAL_in 	: in std_logic_vector(CONTROLLER_OUT_SIZE-1 downto WR_STAGE_BEGIN);
	  MEM_WB_Priority_Zero_in	: in std_logic_vector(PRIORITY_OUTPUT_SIZE downto  0);
	   
	   -----------------------------Enable to this stage------------------------------------------------------------
	  enable_CZ_reg		: in std_logic;
	  
	  --------------------- Write back to Register File---------------------
	  WB_Data_to_Reg 		: out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);     --- Data_from_memory, ALU_output, (PC+1/PC+imm/RB)
      WB_carry_zero_out     : out std_logic_vector(1 downto 0);	 
      WB_RegA3_out          : out std_logic_vector(2 downto 0);	  
	  WB_RegWrite           : out std_logic;  
      WB_RegR7_in           : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
	  WB_R7_write           : out std_logic;
	  WB_Priority_Zero_out	: out std_logic_vector(PRIORITY_OUTPUT_SIZE downto 0 );
	  CZ_forward			:in std_logic_vector(1 downto 0)
      );
end entity;

architecture WriteBack_stage_arch of WriteBack_stage is 
signal trial 				:std_logic_vector(3 downto 0);

begin 
trial			<=MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9);
WB_Data_to_Reg <= MEM_WB_ALU_output_in when MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+1 downto WR_STAGE_BEGIN) = "00" else
                  MEM_WB_ReadData_in when MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+1 downto WR_STAGE_BEGIN) = "01"   else
				  MEM_WB_PC_1_imm_RB_in when MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+1 downto WR_STAGE_BEGIN) = "10" else
				  MEM_WB_ZP_in;           


WB_RegA3_out <= MEM_WB_Priority_Zero_in(PRIORITY_OUTPUT_SIZE downto 1) when MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0110"
				else MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5);

WB_RegWrite  <= MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+2);

WB_R7_write  <= MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+8) ;

WB_RegR7_in  <= MEM_WB_PC_1_imm_RB_in when (MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="1100" and MEM_WB_CZ_ALU_Ctrl_in(0)='1')
				else
				----ADC
				MEM_WB_ALU_output_in  when 
				
				
				(MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0000"
				and MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="10"
				and MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"
				--and  CZ_forward ="10"
				 )or
				----ADZ
				(MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0000"
				and MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="01"
				and MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"
				and  CZ_forward ="01" 
				)
						or
				----NDC
				(MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0010"
				and MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="10"
				and MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"
				--and  CZ_forward ="10" 
				)or
				----NDZ
				(MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0010"
				and MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="01"
				and MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"
				and  CZ_forward ="01" )
						or
																	
							----ADD				
				(MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0000"
					and MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"
					and MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="00")or
					--NDU
				(MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0010"
				and MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"
				and MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)="10")or
					--ADI
				(MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0001"
				and MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111"
				)
				else
				MEM_WB_ZP_in	when (MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)="0011"
																		and MEM_WB_CONTROL_SIGNAL_in(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)="111")
																																
				else MEM_WB_PC_and_PC_plus1_in(2*PC_SIZE-1 downto PC_SIZE) ;
				--else MEM_WB_PC_and_PC_plus1_in(PC_SIZE-1 downto 0) ;

----------------------------------------------- Sadaf Date : 27 March ---------------------------------------
 WB_Priority_Zero_out <= MEM_WB_Priority_Zero_in;
-------------------------------------------------------------------------------------------------------------
CZ_flag_inst : nbit_register generic map(SIZE_OF_REGISTER=>2) 
								port map	(reset=>reset,
											 clk=>clk,
											 enable=>enable_CZ_reg,
											 ip_FF=>MEM_WB_CZ_ALU_Ctrl_in(1 downto 0),
											 op_FF=>WB_carry_zero_out);
											 

end WriteBack_stage_arch; 
