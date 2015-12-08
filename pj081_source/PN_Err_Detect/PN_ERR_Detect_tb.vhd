library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use std.textio.all;


entity PN_ERR_Detect_tb is

end PN_ERR_Detect_tb;

architecture TB_ARCHITECTURE of PN_ERR_Detect_tb is
        -- Component declaration of the tested unit
		component PN_ERR_Detect IS
				 PORT
				(
					 aReset	:  IN std_logic;
				   ClockIn:  IN STD_LOGIC;
				   Enable	:  IN	std_logic;
				   DataIn:  	IN  STD_LOGIC;
				   SyncFlag:  Out  STD_LOGIC;
				   ErrResult:  Out  STD_LOGIC_VECTOR(31 DOWNTO 0)
				);
		 END component;
		 
		 signal DataIn	: std_logic; 
     signal SyncFlag: std_logic;
		 signal aReset	: std_logic;
      -- Add your code here ...
      signal StopSim : boolean := false;
      constant kSClkPeriod : time := 10 ns;
      constant kSimCycles : positive := 200000;
      signal Clk : std_logic;
      signal Enable: std_logic;

        
begin

          clkgen: process
          begin
            if(StopSim) then
              wait;
            end if;
            Clk <= '0';
            wait for kSClkPeriod / 2;
            Clk <= '1';
            wait for kSClkPeriod / 2;
          end process;

          resetgen: process
          begin
            aReset <= '1';
            wait for 200 ns;
            aReset <= '0';
            wait;
          end process;


          -- Read Data from file
          ReadData:
          process( Clk)
            
            file infile : text open read_mode is "..\pn_23_enable.txt";
            
            
            variable dl : line;
            variable DataIn_Inter,Enable_Inter : integer :=0;
            variable m_count			: integer :=0;
          begin
						if rising_edge(Clk) then
              if not endfile(infile) then
                readline(infile, dl);
                read(dl, Enable_Inter);
                read(dl, DataIn_Inter);
                --使能信号
                if Enable_Inter=1 then
                		Enable	<= '1';
		                if m_count>=30 then
		                	--增加一比特误码
		                	m_count	:=0;
			                if DataIn_Inter=1 then
			                	DataIn	<= '0';
			                else
			                	DataIn	<= '1';
			                end if;
			              else
			                if DataIn_Inter=1 then
			                	DataIn	<= '1';
			                else
			                	DataIn	<= '0';
			                end if;
			                m_count	:= m_count+1;
			              end if;
			           else
			           		Enable	<= '0';
			           end if;
                	
                
              end if;
            end if;
          end process;
          
		entity_PN_ERR_Detect: PN_ERR_Detect 
				 PORT map
				(
					 aReset		=> aReset,
					 Enable		=> Enable,
				   ClockIn	=> Clk,
				   DataIn		=> DataIn,
				   SyncFlag	=> SyncFlag,
				   ErrResult=> open
				);
          
end TB_ARCHITECTURE;
