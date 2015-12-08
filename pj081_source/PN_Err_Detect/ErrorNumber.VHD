LIBRARY IEEE;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

ENTITY ErrorNumber IS
	PORT(
		 aReset	: IN std_logic;
		 Enable	: In std_logic;
		 InClk:		IN	STD_LOGIC;
		 InDat:		IN	STD_LOGIC;
		 Synchrosize:	OUT	STD_LOGIC;
		 Error    : out std_logic;
		 ErrNoOut: 	OUT	STD_LOGIC_VECTOR(31 DOWNTO  0)
		);
END ErrorNumber;

ARCHITECTURE BEHAVE OF ErrorNumber IS
	SIGNAL ErrNo:	unsigned(31 DOWNTO 0);
	SIGNAL Total:	unsigned(31 DOWNTO 0);

	SIGNAL ErrCount, DetectLen	: integer range 0 to 1000;
	SIGNAL syn_Counter : integer range 0 to 3;


BEGIN

syn_detect: PROCESS(aReset,InClk) --同步搜索，每次搜索200bit，当误码小于50bit时锁定同步带；当误码连续三次超过50bit，重新锁定
BEGIN
	if aReset='1' then
		ErrCount		<= 0;
		DetectLen		<= 0;
		syn_Counter	<= 0;
		Synchrosize	<= '0';
	elsif rising_edge(InClk) THEN	
		if Enable='1' then
				if DetectLen<200 then --统计长度为200
					DetectLen	<=DetectLen+1;
					if InDat='1' then
						ErrCount<=ErrCount+1;
					end if;
				else
					
					DetectLen	<= 0;
					ErrCount	<= 0;
					if ErrCount <= 50 then
						Synchrosize	<= '1';
						syn_Counter	<= 0;
					elsif syn_Counter<3 then
						syn_Counter	<= syn_Counter+1;
					else
						syn_Counter	<= 0;
						Synchrosize	<= '0';
					end if;
				end if;
		end if;
	END IF;
END PROCESS;

		process(aReset,InClk)
        begin
              if aReset='1' then
                 Error <= '0';
              elsif InClk'event and InClk='1' then
                 if unsigned(ErrNo) > 0 then
                    Error <= '1'; 
                 else
                    Error <= '0';                
                 end if;
              end if;
        end process;

Process_Err_Counter: PROCESS(aReset,InClk)
BEGIN
	if aReset='1' then
		ErrNo	<= (others => '0');
		Total	<= (others => '0');
		ErrNoOut	<= (others => '0');
	elsif rising_edge(InClk) THEN	--'1'
		if Enable='1' then
				if total<100000000 then --统计长度为10^7
					Total	<=Total+1;
					IF InDat='1' THEN
						ErrNo<=ErrNo+1;
					END IF;
					
				else
					Total	<= (others => '0');
					ErrNo	<= (others => '0');
					ErrNoOut	<= std_logic_vector(ErrNo);
				end if;
		end if;
	END IF;
END PROCESS;
END BEHAVE;