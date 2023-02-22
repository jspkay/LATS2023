use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library thesis;
use thesis.bitArrays.all;
use thesis.fileFunctions.all;

entity ram is
	generic(filename : string; 
		depth : positive := 8;
		addrDepth : positive := 16;
		filetype : filetype := textual);
	port( addr : in unsigned(1 to addrDepth);
		read_low : in std_logic;
		value : inout signed(1 to depth) );
end ram;

architecture ram of ram is
	signal memory : signed_arr_t(0 to 2 ** addrDepth-1)(1 to depth) := (others => (others => 'Z'));
begin
	process(read_low)
	begin
		if read_low = '1' then -- we are writing
			memory(to_integer(addr)) <= value;
		end if;
	end process;

	value <= (others => 'Z') when read_low /= '1'
		else memory(to_integer(addr)); -- tri-state buffer

end architecture;
