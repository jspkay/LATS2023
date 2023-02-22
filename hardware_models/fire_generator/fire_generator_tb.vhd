library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity tb is end tb;

architecture tb of tb is
	signal clk : std_logic := '0';
	
	component fire_generator is
		generic( bits : positive := 8;
			fire_value : natural := 28;
			reset_value : positive := 28);
		port( clock, reset : in std_logic;
			fire : out std_logic );
	end component;
	signal rst : std_logic := '0';
begin
	FG : fire_generator port map(clk, rst, open);
	FG1 : fire_generator generic map(fire_value => 0) port map(clk, rst, open);
	FG2 : fire_generator generic map( fire_value => 0, reset_value=>2 )
		port map( clk, rst, open);

	clkProcess : process begin
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
	end process;

	rstProceess : process begin
		rst <= '0'; wait for 400 ns;
		rst <= '1'; wait for 30 ns;
	end process;

end architecture;
