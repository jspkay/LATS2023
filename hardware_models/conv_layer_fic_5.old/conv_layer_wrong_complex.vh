-- This file implements a convolutional layer for a neural network.
-- NOTE: the input must have a single channel and the stride must bmust be 1
-- Entity tb represents a single convolutional layer and contains all the logic for reading the input channell (i.e. BW image) and the logic for synchronizing them.
-- The entity channel contains the systolic array and the weights input logic. Since each channel has its own weights, the entity also read the data from file and implements a j-shift-register. This entity also writes the result file

--########################### Convolutional layer ################################
use std.env.finish;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library thesis;
use thesis.bitArrays.all;
use thesis.fileFunctions.all;

entity conv_layer is
	generic( rowTot, colTot : positive;
		kernelHeight, kernelWidth : positive;
		depth : positive;
		n_channels : positive; --output channels
		main_dir : string;
		MAIN_SEQ_FILENAME, OTHER_SEQS_FILENAMES, WEIGHTS_FILENAMES : string; 
		RESULT_FILENAMES : string;
		FILE_EXTENSION : string );
end conv_layer;

architecture conv_layer of conv_layer is
	-- Constants
	constant CLOCK_SEMI_PERIOD : time := 5 ns;
	constant memoryAddrDepth : positive := 8;

	-- synchronization signals
	signal clk : std_logic := '0';
	signal rst : std_logic := '1';
	signal done : std_logic := '0';
 	signal channel_finished : std_logic_vector(1 to n_channels);

	signal fire : std_logic := '0';
	signal fire_line : std_logic_vector(2 to rowTot+1);

	-- memory signals
	signal main_addr : unsigned(1 to memoryAddrDepth);
	signal other_seqs_addrs : unsigned_arr_t(2 to rowTot)(1 to memoryAddrDepth);
	signal seqs_mem_values : signed_arr_t(0 to rowTot-1)(1 to depth);
	
	-- channels inputs
	signal sequences_inputs : signed_arr_t(0 to rowTot-1)(1 to depth); -- image

	-------------- Components
	component channel is
		generic( rowTot, colTot : positive;
			kernelHeight, kernelWidth : positive;
			depth, memoryAddrDepth : positive;
			ID : positive;
			main_dir : string;
			WEIGHTS_FILENAMES, RESULT_FILENAMES : string;
			FILE_EXTENSION : string );
		port( clk, rst : in std_logic;
			done : in std_logic; -- write to memory
			sequences_inputs : in signed_arr_t(0 to rowTot-1)(1 to depth);
			main_addr : in unsigned(0 to memoryAddrDepth-1);
			write_finish : out std_logic );
	end component;
	component rom is
		generic(filename : string;
			depth : positive := depth;
			addrDepth : positive := memoryAddrDepth);
		port( addr : in unsigned(1 to addrDepth);
			value : out signed(1 to depth) );
	end component;
	component fire_generator is
		generic( bits : positive := 5;
			fire_value : natural := 0;
			reset_value : positive := kernelHeight - 1);
		port( clock, reset : in std_logic;
			fire : out std_logic );
	end component;
	component counter is
		generic( bits : positive := memoryAddrDepth;
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
begin
	---------------------------------------------------------------- Sanity checks
	assert( main_dir(main_dir'right) = '/' )
		report "main_dir name must end with a '/' character!"
		severity failure;
	assert( OTHER_SEQS_FILENAMES(OTHER_SEQS_FILENAMES'right) = '_' )
		report "OTHER_SEQS_FILENAMES must end with a '_' character!"
		severity failure;
	assert( WEIGHTS_FILENAMES(WEIGHTS_FILENAMES'right) = '_' )
		report "WEIGHTS_FILENAMES must end with a '_' character!"
		severity failure;
	assert( RESULT_FILENAMES(RESULT_FILENAMES'right) = '_' )
		report "RESULT_FILENAMES must end with a '_' character!"
		severity failure;


	-------------------------------------------------------------------- synchronization processes
	ResetProcess : process
	begin
		rst <= '1';
		wait for 2 * CLOCK_SEMI_PERIOD; -- 1 clock cycles
		rst <= '0';
		wait; -- end of the process.
	end process ResetProcess;

	ClockProcess : process
	begin	-- Maybe we can check whether done=1 and in that case block the clock. 
		clk <= '1';
		wait for CLOCK_SEMI_PERIOD;
		clk <= '0';
		wait for CLOCK_SEMI_PERIOD;
	end process ClockProcess;

	WriteInMemory : process
		variable writeResult : boolean;
	begin
		wait for 2 * (rowTot * kernelHeight + colTot + 5) * CLOCK_SEMI_PERIOD + CLOCK_SEMI_PERIOD;
		done <= '1';
		for i in 1 to n_channels loop -- wait for all the channels to write the result and end the simulation
			wait until channel_finished(i) = '1';
		end loop;
		finish;
	end process;

	------------------------------------------------------------------ Input channel memory	
	inputAddress : counter 
			port map(clk, rst, main_addr); 

	mainSequence : rom generic map(filename => main_dir & MAIN_SEQ_FILENAME & FILE_EXTENSION )
			port map(main_addr, seqs_mem_values(0));

	fireGenerator : fire_generator -- The fire signal is used for the selective shift_register
			port map(clk, rst, fire);

	otherSeqs : for i in 2 to rowTot generate
		otherSeqsAddrGenerator : counter generic map(initial_value => 2**memoryAddrDepth-2)
			port map(fire_line(i), rst, other_seqs_addrs(i));
		otherSequences : rom generic map(filename => main_dir & OTHER_SEQS_FILENAMES & integer'image(i) & FILE_EXTENSION )
			port map(other_seqs_addrs(i), seqs_mem_values(i-1) );
	end generate;
	
	-------------------------------------------------------------------------- Channel instansiation and sequences input
	sequencesIn : selective_shift_register
			port map(clk, fire, seqs_mem_values, sequences_inputs, fire_line);

 	channels_generate : for i in 1 to n_channels generate
 		C : channel generic map(rowTot, colTot, kernelHeight, kernelWidth,
				depth, memoryAddrDepth,
				i, -- ID
				main_dir, WEIGHTS_FILENAMES, RESULT_FILENAMES,
				FILE_EXTENSION )
			port map(clk, rst, done,
				sequences_inputs, main_addr, channel_finished(i) );
 
 	end generate;

end architecture;

--############ Channel ##########################################################################
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library thesis;
use thesis.bitArrays.all;
use thesis.fileFunctions.all;

entity channel is
	generic( rowTot, colTot : natural;
		kernelHeight, kernelWidth : positive;
		depth, memoryAddrDepth : positive;
		ID : positive;
		main_dir : string;
		WEIGHTS_FILENAMES, RESULT_FILENAMES : string;
		FILE_EXTENSION : string );
	port( clk, rst : in std_logic;
		done : in std_logic; -- write to memory
		sequences_inputs : in signed_arr_t(0 to rowTot-1)(1 to depth);
		main_addr : in unsigned(0 to memoryAddrDepth-1);
		write_finish : out std_logic );
end channel;
	
architecture channel of channel is
	signal result : signed_mat_t(0 to rowTot-1, 0 to ColTot-1)(1 to 2*depth);
	signal weights_mem_value : signed(1 to depth); 
	signal weights_inputs : signed_arr_t(0 to colTot-1)(1 to depth); -- systolic array's column input
	
	-- COMPONENTS
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
			depth : positive := depth;
			addrDepth : positive := memoryAddrDepth);
		port( addr : in unsigned(1 to addrDepth);
			value : out signed(1 to depth) );
	end component;
	component j_shift_register is
		generic( depth : positive := depth;
			j : positive := kernelHeight+1;
			length : positive := rowTot );
		port( clk, rst : in std_logic;
			din : in signed(1 to depth);
			dout : out signed_arr_t(0 to length-1)(1 to depth) );
	end component;
begin
	-------------------------------------------------------------- Write in memory
	WriteInMemory : process
		variable writeResult : boolean;
	begin
		wait until rising_edge(done);
		writeResult := writeMatrixContent( 
			main_dir & RESULT_FILENAMES & integer'image(ID) & FILE_EXTENSION,
			result,
			hexadecimal);
		write_finish <= '1';
		wait until falling_edge(done);
	end process;

	--------------------------------------------------------------- Memory management
	weightsMemory : rom generic map(filename => main_dir & WEIGHTS_FILENAMES & integer'image(ID) & FILE_EXTENSION )
			port map(main_addr, weights_mem_value);


	--------------------------------------------------------------- Systolic array and its inputs
	weightsIn : j_shift_register
			port map(clk, rst, weights_mem_value, weights_inputs);

	systolicArray : systolic_generic
			port map(clk, rst, weights_inputs, sequences_inputs, result);
end architecture;

