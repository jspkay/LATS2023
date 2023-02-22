library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity signed_and is
generic(n_bits : positive := 8);
port(
	input1 : in signed(0 to n_bits-1);
	input2 : in signed(0 to n_bits-1);
	output : out signed(0 to n_bits-1) );
end signed_and;

architecture b of signed_and is

	function "and" (Left, Right : signed(0 to 7)) return signed is
		variable res : signed(0 to 7);
	begin
		for i in 0 to 7 loop
			res(i) := Left(i) and Right(i);
		end loop;
		return res;
	end "and";

begin

	process(input1, input2) is
	begin
		output <= input1 and input2;
	end process;
end b;
