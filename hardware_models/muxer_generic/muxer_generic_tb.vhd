library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library thesis;
use thesis.bitArrays.all;

entity tb is end tb;

architecture muxer_generic of tb is
	component muxer_generic is
		generic( depth : positive := 8;
			selector_bits : positive := 2 );
		port( selector : in std_logic_vector(1 to selector_bits);
			din : in std_logic_arr_t(0 to 2**selector_bits);
			dout : out std_logic_vector(1 to depth) );
	end component;
		
	signal inputs : std_logic_arr_t(1 to 4)(1 to 8);
	signal selector : std_logic_vector(1 to 2);
begin

	mg : muxer_generic port map(selector, inputs, open);

	process begin
		inputs(1) <= std_logic_vector( to_unsigned(12, 8));
		inputs(2) <= std_logic_vector( to_unsigned(24, 8));
		inputs(3) <= std_logic_vector( to_unsigned(18, 8));
		inputs(4) <= std_logic_vector( to_unsigned(255, 8));

		selector <= "00";

		wait for 10 ns;
		selector <= "10";

		wait for 10 ns;

		selector <= "01";
		wait for 10 ns;

		selector <= "11";

		wait for 10 ns;

	end process;
	
end architecture;
