library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PN_gen4_ena is
port(
		aReset 	: in std_logic;
		clk		: in std_logic;
		ena		: in std_logic;
		PN_Dataout	: out std_logic_vector(3 downto 0)
		);
end entity;

architecture rtl of PN_gen4_ena is
signal a : std_logic_vector(22 downto 0);

begin
process(aReset,clk)
begin
	if aReset = '1' then
		a <= "01000000000000000000000";
		PN_Dataout <= (others => '0');
	elsif rising_edge(clk) then
	if ena = '1' then
		a(22 downto 19) <= a(3 downto 0) XOR a(8 downto 5); --a(8 downto 7);
		a(18 downto 0) <= a(22 downto 4);
		PN_Dataout <= a(3 downto 0);
	end if;
	end if;
end process;
end rtl;