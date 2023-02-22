library ieee;
use ieee.std_logic_1164.all;

use std.env.finish;

entity tb is end tb;

architecture tb of tb is
	signal a : std_logic_vector(1 to 10) := (others => '0');
	signal b : std_logic;
begin
	b <= or(a);

	process begin
		a(1) <= '1';
		wait for 5 ns;
		a(1) <= '0';
		wait for 5 ns;
		a(5) <= '1';
		wait for 5 ns;
		a(5) <= '0';
		a(8) <= '1';
		wait for 5 ns;
		a(8) <= '0';
		wait for 5 ns;
		finish;
	end process;
end architecture;
