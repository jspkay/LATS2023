library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is end tb;

architecture tb of tb is
	constant depth : positive := 8;

	component muxer is
		generic( depth : positive := depth);
		port( selector : in std_logic;
			din0, din1 : std_logic_vector(1 to depth);
			dout : out std_logic_vector(1 to depth) );
	end component;

	signal fire : std_logic := '0';

	signal prev : std_logic_vector(1 to depth) := std_logic_vector(to_signed(12, depth));
	signal n : std_logic_vector(1 to depth) := std_logic_vector(to_signed(75, depth));
begin
	M : muxer port map(fire, prev, n, open);

	process begin
		wait for 10 ns;
		fire <= '1';
		wait for 10 ns;
		fire <= '0';
	end process;

end architecture;
