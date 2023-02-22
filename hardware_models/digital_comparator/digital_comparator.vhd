library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity digital_comparator is
	generic( fire_value : natural := 3;
		bits : positive := 2 ); -- this value need to be as small as possibile but such that 2^bits < fire_value
	port( counter_in : in unsigned(1 to bits);
		rst : in std_logic;
		fire : out std_logic );
end digital_comparator;


architecture digital_comparator of digital_comparator is
begin
	fire <= '1' when to_integer(counter_in) = fire_value and rst = '0' else
		'0';
end;
	
