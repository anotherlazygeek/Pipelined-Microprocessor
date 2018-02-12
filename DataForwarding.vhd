library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
----The EX_MEM_data and MEM_WB_data has been changed from 32 bit to 16 bit .Later R7_out will come into play then it has to be 32 bits.

-------------Defined package-----------------------------
use work.Package_component_Pipeline.all;
---------------------------------------------------------

entity DataForwarding is
 port(reset											:in std_logic;
	  RR_stage_opcode								:in std_logic_vector(OPCODE_SIZE-1 downto 0);
	  EX_stage_opcode 								:in std_logic_vector(OPCODE_SIZE-1 downto 0);
	  EX_MEM_opcode									:in std_logic_vector(OPCODE_SIZE-1 downto 0);
	  MEM_WB_opcode									:in std_logic_vector(OPCODE_SIZE-1 downto 0);
	  RR_stage_reg_addr								:in std_logic_vector(2*SIZE_OF_INPUT_BIT +1 downto 0);---A2 is 6 downto 4 and A1 is 2 downto 0 
	  EX_stage_reg_addr								:in std_logic_vector(2*SIZE_OF_INPUT_BIT +1 downto 0);---A2 is 6 downto 4 and A1 is 2 downto 0 
	  MEM_stage_reg_addr							:in std_logic_vector(SIZE_OF_INPUT_BIT -1 downto 0); ----DATA INPUT OF THE MEMORY
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
	  --------------------------------------------------------------------------------------------------------------------------
	  load_stalls									:out std_logic);

end entity;

architecture behav of DataForwarding is
signal check 				:std_logic_vector(7 downto 0);
signal load_stalls_sig		:std_logic;	
---The first preference is always given to the EX/MEM stage over the MEM/WB stage because the former has more updated results than the latter.  
begin

load_stalls								<=load_stalls_sig;

------------------------------RR_stage is being checked here--------------------------------------------------------------------------------------
process(reset,MEM_WB_reg_addr,RR_stage_reg_addr,RR_stage_opcode,MEM_WB_CONTROL_SIGNAL,MEM_WB_data)
begin
	if(reset='1')then
		FWD_reg_RR_data1		<=(others=>'0');
		FWD_reg_RR_addr1		<=(others=>'0');
		FWD_Mux_RR_Select_signal1	<='0';
	
	
	--elsif(RR_stage_opcode="0000" or RR_stage_opcode="0001" or RR_stage_opcode="0010" or RR_stage_opcode="0100" or RR_stage_opcode="0110" or 
		--	RR_stage_opcode="0111" or RR_stage_opcode="1100" or RR_stage_opcode="0101" or RR_stage_opcode="0111" or RR_stage_opcode="1100"  )then			----A1 match with A3 in EX_MEM_reg

	else			
					----A1 match with A3 in MEM_WB_reg
		if(MEM_WB_CONTROL_SIGNAL(1)='1' and MEM_WB_reg_addr=RR_stage_reg_addr(SIZE_OF_INPUT_BIT-1 downto 0))then
				FWD_reg_RR_data1			<=	MEM_WB_data(DATA_WIDTH-1 downto 0);
				FWD_reg_RR_addr1			<=	MEM_WB_reg_addr;
				FWD_Mux_RR_Select_signal1	<='1';
				
		else 
				FWD_reg_RR_data1			<=	(others=>'0');
				FWD_reg_RR_addr1			<=	(others=>'0');
				FWD_Mux_RR_Select_signal1	<='0';
		end if;
	--else
				--FWD_reg_RR_data1			<=	(others=>'0');
				--FWD_reg_RR_addr1			<=	(others=>'0');
				--FWD_Mux_RR_Select_signal1	<='0';
	end if;
end process;			

process(reset,RR_stage_opcode,MEM_WB_reg_addr,RR_stage_reg_addr,MEM_WB_data,MEM_WB_CONTROL_SIGNAL)
begin
	if(reset='1')then
		FWD_reg_RR_data2		<=(others=>'0');
		FWD_reg_RR_addr2		<=(others=>'0');
		FWD_Mux_RR_Select_signal2	<='0';
	
	--~ elsif(RR_stage_opcode="0000" or RR_stage_opcode="0010" or RR_stage_opcode="0101"  or RR_stage_opcode="1001" 
		 --~ or RR_stage_opcode="0110"   or RR_stage_opcode="1100"   )then				---A2 match with A3 in EX_MEM_reg
	
	else	
						---A2 match with A3 in EX_MEM_reg
		if(MEM_WB_CONTROL_SIGNAL(1)='1' and MEM_WB_reg_addr=RR_stage_reg_addr(2*SIZE_OF_INPUT_BIT downto SIZE_OF_INPUT_BIT+1))then
				FWD_reg_RR_data2			<=	MEM_WB_data(DATA_WIDTH-1 downto 0);
				FWD_reg_RR_addr2			<=	MEM_WB_reg_addr;
				FWD_Mux_RR_Select_signal2	<='1';
				check(7	)					<='1';
		else 
				FWD_reg_RR_data2			<=	(others=>'0');
				FWD_reg_RR_addr2			<=	(others=>'0');
				FWD_Mux_RR_Select_signal2	<='0';
		end if;
	--else
				--FWD_reg_RR_data2			<=	(others=>'0');
				--FWD_reg_RR_addr2			<=	(others=>'0');
				--FWD_Mux_RR_Select_signal2	<='0';
	end if;
end process;					

-----------------------------------------------------------------------------------------------------------------------------------------------------



---------------------------------------------------------------Execute stage is being checked out here---------------------------------------------------
----In this process we are checking only for A1 
process(reset,EX_MEM_reg_addr,MEM_WB_reg_addr,EX_stage_reg_addr,EX_MEM_data,MEM_WB_data,EX_stage_opcode,EX_MEM_CONTROL_SIGNAL)
begin

	if(reset='1')then
		FWD_reg_EX_data1		<=(others=>'0');
		FWD_reg_EX_addr1		<=(others=>'0');
		FWD_Mux_Select_signal1	<='0';
	---Checking with EX/MEM------------------------------------------------------------------------------------
	--EX_MEM_CONTROL_SIGNAL(1)=reg_write
	--EX_stage_reg_addr(SIZE_OF_INPUT_BIT-1 downto 0)=A1
	--EX_MEM_reg_addr=A3
	elsif(EX_MEM_opcode ="0110" and EX_stage_opcode=EX_MEM_opcode)then
				FWD_reg_EX_data1		<=	(others=>'0');
				FWD_reg_EX_addr1		<=	(others=>'0');
				FWD_Mux_Select_signal1	<='0';
	--~ elsif(EX_MEM_opcode ="0111" and EX_stage_opcode=EX_MEM_opcode)then
				--~ FWD_reg_EX_data1		<=	(others=>'0');
				--~ FWD_reg_EX_addr1		<=	(others=>'0');
				--~ FWD_Mux_Select_signal1	<='0';
	elsif(EX_stage_opcode="0000" or EX_stage_opcode="0001" or EX_stage_opcode="0010" or EX_stage_opcode="0100" or EX_stage_opcode="0110" or 
			EX_stage_opcode="0101" or EX_stage_opcode="0111" or EX_stage_opcode="1100"   )then
		if(EX_MEM_CONTROL_SIGNAL(1)='1' and EX_MEM_reg_addr=EX_stage_reg_addr(SIZE_OF_INPUT_BIT-1 downto 0) ) then
				FWD_reg_EX_data1		<=	EX_MEM_data(DATA_WIDTH-1 downto 0);
				FWD_reg_EX_addr1		<=	EX_MEM_reg_addr;
				FWD_Mux_Select_signal1	<='1';
				check(3)				<='1';		
		--EX_MEM_CONTROL_SIGNAL(0)=R7_write		
		elsif(EX_MEM_CONTROL_SIGNAL(0)='1' and EX_stage_reg_addr(SIZE_OF_INPUT_BIT-1 downto 0)="111")then
				FWD_reg_EX_data1		<=	EX_MEM_data(2*DATA_WIDTH-1 downto DATA_WIDTH);
				FWD_reg_EX_addr1		<=	EX_MEM_reg_addr;
				FWD_Mux_Select_signal1	<='1';
				check(4)				<='1';	
		--Checking with MEM/WB--------------------------------------------------------------------------------------
			
		elsif(MEM_WB_CONTROL_SIGNAL(1)='1' and MEM_WB_reg_addr=EX_stage_reg_addr(SIZE_OF_INPUT_BIT-1 downto 0))then
				FWD_reg_EX_data1		<=	MEM_WB_data(DATA_WIDTH-1 downto 0);
				FWD_reg_EX_addr1		<=	MEM_WB_reg_addr;
				FWD_Mux_Select_signal1	<='1';
				check(5)				<='1';			
				
		elsif(MEM_WB_CONTROL_SIGNAL(0)='1' and EX_stage_reg_addr(SIZE_OF_INPUT_BIT-1 downto 0)="111")then
				FWD_reg_EX_data1		<=	MEM_WB_data(2*DATA_WIDTH-1 downto DATA_WIDTH);
				FWD_reg_EX_addr1		<=	MEM_WB_reg_addr;
				FWD_Mux_Select_signal1	<='1';
				check(6)				<='1';	
		else 
				FWD_reg_EX_data1		<=	(others=>'0');
				FWD_reg_EX_addr1		<=	(others=>'0');
				FWD_Mux_Select_signal1	<='0';
		end if;
	else
		FWD_reg_EX_data1		<=	(others=>'0');
		FWD_reg_EX_addr1		<=	(others=>'0');
		FWD_Mux_Select_signal1	<='0';
	end if;
end process;


----In this process we are checking only for A2 
process(reset,EX_MEM_reg_addr,MEM_WB_reg_addr,EX_stage_reg_addr,EX_MEM_data,MEM_WB_data,EX_stage_opcode,EX_MEM_CONTROL_SIGNAL)
begin
	
	if(reset='1')then
		FWD_reg_EX_data2			<=(others=>'0');
		FWD_reg_EX_addr2			<=(others=>'0');
		FWD_Mux_Select_signal2		<='0';
	---Checking with EX/MEM------------------------------------------------------------------------------------
	--EX_MEM_CONTROL_SIGNAL(1)=reg_write
	--EX_stage_reg_addr(SIZE_OF_INPUT_BIT-1 downto 0)=A2
	--EX_MEM_reg_addr=A3
	elsif(EX_MEM_opcode ="0110" and EX_stage_opcode=EX_MEM_opcode)then
				FWD_reg_EX_data2		<=	(others=>'0');
				FWD_reg_EX_addr2		<=	(others=>'0');
				FWD_Mux_Select_signal2	<='0';
	--~ elsif(EX_MEM_opcode ="0111" and EX_stage_opcode=EX_MEM_opcode)then
				--~ FWD_reg_EX_data2		<=	(others=>'0');
				--~ FWD_reg_EX_addr2		<=	(others=>'0');
				--~ FWD_Mux_Select_signal2	<='0';
	elsif(EX_stage_opcode="0000" or EX_stage_opcode="0010"  or EX_stage_opcode="1001"
				or EX_stage_opcode="0101" or EX_stage_opcode="0111"	
				or EX_stage_opcode="0110" or EX_stage_opcode="1100")then																				--7 downto 4
			if(EX_MEM_CONTROL_SIGNAL(1)='1' and EX_MEM_reg_addr=EX_stage_reg_addr(2*SIZE_OF_INPUT_BIT downto SIZE_OF_INPUT_BIT+1) ) then
					FWD_reg_EX_data2		<=	EX_MEM_data(DATA_WIDTH-1 downto 0);
					FWD_reg_EX_addr2		<=	EX_MEM_reg_addr;
					FWD_Mux_Select_signal2	<='1';
			--EX_MEM_CONTROL_SIGNAL(0)=R7_write		
			elsif(EX_MEM_CONTROL_SIGNAL(0)='1' and EX_stage_reg_addr(2*SIZE_OF_INPUT_BIT downto SIZE_OF_INPUT_BIT+1)="111")then
					FWD_reg_EX_data2		<=	EX_MEM_data(2*DATA_WIDTH-1 downto DATA_WIDTH);
					FWD_reg_EX_addr2		<=	EX_MEM_reg_addr;
					FWD_Mux_Select_signal2	<='1';
			----Checking with MEM/WB--------------------------------------------------------------------------------------
				
			elsif(MEM_WB_CONTROL_SIGNAL(1)='1' and MEM_WB_reg_addr=EX_stage_reg_addr(2*SIZE_OF_INPUT_BIT downto SIZE_OF_INPUT_BIT+1))then
					FWD_reg_EX_data2		<=	MEM_WB_data(DATA_WIDTH-1 downto 0);
					FWD_reg_EX_addr2		<=	MEM_WB_reg_addr;
					FWD_Mux_Select_signal2	<='1';
			elsif(MEM_WB_CONTROL_SIGNAL(0)='1' and EX_stage_reg_addr(2*SIZE_OF_INPUT_BIT downto SIZE_OF_INPUT_BIT+1)="111")then
					FWD_reg_EX_data2		<=	MEM_WB_data(2*DATA_WIDTH-1 downto DATA_WIDTH);
					FWD_reg_EX_addr2		<=	MEM_WB_reg_addr;
					FWD_Mux_Select_signal2	<='1';
			else 
					FWD_reg_EX_data2		<=	(others=>'0');
					FWD_reg_EX_addr2		<=	(others=>'0');
					FWD_Mux_Select_signal2	<='0';
			end if;
	else
				FWD_reg_EX_data2		<=	(others=>'0');
				FWD_reg_EX_addr2		<=	(others=>'0');
				FWD_Mux_Select_signal2	<='0';
	end if;
	
end process;
-----------------------------------------------------------------------------------------------------------------------------------------------

----Checking of the stalls for the load signals
process(reset,EX_stage_opcode,EX_MEM_opcode,EX_MEM_reg_addr,EX_stage_reg_addr,EX_MEM_CONTROL_SIGNAL)
begin 
		if(reset='1')then
			load_stalls_sig					<='0';
			
		elsif(EX_MEM_opcode ="0110" and EX_stage_opcode=EX_MEM_opcode)then
			load_stalls_sig				<='0';

		elsif(EX_MEM_opcode ="0100" or EX_MEM_opcode ="0110")then
			if(EX_MEM_CONTROL_SIGNAL(1)='1'  and(EX_MEM_reg_addr=EX_stage_reg_addr(SIZE_OF_INPUT_BIT-1 downto 0)))then
		--	check(4)			<='1';
					if(EX_stage_opcode="0000" or EX_stage_opcode="0001" or EX_stage_opcode="0010" or EX_stage_opcode="0100" or EX_stage_opcode="0110" or 
						EX_stage_opcode="0111" or EX_stage_opcode="1100" or EX_stage_opcode="0101")then
						load_stalls_sig				<='1';
						--check(3)<='1';
					else
						load_stalls_sig				<='0';
						--	check(5)			<='1';
					end if;
			
	
				
				
			elsif((EX_MEM_CONTROL_SIGNAL(1)='1'  and (EX_MEM_reg_addr=EX_stage_reg_addr(2*SIZE_OF_INPUT_BIT downto SIZE_OF_INPUT_BIT+1))))then	
					 --check(1)<='1'; 
						if(EX_stage_opcode="0000" or EX_stage_opcode="0010"  or EX_stage_opcode="0111" or EX_stage_opcode="0110" 
						or EX_stage_opcode="1001" or EX_stage_opcode="1100"   )then  
						 
						 
							load_stalls_sig				<='1';
						else
							load_stalls_sig				<='0';
						 --check(2)<='1';
						end if;
				
			else
					load_stalls_sig					<='0';
			end if;
		else
			
			load_stalls_sig					<='0';
		end if;
		
		
		
		
		
		
end process;

----------------------For load followed by store without stalls-------


-----------------------For A2(Memory data )---------------------------
process(reset,EX_MEM_opcode,MEM_WB_opcode,EX_MEM_reg_addr,EX_MEM_CONTROL_SIGNAL,EX_stage_reg_addr)
begin
	if(reset='1')then
			FWD_reg_MEM_addr2				<=(others=>'0');
			FWD_reg_MEM_data2				<=(others=>'0');
			FWD_Mux_MEM_Select_signal2			<='0';
	elsif(MEM_WB_opcode="0100" or MEM_WB_opcode="0110" )then		---Checks whether the A3 of the load(WB) matches A2 of the Store(MEM stage)
		if(MEM_WB_CONTROL_SIGNAL(1)='1' and MEM_WB_reg_addr = MEM_stage_reg_addr and EX_MEM_opcode="0101"  )then
				FWD_reg_MEM_data2		<=	MEM_WB_data(DATA_WIDTH-1 downto 0);
				FWD_reg_MEM_addr2		<=	MEM_WB_reg_addr;
				FWD_Mux_MEM_Select_signal2	<='1';
		else
			FWD_reg_MEM_addr2				<=(others=>'0');
			FWD_reg_MEM_data2				<=(others=>'0');
			FWD_Mux_MEM_Select_signal2			<='0';
		end if;
	else
			FWD_reg_MEM_addr2				<=(others=>'0');
			FWD_reg_MEM_data2				<=(others=>'0');
			FWD_Mux_MEM_Select_signal2			<='0';
	
	end if;
	
end process;
end;
