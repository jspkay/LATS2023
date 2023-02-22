library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library thesis;
use thesis.bitArrays.all;

entity tb is end tb;

architecture tb of tb is
	component super_muxer is
		generic ( depth: positive := 8;
				selector_bits : positive := 8;
				inrows : positive := 2;
				incols : positive := 2;
				outrows : positive := 28;
				outcols : positive := 28
				);
		port( selector: in std_logic_vector (1 to selector_bits);
			cs : in std_logic; -- chip select
			din : in std_logic_mat_t(0 to inrows-1, 0 to incols-1)(1 to depth);
			dout : out std_logic_mat_t(0 to outrows-1, 0 to outcols-1)(1 to depth)
			);
	end component;

	signal selector : std_logic_vector(1 to 8) := (others => '0');
	signal input : std_logic_mat_t(0 to 1, 0 to 1)(1 to 8);
	signal cs : std_logic := '0';
begin

	sm : super_muxer port map(selector, cs, input, open);

	process is
	begin
		input(0,0) <= std_logic_vector(to_unsigned(10, 8));
		input(0,1) <= std_logic_vector(to_unsigned(11, 8));
		input(1,1) <= std_logic_vector(to_unsigned(12, 8));
		input(1,0) <= std_logic_vector(to_unsigned(13, 8));
		wait for 10 ns;
		cs <= '1';
		wait for 5 ns;
		cs <= '0';
		wait for 10 ns;
		selector <= b"00_00_00_01";
		cs <= '1';
		wait for 10 ns;
		input(0,0) <= std_logic_vector(to_unsigned(34, 8));
		input(0,1) <= std_logic_vector(to_unsigned(23, 8));
		input(1,1) <= std_logic_vector(to_unsigned(19, 8));
		input(1,0) <= std_logic_vector(to_unsigned(32, 8));
		selector <= (others => '0');
		wait for 10 ns;
		selector <= b"00_00_00_10";
		wait for 10 ns;
		selector <= b"01_10_00_10";
	end process;
	
end;
