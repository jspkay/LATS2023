library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity digital_comparator_tb is
end digital_comparator_tb;

architecture digital_comparator_tb of digital_comparator_tb is
	constant bits : positive := 8;
	signal counter : unsigned(1 to bits);

	component digital_comparator is
		generic(fire_value : positive := 3; bits:positive:=bits);
		port(counter_in : in unsigned(1 to bits); 
			rst : in std_logic; 
			fire : out std_logic );
	end component;

	signal rst : std_logic := '0'; 
begin

	D_5 : digital_comparator generic map(fire_value => 5, bits => bits)
		port map(counter, rst, open);

	D_18 : digital_comparator generic map(fire_value => 18 )
		port map(counter, rst, open);

	D_32 : digital_comparator generic map(fire_value => 32)
		port map(counter, rst, open);

	process begin
		for i in 1 to 50 loop
			counter <= to_unsigned(i, counter'length);
			wait for 5 ns;
		end loop;
	end process;

	process begin
		rst <= '1'; wait for 180 ns;
		rst <= '0'; wait;
	end process;

end;
