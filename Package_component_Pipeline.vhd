library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
package Package_component_Pipeline is


	constant		PC_SIZE					:integer 	:=16;
	constant		INSTRUCTION_SIZE		:integer	:=16;
	constant		PRIORITY_OUTPUT_SIZE	:integer	:=3;
	
	constant		ADDRESS_WIDTH 			:integer	:= 16;
	constant		DATA_WIDTH 				:integer	:= 16;


	constant		CONTROLLER_OUT_SIZE		:integer	:=58;
	constant       	OPCODE_SIZE				:integer 	:=4;
	constant       	CZ_SIZE					:integer 	:=2;
	
	
	constant		ID_STAGE_BEGIN			:integer 	:=0;
	constant      	RR_STAGE_BEGIN			:integer 	:=1;
	constant		EX_STAGE_BEGIN			:integer 	:=23;
	constant		MM_STAGE_BEGIN			:integer 	:=37;
	constant		WR_STAGE_BEGIN			:integer	:=45;
	constant		PRIORITY_INPUT_SIZE		:integer	:=8;
	constant		SIZE_OF_INPUT_BIT		:integer	:=3;
	constant		CONTROL_SIGNAL_FWD_SIZE :integer	:=2;

---------------------------------------PC and LM./SM--------------------------------------------------------------------------------------------
	component adder_PC is 
	generic(PC_SIZE:integer:=16);
	port(PC_in:in std_logic_vector(PC_SIZE-1 downto 0);
		 PC_out:out std_logic_vector(PC_SIZE-1 downto 0));
	end component;



	component adder_PC_plus_imm is 
	generic(PC_SIZE:integer:=16);
	port(PC_in:in std_logic_vector(PC_SIZE-1 downto 0);
             SE_in: in std_logic_vector(PC_SIZE-1 downto 0);
		 PC_out:out std_logic_vector(PC_SIZE-1 downto 0));
	end component;


----------------------Memory-------------------------------------------------------------------------------------------------------
	component memory is
	generic(ADDR_WITH:integer :=8;
		DATA_WIDTH:integer:=16);
	port(	clk			:in std_logic;
			mem_write	:in std_logic;
			mem_read	:in std_logic;
			addr		:in std_logic_vector(ADDR_WITH -1 downto 0);
			data_in		:in std_logic_vector(DATA_WIDTH -1 downto 0);
			data_out	:out std_logic_vector(DATA_WIDTH -1 downto 0)
		);
	end component;
	----------------------Decoder--------------------------------------------------------------------------------------------------------------
	
	component Decoder is 
	port(reset				:in std_logic;
		clk					: in std_logic;----clk for SM reg
		INSTRUCTION 		:in std_logic_vector(INSTRUCTION_SIZE -1 downto 0);
		 opcode_out 		:inout std_logic_vector(INSTRUCTION_SIZE -1 downto INSTRUCTION_SIZE -4);
		 CONTROL_SIGNAL_OUT	:out std_logic_vector(CONTROLLER_OUT_SIZE-1 downto 0)
			);
	
	end component;
	
	-------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------Priority_logic---------------------------------------------------------------------------------------------------
	component priority_logic is 
	generic(PRIORITY_INPUT_SIZE:integer :=8;PRIORITY_OUTPUT_SIZE:integer:=3);
	port(reset					:in std_logic;
		clk 					:in std_logic;
		enable_priority			:in std_logic;
		priory_mux_sel			:in std_logic;
		priority_zero			:out std_logic;
		priority_ip_immediate 	:in std_logic_vector(PRIORITY_INPUT_SIZE -1 downto 0);
		op_to_register_file		:out std_logic_vector(PRIORITY_OUTPUT_SIZE-1 downto 0)
		);
		end component;
	---------------------------------------------------------------------------------------------------------------------------------------------
	
	-----------------------------------------Register File------------------------------------------------------------------------------
component register_file is 
		generic(SIZE_OF_INPUT_BIT				:integer:=3;
				SIZE_OF_REGISTER_FILE			:integer:=8
			    );
		port (	clk				:in std_logic;
				A1			:in std_logic_vector(SIZE_OF_INPUT_BIT-1 downto 0);
				A2			:in std_logic_vector(SIZE_OF_INPUT_BIT-1 downto 0);
				A3			:in std_logic_vector(SIZE_OF_INPUT_BIT-1 downto 0);
				data_out1		:out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				data_out2		:out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				data_in3		:in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				reg_file_write	:in std_logic;
				R7_in			:in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R7_write		:in std_logic;
				
				R0              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R1              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R2              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R3              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R4              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R5              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R6              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
				R7              : out std_logic_vector(INSTRUCTION_SIZE-1 downto 0)
			);
		end component;
	
	
	
	
	---------------------------------------------------------------------------------------------------------------------------------
	
	-------------------------------LM_SM_logic_for the displacement in the ra register----------------------------------------------- 
	component	LM_SM_logic is
	generic(INSTRUCTION_SIZE:integer :=16);
	port(clk:in std_logic;
		reset:in std_logic;
		priority_zero	:in std_logic_vector(0 downto 0);
		enable_displacement	:in std_logic;
		displacement_out	:out std_logic_vector(INSTRUCTION_SIZE-1 downto 0)
			);
			
	end component;
	
	
	---------------------------------------------------ALU component------------------------------------------------------------------
	component twocomplement is
	generic(NO_OF_BIT :integer :=8);
	port(input :in std_logic_vector(NO_OF_BIT -1 downto 0);
		 output :out std_logic_vector(NO_OF_BIT -1 downto 0));
	end component;


	 component left_shift is
		generic(NO_OF_BIT :integer :=8);
		port(input :in std_logic_vector(NO_OF_BIT -1 downto 0);
		 output :out std_logic_vector(NO_OF_BIT -1 downto 0));
	end component;
	
	
	component sign_extender is
	generic(NO_OF_INPUT_BIT:integer:=8;
			NO_OF_OUTPUT_BIT:integer:=16);
	port(input :in std_logic_vector(NO_OF_INPUT_BIT -1 downto 0);
		output :out std_logic_vector(NO_OF_OUTPUT_BIT -1 downto 0)
		);
	end component;



	component zeropadding is 
	generic(NO_OF_INPUT_BIT:integer:=9;
			NO_OF_OUTPUT_BIT:integer:=16);
	port(input :in std_logic_vector(NO_OF_INPUT_BIT -1 downto 0);
		output :out std_logic_vector(NO_OF_OUTPUT_BIT -1 downto 0)
		);
	end component;
	
	
	
	
	component nbit_adder is 
	generic(NO_OF_ADDER_BIT:integer:=8);	
	port(reset		 : in std_logic;
		input1 		:in std_logic_vector(NO_OF_ADDER_BIT-1 downto 0);
		input2 		:in std_logic_vector(NO_OF_ADDER_BIT-1 downto 0);
		sum			:out std_logic_vector(NO_OF_ADDER_BIT-1 downto 0);
		carry_flag	 :out std_logic;
		Zero_flag	 :out std_logic);
	end component;
	
	
	
	component nand_operation is
	generic(NO_OF_NAND_BIT :integer := 8);
	port (reset		 : in std_logic;
		input1 		:in std_logic_vector(NO_OF_NAND_BIT-1 downto 0);
		input2 		:in std_logic_vector(NO_OF_NAND_BIT-1 downto 0);
		output		:out std_logic_vector(NO_OF_NAND_BIT-1 downto 0);
		Zero_flag	:out std_logic);
		
	end component;

	component ALU is 	
	generic(NO_OF_ALU_BIT:integer:=8;SIZE_OF_ALU_CONTROL_SIGNAL :integer:=3);	
	port(reset		: in std_logic;
		Alu_op		:in std_logic_vector(SIZE_OF_ALU_CONTROL_SIGNAL-1 downto 0);
		input1 		:in std_logic_vector(NO_OF_ALU_BIT-1 downto 0);
		input2 		:in std_logic_vector(NO_OF_ALU_BIT-1 downto 0);
		output		:out std_logic_vector(NO_OF_ALU_BIT-1 downto 0);
		carry_flag	 :out std_logic;
		Zero_flag	 :out std_logic);
	end component;
-----------------------------------------------------------------------------------------------------------------------------------
----------------------------------------Special Reg for LM/SM ---------------------------------------------------------------------
--Stores the value at the rising edge of enable signal 

component LM_SM_special_reg is
	generic(SIZE_OF_REGISTER		:integer :=16);
	port(clk						:in std_logic;
		 enable 					:in std_logic;
		 FWD_Mux_Select_signal1		:in std_logic;
		 FWD_reg_EX_data1			:in std_logic_vector(SIZE_OF_REGISTER-1 downto 0);
		 din						:in std_logic_vector(SIZE_OF_REGISTER-1 downto 0);
		 dout						:out std_logic_vector(SIZE_OF_REGISTER-1 downto 0)	
			);
	end component;

---------------------------------------------nbit_register-------------------------------------------------------------------------
	
component nbit_register is 
	generic(SIZE_OF_REGISTER	:integer :=16);
	port(reset		:in std_logic;
		clk			:in std_logic;
		enable		: in std_logic;
		ip_FF		:in std_logic_vector(SIZE_OF_REGISTER-1 downto 0);
		 op_FF		:out std_logic_vector(SIZE_OF_REGISTER-1 downto 0)
	
			);
			
	end component;
	-----------------------------------------------nbit_register_stage------------------------------------------------------------------------
	
	
	component nbit_register_stage is 
	generic(END_OF_NBIT_REGISTER_STAGES	:integer :=24;
			BEGIN_OF_NBIT_REGISTER_STAGES:integer:=16);
	port(reset		:in std_logic;
		clk			:in std_logic;
		enable		: in std_logic;
		ip_FF		:in std_logic_vector(END_OF_NBIT_REGISTER_STAGES-1 downto BEGIN_OF_NBIT_REGISTER_STAGES);
		 op_FF		:out std_logic_vector(END_OF_NBIT_REGISTER_STAGES-1 downto BEGIN_OF_NBIT_REGISTER_STAGES)
	
			);
			
	end component;
	-----------------------------------------------------------------------------------------------------------------------------------------
	
	
	
	
	
	
	
	
	
	
	
-----------------------------------------------Adding stages of the pipeline in the package---------------------------------------------------------------
------------------------------------------------------------IF stage---------------------------------------------------------
component IF_stage is 
	
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
	end component;
------------------------------------------------------------------------------------------------------------------------------


------------ID stage---------------------------------------------------------------------------	
component ID_stage is
		port(reset	:in std_logic;
		clk		:in std_logic;
		opcode					:inout std_logic_vector(INSTRUCTION_SIZE -1 downto INSTRUCTION_SIZE -4);
		--------------------Comming from previous stage---------------------------------------------------------------
		IF_ID_mem_in			:in std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
		IF_ID_PC_in				:in std_logic_vector(2*PC_SIZE-1 downto 0);
		---------------------------------------------------------------------------------------------------------------
		-----------------------------Enable to this stage------------------------------------------------------------
		enable_ID_RR_reg		: in std_logic;
		ID_RR_Priority_in		:in std_logic_vector(PRIORITY_OUTPUT_SIZE downto 0);
		op_to_register_file 	:out std_logic_vector(PRIORITY_OUTPUT_SIZE-1 downto 0);
		priority_zero			:out std_logic;
		
		
		-------------------Going to the next stage---------------------------------------------------------------------
		ID_RR_control_logic_out		:out std_logic_vector(CONTROLLER_OUT_SIZE-1	downto RR_STAGE_BEGIN);
		ID_RR_Priority_out			:out std_logic_vector(PRIORITY_OUTPUT_SIZE downto 0);--includes op_to_register_file and priority_zero
		ID_RR_first_stage_mem_out	:out std_logic_vector(INSTRUCTION_SIZE-1	downto 0);
		ID_RR_first_stage_PC_out	:out std_logic_vector(2*PC_SIZE-1 downto 0);
				------------------------------enable_priority =0 when load_stall =1
		load_stalls					:in std_logic;
		load_stall_LM_out			:out std_logic
		);
end component;
-----------------------------------------------------------------------------------------------	
----------------RR stage------------------------------------------------------------------------

component RR_stage is 
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
	--	 PC_JLR										:out std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
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
end component;
------------------EX_stage---------------------------------------------------------------------
component Execute_stage is
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
end component;
-------------------------------------------------------------------------------------------------------------------	
-------------------Memory_stage-----------------------------------------------------------------------------------	
component Memory_stage is
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
end component;

	
-----------------------------------------------------------------------------------------------------------------------	
	
component WriteBack_stage is
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
end component;
	
	
	
	
	
	
component Pipeline_intermediate_register_enable is
		port(clk				:in std_logic;
			reset				:in std_logic;
			load_stalls			:in std_logic;
			load_stall_LM_out	:in std_logic;
			priority_zero		:in std_logic;
			opcode				:in std_logic_vector(3 downto 0);
			enable_PC			:out std_logic;
			enable_IF_ID_reg	:out std_logic;
			enable_ID_RR_reg	:out std_logic;
			enable_RR_EX_reg	:out std_logic;
			enable_EX_MEM_reg	:out std_logic;
			enable_MEM_WB_reg	:out std_logic
			
			);
end component;
	
	
component Flag_contrrol is
	port(	reset				:in std_logic;
		ALU_Ctrl_EX_MEM			:in std_logic_vector(2 downto 0);
		ALU_Ctrl_MEM_WB			:in std_logic_vector(2 downto 0);	
		EX_MEM_carry_zero_out	:in std_logic_vector(1 downto 0);
		MEM_WB_carry_zero_out	:in std_logic_vector(1 downto 0);
		CZ_forward				:out std_logic_vector(1 downto 0);
		CZ_reg					:in std_logic_vector(1 downto 0);
		zero_flag_select		:in std_logic_vector(1 downto 0);
		zero_flag_mem_update_sig:in std_logic
	--	forward_flag_Ctrl		:out std_logic_vector(1 downto 0)
		
		);
end component;
	
	
	
component DataForwarding is
 port(reset											:in std_logic;
	  RR_stage_opcode								:in std_logic_vector(OPCODE_SIZE-1 downto 0);
	  EX_stage_opcode 								:in std_logic_vector(OPCODE_SIZE-1 downto 0);
	  EX_MEM_opcode									:in std_logic_vector(OPCODE_SIZE-1 downto 0);
	  MEM_WB_opcode									:in std_logic_vector(OPCODE_SIZE-1 downto 0);
	  RR_stage_reg_addr								:in std_logic_vector(2*SIZE_OF_INPUT_BIT +1 downto 0);---A2 is 6 downto 4 and A1 is 2 downto 0 
	  EX_stage_reg_addr								:in std_logic_vector(2*SIZE_OF_INPUT_BIT +1 downto 0);---A2 is 6 downto 4 and A1 is 2 downto 0 
	  MEM_stage_reg_addr							:in std_logic_vector(SIZE_OF_INPUT_BIT -1 downto 0); ----MEM_ADDR and DATA INPUT OF THE MEMORY
	  EX_MEM_reg_addr								:in std_logic_vector(SIZE_OF_INPUT_BIT-1 downto 0);----A3
	  MEM_WB_reg_addr								:in std_logic_vector(SIZE_OF_INPUT_BIT-1 downto 0);----A3
	 
	  
	  EX_MEM_data									:in std_logic_vector(2*DATA_WIDTH-1 downto 0);--The result of the ALU computation which 
	  --will be written into the register file and the content of R7 register in the writeback stage
	  EX_MEM_CONTROL_SIGNAL							:in std_logic_vector(CONTROL_SIGNAL_FWD_SIZE -1 downto 0);--reg_write and R7_write is forwarded
	  
	  
	 
	 
	  MEM_WB_data									:in std_logic_vector(2*DATA_WIDTH-1 downto 0);--The result of the ALU computation which 
	  --will be written into the register file and the content of R7 register in the writeback stage
	  MEM_WB_CONTROL_SIGNAL							:in std_logic_vector(CONTROL_SIGNAL_FWD_SIZE -1 downto 0);--reg_write and R7_write is forwarded
		
	  -----------------------Taken out for EX stage-----------------------------------------------------------------------------
	  FWD_reg_EX_addr1								:out std_logic_vector(SIZE_OF_INPUT_BIT-1 downto 0);
	  FWD_reg_EX_data1								:out std_logic_vector(DATA_WIDTH-1 downto 0);
	  FWD_Mux_Select_signal1						:out std_logic;
	  
	  FWD_reg_EX_addr2								:out std_logic_vector(SIZE_OF_INPUT_BIT-1 downto 0);
	  FWD_reg_EX_data2								:out std_logic_vector(DATA_WIDTH-1 downto 0);
	  FWD_Mux_Select_signal2						:out std_logic;
	  
	  
	   -----------------------Taken out for RR stage-----------------------------------------------------------------------------
	  FWD_reg_RR_addr1								:out std_logic_vector(SIZE_OF_INPUT_BIT-1 downto 0);
	  FWD_reg_RR_data1								:out std_logic_vector(DATA_WIDTH-1 downto 0);
	  FWD_Mux_RR_Select_signal1						:out std_logic;
	  
	  FWD_reg_RR_addr2								:out std_logic_vector(SIZE_OF_INPUT_BIT-1 downto 0);
	  FWD_reg_RR_data2								:out std_logic_vector(DATA_WIDTH-1 downto 0);
	  FWD_Mux_RR_Select_signal2						:out std_logic;
	  
	  ---------------------Taking for the MEM stage------------------------------------------------------------------------------
	  FWD_reg_MEM_addr2									:out std_logic_vector(SIZE_OF_INPUT_BIT-1 downto 0);
	  FWD_reg_MEM_data2									:out std_logic_vector(DATA_WIDTH-1 downto 0);
	  FWD_Mux_MEM_Select_signal2						:out std_logic;
	  -----------------------------------------------------------------------------------------------------------------------------
	  load_stalls									:out std_logic);

end component;
	
	
	
	
	
	
	
	
	
	
	
	
end package;
