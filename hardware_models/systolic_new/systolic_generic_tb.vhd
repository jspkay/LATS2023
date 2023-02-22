library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.my_types.all;

entity systolic_tb is
end systolic_tb;

architecture behaviour of systolic_tb is
	constant n_bits : positive := 8;
	constant delay : time := 5 ns;
	constant r : positive := 4;

	function "and" (Left, Right : signed(0 to n_bits-1)) return signed is
		variable res : signed(0 to 7);
	begin 
		for i in 0 to n_bits-1 loop
			res(i) := Left(i) and Right(i);
		end loop;
		return res;
	end "and";

	-- type for the input
	type int_array is array(1 to 4, 1 to 10) of integer;

	-- input ### START STRING
	constant A : int_array := (
		1 => ( 4,  3,  2,  1,  0,  0,  0, 0, 0, 0),
		2 => ( 0,  8,  7,  6,  5,  0,  0, 0, 0, 0),
		3 => ( 0,  0, 12, 11, 10,  9,  0, 0, 0, 0),
		4 => ( 0,  0,  0, 16, 15, 14, 13, 0, 0, 0) );
 	constant B : int_array := (
		1 => (13,  9,  5,  1,  0,  0,  0, 0, 0, 0),
		2 => ( 0, 14, 10,  6,  2,  0,  0, 0, 0, 0),
		3 => ( 0,  0, 15, 11,  7,  3,  0, 0, 0, 0),
		4 => ( 0,  0,  0, 16, 12,  8,  4, 0, 0, 0) );
	-- input ### STOP STRING
	
	-- systolic array component definition
	component multiplicator is
		generic(rows:positive:=4; cols:positive:=4; n_bits:positive:=8);
		port(
			clk, rst : in std_logic;
			r_in : in signed_8bit_arr_t(1 to r);
			c_in : in signed_8bit_arr_t(1 to r);
			m : out signed_16bit_mat_t(1 to r, 1 to r) );
	end component;
	
	-- signals for the inputs (rx, cx) and the ouputs of each cell (mxx)
	signal clk, reset : std_logic := '0';
	signal r_in : signed_8bit_arr_t(1 to r);
	signal c_in : signed_8bit_arr_t(1 to r);
	signal m_sig : signed_16bit_mat_t(1 to r, 1 to r); -- golden execution
	signal f_sig : signed_16bit_mat_t(1 to r, 1 to r); -- faulty
	signal p_sig : signed_16bit_mat_t(1 to r, 1 to r); -- result

	-- systolic array 
begin
	M : multiplicator port map (clk, reset, r_in, c_in, m_sig);
	
	faulty : multiplicator port map (clk, reset, r_in, c_in, f_sig);

	process
	begin	
		for i in 1 to 10 loop -- run for 10 clock cycles

			M.clk <= '0';

			for j in 1 to r loop
				r_in(j) <= conv_signed(A(j,i), n_bits);
				c_in(j) <= conv_signed(B(j,i), n_bits);
			end loop;

			for j in 1 to r loop
				for k in 1 to r loop
					p_sig(j, k) <= m_sig(j,k) - f_sig(j,k);
				end loop;
			end loop;

			clk <= '1';
			wait for delay;
			clk <= '0';
			wait for delay;
		end loop;
	end process;
end	behaviour;
