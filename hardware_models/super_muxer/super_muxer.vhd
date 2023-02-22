library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library thesis;
use thesis.bitArrays.all;

entity super_muxer is
	generic ( depth: positive := 8;
			selector_bits : positive := 2;
			inrows : positive := 2;
			incols : positive := 2;
			outrows : positive := 4;
			outcols : positive := 4
			);
	port( selector: in std_logic_vector (1 to selector_bits);
		cs : in std_logic; -- chip select
		din : in std_logic_mat_t(0 to inrows-1, 0 to incols-1)(1 to depth);
		dout : out std_logic_mat_t(0 to outrows-1, 0 to outcols-1)(1 to depth)
		);
end super_muxer;

architecture super_muxer of super_muxer is 
	function maxRows_f(inrows : integer; outrows : integer) return integer is
		variable remainder, res : integer;
	begin
		res := outrows / inrows;
		remainder := outrows mod inrows;
		if remainder /= 0 then
			res := res + 1;
		end if;
		report "maxRows is " & integer'image(res) severity note;
		return res;
	end function;

	function maxCols_f(incols : integer; outcols : integer) return integer is
		variable remainder, res : integer;
	begin
		res := outcols / incols;
		remainder := outcols mod incols;
		if remainder /= 0 then
			res := res + 1;
		end if;
		report "maxCols is " & integer'image(res) severity note;
		return res;
	end function;

	signal maxRows : integer := maxRows_f(inrows, outrows);
	signal maxCols : integer := maxCols_f(incols, outcols);	
begin

	--sanity checks
	assert( 2**selector_bits >= maxRows * maxCols )
		report "the selector doesn't have enough bits ("& integer'image(selector_bits) &") for an output of " & integer'image(outRows) &"x"& integer'image(outRows)
			&". Total positions to address: " & integer'image(maxRows * maxCols)
		severity failure;
	
	process(selector, cs) is
		variable newr, newc : integer;
	begin
		if cs = '1' then
			report "[super_muxer] newloop - " & integer'image(to_integer(unsigned(selector))) severity note;
			for i in 0 to inrows-1 loop
				for ii in 0 to incols-1 loop
					newr := to_integer(unsigned(selector)) / maxRows * inrows + i;
					newc := to_integer(unsigned(selector)) mod maxCols * incols + ii;
					report "[super_muxer] outputPosition (" & integer'image(newr) & ", " & integer'image(newc) & ")" severity note; 
					if newr >= outrows or newc >= outcols then
						next;
					end if;
					dout(newr, newc) <= din(i, ii);
				end loop; --ii
			end loop; -- i
		end if;
	end process;

end architecture;

