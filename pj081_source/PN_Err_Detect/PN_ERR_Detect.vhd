 LIBRARY IEEE;
 USE IEEE.STD_LOGIC_1164.ALL;
 use IEEE.numeric_std.all;
  
 ENTITY PN_ERR_Detect IS
		 PORT
		(
		   aReset	:		IN std_logic;
		   ClockIn:  	IN  STD_LOGIC;
		   Enable	: 	In	std_logic; --数据使能信号
		   DataIn	:  	IN  STD_LOGIC; -- 待统计数据
		   SyncFlag:  Out  STD_LOGIC;--本地序列发生器同步指示
	       Error    : out std_logic;
		   ErrResult: Out  STD_LOGIC_VECTOR(31 DOWNTO 0) --输出的误码率
		);
 END PN_ERR_Detect;

 ARCHITECTURE Behave OF PN_ERR_Detect IS

		 Component ErrorNumber IS
		 PORT(
				 aReset	: IN std_logic;
				 Enable	: IN std_logic;
				 InClk:		IN	STD_LOGIC;
				 InDat:		IN	STD_LOGIC;
				 Synchrosize:	OUT	STD_LOGIC;
				 Error    : out std_logic;
				 ErrNoOut: 	OUT	STD_LOGIC_VECTOR(31 DOWNTO  0)
		  );
		 END Component;
		
		 SIGNAL DataRight:  STD_LOGIC;
		 SIGNAL ErrorBit:  STD_LOGIC;
		 SIGNAL MSequenceIn:  STD_LOGIC;  --相当于Shifter(0)
		 SIGNAL Synchrosize:  STD_LOGIC;
		-- SIGNAL Shifter:  STD_LOGIC_VECTOR(22 DOWNTO  0);
		 SIGNAL Shifter:  STD_LOGIC_VECTOR(22 DOWNTO  0);
		 Signal ErrorTotal:  STD_LOGIC_VECTOR(31 DOWNTO  0);
		 signal EnableOut_1 : std_logic;
BEGIN
		 
		 ErrResult <= ErrorTotal;
		 SyncFlag <= Synchrosize;
		
		 StatisticError:ErrorNumber
		 Port Map
		(
			 aReset		=> aReset,
			 Enable		=> EnableOut_1,
		   InClk    =>  ClockIn,
		   InDat    =>  ErrorBit,
		   Synchrosize  =>  Synchrosize,
		   Error    => Error,
		   ErrNoOut  =>  ErrorTotal
		);
		
		-- PROCESS(ClockIn,Synchrosize)
		-- BEGIN
		--     If(ClockIn'EVENT AND ClockIn='1') Then
		--       If(Synchrosize='1') Then
		--         MSequenceIn <= DataRight;
		--       ELSE
		--         MSequenceIn <= DataIn;
		--       END If;
		--     END If;
		-- End Process;
		

            
		
		 PROCESS(aReset,ClockIn,Synchrosize)
		 BEGIN
		 		if aReset='1' then
		 			DataRight		<= '0';
		 			MSequenceIn	<= '0';
		 			Shifter			<= (others => '0');
		 			EnableOut_1	<= '0';
		   elsif rising_edge(ClockIn) Then
		--     Shifter( 0) <= MSequenceIn;
		--     FOR I IN 0 TO 21 LOOP
					if Enable='1' then
				     FOR I IN 1 TO 22 LOOP
				       Shifter(I) <= Shifter(I-1);
				     END LOOP;
				     Shifter(0) <= MSequenceIn;
				     
				     If Synchrosize = '1' Then
				       MSequenceIn <= DataRight;
				     ELSE
				       MSequenceIn <= DataIn;
				     END If;
				     ErrorBit <= DataRight XOR DataIn;
				     DataRight <= Shifter(20) XOR Shifter(15);
				     EnableOut_1	<= '1';
				  else
				  	 EnableOut_1	<= '0';
				  end if;
		--     DataRight <= Shifter(22) XOR Shifter(17);
		   END If;
		 END PROCESS;

 END Behave;