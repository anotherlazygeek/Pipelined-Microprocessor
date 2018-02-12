


library IEEE;
use IEEE.STD_LOGIC_1164.all;     
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
-------------------------------Priority_encoder_with_decoder-----------------------------------------------------
entity priority_encoder_8_3 is
	generic(PRIORITY_INPUT_SIZE:integer :=8;PRIORITY_OUTPUT_SIZE:integer:=3);
     port(
         priority_input 	: in STD_LOGIC_VECTOR(PRIORITY_INPUT_SIZE -1 downto 0);
         priority_output 	:out std_logic_vector(PRIORITY_OUTPUT_SIZE-1 downto 0);
         feedback 			: out std_logic_vector(PRIORITY_INPUT_SIZE-1 downto 0)
         );
end priority_encoder_8_3;


architecture priority_enc_arc of priority_encoder_8_3 is
signal decoder_out      		:std_logic_vector(PRIORITY_INPUT_SIZE-1 downto 0);

signal priority_output_alias 	:std_logic_vector(PRIORITY_OUTPUT_SIZE-1 downto 0):=(others=>'0');
 procedure decoder( signal decoder_in : in std_logic_vector(PRIORITY_OUTPUT_SIZE-1 downto 0); 
					signal decoder_out:out std_logic_vector((2**PRIORITY_OUTPUT_SIZE)-1 downto 0)) is
			 
			
				variable temp:std_logic_vector((2**PRIORITY_OUTPUT_SIZE)-1 downto 0):=(others=>'0');
				begin
				
					temp(conv_integer(decoder_in)):= '1';
					decoder_out<=temp;
			
	 end procedure;


begin

    pri_enc : process (priority_input) 
    begin
        if (priority_input(0)='1') then
            priority_output_alias <= "000";
        elsif (priority_input(1)='1') then
            priority_output_alias <= "001";
        elsif (priority_input(2)='1') then
            priority_output_alias <= "010";
        elsif (priority_input(3)='1') then
            priority_output_alias <= "011";
        elsif (priority_input(4)='1') then
            priority_output_alias <= "100";
        elsif (priority_input(5)='1') then
            priority_output_alias <= "101";
        elsif (priority_input(6)='1') then
            priority_output_alias <= "110";
        elsif (priority_input(7)='1') then
            priority_output_alias <= "111";
        else
			priority_output_alias <= "000";
	
        end if;
    end process pri_enc;
   
   
   
   


decoder (priority_output_alias,decoder_out);

feedback <= decoder_out xor priority_input;
priority_output<=priority_output_alias;
end ;

--------------------------------------------------------------------------------------------------------



---------------------Priority_logic------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;     
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.Package_component_Pipeline.all;
entity priority_logic is 
	generic(PRIORITY_INPUT_SIZE:integer :=8;PRIORITY_OUTPUT_SIZE:integer:=3);
	port(reset					:in std_logic;
		clk 					:in std_logic;
		enable_priority			:in std_logic;
		priory_mux_sel			:in std_logic;
		priority_zero			:out std_logic;
		priority_ip_immediate 	:in std_logic_vector(PRIORITY_INPUT_SIZE -1 downto 0);
		op_to_register_file		:out std_logic_vector(PRIORITY_OUTPUT_SIZE-1 downto 0)
		);
		end entity;

architecture structural of  priority_logic  is 
signal feedback				:std_logic_vector(PRIORITY_INPUT_SIZE-1 downto 0);
signal feedback_reg_out		:std_logic_vector(PRIORITY_INPUT_SIZE-1 downto 0);
signal priorty_encoder_ip	:std_logic_vector(PRIORITY_INPUT_SIZE-1 downto 0);
signal enable_priority_sig	:std_logic;
signal priority_zero_sig	:std_logic;	
signal	count 				: integer;	
begin


nbit_reg_inst:nbit_register generic map(SIZE_OF_REGISTER=>8)
									port map (	reset=>reset,									
												clk =>clk,
												enable=>enable_priority_sig,
												ip_FF =>feedback,
												op_FF =>feedback_reg_out);
												
													
priorty_encoder_ip <=priority_ip_immediate when (priory_mux_sel='1') 	else feedback_reg_out;									
												
enable_priority_sig	<=enable_priority ;--when priory_mux_sel='0' else (not priority_zero_sig );



priority_zero	<=priority_zero_sig when reset='0' else '0';


process(priorty_encoder_ip)
variable c: integer;
begin
c:=0;
a1:for i in 0 to 7 loop
if(priorty_encoder_ip(i)='1')then
c:=c+1;
end if; 
end loop a1;
count<=c;
end process;
 
process(reset,enable_priority,priorty_encoder_ip,count)
begin
	
		if( count=1 and reset='0')then
		 if(enable_priority='1')then
			priority_zero_sig 			<= '1';
		end if;
	else
		priority_zero_sig 			<= '0';
	end if;
 
end process; 
 
 priority_encoder_inst: entity work.priority_encoder_8_3 port map (	priority_input	=>priorty_encoder_ip,
																	priority_output	=>op_to_register_file	,
																feedback 	  	=>feedback) ;



end;





