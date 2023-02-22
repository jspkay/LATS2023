library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is end tb;

library thesis;
use thesis.bitArrays.all;

architecture tb of tb is
	constant depth : positive := 8;

	component inverted_muxer is
		generic( depth : positive := depth;
			ports : positive := 4 );
		port( selector : in integer;
			din : std_logic_vector(1 to depth); 
			dout : out std_logic_arr_t(0 to ports-1)(1 to depth) );
	end component;

	signal fire : integer := 0;

	signal input : std_logic_vector(1 to depth);
begin
	M : inverted_muxer port map(fire, din => input, dout => open);

	process begin
		input <= std_logic_vector(to_unsigned(4, depth));
		wait for 10 ns;
		input <= std_logic_vector(to_unsigned(12, depth));
		fire <= 1;
		wait for 10 ns;
		input <= std_logic_vector(to_unsigned(24, depth));
		fire <= 2;
		wait for 10 ns;
		input <= std_logic_vector(to_unsigned(254, depth));
		fire <= 3;
		wait for 10 ns;
	end process;

end architecture;
