-- Author: JiangLong

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

---------------------------------------------
entity ena_global_pj081_v2 is
	port (
		aReset    	: in  std_logic; 
		clk			: in  std_logic;
		--mode			: in  std_logic_vector(4 downto 0);
		mode			: in  std_logic_vector(1 downto 0);
		
		ena_out		: out  std_logic
		--ena_out_dly3 : out std_logic;
		--mode_change	: out std_logic
     );
end ena_global_pj081_v2;

architecture rtl of ena_global_pj081_v2 is

signal ena : std_logic;
signal cnt, cnt_stop1, cnt_stop2 : integer range 0 to 65535 := 0;


begin

ena_out <= ena;

-- identifier
process( clk, aReset )
begin
  if( aReset = '1' ) then
    cnt <= 0;
  elsif( rising_edge(clk) ) then
  	if cnt = 5 then
  		cnt <= 0;
  	else
  		cnt <= cnt + 1;
  	end if;

  	if cnt = 3 then
  		ena <= '1';
  	elsif cnt = 0 then
  		ena <= '0';
  	else
  		ena <= ena;
  	end if;

--  	if cnt = 43575 then
--  		cnt <= 0;
--  	else
--  		cnt <= cnt + 1;
--  	end if;
--
--  	if cnt = 1 then
--  		ena <= '1';
--  	elsif cnt = 16726 then
--  		ena <= '0';
--  	else
--  		ena <= ena;
--  	end if;

  end if ;
end process ; 


end rtl;