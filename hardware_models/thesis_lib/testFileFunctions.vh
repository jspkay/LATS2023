use std.env.finish;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library thesis;
use thesis.bitArrays.all;
use thesis.fileFunctions.all;

entity tb is end tb;

architecture tb of tb is
begin
	process is
		variable res : std_logic_mat_t(0 to 10, 4 to 12)(1 to byte);
		variable r : boolean;
		variable value : signed(1 to byte) := to_signed(H"FF");
	begin
		
		for i in 0 to 10 loop
			for j in 4 to 12 loop
				res(i, j) := std_logic_vector(value )  ;
			end loop;
		end loop;
		r := writeMatrixContent("fileprova.dat", res, hexadecimal);
		finish;
		wait;
	end process;
end architecture;
