use std.textio.all; 

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library thesis;
use thesis.bitArrays.all; 

package fileFunctions is
	type filetype is (textual, binary, hexadecimal, octal);
	

 	impure function readRomContent(filename : in string;
			addrDepth : in positive; 
			depth : in positive;
			filetype : filetype )
		return signed_arr_t; 

 	impure function writeMatrixContent(filename : string;
		result : std_logic_mat_t;
 		ft : filetype)
 		return boolean;

end package;

package body fileFunctions is
	
 	impure function readRomContent(filename : in string;
			addrDepth : in positive; 
			depth : in positive;
			filetype : filetype ) 
		return signed_arr_t is

		file fp : text open read_mode is filename; -- The function needs to be impure to use a file type
		variable counter, fileEnd: integer := 0;
		variable res : signed_arr_t(0 to 2**addrDepth-1)(1 to depth);
		variable l : line;
		variable rr : integer;
	begin
		report "Reading file "&filename&"..."
			severity note;
		while not endfile(fp) loop
			readline(fp, l); 
			case filetype is
				when textual => read(l, rr);
					res(counter) := to_signed(rr, depth);
					report "depth: " & integer'image(depth) & " value: " & integer'image(rr)
						severity note;
				when hexadecimal => hread(l, res(counter));
				when octal => oread(l, res(counter));
				when binary => report "Not implemented yet!" severity Error;
			end case;
			counter := counter + 1;
			if counter > res'high then
				report "The file " & filename & " contains more data than the size of ther rom (2^"&integer'image(addrDepth)&")."
				severity failure;
				exit;
			end if;
		end loop;
		
		fileEnd := counter;
		report "File finished when counter was " & integer'image(counter-1)  severity note;

		while counter <= res'high loop
			res(counter) := to_signed(0, depth);
			counter := counter+1;
		end loop;
		file_close(fp);

		if fileEnd /= counter then
			report "File ended before filling the memory. "& integer'image(counter-fileEnd) & " additional zero padding added. "
			severity note;
		end if;
			

		report "ROM Setup finished. file("&filename&")" severity note;
		return res;
	end readRomContent;
	
	function to_unsigned_hex(value : in signed) return unsigned is
		variable l : positive := value'length(1);
		variable res : unsigned(0 to l-1); 
		variable j : natural := 0;
		variable start, stop : integer;
	begin
		for i in value'low to value'high loop
			res(j) := value(i);
			j := j+1;
		end loop;
		return res;
	end function;

 	impure function writeMatrixContent( filename : string;
				result : std_logic_mat_t;
 				ft : filetype)
 			return boolean is
		file fp : text open write_mode is filename;
		variable l : line;	
		variable space : character := ' ';
		variable left1 : integer := result'left(1);
		variable right1 : integer := result'right(1);
		variable left2 : integer := result'left(2);
		variable right2 : integer := result'right(2);
		variable depth : integer := result(left1, left2)'length; 

		variable uHex : unsigned(1 to depth); -- unsigned hex representation
		variable tmp : integer := 0;
		variable c : integer := 0;
	begin
		--report integer'image(result'right(2)) severity note;
		report "File " & filename & " opened successfully"
			severity note;
		for i in left1 to right1 loop
			for j in left2 to right2 loop
				case ft is
					when textual => tmp := to_integer( signed(result(i,j)) );
						write(l, tmp);
					when hexadecimal => -- uHex := to_unsigned_hex( signed(result(i,j)) );
						hwrite(l, result(i,j));
					when binary => report "byinary files are not supported yet!" severity error;
					when octal => owrite(l, result(i,j));
				end case;
				write(l, space);
			end loop;
			writeline(fp, l);
			c := c + 1;
		end loop;
		report "Finished writing " & filename & ". " & integer'image(c) & " lines wrote. "
			severity note;
		return false;
	end writeMatrixContent;


end package body;



