library ieee;
use ieee.std_logic_1164.all;
library std;
use std.textio.all;
-------------Defined package-------------------------
use work.Package_component_Pipeline.all;
--------------------------------------------------------

entity Testbench is
end entity;

architecture behaviour of Testbench is 
component Datapath is 
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
			
	end component;
	
signal				R0              :  std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal				R1              :  std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal				R2              :  std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal				R3              :  std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal				R4              :  std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal				R5              :  std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal				R6              :  std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal				R7              :  std_logic_vector(INSTRUCTION_SIZE-1 downto 0);
signal 				clk 			:std_logic :='0';
signal 				reset			:std_logic := '1';
function to_string(x: string) return string is
      variable ret_val: string(1 to x'length);
      alias lx : string (1 to x'length) is x;
  begin
      ret_val := lx;
      return(ret_val);
  end to_string;

  function to_std_logic_vector(x: bit_vector) return std_logic_vector is
    alias lx: bit_vector(1 to x'length) is x;
    variable ret_var : std_logic_vector(1 to x'length);
  begin
     for I in 1 to x'length loop
        if(lx(I) = '1') then
           ret_var(I) :=  '1';
        else
           ret_var(I) :=  '0';
  end if;
     end loop;
     return(ret_var);
  end to_std_logic_vector;

  function to_std_logic(x: bit) return std_logic is
      variable ret_val: std_logic;
  begin
      if (x = '1') then
        ret_val := '1';
      else
        ret_val := '0';
      end if;
      return(ret_val);
  end to_std_logic;


begin
 
 
 clk <=	not clk after 10 ns; 


 process
  begin
     wait for 50 ns;
     reset <= '0';
     wait;
  end process;

  --process
    ----variable err_flag : boolean := false;
    ----File INFILE: text open read_mode is "tracefile_memory.txt";
    ----FILE OUTFILE: text  open write_mode is "output_memory.txt";

    -------------------------------------------------------
    ------ edit the next few lines to customize
    ----variable m_write: bit;
    ----variable ad: bit_vector(ADDR_WITH -1 downto 0);
    ----variable din: bit_vector (15 downto 0);
    ----variable dout: bit_vector (15 downto 0);
    --------------------------------------------------------
    ----variable INPUT_LINE: Line;
    ----variable OUTPUT_LINE: Line;
    ----variable LINE_COUNT: integer := 0;

  ----begin
    ------addr <= (others=>'0');
    ----wait until clk = '1';

    ----while not endfile(INFILE) loop
      ----readLine(INFILE, INPUT_LINE);
      ----read(INPUT_LINE, m_write);
      ----read(INPUT_LINE, ad);
      ----read(INPUT_LINE, din);
      ----LINE_COUNT := LINE_COUNT + 1;
      ----mem_write <= to_std_logic(m_write);
      ----addr <= to_std_logic_vector(ad);
      ----data_in <= to_std_logic_vector(din);

      ----wait until clk = '0';

        ----if (m_write /= '1' and data_out /= to_std_logic_vector(din)) then
          ----write(OUTPUT_LINE,to_string("ERROR: in RESULT , line "));
          ----write(OUTPUT_LINE, LINE_COUNT);
          ----writeline(OUTFILE, OUTPUT_LINE);
          ----err_flag := true;
        ----end if;

    	----wait until clk = '1';

    ----end loop;

    ----assert (err_flag) report "SUCCESS, all tests passed." severity note;
    ----assert (not err_flag) report "FAILURE, some tests failed." severity error;

    --wait;
  --end process;





	Datapath_inst:Datapath port map(clk=>clk,
									reset=>reset,
									R0	=>R0,
									R1	=>R1,
									R2	=>R2,
									R3	=>R3,
									R4	=>R4,
									R5	=>R5,
									R6	=>R6,
									R7	=>R7);





end;

