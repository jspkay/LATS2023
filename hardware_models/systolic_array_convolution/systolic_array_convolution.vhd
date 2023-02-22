use std.env.finish;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library thesis;
use thesis.bitArrays.all;
use thesis.fileFunctions.all;

entity tb is
	generic(main_dir : string := "./data/6x6_prova/");
end tb;

architecture systolic_array_convolution of tb is
	constant CLOCK_SEMI_PERIOD : time := 5 ns;

	-- Contants corresponding to the hyperparameters
	constant rowTot : natural := 6; -- 28; -- resulting image width
	constant colTot : natural := 6; --28; -- resulting image height

	constant kernelHeight : natural := 3; --5; -- kernel height
	constant kernelWidth : natural := 3; -- 5; -- kernel width

	constant depth : positive := byte; -- 8 bit data

	-- Systolic Input/Output signals
	signal weights_inputs : signed_arr_t(0 to colTot-1)(1 to depth); -- systolic array's column input
	signal sequences_inputs : signed_arr_t(0 to rowTot-1)(1 to depth) := (others => to_signed(0, depth));

	signal clk : std_logic := '0';
	signal rst : std_logic := '1';

	signal result : signed_mat_t(0 to rowTot-1, 0 to ColTot-1)(1 to 2*depth);

	-- Memory related signals and constants
	constant memoryAddrDepth : positive := 8;

	signal main_seq_mem_value : signed(1 to depth); 
	signal weights_mem_value : signed(1 to depth); 
	signal main_addr : unsigned(1 to memoryAddrDepth); -- increments with clock. Used for weights and main sequence

	signal other_seqs_mem_values : signed_arr_t(2 to rowTot)(1 to depth);
	signal other_seqs_addrs : unsigned_arr_t(2 to rowTot)(1 to depth); -- increment with a fire signal
	signal fire : std_logic := '0';
	signal fire_line : std_logic_vector(2 to rowTot+1);
	signal seqs_mem_values : signed_arr_t(0 to rowTot-1)(1 to depth);

	signal simulationDone : boolean := false; -- when this signal goes to true the simulation is finished

	-- Components
	component systolic_generic is 
		generic(rows: positive := rowTot;
			cols: positive := colTot;
			depth : positive := depth );
		port(	clk, rst : in std_logic;
			c_in : in signed_arr_t(1 to cols);
			r_in : in signed_arr_t(1 to rows)(1 to depth) ;
			m : out signed_mat_t(1 to rows, 1 to cols)(1 to 2*depth) );
	end component;
	component rom is
		generic(filename : string;
			depth : positive := byte;
			addrDepth : positive := memoryAddrDepth);
		port( addr : in unsigned(1 to addrDepth);
			value : out signed(1 to depth) );
	end component;
	component fire_generator is
		generic( bits : positive := 5;
			fire_value : natural := 0;
			reset_value : positive := kernelHeight-1);
		port( clock, reset : in std_logic;
			fire : out std_logic );
	end component;
	component j_shift_register is
		generic( depth : positive := memoryAddrDepth;
			j : positive := kernelHeight;
			length : positive := rowTot );
		port( clk, rst : in std_logic;
			din : in signed(1 to depth);
			dout : out signed_arr_t(0 to length-1)(1 to depth) );
	end component;
	component counter is
		generic( bits : positive := depth;
			initial_value : natural := 2**memoryAddrDepth-1 ); -- This value is necessary because when the reset line goes high, the first two values of these memories are considered garbage.
		port( clk, rst : in std_logic;
			value : out unsigned(1 to bits) );
	end component;
	component selective_shift_register is
		generic( length : positive := rowTot;
			depth : positive := depth );
		port( clk, fire : in std_logic;
			input : in signed_arr_t(0 to length-1)(1 to depth);
			output : out signed_arr_t(0 to length-1)(1 to depth);
			fire_line : out std_logic_vector(0 to length-1) );
	end component;
	
	-- name constants
	constant WEIGHTS_FILENAME : string := "HW_SIM_WEIGHTS_1";
	constant MAIN_SEQ_FILENAME : string := "HW_SIM_MAIN_SEQ";
	constant OTHER_SEQS_FILENAMES : string := "HW_SIM_SEQ_"; -- & number
	constant FILE_EXTENSION : string := ".DAT";
begin
	-------------------------------------------------------------------- Sanity checks
	assert(main_dir(main_dir'length) = '/')
		report "main_dir name must end with a '/' character!"
		severity failure;

	-------------------------------------------------------------------- clock and reset
	ResetProcess : process
	begin
		rst <= '1';
		wait for 2 * CLOCK_SEMI_PERIOD; -- 1 clock cycles
		rst <= '0';
		wait; -- end of the process.
	end process ResetProcess;

	ClockProcess : process
	begin 
		clk <= '1';
		wait for CLOCK_SEMI_PERIOD;
		clk <= '0';
		wait for CLOCK_SEMI_PERIOD;
	end process ClockProcess;

	WriteInMemory : process
		variable writeResult : boolean;
	begin
		wait for 2 * (rowTot * kernelHeight + colTot + 5) * CLOCK_SEMI_PERIOD + CLOCK_SEMI_PERIOD;
		writeResult := writeMatrixContent( "RESULT.DAT",
			result,
			textual);
		finish;
	end process;
	
	-------------------------------------------------------------------- Memory management (inputs)
	mainAddrGenerator : counter 
			port map(clk, rst, main_addr); 

	weightsMemory : rom generic map(filename => main_dir & WEIGHTS_FILENAME & FILE_EXTENSION )
			port map(main_addr, weights_mem_value);
	mainSequence : rom generic map(filename => main_dir & MAIN_SEQ_FILENAME & FILE_EXTENSION )
			port map(main_addr, seqs_mem_values(0));
	
	fireGenerator : fire_generator -- The fire signal is used for the selective shift_register
			port map(clk, rst, fire);

	otherSeqs : for i in 2 to rowTot generate
		otherSeqsAddrGenerator : counter generic map(initial_value => 2**depth-2)
			port map(fire_line(i), rst, other_seqs_addrs(i));
		otherSequences : rom generic map(filename => main_dir & OTHER_SEQS_FILENAMES & integer'image(i) & FILE_EXTENSION )
			port map(other_seqs_addrs(i), seqs_mem_values(i-1) );
	end generate;

	-------------------------------------------------------------------- Systolic array actual inputs
	weightsIn : j_shift_register
			port map(clk, rst, weights_mem_value, weights_inputs);

	sequencesIn : selective_shift_register
			port map(clk, fire, seqs_mem_values, sequences_inputs, fire_line);

	systolicArray : systolic_generic
			port map(clk, rst, weights_inputs, sequences_inputs, result);
end systolic_array_convolution;



