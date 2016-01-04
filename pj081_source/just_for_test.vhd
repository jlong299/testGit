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

commit 1 content

commit 1 bugFix

commit 2 bugFix


end rtl;