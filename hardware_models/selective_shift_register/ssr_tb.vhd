library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library thesis;
use thesis.bitArrays.all;

entity tb is end tb;

architecture tb of tb is
	constant depth : positive := byte;
	constant length : positive := 6;

	component selective_shift_register is
		generic( length : positive := length;
			depth : positive := byte );
		port( clk, fire : in std_logic := '0';
			input : in signed_arr_t(0 to length-1)(1 to depth);
			output : out signed_arr_t(0 to length-1)(1 to depth)  );
	end component;

	signal clk, fire : std_logic;
	signal inin : signed_arr_t(0 to length-1)(1 to depth);
begin
	ssr : selective_shift_register port map(clk, fire, inin, open);

	clkProcess : process
	begin
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
	end process clkProcess;

 	seqs : process
 	begin
		--inin(0) <= (others => 'X');
		--wait for 30 ns; 
 		for i in 0 to 100 loop
			if i mod 3 = 1 then
				for j in 1 to length-1 loop
					inin(j) <= to_signed( (i+1) * 3 + j, depth);
				end loop;
			end if;
			inin(0) <= to_signed(i, depth);
			wait until rising_edge(clk);
 		end loop;
 	end process seqs;

	fire_process : process
	begin
			for i in 1 to 10000 loop
				fire <= '1';
				wait until rising_edge(clk);
				fire <= '0';
				wait until rising_edge(clk);
				wait until rising_edge(clk);
			end loop;
	end process fire_process;

end architecture;
