library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity delay_block is 
	generic( depth : positive );
	port( clk : in std_logic;
		din : in signed;
		dout : out signed := to_signed(0, depth) );
end delay_block;
architecture db of delay_block is
begin
	process(clk) 
	begin
		if rising_edge(clk) then
			dout <= din;
		end if;
	end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library thesis; -- use configure.sh
use thesis.bitArrays.all;
entity selective_shift_register is
	generic( length : positive := 4;
		depth : positive := byte );

	port( 	clk, fire : in std_logic;
		input : in signed_arr_t(0 to length-1)(1 to depth);
		output : out signed_arr_t(0 to length-1)(1 to depth) := (others => to_signed(0, depth) ); 
		fire_line : out std_logic_vector(0 to length-1) := (others => '0') );
end selective_shift_register;

architecture ssr of selective_shift_register is
	component fire_forwarder is
		generic( length : positive := length;
			delay : positive := 2;
			first_delay : natural := 1);
		port( clk, rst : in std_logic;
			fire : in std_logic;
			fire_line : out std_logic_vector(0 to length-1) );
	end component;

	component muxer is
		generic( depth : positive := depth);
		port( selector : in std_logic;
			din0, din1 : in signed(1 to depth);
			dout : out signed(1 to depth) );
	end component; 

	component delay_block is 
		generic( depth : positive := depth );
		port(clk : in std_logic;
			din : in signed(1 to depth);
			dout : out signed(1 to depth) );
	end component;	

	--signal fl : std_logic_vector(0 to length-1) := (others => '0');
	signal tmp : signed_arr_t(0 to length-1)(1 to depth);
begin

	DB1 : delay_block port map(clk, input(0), output(0));
	DBM : for i in 1 to length-1 generate
		DB : delay_block port map(clk, output(i-1), tmp(i));
		M : muxer port map(fire_line(i-1), tmp(i), input(i), output(i));
	end generate;

	ff : fire_forwarder port map(clk, '0', fire, fire_line);

end architecture;
