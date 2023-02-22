library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library thesis;
use thesis.bitArrays.all;

entity j_shift_register is -- j Shift Register
	generic(
		depth : positive := byte; 
		j : positive := 4; -- j between blocks
		length : positive := 2 -- total blocks of the register
	);
	port( 
		clk, rst : in std_logic;
		din : in std_logic_vector(1 to depth);
		dout : out std_logic_arr_t(0 to length-1)(1 to depth)
	);
end j_shift_register;

architecture j_shift_register of j_shift_register is
	function arrToZero return std_logic_arr_t is
		variable res : std_logic_arr_t(0 to length*j-1)(1 to depth);
	begin
		for i in res'left to res'right loop
			res(i) := (others => '0');
		end loop;
		return res;
	end function;
	
	signal registers : std_logic_arr_t(0 to length*j-1)(1 to depth) := arrToZero;
begin

	process(clk, rst)
	begin
		if rising_edge(clk) then
			
			registers(0) <= din; -- check assignment

			for i in length*j-1 downto 1
			loop
				registers(i) <= registers(i-1);
			end loop;

			dout(0) <= din;
			for i in 1 to length-1
			loop
				dout(i) <= registers( i * j - 1) ;
			end loop;

		end if;

 		if rising_edge(rst) then
			registers <= arrToZero;
 		 end if;
	end process;

	

 end architecture;

