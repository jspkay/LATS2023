library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library thesis;
use thesis.bitArrays.all;

entity tb is
end tb;

architecture behaviour of tb is
	constant n_bits : positive := byte;
	constant res_depth : positive := word;
	constant delay : time := 5 ns;
	constant r : positive := 4;

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
	component systolic_generic is
		generic( rows:positive:=4;
			cols:positive:=4;
			depth:positive:=byte;
			is_north_signed : bit := '0';
			is_west_signed : bit := '0' );

		port( clk, rst : in std_logic;
			r_in : in std_logic_arr_t(1 to r)(1 to depth);
			c_in : in std_logic_arr_t(1 to r)(1 to depth);
			m : out std_logic_mat_t(1 to r, 1 to r)(1 to res_depth) );
	end component;
	
	-- signals for the inputs (rx, cx) and the ouputs of each cell (mxx)
	signal clk, reset : std_logic := '0';
	signal r_in : std_logic_arr_t(1 to r)(1 to n_bits);
	signal c_in : std_logic_arr_t(1 to r)(1 to n_bits);
	signal m_sig : std_logic_mat_t(1 to r, 1 to r)(1 to res_depth); -- golden execution
	signal f_sig : std_logic_mat_t(1 to r, 1 to r)(1 to res_depth); -- faulty
	signal p_sig : std_logic_mat_t(1 to r, 1 to r)(1 to res_depth); -- result

	-- systolic array 
begin
	M : systolic_generic port map (clk, reset, r_in, c_in, m_sig);
	
	faulty : systolic_generic port map (clk, reset, r_in, c_in, f_sig);

	process
	begin	
		for i in 1 to 10 loop -- run for 10 clock cycles

			for j in 1 to r loop
				r_in(j) <= std_logic_vector(to_signed(A(j,i), n_bits));
				c_in(j) <= std_logic_vector(to_signed(B(j,i), n_bits));
			end loop;

		--	for j in 1 to r loop
		--		for k in 1 to r loop
		--			p_sig(j, k) <= m_sig(j,k) - f_sig(j,k);
		--		end loop;
		--	end loop;

			clk <= '1';
			wait for delay;
			clk <= '0';
			wait for delay;
		end loop;
	end process;
end behaviour;
