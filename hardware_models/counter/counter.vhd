library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is 
	generic( bits : positive := 8;
		initial_value : natural := 0 );
	port(
		clk, rst: in std_logic;
		value: out unsigned(1 to bits) := to_unsigned(initial_value, bits) );
end counter;

architecture counter of counter is
begin
	process(clk)	
	begin
		if rising_edge(clk) then
			value <= value + to_unsigned(1, value'length);
			if rst = '1' then
				value <= to_unsigned(initial_value, value'length) after 0 ns;
			end if;
		end if;
	end process;
end architecture;
