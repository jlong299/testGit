---------------------------------
-- Author	: JiangLong
-- Date   	: 201511
-- Project	: pj081
-- Function	: flow --> data
-- Description	: Input :  1bit data  and valid.   data :  frameHead + length + payload + padding
--                 framHead : B2   length : 1~248    payload(1~248 bytes)   padding : 47
--                Output :  8bit data and valid.   data : only payload
-- Ports	: 
--
-- Problems	: 
-- History	: 
----------------------------------
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;

entity flow2data_pj081 is
  port (
  	aReset	: in std_logic;
  	clk_1bit : in std_logic;
  	clk_8bit : in std_logic;
  	d_in	 : in std_logic;
  	val_in	 : in std_logic;

  	d_out	 : out std_logic_vector(7 downto 0) ;
  	val_out	 : out std_logic
  ) ;
end entity ; 

architecture arch of flow2data_pj081 is

component ff_1to8_pj081 IS
	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		data		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		rdusedw		: OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
		wrfull		: OUT STD_LOGIC 
	);
END component;

signal d_shift, q, q_reg : std_logic_vector(7 downto 0) ;
signal val_glb, rdreq : std_logic;
signal rdusedw : std_logic_vector(5 downto 0) ;
signal shift : unsigned(2 downto 0);

	-- Build an enumerated type for the state machine
	type state_type is (s0, s1, s20, s21);

	-- Register to hold the current state
	signal state   : state_type;

constant thd_padding_lost_s0 : integer := 16;
signal cnt_s0 : integer range 0 to 31;
constant thd_padding_lost_s1 : integer := 8;
signal cnt_s1 : integer range 0 to 31;
signal cnt_s2, length_record : unsigned(7 downto 0);
signal s2_finish : std_logic;
	signal d_shift_dly : std_logic_vector(7 downto 0) ;


begin

--------------------------------------------
------------- PART 1 :  FIFO 1bit --> 8bit
--------------------------------------------
ff_1to8_pj081_inst : ff_1to8_pj081
PORT map
	(
		aclr		=> aReset ,
		data(0)		=> d_in ,
		rdclk		=> clk_8bit ,
		rdreq		=> rdreq ,
		wrclk		=> clk_1bit ,
		wrreq		=> val_in ,
		q			=> q ,
		rdempty		=> open ,
		rdusedw		=> rdusedw ,
		wrfull		=> open 
	);

-- rdreq
process( clk_8bit, aReset )
begin
  if( aReset = '1' ) then
    rdreq <= '0' ;
    val_glb <= '0' ;
  elsif( rising_edge(clk_8bit) ) then
  	if unsigned(rdusedw) > to_unsigned(8, rdusedw'length) then
  		rdreq <= '1' ;
  	else
  		rdreq <= '0' ;
  	end if;
  	val_glb <= rdreq;
  end if ;
end process ;

-------------------------------------------------------------
---------------- PART 2 : shift[2:0]   Adjust wire sequence
-------------------------------------------------------------
-- d_shift
process( clk_8bit, aReset )
begin
  if( aReset = '1' ) then
    d_shift <= (others => '0');
    q_reg <= (others => '0');
  elsif( rising_edge(clk_8bit) ) then
  if val_glb = '1'  then
  	q_reg <= q;
  	case shift is
  		when "000" =>
			d_shift <= q_reg(7 downto 0);
		when "001" =>
			d_shift <= q(0 downto 0) & q_reg(7 downto 1);
		when "010" =>
			d_shift <= q(1 downto 0) & q_reg(7 downto 2);
		when "011" =>
			d_shift <= q(2 downto 0) & q_reg(7 downto 3);
		when "100" =>
			d_shift <= q(3 downto 0) & q_reg(7 downto 4);
		when "101" =>
			d_shift <= q(4 downto 0) & q_reg(7 downto 5);
		when "110" =>
			d_shift <= q(5 downto 0) & q_reg(7 downto 6);
		when "111" =>
			d_shift <= q(6 downto 0) & q_reg(7 downto 7);
		when others =>
			d_shift <= q_reg(7 downto 0);
	end case;
  end if;
  end if ;
end process ; 

--------------------------------------------------------------
---------------  PART 3 : Remove frame head,length and padding 
--------------------------------------------------------------

--------------   State machine  ---------------------

	-- Logic to advance to the next state
	process (clk_8bit, aReset)
	begin
		if aReset = '1' then
			state <= s0;
			d_shift_dly <= (others => '0');
		elsif (rising_edge(clk_8bit)) then
		if val_glb = '1'  then
			case state is
				when s0=>
					if d_shift = "01000111" and d_shift_dly = "01000111" then  -- padding
						state <= s1;
					else
						state <= s0;
					end if;
				when s1=>
					if d_shift = "10110010" then  -- frm head
						state <= s20;
					elsif cnt_s1 = thd_padding_lost_s1 then
						state <= s0;
					else
						state <= s1;
					end if;
				when s20 =>
					state <= s21;
				when s21=>
					if s2_finish = '1' then
						state <= s0;
					else
						state <= s21;
					end if;
				when others =>
					state <= s0;
			end case;
			d_shift_dly <= d_shift;
		end if;
		end if;
	end process;


---------   End  of state machine ---------------------

-- shift[2:0]
process( clk_8bit, aReset )
begin
  if( aReset = '1' ) then
    shift <= (others => '0');
    cnt_s0 <= 0;
  elsif( rising_edge(clk_8bit) ) then
  	if val_glb = '1'  then
  		if cnt_s0 = thd_padding_lost_s0 then
  			shift <= shift + 1;
  		else
  			shift <= shift;
  		end if;

  		if state = s0 then
  			if cnt_s0 = thd_padding_lost_s0 then
  				cnt_s0 <= 0;
  			else
  				cnt_s0 <= cnt_s0 + 1;
  			end if;
  		else
  			cnt_s0 <= 0;
  		end if;
  	end if;
  end if ;
end process ; 

-- padding_lost_s1
process( clk_8bit, aReset )
begin
  if( aReset = '1' ) then
    cnt_s1 <= 0 ;
  elsif( rising_edge(clk_8bit) ) then
  	if val_glb = '1'  then
  		if state = s1 then
  			if d_shift = "01000111" and cnt_s1 /= 0 then -- padding
  				cnt_s1 <= cnt_s1 - 1;
  			else
  				cnt_s1 <= cnt_s1 + 1;
  			end if;
  		else
  			cnt_s1 <= 0;
  		end if;
  	end if;
  end if ;
end process ; 

-- length_record
process( clk_8bit, aReset )
begin
  if( aReset = '1' ) then
    length_record <= (others => '0');
  elsif( rising_edge(clk_8bit) ) then
  	if val_glb = '1'  then
  		if state = s20 then
  			length_record <= unsigned(d_shift);
  		end if;
  	end if;
  end if ;
end process ; 

-- d_out val_out
process( clk_8bit, aReset )
begin
  if( aReset = '1' ) then
    d_out <= (others => '0');
    val_out <= '0' ;
    cnt_s2 <= (others => '0');
    s2_finish <= '0' ;
  elsif( rising_edge(clk_8bit) ) then
  	if val_glb = '1'  then
  		if state = s21 then
  			if cnt_s2 /= length_record then
  				d_out <= d_shift;
  				val_out <= val_glb;
  			else
  				d_out <= (others => '0');
  				val_out <= '0' ;
  			end if;

  			if cnt_s2 /= length_record then
  				cnt_s2 <= cnt_s2 + 1;
  			end if;

  			if cnt_s2 = length_record then
  				s2_finish <= '1' ;
  			else
  				s2_finish <= '0' ;
  			end if;

  		else
  				d_out <= (others => '0');
  				val_out <= '0' ;
  				cnt_s2 <= (others => '0');
  				s2_finish <= '0' ;
  		end if;
  	else
  		val_out <= '0' ;
  	end if;
  end if ;
end process ; 






end architecture ;
