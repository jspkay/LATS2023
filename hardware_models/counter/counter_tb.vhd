library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_tb is
end counter_tb;

architecture counter_tb of counter_tb is
	signal clk, rst: std_logic;
	constant bits : positive := 8;
	signal v : unsigned(1 to bits);

	component counter is
		generic( bits : positive := bits );
		port(clk, rst : in std_logic;
			value : out unsigned);
	end component;
begin
	c : counter port map(clk, rst, v);

	process begin
		rst <= '1'; wait for 5 ns;
		rst <= '0'; wait for 5 ns;
		for i in 1 to 200 loop
			clk <= '1';
			wait for 5 ns;
			clk <= '0';
			wait for 5 ns;
		end loop;
		rst <= '1'; wait for 5 ns;
		rst <= '0'; wait for 5 ns;
		for i in 1 to 300 loop
			clk <= '1'; wait for 5 ns;
			clk <= '0'; wait for 5 ns;
		end loop;
	end process;
end architecture;
