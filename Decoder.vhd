

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
-------------Defined package-------------------------
use work.Package_component_Pipeline.all;
--------------------------------------------------------


entity Decoder is 
	port(reset				: in std_logic;
		clk					: in std_logic;	----clk for SM reg
		INSTRUCTION 		:in std_logic_vector(INSTRUCTION_SIZE -1 downto 0);
		 opcode_out 		: inout std_logic_vector(INSTRUCTION_SIZE -1 downto INSTRUCTION_SIZE -4);
		 CONTROL_SIGNAL_OUT	:out std_logic_vector(CONTROLLER_OUT_SIZE-1 downto 0)
			);
	
	end entity;
	
	
	
architecture behavour of Decoder is 


signal CZ 	  			:std_logic_vector(CZ_SIZE-1 downto 0);
type INSTRUCION_NAME is (ADD,ADC,ADZ,ADI,NDU,NDC,NDZ,LHI,LW,SW,LM,SM,BEQ,JAL,JLR,NONE);
signal INSTRUCTION_OUT:INSTRUCION_NAME;
signal opcode 			:std_logic_vector(INSTRUCTION_SIZE -1 downto INSTRUCTION_SIZE -4);
---Register Read stage-------------------------------------------------------------
signal R_A1					:std_logic_vector(2 downto 0);
signal R_A2					:std_logic_vector(2 downto 0);
signal immediate6			:std_logic_vector(5 downto 0);
signal immediate9			:std_logic_vector(8 downto 0);
signal mux_sel_SE6_SE9 		:std_logic;
signal enable_priority		:std_logic;
----------EX_stage---------------------------------------------------------------
signal ALU_Op1						:std_logic_vector(1 downto 0);
signal ALU_Op2						:std_logic_vector(1 downto 0);
signal ALU_Ctrl						:std_logic_vector(2 downto 0);
signal enable_displacement			:std_logic;
--------------------------------Memory---------------------------------------------
signal memory_write	:std_logic;
signal memory_read	:std_logic;
signal PC_select    :std_logic_vector(1 downto 0);
signal zero_flag_select :std_logic;
-----------------------------Write_back_stage-----------------------------------------
signal mem_to_reg		:std_logic_vector(1 downto 0);
signal reg_write		:std_logic;
signal check_cz			:std_logic_vector(1 downto 0);
signal R_A3				:std_logic_vector(2 downto 0);
signal R7_write			:std_logic;
----------------------------------------------------------------------------------------
signal	R_A3_reg_write			:std_logic_vector(3 downto 0);
signal	R_A3_reg_write_previous	:std_logic_vector(3 downto 0);


begin
opcode <= INSTRUCTION(INSTRUCTION_SIZE -1 downto INSTRUCTION_SIZE -4);
opcode_out<=INSTRUCTION(INSTRUCTION_SIZE -1 downto INSTRUCTION_SIZE -4);
----------------ID_stage------------------------------------------------------------------

CONTROL_SIGNAL_OUT(ID_STAGE_BEGIN)									<= enable_priority; 
-----------------Register_read_stage------------------------------------------------------
CONTROL_SIGNAL_OUT(RR_STAGE_BEGIN+2 downto  RR_STAGE_BEGIN)			<=	R_A1;
CONTROL_SIGNAL_OUT(RR_STAGE_BEGIN+5 downto RR_STAGE_BEGIN+3)		<=	R_A2;
CONTROL_SIGNAL_OUT(RR_STAGE_BEGIN+11 downto RR_STAGE_BEGIN+6)		<=	immediate6;
CONTROL_SIGNAL_OUT(RR_STAGE_BEGIN+20 downto RR_STAGE_BEGIN+12)		<=	immediate9;
CONTROL_SIGNAL_OUT(RR_STAGE_BEGIN+21)        			      		<= mux_sel_SE6_SE9;     ---Sadaf Date 18 March 2017 11:05am    			      		    
---------------Execute stage-----------------------------------------------------------------
CONTROL_SIGNAL_OUT(EX_STAGE_BEGIN+1 downto EX_STAGE_BEGIN)			<=	ALU_Op1;
CONTROL_SIGNAL_OUT(EX_STAGE_BEGIN+3 downto EX_STAGE_BEGIN+2)		<=	ALU_Op2;
CONTROL_SIGNAL_OUT(EX_STAGE_BEGIN+6 downto EX_STAGE_BEGIN+4)		<=	ALU_Ctrl;
CONTROL_SIGNAL_OUT(EX_STAGE_BEGIN+7)								<=enable_displacement;
CONTROL_SIGNAL_OUT(EX_STAGE_BEGIN+10  downto EX_STAGE_BEGIN+8)		<=R_A1;
CONTROL_SIGNAL_OUT(EX_STAGE_BEGIN+13  downto EX_STAGE_BEGIN+11)		<=R_A2;

-----------------Memory stage------------------------------------------------------------------
CONTROL_SIGNAL_OUT(MM_STAGE_BEGIN)									<=	memory_write;
CONTROL_SIGNAL_OUT(MM_STAGE_BEGIN+1)								<=	memory_read;
CONTROL_SIGNAL_OUT(MM_STAGE_BEGIN+3 downto MM_STAGE_BEGIN+2)		<=	PC_select;
CONTROL_SIGNAL_OUT(MM_STAGE_BEGIN+4)		                        <=  zero_flag_select;
CONTROL_SIGNAL_OUT(MM_STAGE_BEGIN+7 downto MM_STAGE_BEGIN+5)		<=	R_A2;

----The signal R_A1	and R_A2 are forwarded just because of the reason that in case of the forwarding logic we have to check the address 
----of the registers (A1,A2) matches with the destination address then forwarding of the data is done.


---------------Register_write_back--------------------------------------------------------------
CONTROL_SIGNAL_OUT(WR_STAGE_BEGIN+1 downto WR_STAGE_BEGIN)			<=	mem_to_reg;
CONTROL_SIGNAL_OUT(WR_STAGE_BEGIN+2)								<=	reg_write;
CONTROL_SIGNAL_OUT(WR_STAGE_BEGIN+4 downto WR_STAGE_BEGIN+3)		<=	check_cz;
CONTROL_SIGNAL_OUT(WR_STAGE_BEGIN+7 downto WR_STAGE_BEGIN+5)		<=	R_A3;
CONTROL_SIGNAL_OUT(WR_STAGE_BEGIN+8)             				 	<=  R7_write;
CONTROL_SIGNAL_OUT(WR_STAGE_BEGIN+12 downto WR_STAGE_BEGIN+9)       <=INSTRUCTION(INSTRUCTION_SIZE -1 downto INSTRUCTION_SIZE -4);

--------------------------------------------------------------------------------------------------


CZ		<=INSTRUCTION( 1 downto 0);

process (opcode,CZ,reset,INSTRUCTION)
begin
	mux_sel_SE6_SE9 <= '0';
				if(reset='1')then
								INSTRUCTION_OUT <=NONE;
								--------------ID_stage-------------------------------------------------
								enable_priority	<='0';	
								-------------Register_read----------------------------------------------
								R_A1			<=(others=>'0');
								R_A2			<=(others=>'0');
								immediate6		<=(others=>'0');
								immediate9		<=(others=>'0');	
								mux_sel_SE6_SE9 <= '0';
								------------Execute stage----------------------------------------------
								ALU_Op1			<="00";
								ALU_Op2			<="00";
								ALU_Ctrl		<="000";
								enable_displacement	<='0';
								-------------Memory stage----------------------------------------------
								memory_write	<='0';
								memory_read		<='0';
								PC_select		<="00";
								--------------Write back stage----------------------------------------
								mem_to_reg		<="00";			--Actually dont care
								reg_write		<='0';
								--reg_write_sel		<='';
								check_cz			<="00";
								R_A3			<=(others=>'0');	
								R7_write		<='0';
								---------------------------------------------------------------------------
	else
	case opcode is
		
		
		
		when "0000" =>	if(CZ="00")then
								INSTRUCTION_OUT <=ADD;
								--------------ID_stage-------------------------------------------------
								enable_priority	<='0';									
								-------------Register_read----------------------------------------------
								R_A1			<=INSTRUCTION(11 downto 9);
								R_A2			<=INSTRUCTION(8 downto 6);
								immediate6		<=(others => '0');
								immediate9		<=(others=>'0');	
								------------Execute stage----------------------------------------------
								ALU_Op1				<="00";
								ALU_Op2				<="00";
								ALU_Ctrl			<="011";
								enable_displacement	<='0';
								-------------Memory stage----------------------------------------------
								memory_write	<='0';
								memory_read		<='0';
								PC_select		<="00";
								zero_flag_select<= '0';
								--------------Write back stage----------------------------------------
								mem_to_reg		<="00";
								reg_write		<='1';
								--reg_write_sel		<='';
								check_cz			<="00";
								R_A3			<=INSTRUCTION(5 downto 3);
								R7_write		<='1';
								---------------------------------------------------------------------------
								
							elsif(CZ="10")then
								INSTRUCTION_OUT <=ADC;
								--------------ID_stage-------------------------------------------------
								enable_priority	<='0';	
								-------------Register_read----------------------------------------------
								R_A1			<=INSTRUCTION(11 downto 9);
								R_A2			<=INSTRUCTION(8 downto 6);
								immediate6		<=(others => '0');	
								immediate9		<=(others=>'0');	
								------------Execute stage----------------------------------------------
								ALU_Op1				<="00";
								ALU_Op2				<="00";
								ALU_Ctrl			<="011";
								enable_displacement	<='0';
								-------------Memory stage----------------------------------------------
								memory_write	<='0';
								memory_read		<='0';
								PC_select		<="00";
								zero_flag_select<= '0';
								--------------Write back stage----------------------------------------
								mem_to_reg		<="00";
								reg_write		<='1';
								--reg_write_sel		<='';
								check_cz			<="10";
								R_A3			<=INSTRUCTION(5 downto 3);
								R7_write		<='1';
								------------------------------------------------------------------------
								
								
							elsif(CZ="01")then
								INSTRUCTION_OUT <=ADZ;
								--------------ID_stage-------------------------------------------------
								enable_priority	<='0';	
								-------------Register_read----------------------------------------------
								R_A1			<=INSTRUCTION(11 downto 9);
								R_A2			<=INSTRUCTION(8 downto 6);
								immediate6		<=(others => '0');	
								immediate9		<=(others=>'0');	
								------------Execute stage----------------------------------------------
								ALU_Op1				<="00";
								ALU_Op2				<="00";
								ALU_Ctrl			<="011";
								enable_displacement	<='0';
								-------------Memory stage----------------------------------------------
								memory_write	<='0';
								memory_read		<='0';
								PC_select		<="00";
								zero_flag_select<= '0';
								--------------Write back stage----------------------------------------
								mem_to_reg		<="00";
								reg_write		<='1';
								--reg_write_sel		<='';
								check_cz			<="01";
								R_A3			<=INSTRUCTION(5 downto 3);
								R7_write		<='1';
								------------------------------------------------------------------------
							end if;
								
							
							
		when "0001" =>			INSTRUCTION_OUT <=ADI;
								--------------ID_stage-------------------------------------------------
								enable_priority	<='0';	
								-------------Register_read----------------------------------------------
								R_A1			<=INSTRUCTION(11 downto 9);
								immediate6		<=INSTRUCTION(5 downto 0);	
								immediate9		<=(others=>'0');	
								mux_sel_SE6_SE9 <= '0';
								------------Execute stage----------------------------------------------
								ALU_Op1				<="00";
								ALU_Op2				<="01";
								ALU_Ctrl			<="011";
								enable_displacement	<='0';
								-------------Memory stage----------------------------------------------
								memory_write	<='0';
								memory_read		<='0';
								PC_select		<="00";
								zero_flag_select<= '0';
								--------------Write back stage----------------------------------------
								mem_to_reg		<="00";
								reg_write		<='1';
								--reg_write_sel		<='';
								check_cz			<="00";
								R_A3			<=INSTRUCTION(8 downto 6);
								R7_write		<='1';
								------------------------------------------------------------------------
		
		
		when "0010" =>		if(CZ="00")then
								INSTRUCTION_OUT <=NDU;
								--------------ID_stage-------------------------------------------------
								enable_priority	<='0';	
								-------------Register_read----------------------------------------------
								R_A1			<=INSTRUCTION(11 downto 9);
								R_A2			<=INSTRUCTION(8 downto 6);
								immediate6		<=(others => '0');
								immediate9		<=(others=>'0');		
								------------Execute stage----------------------------------------------
								ALU_Op1				<="00";
								ALU_Op2				<="00";
								ALU_Ctrl			<="111";
								enable_displacement	<='0';
								-------------Memory stage----------------------------------------------
								memory_write	<='0';
								memory_read		<='0';
								PC_select		<="00";
								zero_flag_select<= '0';
								--------------Write back stage----------------------------------------
								mem_to_reg		<="00";
								reg_write		<='1';
								--reg_write_sel		<='';
								check_cz			<="00";
								R_A3			<=INSTRUCTION(5 downto 3);
								R7_write		<='1';
								---------------------------------------------------------------------------
							elsif(CZ="10")then
								INSTRUCTION_OUT <=NDC;
								--------------ID_stage-------------------------------------------------
								enable_priority	<='0';	
								-------------Register_read----------------------------------------------
								R_A1			<=INSTRUCTION(11 downto 9);
								R_A2			<=INSTRUCTION(8 downto 6);
								immediate6		<=(others => '0');	
								immediate9		<=(others=>'0');	
								------------Execute stage----------------------------------------------
								ALU_Op1				<="00";
								ALU_Op2				<="00";
								ALU_Ctrl			<="111";
								enable_displacement	<='0';
								-------------Memory stage----------------------------------------------
								memory_write		<='0';
								memory_read			<='0';
								PC_select		<="00";
								zero_flag_select<= '0';
								--------------Write back stage----------------------------------------
								mem_to_reg			<="00";
								reg_write			<='1';
								--reg_write_sel		<='';
								check_cz			<="10";
								R_A3			<=INSTRUCTION(5 downto 3);
								R7_write		<='1';
								------------------------------------------------------------------------
							elsif(CZ="01")then
								INSTRUCTION_OUT <=NDZ;
								--------------ID_stage-------------------------------------------------
								enable_priority	<='0';	
								-------------Register_read----------------------------------------------
								R_A1			<=INSTRUCTION(11 downto 9);
								R_A2			<=INSTRUCTION(8 downto 6);
								immediate6		<=(others => '0');	
								immediate9		<=(others=>'0');	
								------------Execute stage----------------------------------------------
								ALU_Op1				<="00";
								ALU_Op2				<="00";
								ALU_Ctrl			<="111";
								enable_displacement	<='0';
								-------------Memory stage----------------------------------------------
								memory_write	<='0';
								memory_read		<='0';
								PC_select		<="00";
								zero_flag_select<= '0';
								--------------Write back stage----------------------------------------
								mem_to_reg		<="00";
								reg_write		<='1';
								--reg_write_sel	<='';
								check_cz			<="01";
								R_A3			<=INSTRUCTION(5 downto 3);
								R7_write		<='1';
								------------------------------------------------------------------------
							end if;
							
						
		
		
		
		
		
		when "0011" =>	INSTRUCTION_OUT <=LHI;
								--------------ID_stage-------------------------------------------------
								enable_priority	<='0';	
								-------------Register_read----------------------------------------------
								-------------Only immediate is required----------------------------------
								--R_A1			<=INSTRUCTION(8 downto 6);	----		Not required
								--R_A2			<=INSTRUCTION(8 downto 6);	----		Not required
								immediate9		<=INSTRUCTION(8 downto 0);	
								mux_sel_SE6_SE9 <= '1';
								------------Execute stage----------------------------------------------
								---------------NOt Required--------------------------------------------
								--ALU_Op1			<="00";
								--ALU_Op2			<="01";
								ALU_Ctrl		<="000";
								enable_displacement	<='0';
								-------------Memory stage----------------------------------------------
								memory_write	<='0';
								memory_read		<='0';
								PC_select		<="00";
								zero_flag_select<= '0';
								--------------Write back stage----------------------------------------
								mem_to_reg		<="11";
								reg_write		<='1';
								--reg_write_sel		<='';
								check_cz			<="00";
								R_A3			<=INSTRUCTION(11 downto 9);
								R7_write		<='1';
								---------------------------------------------------------------------------
		
						
					
		when "0100" =>	INSTRUCTION_OUT <=LW;
								--------------ID_stage-------------------------------------------------
								enable_priority	<='0';	
								-------------Register_read----------------------------------------------
								R_A1			<=INSTRUCTION(8 downto 6);
								--R_A2			<=INSTRUCTION(8 downto 6);
								immediate6		<=INSTRUCTION(5 downto 0);
								immediate9		<=(others=>'0');	
								mux_sel_SE6_SE9 <= '0';    
								------------Execute stage----------------------------------------------
								ALU_Op1				<="00";
								ALU_Op2				<="01";
								ALU_Ctrl			<="000";
								enable_displacement	<='0';
								-------------Memory stage----------------------------------------------
								memory_write	<='0';
								memory_read		<='1';
								PC_select		<="00";
								zero_flag_select<= '1';
								--------------Write back stage----------------------------------------
								mem_to_reg		<="01";
								reg_write		<='1';
								--reg_write_sel		<='';
								check_cz			<="00";
								R_A3			<=INSTRUCTION(11 downto 9);
								R7_write		<='1';
								---------------------------------------------------------------------------
		
		
		
		
					
		when "0101" =>	INSTRUCTION_OUT <=SW;
								--------------ID_stage-------------------------------------------------
								enable_priority	<='0';	
								-------------Register_read----------------------------------------------
								R_A1			<=INSTRUCTION(8 downto 6);
								R_A2			<=INSTRUCTION(11 downto 9);
								immediate6		<=INSTRUCTION(5 downto 0);	
								immediate9		<=(others=>'0');	
								mux_sel_SE6_SE9 <= '0';
								------------Execute stage----------------------------------------------
								ALU_Op1				<="00";
								ALU_Op2				<="01";
								ALU_Ctrl			<="000";
								enable_displacement	<='0';
								-------------Memory stage----------------------------------------------
								memory_write	<='1';
								memory_read		<='0';
								PC_select		<="00";
								zero_flag_select<= '0';
								--------------Write back stage----------------------------------------
								mem_to_reg		<="01";
								reg_write		<='0';
								--reg_write_sel		<='';
								check_cz			<="00";
								--R_A3			<=
								R7_write		<='1';
								---------------------------------------------------------------------------
		
		
		
		
		
		
		when "0110" =>	INSTRUCTION_OUT <=LM;
								--------------ID_stage-------------------------------------------------
								enable_priority	<='1';	
								--------------------------------Register_read--------------------------------------
								R_A1			<=INSTRUCTION(11 downto 9);
								immediate9		<= '0' & INSTRUCTION(7 downto 0);	
								-------------------------------Execute stage-----------------------------------------
								enable_displacement	<='1';
								ALU_Op1				<="01";
								ALU_Op2				<="10";
								ALU_Ctrl			<="000";
								---------------------------------Memory_stage---------------------------------------
							
								memory_write	<='0';
								memory_read		<='1';
								PC_select		<="00";
								zero_flag_select<= '1';
								--------------Write back stage----------------------------------------
								mem_to_reg		<="01";
								reg_write		<='1';
								--reg_write_sel		<='';
								check_cz			<="00";
								R_A3			<=INSTRUCTION(11 downto 9);
								R7_write		<='1';
								---------------------------------------------------------------------------
						
						
						
		when "0111" =>	INSTRUCTION_OUT <=SM;
							--------------ID_stage-------------------------------------------------
								enable_priority	<='1';	
							--------------------------------Register_read----------------------------------------
								R_A1			<=INSTRUCTION(11 downto 9);
								immediate9		<= '0' & INSTRUCTION(7 downto 0);		
							-------------------------------Execute stage-----------------------------------------
								enable_displacement	<='1';
								ALU_Op1				<="00";
								ALU_Op2				<="10";
								ALU_Ctrl			<="000";
							-------------Memory stage----------------------------------------------
								memory_write	<='1';
								memory_read		<='0';
								PC_select		<="00";
								zero_flag_select<= '0';
								--------------Write back stage----------------------------------------
								mem_to_reg		<="01";			--	Actually dont care
								reg_write		<='0';--R_A3_reg_write_previous(3);
								--reg_write_sel		<='';
								check_cz			<="00";
								R_A3			<=R_A3_reg_write_previous(2 downto 0);
								R7_write		<='1';
							---------------------------------------------------------------------------		
								
						
		when "1000" =>		INSTRUCTION_OUT <=JAL;
								--------------ID_stage-------------------------------------------------
								enable_priority	<='0';	
								-------------Register_read----------------------------------------------
								--R_A1			<=INSTRUCTION(8 downto 6);
								--R_A2			<=INSTRUCTION(8 downto 6);
								immediate9		<=INSTRUCTION(8 downto 0);	
								mux_sel_SE6_SE9 <= '1';
								------------Execute stage----------------------------------------------
								--------NOt reguired here---------------------------------
								ALU_Op1			<="00";
								ALU_Op2			<="01";
								ALU_Ctrl		<="000";
								enable_displacement	<='0';
								-------------Memory stage----------------------------------------------
								memory_write	<='0';
								memory_read		<='0';
								PC_select		<="00";
								zero_flag_select<= '0';
								--------------Write back stage----------------------------------------
								mem_to_reg		<="10";					--PC+1 into Reg
								reg_write		<='1';
								--reg_write_sel		<='';
								check_cz			<="00";
								R_A3			<=INSTRUCTION(11 downto 9);
								R7_write		<='1';
								---------------------------------------------------------------------------
							
		when "1001" =>	INSTRUCTION_OUT <=JLR;
								--------------ID_stage-------------------------------------------------
								enable_priority	<='0';	
								-------------Register_read----------------------------------------------
								--R_A1			<=INSTRUCTION(8 downto 6);
								R_A2			<=INSTRUCTION(8 downto 6);
								--immediate9		<=INSTRUCTION(8 downto 0);	
								------------Execute stage----------------------------------------------
								--------NOt reguired here---------------------------------
								ALU_Op1			<="00";
								ALU_Op2			<="01";
								ALU_Ctrl		<="000";
								enable_displacement	<='0';
								-------------Memory stage----------------------------------------------
								memory_write	<='0';
								memory_read		<='0';
								PC_select		<="00";
								zero_flag_select<= '0';
								--------------Write back stage----------------------------------------
								mem_to_reg		<="10";					--PC+1 into Reg
								reg_write		<='1';
								--reg_write_sel		<='';
								check_cz			<="00";
								R_A3			<=INSTRUCTION(11 downto 9);
								R7_write		<='1';
								---------------------------------------------------------------------------
		when "1100" =>	INSTRUCTION_OUT <=BEQ;
								--------------ID_stage-------------------------------------------------
								enable_priority	<='0';	
								-------------Register_read----------------------------------------------
								R_A1			<=INSTRUCTION(11 downto 9);
								R_A2			<=INSTRUCTION(8 downto  6);
								immediate6		<=INSTRUCTION(5 downto 0);	
								immediate9		<=(others=>'0');	
								mux_sel_SE6_SE9 <= '0';
								------------Execute stage----------------------------------------------
								ALU_Op1			<="00";
								ALU_Op2			<="11";
								ALU_Ctrl		<="001";
								enable_displacement	<='0';
								-------------Memory stage----------------------------------------------
								memory_write	<='0';
								memory_read		<='0';
								PC_select		<="01";
								zero_flag_select<= '0';
								--------------Write back stage----------------------------------------
								mem_to_reg		<="00";			--Actually dont care
								reg_write		<='0';
								--reg_write_sel		<='';
								check_cz			<="00";
								R_A3			<=INSTRUCTION(11 downto 9);
								R7_write		<='1';
								---------------------------------------------------------------------------
		
		when  others =>INSTRUCTION_OUT <=NONE;
								--------------ID_stage-------------------------------------------------
								enable_priority	<='0';	
								-------------Register_read----------------------------------------------
								R_A1			<=INSTRUCTION(8 downto 6);
								R_A2			<=INSTRUCTION(8 downto 6);
								immediate6		<=(others=>'0');
								immediate9		<=(others=>'0');	
								mux_sel_SE6_SE9 <= '0';
								------------Execute stage----------------------------------------------
								ALU_Op1			<="00";
								ALU_Op2			<="00";
								ALU_Ctrl		<="000";
								enable_displacement	<='0';
								-------------Memory stage----------------------------------------------
								memory_write	<='0';
								memory_read		<='0';
								PC_select		<="00";
								zero_flag_select<= '0';

								--------------Write back stage----------------------------------------
								mem_to_reg		<="00";			--Actually dont care
								reg_write		<='0';
								--reg_write_sel		<='';
								check_cz			<="00";
								R_A3			<=INSTRUCTION(11 downto 9);
								R7_write		<='0';
								---------------------------------------------------------------------------
		
		end case;
	end if;
end process;



			
	R_A3_reg_write	<=reg_write & R_A3; 	
NBIT_Reg_SM	:nbit_register generic map(SIZE_OF_REGISTER	=>4)
						port map(reset=>reset,
									clk=>clk,
									enable=>'1',
									ip_FF=>R_A3_reg_write,
									op_FF=>R_A3_reg_write_previous);
	
end;
		
		 
		
