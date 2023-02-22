library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity systolic_tb is
end systolic_tb;

architecture behaviour of systolic_tb is
	constant n_bits : positive := 8;
	constant delay : time := 5 ns;

	type int_array is array(1 to 10) of integer;
	constant A1 : int_array := ( 4,  3,  2,  1,  0,  0,  0, 0, 0, 0);
	constant A2 : int_array := ( 0,  8,  7,  6,  5,  0,  0, 0, 0, 0);
	constant A3 : int_array := ( 0,  0, 12, 11, 10,  9,  0, 0, 0, 0);
	constant A4 : int_array := ( 0,  0,  0, 16, 15, 14, 13, 0, 0, 0);
	constant B1 : int_array := (13,  9,  5,  1,  0,  0,  0, 0, 0, 0);
	constant B2 : int_array := ( 0, 14, 10,  6,  2,  0,  0, 0, 0, 0);
	constant B3 : int_array := ( 0,  0, 15, 11,  7,  3,  0, 0, 0, 0);
	constant B4 : int_array := ( 0,  0,  0, 16, 12,  8,  4, 0, 0, 0);



	signal clk, reset : std_logic := '0';
	signal r1, r2, r3, r4, c1, c2, c3, c4 : signed(0 to n_bits-1);
	signal m11, m12, m13, m14,
			m21, m22, m23, m24,
			m31, m32, m33, m34,
			m41, m42, m43, m44 : signed(0 to 2*n_bits-1);

	component multiplicator is
		generic(r:positive:=4; n_bits:positive:=8);
		port(
			clk, rst : in std_logic;
			r1, r2, r3, r4 : in signed(0 to n_bits-1);
			c1, c2, c3, c4 : in signed(0 to n_bits-1);
			m11, m12, m13, m14,
			m21, m22, m23, m24,
			m31, m32, m33, m34,
			m41, m42, m43, m44 : out signed(0 to 2*n_bits-1)
		);
	end component;
begin
	M : multiplicator port map (clk, reset, 
		r1, r2, r3, r4, c1, c2, c3, c4,
			m11, m12, m13, m14,
			m21, m22, m23, m24,
			m31, m32, m33, m34,
			m41, m42, m43, m44
		);
	
	process
	begin	
		-- multiply two matrices like
		-- [1 2 3 4;
		--  5 6 7 8;
		--  9 10 11 12;
		--  13 14 15 16]
		for i in 1 to 10 loop
			r1 <= conv_signed(A1(i), n_bits);
			r2 <= conv_signed(A2(i), n_bits);
			r3 <= conv_signed(A3(i), n_bits);
			r4 <= conv_signed(A4(i), n_bits);
			c1 <= conv_signed(B1(i), n_bits);
			c2 <= conv_signed(B2(i), n_bits);
			c3 <= conv_signed(B3(i), n_bits);
			c4 <= conv_signed(B4(i), n_bits);
			clk <= '1';
			wait for delay;
			clk <= '0';
			wait for delay;
		end loop;
	end process;
end	behaviour;
