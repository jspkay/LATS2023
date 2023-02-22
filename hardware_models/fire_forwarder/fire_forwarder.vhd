library ieee;
use ieee.std_logic_1164.all;

entity ff_block is
	generic( delay : positive := 1 );
	port ( clk, rst : in std_logic;
		fin : in std_logic; 
		fout : out std_logic := '0');
end ff_block;

architecture ff of ff_block is
	signal tmp : std_logic_vector(1 to delay) := (others => '0');
begin
	process(clk) is
	begin
		if rising_edge(clk) then
			if( delay = 1 ) then
				fout <= fin;
			else 
				tmp(1) <= fin;
				for i in 2 to delay-1 loop
					tmp(i) <= tmp(i-1);
				--	report "The value of i is" & integer'IMAGE(i)
				--	severity note;
				end loop;
				fout <= tmp(delay-1);
			end if;



			if rst = '1' then
				fout <= '0';
			end if;
		end if;
	end process;
end architecture;
library ieee;
use ieee.std_logic_1164.all;

entity fire_forwarder is
	generic(
		length : positive := 3;
		delay : positive := 1;
		first_delay : natural := 0);
	port(	clk, rst : in std_logic;
		fire : in std_logic;
		fire_line : out std_logic_vector(1 to length)  := (others => '0') );
end fire_forwarder;

architecture fire_forwarder of fire_forwarder is
	component ff_block is
		generic( delay : positive := delay);
		port( clk, rst: in std_logic;
			fin : in std_logic;
			fout : out std_logic );
	end component;
begin
	FF1 : ff_block generic map(delay => first_delay + 1) port map(clk, rst, fire, fire_line(1));
	fire_line_component : for i in 2 to length generate
			FF : ff_block port map(clk, rst, fire_line(i-1), fire_line(i));
	end generate;

end architecture;
