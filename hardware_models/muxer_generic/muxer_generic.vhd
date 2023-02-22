library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library thesis;
use thesis.bitArrays.all;

entity muxer_generic is
	generic( depth : positive := 8;
		selector_bits : positive := 2 );
	port(	selector : in std_logic_vector(1 to selector_bits);
		din : in std_logic_arr_t(0 to 2**selector_bits-1)(1 to depth);
		dout : out std_logic_vector(1 to depth) );
end muxer_generic;

architecture muxer_generic of muxer_generic is
begin
	assert or(selector) /= 'X'
		report "selector has at least one unkonwn bit."
		severity warning;

	dout <= din( to_integer(unsigned(selector)) );
end architecture;
