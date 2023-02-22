library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity muxer is
	generic( depth : positive := 8);
	port(	selector : in std_logic;
		din0, din1 : in std_logic_vector(1 to depth);
		dout : out std_logic_vector(1 to depth) );
end muxer;

architecture muxer of muxer is
begin
	dout <= din0 when selector = '0' else
		din1 when selector = '1' else
		(others => 'X');
end architecture;
