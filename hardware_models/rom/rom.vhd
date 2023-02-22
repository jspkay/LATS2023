use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library thesis;
use thesis.bitArrays.all;
use thesis.fileFunctions.all;

entity rom is
	generic(filename : string; 
		depth : positive := 8;
		addrDepth : positive := 16;
		filetype : filetype := textual);
	port( addr : in unsigned(1 to addrDepth);
		value : out signed(1 to depth) );
end rom;

architecture rom of rom is

--  	impure function readRomContent(filename : in string;
-- 			addrDepth : in positive; 
-- 			depth : in positive;
-- 			filetype : string ) 
-- 		return signed_arr_t is
-- 
-- 		file fp : text open read_mode is filename; -- The function needs to be impure to use a file type
-- 		variable counter, fileEnd: integer := 0;
-- 		variable res : signed_arr_t(0 to 2**addrDepth-1)(1 to depth);
-- 		variable l : line;
-- 		variable rr : integer;
-- 	begin
-- 		report "Reading file "&filename&"..."
-- 			severity note;
-- 		while not endfile(fp) loop
-- 			readline(fp, l);
-- 			if 
-- 			read(l, rr);
-- 			hread(l, res(counter));
-- 			res(counter) := to_signed(rr, depth);
-- 			counter := counter + 1;
-- 			if counter > res'high then
-- 				report "The file " & filename & " contains more data than the size of ther rom (2^"&integer'image(addrDepth)&"). The rest will be ignored."
-- 				severity warning;
-- 				exit;
-- 			end if;
-- 		end loop;
-- 		
-- 		fileEnd := counter;
-- 		report "File finished when counter was " & integer'image(counter-1)  severity note;
-- 
-- 		while counter <= res'high loop
-- 			res(counter) := to_signed(0, depth);
-- 			counter := counter+1;
-- 		end loop;
-- 		file_close(fp);
-- 
-- 		if fileEnd /= counter then
-- 			report "File ended before filling the memory. "& integer'image(counter-fileEnd) & " additional zero padding added. "
-- 			severity note;
-- 		end if;
-- 			
-- 
-- 		report "ROM Setup finished. file("&filename&")" severity note;
-- 		return res;
-- 	end readRomContent;

	signal memory : signed_arr_t(0 to 2 ** addrDepth-1)(1 to depth) := readRomContent(filename, addrDepth, depth, filetype); 
	
begin

	value <= memory(to_integer(addr));

end architecture;
