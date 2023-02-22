library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity tb is end tb;

architecture tb of tb is
	component ram is
		generic( filename : string := "ROM_TEST";
			depth : positive := 8;
			addrDepth : positive := 16 );
		port( addr : in unsigned(1 to addrDepth);
			read_low : inout std_logic;
			value : inout signed(1 to depth) );
	end component;

	constant dddd : positive := 4;
	constant depth : positive := 8;
	
	signal addr : unsigned(1 to dddd) := to_unsigned(0, dddd);
	signal v : signed(1 to depth) := (others => '0');
	signal rd: std_logic := 'U';
begin
	ROM_16bit : ram generic map(addrDepth =>dddd, depth => depth) port map(addr=>addr, value=>v, read_low=>rd);
	process
	begin
		for i in 0 to 2**dddd-1 loop
			addr <= to_unsigned(i, dddd);
			rd <= '1';
			v <= to_signed(i+10, depth);
			wait for 10 ns;
			rd <= '0';
			wait for 10 ns;
		end loop;
		finish;
	end process;
end architecture;
