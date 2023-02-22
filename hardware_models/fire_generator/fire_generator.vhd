library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fire_generator is
	generic( 
		bits : positive := 2;
		fire_value : natural := 3;
		reset_value : positive);
	port(
		clock, reset : in std_logic;
		fire : out std_logic );
end fire_generator;

architecture fire_generator of fire_generator is
	
	component counter is
		generic( bits : positive := bits);
		port( 
			clk, rst : in std_logic;
			value : out unsigned(1 to bits) );
	end component;

	component digital_comparator is
		generic( fire_value : natural := fire_value;
			bits : positive := bits );
		port( counter_in : in unsigned(1 to bits);
			rst : in std_logic;
			fire : out std_logic );
	end component;

	signal v : unsigned(1 to bits);
	signal internal_reset, rst : std_logic := '0';
begin
	assert fire_value < 2 ** bits 
		report "Not enough bit ("&integer'image(bits)&") for the specified fire_value (" & integer'image(fire_value) & ")."
		severity error;
	assert fire_value <= reset_value
		report "reset value must be greater than the reset value"
		severity error;

	rst <= internal_reset or reset;
	
	c : counter port map(clock, rst, v);
	dc : digital_comparator port map(v, reset, fire);
	reset_comp : digital_comparator generic map(fire_value=>reset_value) port map(v, reset, internal_reset);

end architecture fire_generator;
		
