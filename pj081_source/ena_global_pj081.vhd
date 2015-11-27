-- Author: JiangLong

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

---------------------------------------------
entity ena_global_pj081 is
	port (
		aReset    	: in  std_logic; 
		clk			: in  std_logic;
		--mode			: in  std_logic_vector(4 downto 0);
		mode			: in  std_logic_vector(1 downto 0);
		
		ena_out		: out  std_logic;
		--ena_out_dly3 : out std_logic;
		mode_change	: out std_logic
     );
end ena_global_pj081;

architecture rtl of ena_global_pj081 is

signal ena : std_logic;
signal cnt, cnt_stop1, cnt_stop2 : integer range 0 to 65535 := 0;
signal cnt_change, len_change, cnt_wait, cnt_wait_2 : integer range 0 to 1023 := 0;
signal ena_out_dly1,ena_out_dly2 : std_logic;
signal mode_r0, mode_r1, mode_r2, mode_r3 : std_logic_vector(1 downto 0);
signal mode_change_dly : std_logic_vector(10 downto 0);

begin

ena_out <= ena;

process(clk)
begin
	if rising_edge(clk) then
		mode_r0 <= mode;
		mode_r1 <= mode_r0;
		mode_r2 <= mode_r1;
		mode_r3 <= mode_r2;
	end if;
end process;

process(clk)
begin
	if rising_edge(clk) then
		if mode_r3 /= mode_r2 then
			mode_change_dly(0) <= '1';
		else
			mode_change_dly(0) <= '0';
		end if;
		
		mode_change_dly(10 downto 1) <= mode_change_dly(9 downto 0);
		mode_change <= mode_change_dly(10);
	end if;
end process;

process(aReset, clk)
begin
	if aReset='1' then
		cnt <= 0;
		ena <= '0';
		cnt_change <= 0;
		len_change <= 0;
		cnt_wait <= 0;
		cnt_wait_2 <= 0;
	elsif rising_edge(clk) then
		------- 0
		if cnt /= 43575 then
			cnt <= cnt+1;
		else
			cnt <= 0;
		end if;
		
		------- 1
		if cnt_change = 0 then
			if cnt=1 then
				ena <= '1';
			elsif cnt=cnt_stop1 and cnt_wait>100 then
				ena <= '0';
				--*************
				if cnt_change = len_change then
					cnt_change <= 0;
				else
					cnt_change <= cnt_change + 1;
				end if;
				--*************
			else
				ena <= ena;
			end if;
			
			----
			if cnt_wait = 1023 then
				cnt_wait <= 1023;
			else
				cnt_wait <= cnt_wait + 1;
			end if;
			---
			
			----
			cnt_wait_2 <= 0;
			----
			
			
		else
			if cnt=1 then
				ena <= '1';
			elsif cnt=cnt_stop2 and cnt_wait_2>100 then
				ena <= '0';
				--*************
				if cnt_change = len_change then
					cnt_change <= 0;
				else
					cnt_change <= cnt_change + 1;
				end if;
				--*************
			else
				ena <= ena;
			end if;
			
			----
			if cnt_wait_2 = 1023 then
				cnt_wait_2 <= 1023;
			else
				cnt_wait_2 <= cnt_wait_2 + 1;
			end if;
			---
			
			----
			cnt_wait <= 0;
			----
			
		end if;
		
		------- 2
		case mode(1 downto 0) is
			when "00" =>
				len_change <= 1;
			when "01" =>
				len_change <= 1;
			when "10" =>
				len_change <= 1;
			when others =>
				len_change <= 1;
		end case;		
			
	end if;
end process;

process(aReset, clk)
begin
	if aReset='1' then
		cnt_stop1 <= 0;
		cnt_stop2 <= 0;
	elsif rising_edge(clk) then
	--if mode(4)='0' then
	--	case mode(2 downto 0) is
	--		when "000" =>
	--			cnt_stop1 <= 1025;
	--			cnt_stop2 <= 1025;
	--		when "101" =>
	--			cnt_stop1 <= 513;
	--			cnt_stop2 <= 513;
	--		when "001" =>
	--			cnt_stop1 <= 257;
	--			cnt_stop2 <= 257;
	--		when "110" =>
	--			cnt_stop1 <= 129;
	--			cnt_stop2 <= 129;
	--		when others =>
	--			cnt_stop1 <= 1025;
	--			cnt_stop2 <= 1025;
	--	end case;
	--else
		case mode(1 downto 0) is
			when "00" =>
				cnt_stop1 <= 16726;
				cnt_stop2 <= 16726;
			when "01" =>
				cnt_stop1 <= 33451;
				cnt_stop2 <= 33451;
			when "10" =>
				cnt_stop1 <= 8364;
				cnt_stop2 <= 8363;
			when others =>
				cnt_stop1 <= 16726;
				cnt_stop2 <= 16726;
		end case;
	end if;
	--end if;
end process;

process( clk)
begin
	if rising_edge(clk) then
		ena_out_dly1 <= ena;
		ena_out_dly2 <= ena_out_dly1;
		--ena_out_dly3 <= ena_out_dly2;
	end if;
end process;


end rtl;