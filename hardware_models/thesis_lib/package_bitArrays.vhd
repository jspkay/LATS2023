library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

------------ IMPORTANT: compile with 2008 standard or later!!!! ------------------
-- (works both with questasim and ghdl) 


package bitArrays is
	constant byte : positive := 8;
	constant half : positive := 16;
	constant word : positive := 32;

	type std_logic_arr_t is array(natural range <>) of std_logic_vector;
	type std_logic_mat_t is array(natural range <>, natural range <>) of std_logic_vector;

	-- monodimensional
	type signed_arr_t is array(natural range <>) of signed;
	type unsigned_arr_t is array(natural range <>) of unsigned;

	type signed_byte_arr_t is array(natural range <>) of signed(0 to byte-1);
	type signed_half_arr_t is array(natural range<>) of signed(0 to half-1);
	type signed_word_arr_t is array(natural range<>) of signed(0 to word-1);

	type unsigned_byte_arr_t is array(natural range <>) of unsigned(0 to byte-1);
	type unsigned_half_arr_t is array(natural range<>) of unsigned(0 to half-1);
	type unsigned_word_arr_t is array(natural range<>) of unsigned(0 to word-1);

	-- bidimensional
	type signed_mat_t is array(natural range<>, natural range<>) of signed;
	type unsigned_mat_t is array(natural range<>, natural range<>) of unsigned;

	type signed_byte_mat_t is array(natural range<>, natural range <>) of signed(0 to byte-1);
	type signed_half_mat_t is array(natural range<>, natural range<>) of signed(0 to half-1);
	type signed_word_mat_t is array(natural range<>, natural range<>) of signed(0 to word-1);

	type unsigned_byte_mat_t is array(natural range<>, natural range <>) of unsigned(0 to byte-1);
	type unsigned_half_mat_t is array(natural range<>, natural range<>) of unsigned(0 to half-1);
	type unsigned_word_mat_t is array(natural range<>, natural range<>) of unsigned(0 to word-1);

	-- functions
	function write_result_on_file(res : in signed_mat_t) return boolean;
end package bitArrays;

package body bitArrays is
	function write_result_on_file (res : in signed_mat_t ) 
		return boolean is
	begin
		report "Writing result to disk..." severity note;
		report "Not implemented yet!" severity warning;
		return false;
	end function;
end package body;
