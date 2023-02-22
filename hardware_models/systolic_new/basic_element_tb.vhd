library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity basic_tb is
end basic_tb;

architecture behave of basic_tb is
	constant n_bits : positive := 8;


	signal clk, r : std_logic := '0';
	signal n,w,e,s : signed(0 to n_bits-1);
	signal result : signed(0 to 2*n_bits-1);

	component P is 
		port(
			clk : in std_logic;
			north, west : in signed(0 to n_bits-1);
			east, south : out signed(0 to n_bits-1);
			result : out signed(0 to 2*n_bits-1);
			reset : in std_logic
		);
	end component;

begin
	
	P1 : P port map (clk, n, w, e, s, result, r);

	process 
	begin
	
		n <= conv_signed(2, n_bits);
		w <= conv_signed(3, n_bits);
		clk <= '0';
		wait for 10 ns;
		clk <= '1';
		wait for 10 ns;

		-- expected 2 on  result
		--   1 on south, 2 on east

		
		
	end process;

end behave;

