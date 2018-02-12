---Here the ALU_Ctrl (1 downto 0 ) is for the Carry Flag and Zero Flag. All the AADs,ADI,NANDs instruction modify the carry and zero flag respectively.
---Instruction like ADC,ADZ,NDC,NDZ will perform the operation only when the previous instruction has set the carry flag and zero flag respectively.

----In this entity we are basically forwarding the carry,zero flag from the MEM stage and WB stage to the EX stage so that it can be used by the 
----instruction in the EX stage(for ADC,ADZ,NDC,NDZ instruction)and prform the operation.


library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Flag_contrrol is
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
end entity;

architecture behav of Flag_contrrol is

begin
		
			process(ALU_Ctrl_EX_MEM,ALU_Ctrl_MEM_WB,MEM_WB_carry_zero_out,EX_MEM_carry_zero_out,CZ_reg)
			begin
				
				if(reset='1')then
					CZ_forward(1)			<='0';
					--forward_flag_Ctrl(1)	<='0';
				else	
					if(ALU_Ctrl_EX_MEM(1)='1')then
						CZ_forward(1)			<=MEM_WB_carry_zero_out(1);
											
					--	forward_flag_Ctrl(1)	<='1';
					elsif(ALU_Ctrl_MEM_WB(0)='1')then
						CZ_forward(1)			<=EX_MEM_carry_zero_out(1);
						
					--	forward_flag_Ctrl(1)	<='1';
					else
						CZ_forward(1)			<=CZ_reg(1);
					--	forward_flag_Ctrl(1)	<='0';
					end if;
				end if;
			end process;
			
			
			
			
			process(ALU_Ctrl_EX_MEM,ALU_Ctrl_MEM_WB,MEM_WB_carry_zero_out,EX_MEM_carry_zero_out,CZ_reg)
			begin
				
				if(reset='1')then
					CZ_forward(0)			<='0';
					--forward_flag_Ctrl(0)	<='0';
				else	
					if(ALU_Ctrl_EX_MEM(0)='1')then
						CZ_forward(0)			<=MEM_WB_carry_zero_out(0);
					elsif(zero_flag_select="11")then
					
								CZ_forward(0)	<=zero_flag_mem_update_sig;						
					--	forward_flag_Ctrl(0)	<='1';
					elsif(ALU_Ctrl_MEM_WB(0)='1')then
						CZ_forward(0)			<=EX_MEM_carry_zero_out(0);
													
					--	forward_flag_Ctrl(0)	<='1';
					else
						CZ_forward(0)			<=CZ_reg(0);
					--	forward_flag_Ctrl(0)	<='0';
					end if;
				end if;
			end process;

end;
			
			
			
			
			
