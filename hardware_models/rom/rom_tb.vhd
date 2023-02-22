library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity tb is end tb;

architecture tb of tb is
	component rom is
		generic( filename : string := "ROM_TEST";
			depth : positive := 8;
			addrDepth : positive := 16 );
		port( addr : in unsigned(1 to addrDepth);
			value : out signed(1 to depth) );
	end component;

	constant dddd : positive := 15;
	constant depth : positive := 17;
	
	signal addr : unsigned(1 to dddd) := to_unsigned(0, dddd);
	signal srom_16 : signed(1 to depth);
begin
	ROM_16bit : rom generic map(addrDepth =>dddd, depth => depth) port map(addr, srom_16);
--	ROM_WRONG : rom generic map(addrDepth => 9) port map(addr9, srom_wrong);

	process
	begin
		for i in 0 to 2**dddd-1 loop
			addr <= to_unsigned(i, dddd);
			wait for 10 ns;
		end loop;
		finish;
	end process;
end architecture;
