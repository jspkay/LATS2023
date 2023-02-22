library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

entity ReadFromFile is
end ReadFromFile;

architecture ReadFromFile of ReadFromFile is
	
	signal clk : std_logic := '0';
	signal value : std_logic_vector(1 to 8);

	constant filename : string := "justTrying.txt";

	file fptr : text;

begin
	ClockProcess : process
	begin
		clk <= '0' after 10 ns, '1' after 20 ns;
		wait for 20 ns;
	end process;

	------------------------

	GetDataProcess : process

		variable fstatus : file_open_status;
		variable file_line : line;
		variable char : integer;
		variable ok : boolean;
	begin	
		
		file_open(fstatus, fptr, filename, read_mode);

		while (not endfile(fptr)) loop
			wait until clk = '1';
			readline(fptr, file_line);

			if file_line.all'length = 0 then
				next;
			end if;

			read(file_line, value, ok);
			assert ok report "Error in reading!" severity failure;
			report file_line.all severity note;
		end loop;
	end process;

end ReadFromFile;
