library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity P is
generic(depth : positive := 8;
	res_depth : positive := 32; 
	is_north_signed, is_west_signed : bit );
port (
	clk, reset : in std_logic;
	north, west : in std_logic_vector(0 to depth-1);
	east, south : out std_logic_vector(0 to depth-1) := (others=>'0');
	result : out std_logic_vector(0 to res_depth-1) := (others=>'0') );
end P;

architecture P of P is
	function multiplyAndSum(n,w : std_logic_vector(0 to depth-1);
			is_north_signed, is_west_signed : bit;
			ps : std_logic_vector(0 to res_depth-1)  ) return std_logic_vector is
		variable sig_n   : signed(0 to depth-1) := signed(n);
		variable sig_w   : signed(0 to depth-1) := signed(w);
		variable unsig_n : unsigned(0 to depth-1) := unsigned(n);
		variable unsig_w : unsigned(0 to depth-1) := unsigned(w);
		variable sig_res : signed(0 to res_depth-1) := signed(ps);
		variable unsig_res : unsigned(0 to res_depth-1) := unsigned(ps);
		variable res : std_logic_vector(0 to res_depth-1);
	begin
		case is_north_signed&is_west_signed is
			when "00" => unsig_res := unsig_res + unsig_n * unsig_w;
			when "11" =>   sig_res := sig_res + sig_n * sig_w;
			when "01" =>   sig_res := resize( sig_res + signed(resize(unsig_n, depth+1)) * sig_w, res_depth );
			when "10" =>   sig_res := resize( sig_res + sig_n * signed(resize(unsig_w, depth+1)), res_depth );
		end case;
	
		if not (is_north_signed or is_west_signed) then
			for i in 0 to res_depth-1 loop
				res(i) := unsig_res(i);
			end loop;
		else 
			for i in 0 to res_depth-1 loop
				res(i) := sig_res(i);
			end loop;
		end if;
		
		return res;
	end function; 

begin
	process(clk) is
		variable partial_sum : std_logic_vector(0 to res_depth-1) := (others => '0');
	begin
		if rising_edge(clk) then
			partial_sum := multiplyAndSum(north, west, is_north_signed, is_west_signed, partial_sum);
			east <= west;
			south <= north;
			result <= partial_sum;

			if reset = '1' then
				partial_sum := (others => '0');
			end if;
		end if;
	end process;
end P;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library thesis;
use thesis.bitArrays.all;

entity systolic_generic is
	generic(
		rows : positive := 4;
		cols : positive := 4;
		depth : positive := byte;
		res_depth : positive := word;
		is_north_signed, is_west_signed : bit );
	port(
		clk, rst : in std_logic;
		r_in : in std_logic_arr_t(1 to rows)(1 to depth);
		c_in : in std_logic_arr_t(1 to cols)(1 to depth);
		m : out std_logic_mat_t(1 to rows, 1 to cols)(1 to res_depth)  );
end systolic_generic;

architecture behavior of systolic_generic is
	--type signed_8bit_mat_t is array (1 to r) of array (1 to r) of std_logic_vector(0 to 7);

	signal clock, reset : std_logic := '0';
	signal r_mat : std_logic_mat_t(1 to rows, 1 to rows-1)(1 to depth); 
	signal c_mat : std_logic_mat_t(1 to cols-1, 1 to cols)(1 to depth); -- These are the signals between processors. Indeed c_mat contains all the signals for the columns and r_mat contains all the signals for the rows. Note that the index correspond to the exit procesor, so c_mat(3,2) exits from processor in column 2 and row 3 and enters (same column) in processor P42 in column 2 and row 4. Furthermore, we only need r-1 signals for each column and row since the last processor is not connected.
	--signal north_tmp, west_tmp, east_tmp, south_tmp : std_logic;
	component P is
		generic( depth : positive := depth;
			res_depth : positive := word;
			is_north_signed : bit := is_north_signed;
			is_west_signed : bit := is_west_signed );
		port(
			clk : in std_logic;
			north, west : in std_logic_vector(0 to depth-1); -- signed_8bit_t;
			east, south : out std_logic_vector(0 to depth-1); --signed_8bit_t;
			result : out std_logic_vector(0 to res_depth-1); -- signed_8bit_t;
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

	process(rst) is
	begin
		reset <= rst;
	end process;
end behavior;
			
