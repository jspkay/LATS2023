library ieee;
use ieee.std_logic_1164.all;

entity tb is end tb;

architecture tb of tb is
	signal clk : std_logic := '0';
	signal rst : std_logic := '0';
	signal fire : std_logic := '0';
	signal fire_line1,
		fire_line2,
		fire_line3,
		fire_line4,
		fire_line5,
		fire_line6
		: std_logic_vector(1 to 10) := B"0000_0000_00";

	component fire_forwarder is
		generic(delay : positive := 1; 
			length : positive := 10); 
		port( clk, rst : in std_logic;
			fire : in std_logic;
			fire_line : out std_logic_vector(1 to length) );
	end component;
begin
		
	ff1: fire_forwarder port map(clk, rst, fire, fire_line1);
	ff2 : fire_forwarder generic map (delay=>2) port map(clk, rst, fire, fire_line2);
	ff3 : fire_forwarder generic map (delay=>3) port map(clk, rst, fire, fire_line3);
	ff4 : fire_forwarder generic map (delay=>4) port map(clk, rst, fire, fire_line4);
	ff5 : fire_forwarder generic map (delay=>5) port map(clk, rst, fire, fire_line5);
	ff6 : fire_forwarder generic map (delay=>6) port map(clk, rst, fire, fire_line6);

	clkProcess : process
	begin
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
	end process clkProcess;

	rstProcess : process
	begin
		rst <= '1'; wait for 10 ns; -- one clock cycle
		rst <= '0';
		wait;
	end process rstProcess;

	process
	begin
		fire <= '1';
		wait for 10 ns;
		fire <= '0';
		wait for 70 ns;
	end process;

end architecture;
