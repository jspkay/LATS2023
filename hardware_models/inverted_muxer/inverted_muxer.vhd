library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library thesis;
use thesis.bitArrays.all;

entity inverted_muxer is
	generic( depth : positive := 8;
		ports : positive := 4 );
	port(	selector : in integer;
		din : in std_logic_vector(1 to depth); 
		dout : out std_logic_arr_t(0 to ports-1)(1 to depth) );
end inverted_muxer;

architecture muxer of inverted_muxer is
	
begin
	assert selector <= ports and selector >= 0
		report "inverted_muxer Error!"
		severity failure;

	dout(selector) <= din;
end architecture;
