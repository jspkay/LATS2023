library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;


entity systolic_tb is
end systolic_tb;

architecture behaviour of systolic_tb is
	constant n_bits : positive := 8;
	constant delay : time := 5 ns;

	function "and" (Left, Right : signed(0 to n_bits-1)) return signed is
		variable res : signed(0 to 7);
	begin 
		for i in 0 to n_bits-1 loop
			res(i) := Left(i) and Right(i);
		end loop;
		return res;
	end "and";

-- type for the input
	type int_array is array(1 to 10) of integer;

	-- input
	constant A1 : int_array := ( 4,  3,  2,  1,  0,  0,  0, 3, 0, 1);
	constant A2 : int_array := ( 0,  8,  7,  6,  5,  0,  0, 0, 0, 0);
	constant A3 : int_array := ( 0,  0, 12, 11, 10,  9,  0, 0, 0, 0);
	constant A4 : int_array := ( 0,  0,  0, 16, 15, 14, 13, 0, 0, 0);
	constant B1 : int_array := (13,  9,  5,  1,  0,  0,  0, 0, 0, 0);
	constant B2 : int_array := ( 0, 14, 10,  6,  2,  0,  0, 0, 0, 0);
	constant B3 : int_array := ( 0,  0, 15, 11,  7,  3,  0, 0, 0, 0);
	constant B4 : int_array := ( 0,  0,  0, 16, 12,  8,  4, 0, 0, 0);

	-- signals for the inputs (rx, cx) and the ouputs of each cell (mxx)
	signal clk, reset : std_logic := '0';
	signal r1, r2, r3, r4, c1, c2, c3, c4 : signed(0 to n_bits-1);
	signal m11, m12, m13, m14,
			m21, m22, m23, m24,
			m31, m32, m33, m34,
			m41, m42, m43, m44 : signed(0 to 2*n_bits-1);


	signal f11, f12, f13, f14,
			f21, f22, f23, f24,
			f31, f32, f33, f34,
			f41, f42, f43, f44 : signed(0 to 2*n_bits-1);
	
	signal p11, p12, p13, p14,
			p21, p22, p23, p24,
			p31, p32, p33, p34,
			p41, p42, p43, p44 : signed(0 to 2*n_bits-1);

	-- systolic array 
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
	
	faulty : multiplicator port map (clk, reset,
		r1, r2, r3, r4, c1, c2, c3, c4, 
			f11, f12, f13, f14,
			f21, f22, f23, f24,
			f31, f32, f33, f34,
			f41, f42, f43, f44
		);


	process
	begin	
		for i in 1 to 10 loop -- run for 10 clock cycles
			r1 <= conv_signed(A1(i), n_bits);
			r2 <= conv_signed(A2(i), n_bits);
			r3 <= conv_signed(A3(i), n_bits);
			r4 <= conv_signed(A4(i), n_bits);
			c1 <= conv_signed(B1(i), n_bits);
			c2 <= conv_signed(B2(i), n_bits);
			c3 <= conv_signed(B3(i), n_bits);
			c4 <= conv_signed(B4(i), n_bits);

			p11 <= m11 - f11;
			p12 <= m12 - f12;
			p13 <= m13 - f13;
			p14 <= m14 - f14;
			p21 <= m21 - f21;
			p22 <= m22 - f22;
			p23 <= m23 - f23;
			p24 <= m24 - f24;
			p31 <= m31 - f31;
			p32 <= m32 - f32;
			p33 <= m33 - f33;
			p34 <= m34 - f34;
			p41 <= m41 - f41;
			p42 <= m42 - f42;
			p43 <= m43 - f43;
			p44 <= m44 - f44;

			clk <= '1';
			wait for delay;
			clk <= '0';
			wait for delay;
		end loop;
	end process;
end	behaviour;
