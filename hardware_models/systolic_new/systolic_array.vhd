library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity multiplicator is
	generic(r : positive := 4;
		n_bits : positive := 8);
	port(
		clk, rst : in std_logic;
		r1, r2, r3, r4 : in signed(0 to n_bits-1);
		c1, c2, c3, c4 : in signed(0 to n_bits-1);
		m11, m12, m13, m14,
		m21, m22, m23, m24,
		m31, m32, m33, m34,
		m41, m42, m43, m44 : out signed(0 to 2*n_bits-1)
		);
end multiplicator;

architecture behavior of multiplicator is
	type matrix is array(0 to r) of std_logic_vector(0 to 7);

	signal clock, reset : std_logic := '0';
	signal r11, r12, r13,
		r21, r22, r23,
		r31, r32, r33,
		r41, r42, r43,
			c11, c12, c13,
		c21, c22, c23,
		c31, c32, c33,
		c41, c42, c43 : signed(0 to n_bits-1);

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
	P11 : P port map(clock, c1,  r1,  r11, c11, m11, reset);
	P12 : P port map(clock, c2,  r11, r12, c21, m12, reset);
	P13 : P port map(clock, c3,  r12, r13, c31, m13, reset);
	P14 : P port map(clock, c4,  r13, open,c41, m14, reset);

	P21 : P port map(clock, c11, r2,  r21, c12, m21, reset);
	P22 : P port map(clock, c21, r21, r22, c22, m22, reset);
	P23 : P port map(clock, c31, r22, r23, c32, m23, reset);
  P24 : P port map(clock, c41, r23, open,c42, m24, reset);

	P31 : P port map(clock, c12, r3,  r31, c13, m31, reset);
	P32 : P port map(clock, c22, r31, r32, c23, m32, reset);
	P33 : P port map(clock, c32, r32, r33, c33, m33, reset);
	P34 : P port map(clock, c42, r33, open,c43, m34, reset);

	P41 : P port map(clock, c13, r4,  r41,open, m41, reset);
	P42 : P port map(clock, c23, r41, r42,open, m42, reset);
	P43 : P port map(clock, c33, r42, r43,open, m43, reset);
	P44 : P port map(clock, c43, r43,open,open, m44, reset);

	-- ROWS: for i in 0 to r-1 generate 
	-- 	COLS: for ii in 0 to r-1 generate 
	-- 		p_inst : P port map(clock=>clock, north=> south(i-1), west=>east(ii-1));
	-- 	end generate;
	-- end generate;
process (clk) is
begin
	clock <= clk;
end process;
end behavior;
			
