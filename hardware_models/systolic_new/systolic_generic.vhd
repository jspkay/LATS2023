library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package my_types is
	type signed_8bit_mat_t is array(natural range <>, natural range <>) of signed(0 to 7);
	type signed_8bit_arr_t is array (natural range <>) of signed(0 to 7);
	type signed_16bit_mat_t is array(natural range<>, natural range <>) of signed(0 to 15);
	-- type signed_8_bit_t is signed(0 to 7);
	-- subtype signed_16_bit_t is signed range 0 to 15);
end package my_types;

library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;
use work.my_types.all;

entity multiplicator is
	generic(
		rows : positive := 4;
		cols : positive := 4;
		n_bits : positive := 8);
	port(
		clk, rst : in std_logic;
		r_in : signed_8bit_arr_t(1 to rows);
		c_in : signed_8bit_arr_t(1 to cols);
		m : out signed_16bit_mat_t(1 to rows, 1 to cols) );
end multiplicator;

architecture behavior of multiplicator is
	--type signed_8bit_mat_t is array (1 to r) of array (1 to r) of std_logic_vector(0 to 7);

	signal clock, reset : std_logic := '0';
	signal r_mat : signed_8bit_mat_t(1 to rows, 1 to rows-1); 
	signal c_mat : signed_8bit_mat_t(1 to cols-1, 1 to cols); -- These are the signals between processors. Indeed c_mat contains all the signals for the columns and r_mat contains all the signals for the rows. Note that the index correspond to the exit procesor, so c_mat(3,2) exits from processor in column 2 and row 3 and enters (same column) in processor P42 in column 2 and row 4. Furthermore, we only need r-1 signals for each column and row since the last processor is not connected.
	--signal north_tmp, west_tmp, east_tmp, south_tmp : std_logic;
	component P is
		port(
			clk : in std_logic;
			north, west : in signed(0 to 7); -- signed_8bit_t;
			east, south : out signed(0 to 7); --signed_8bit_t;
			result : out signed(0 to 15); -- signed_8bit_t;
			reset : in std_logic );
	end component;

begin
 	rows_generate: 	for i in 1 to rows generate
		cols_generate: for j in 1 to cols generate
		
		-- For generating these connection we need to account for different cases:
		-- 1. Processor P11 -> it is connected from north and west to the direct input of the entity
		-- 2. Processors P1j (1<j<cols) -> These processors are connected with the input of the entity on north, while west is connected with the following processors
		-- 3. Processors Pi1 (1<i<rows) -> Same as 2
		-- 4. Processors Pij (1<i,j<cols) -> The interal processors are only interconnected.
		-- 5. Processor Pr1 -> Direct input on west, open connection on south.
		-- 6. Processor P1c -> Direct input on north, open connection on east.
		-- 7. Processors Prj (1<j<cols) -> Like 5 but west is connected with preceding processors
		-- 8. Processors Pic (1<i<rows) -> Like 6 but north is connected with preceding processors
		-- 9. Processor Prc -> Open connection on east and south 

			P11 : if i=1 and j=1 generate -- 1
				P_mat : P port map(clock, c_in(j), r_in(i), r_mat(i,j), c_mat(i,j), m(i,j), reset); 
			end generate P11;

			P1j : if i=1 and j>1 and j<cols generate -- 2
				P_mat : P port map(clock, c_in(j), r_mat(i,j-1), r_mat(i,j), c_mat(i,j), m(i,j), reset); 
			end generate P1j;

			Pi1 : if i>1 and i<rows and j=1 generate -- 3
				P_mat : P port map(clock, c_mat(i-1,j), r_in(i), r_mat(i,j), c_mat(i,j), m(i,j), reset); 
			end generate Pi1;	
			
			Pij : if i>1 and i<rows and j>1 and j<cols generate -- 4
				P_mat : P port map(clock, c_mat(i-1, j), r_mat(i, j-1), r_mat(i,j), c_mat(i,j), m(i,j), reset);
			end generate Pij;

			Pr1 : if i=rows and j=1 generate -- 5
				P_mat : P port map(clock, c_mat(i-1,j), r_in(i), r_mat(i,j), open, m(i,j), reset);
			end generate Pr1;

			P1c : if i=1 and j=cols generate -- 6
				P_mat : P port map(clock, c_in(j), r_mat(i, j-1), open, c_mat(i,j), m(i,j), reset);
			end generate P1c;

			Prj : if i=rows and j>1 and j<cols generate -- 7
				P_mat : P port map(clock, c_mat(i-1, j), r_mat(i, j-1), r_mat(i,j), open, m(i,j), reset);
			end generate Prj;

			Pic : if i>1 and i<rows and j=cols generate -- 8
				P_mat : P port map(clock, c_mat(i-1, j), r_mat(i, j-1), open, c_mat(i,j), m(i,j),  reset);
			end generate Pic;
	
			Prc : if i=rows and j=cols generate-- 9
				P_mat : P port map(clock, c_mat(i-1,j), r_mat(i, j-1), open, open, m(i,j), reset);
			end generate Prc;

		end generate cols_generate;
	end generate rows_generate;


process (clk) is
begin
	clock <= clk;
end process;
end behavior;
			
