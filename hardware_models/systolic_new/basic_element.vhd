library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity P is
generic(n_bits : positive := 8);
port (
	clk, reset : in std_logic;
	north, west : in signed(0 to n_bits-1);
	east, south : out signed(0 to n_bits-1) := B"0000_0000";
	result : out signed(0 to 2*n_bits-1) := B"0000_0000_0000_0000" );
end P;

architecture behave of P is
 	-- signal c : signed(0 to 2*n_bits-1) := B"0000_0000_0000_0000" ;
begin
	process(clk) is
		variable partial_sum : signed(0 to 2*n_bits-1) := B"0000_0000_0000_0000";
	begin
		if rising_edge(clk) then
		partial_sum := partial_sum + north*west;
		east <= west;
		south <= north;
		-- c <= partial_sum;
		result <= partial_sum;
		end if;
	end process;

	-- process(reset) is
	-- 	variable r : signed(0 to 2*n_bits-1) := B"0000_0000_0000_0000";
	-- begin
	-- 	if rising_edge(reset) then
	-- 		result <= r;
	-- 		east <= r;
	-- 		south <= r;
	-- 	end if;
	-- end process;
end behave;


