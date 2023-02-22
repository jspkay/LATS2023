library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library thesis;
use thesis.bitArrays.all;

entity jSR_tb is
end jSR_tb;

architecture jSR_tb of jSR_tb is
	signal clk, rst: std_logic := '0';
	constant depth : positive := half;

	component j_shift_register is
		generic(
			depth : positive := depth;
			j : positive := 3;
			length : positive := 10
			);
		port( clk, rst :in std_logic;
			din : in std_logic_vector(0 to depth-1)
		);
	end component;

	signal din : std_logic_vector(0 to depth-1) := (others => '0');
begin
	clockProcess : process
	begin
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		wait for 5 ns;
	end process clockProcess;

	SR_5 : j_shift_register port map(clk, rst, din);

	process begin
		rst <= '1';
		wait for 10 ns;
		rst <= '0';
		wait for 5 ns;
		din <= std_logic_vector(to_signed(0, din'length));
		for i in 1 to 100 loop
			wait until clk = '1';
			din <= std_logic_vector(to_signed(i, din'length));
		end loop;
	end process;
end;
