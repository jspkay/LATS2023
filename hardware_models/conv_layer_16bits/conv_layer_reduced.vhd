-- This file implements a convolutional layer for a neural network.
-- NOTE: the input must have a single channel and the stride must bmust be 1
-- Entity tb represents a single convolutional layer and contains all the logic for reading the input channell (i.e. BW image) and the logic for synchronizing them.
-- The entity channel contains the systolic array and the weights input logic. Since each channel has its own weights, the entity also read the data from file and implements a j-shift-register. This entity also writes the result file

--################## Reduced convolutional layer ################################
use std.env.finish;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library thesis;
use thesis.bitArrays.all;
use thesis.fileFunctions.all;

entity conv_layer_reduced is
	generic( rowTot, colTot : positive; -- array size
		kernelHeight, kernelWidth : positive;
		completeRowTot, completeColTot : positive; -- output width and height
		depth : positive;
		n_channels : positive; --output channels
		main_dir : string;
		SEQS_FILENAMES, WEIGHTS_FILENAMES : string; 
		RESULT_FILENAMES : string;
		FILE_EXTENSION : string );
end conv_layer_reduced;

architecture conv_layer_reduced of conv_layer_reduced is
	function computeLastFrame (outputH : positive; outputW : positive; arrH : positive; arrW : positive) return positive is
		variable horLen, verLen, remainder, res : integer;
	begin
		horLen := outputW / arrW;
		remainder := outputW mod arrW;
		if remainder /= 0 then
			remainder := remainder + 1;
		end if;

		verLen := outputH / arrH;
		remainder := outputH mod arrH;
		if remainder /= 0 then
			verLen := verLen + 1;
		end if;

		res := verLen * horLen;
		return res;
	end function;

	-- Constants
	constant CLOCK_SEMI_PERIOD : time := 5 ns;
	constant memoryAddrDepth : positive := 11;

	-- synchronization signals
	signal clk : std_logic := '0';
	signal rst : std_logic := '1';
	signal done : std_logic := '0';
 	signal channel_finished : std_logic_vector(1 to n_channels);

	signal fire : std_logic := '0';
	signal fire_line : std_logic_vector(2 to rowTot+1);

	signal prepareNextFrame : std_logic := '0';
	signal currentFrame : integer := 0;
	constant lastFrame : integer := computeLastFrame(completeRowTot, completeColTot, rowTot, colTot);
	signal frameReset : std_logic := '0';
	signal muxersInputs : std_logic_arr_t(0 to 4*rowTot-1)(1 to depth);

	-- memory signals
	signal weights_addr : unsigned(1 to memoryAddrDepth); --used for the weights
	signal seqs_addrs : unsigned_arr_t(1 to completeRowTot)(1 to memoryAddrDepth) := (others => to_unsigned(0, memoryAddrDepth)); 
	signal seqs_mem_values : std_logic_arr_t(0 to rowTot*4-1)(1 to depth) := (others => std_logic_vector(to_unsigned(0, depth)) );
	
	-- channels inputs
	signal sequences_inputs : std_logic_arr_t(0 to rowTot-1)(1 to depth); -- image

	-------------- Components
	component channel is
		generic( rowTot, colTot : positive;
			kernelHeight, kernelWidth : positive;
			completeRowTot, completeColTot : positive;
			depth, memoryAddrDepth : positive;
			ID : positive;
			main_dir : string;
			WEIGHTS_FILENAMES, RESULT_FILENAMES: string;
			FILE_EXTENSION : string );
		port( clk, rst : in std_logic;
			done : in std_logic; -- write to memory
			prepareNextFrame : in std_logic;
			currentFrame : in integer;
			sequences_inputs : in std_logic_arr_t(0 to rowTot-1)(1 to depth);
			weights_addr : in unsigned(0 to memoryAddrDepth-1);
			write_finish : out std_logic );
	end component;
	component rom is
		generic(filename : string;
			depth : positive := depth;
			addrDepth : positive := memoryAddrDepth);
		port( addr : in unsigned(1 to addrDepth);
			value : out signed(1 to depth) );
	end component;
	component counter is
		generic( bits : positive := memoryAddrDepth;
			initial_value : natural := 2**memoryAddrDepth-1 ); -- This value is necessary because when the reset line goes high, the first two values of these memories are considered garbage.
		port( clk, rst : in std_logic;
			value : out unsigned(1 to bits) );
	end component;
	component muxer_generic is
		generic( depth : positive := depth;
			selector_bits : positive := 2 );
		port( selector : in std_logic_vector(1 to selector_bits);
			din : in std_logic_arr_t(0 to 2**selector_bits-1)(1 to depth);
			dout : out std_logic_vector(1 to depth) );
	end component;
begin
	---------------------------------------------------------------- Sanity checks
	assert( main_dir(main_dir'right) = '/' )
		report "main_dir name must end with a '/' character!"
		severity failure;
	assert( SEQS_FILENAMES(SEQS_FILENAMES'right) = '_' )
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
		report "The computation is going to start... The total number of frame to be processed is "& integer'image(lastFrame)
			severity note;
		rst <= '1';
		wait until falling_edge(clk); -- 1 clock cycles
		rst <= '0';
		wait; -- end of process
	end process ResetProcess;

	ClockProcess : process
	begin	-- Maybe we can check whether done=1 and in that case block the clock. 
		clk <= '1';
		wait for CLOCK_SEMI_PERIOD;
		clk <= '0';
		wait for CLOCK_SEMI_PERIOD;
	end process ClockProcess;

	SwitchFrameProcess : process
		variable L : integer := kernelHeight * (colTot+kernelWidth-1);
	begin
		wait for (L + rowTot + colTot) * 2 * CLOCK_SEMI_PERIOD;
		prepareNextFrame <= '1';
		wait until rising_edge(clk); -- wait for two additional CC
		wait until rising_edge(clk); -- to make sure channel switches frame
		wait until falling_edge(clk);
		prepareNextFrame <= '0';
		currentFrame <= currentFrame + 1;
		frameReset <= '1';  -- reset the array 
		wait until rising_edge(clk); -- wait two more additional CC
		wait until rising_edge(clk);
		frameReset <= '0'; -- restart the computations
	end process;

	WriteInMemory : process
		variable writeResult : boolean;
	begin
		wait until currentFrame = lastFrame;
		wait until rising_edge(clk);
		done <= '1';
		for i in 1 to n_channels loop -- wait for all the channels to write the result and end the simulation
			wait until channel_finished(i) = '1';
		end loop;
		finish;
	end process;

	------------------------------------------------------------------ Input sequences	
	weightAddress : counter generic map(initial_value => 2**memoryAddrDepth-1 )
		port map(clk, rst or frameReset, weights_addr); -- Directly forwarded to the channels
		--port map(clk, frameReset or rst, weights_addr); -- Directly forwarded to the channels

	seqsAdrrs : for i in 1 to rowtot generate
		c : counter generic map (initial_value => 2**memoryAddrDepth-i)
			port map(clk, rst, seqs_addrs(i));
	end generate;

	sequencesInputs : for frame in 0 to 3 generate
		roms : for row in 1 to rowTot generate
			r : rom generic map(filename => main_dir & SEQS_FILENAMES & integer'image(row) & FILE_EXTENSION )
				port map(seqs_addrs(row), std_logic_vector(value) => sequences_inputs(row-1) );
		end generate;
	end generate;

 	channels_generate : for i in 1 to n_channels generate
 		C : channel generic map(rowTot, colTot, kernelHeight, kernelWidth,
				completeRowTot, completeColTot,
				depth, memoryAddrDepth,
				i, -- ID
				main_dir,
				WEIGHTS_FILENAMES, RESULT_FILENAMES,
				FILE_EXTENSION )
			port map(clk, frameReset or rst, done, prepareNextFrame, currentFrame,
				sequences_inputs, weights_addr, channel_finished(i) );
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
		completeRowTot, completeColTot : positive;
		depth, memoryAddrDepth : positive;
		ID : positive;
		main_dir : string;
		WEIGHTS_FILENAMES, RESULT_FILENAMES: string;
		FILE_EXTENSION : string );
	port( clk, rst : in std_logic;
		done : in std_logic; -- write to memory
		prepareNextFrame : in std_logic;
		currentFrame : in  integer; 
		sequences_inputs : in std_logic_arr_t(0 to rowTot-1)(1 to depth);
		weights_addr : in unsigned(0 to memoryAddrDepth-1);
		write_finish : out std_logic );
end channel;

architecture channel of channel is
	constant res_depth : positive := double;

	signal arrayOutput : std_logic_mat_t(0 to rowTot-1, 0 to colTot-1)(1 to res_depth);
	signal result : std_logic_mat_t(0 to completeRowTot-1, 0 to completeColTot-1)(1 to res_depth);
	signal weights_mem_value : signed(1 to depth); 
	signal weights_inputs : std_logic_arr_t(0 to colTot-1)(1 to depth); -- systolic array's column input
	signal sm_cs : std_logic := '0'; -- super muxer chip select
	
	-- COMPONENTS
	component systolic_generic is 
		generic(rows: positive := rowTot;
			cols: positive := colTot;
			depth : positive := depth;
			res_depth : positive := res_depth; 
			is_north_signed : bit := '1';
			is_west_signed : bit := '0' );
		port(	clk, rst : in std_logic;
			c_in : in std_logic_arr_t(1 to cols);
			r_in : in std_logic_arr_t(1 to rows)(1 to depth) ;
			m : out std_logic_mat_t(1 to rows, 1 to cols)(1 to res_depth) );
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
			din : in std_logic_vector(1 to depth);
			dout : out std_logic_arr_t(0 to length-1)(1 to depth) );
	end component;
	component super_muxer is 
		generic (depth : positive := res_depth;
			selector_bits : positive := 6;
			inrows : positive := rowTot; incols : positive := colTot;
			outrows : positive := completeRowTot; outcols : positive := completeColTot );
		port( selector : in std_logic_vector(1 to selector_bits);
			cs : in std_logic;
			din : in std_logic_mat_t(0 to inrows-1, 0 to incols-1)(1 to depth);
			dout : out std_logic_mat_t(0 to outrows-1, 0 to outcols-1)(1 to depth)
		);
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
			hexadecimal );
		write_finish <= '1';
		wait until falling_edge(done);
	end process;

	--------------------------------------------------------------- Switch frame (convolution pass)
	switchFrameProcess: process
	begin
		wait until rising_edge(prepareNextFrame);
		sm_cs <= '1'; -- super muxer's chip select
		wait until rising_edge(clk); -- for at least one CC 
		wait until falling_edge(clk);
		sm_cs <= '0'; -- stop 
	end process; 

	--------------------------------------------------------------- Memory management
	weightsMemory : rom generic map(filename => main_dir & WEIGHTS_FILENAMES & integer'image(ID) & FILE_EXTENSION )
			port map(weights_addr, weights_mem_value);

	--------------------------------------------------------------- Systolic array and its inputs
	weightsIn : j_shift_register
			port map(clk, rst, std_logic_vector(weights_mem_value), weights_inputs);

	systolicArray : systolic_generic
			port map(clk, rst, weights_inputs, sequences_inputs, arrayOutput);

	sm : super_muxer
			port map(std_logic_vector(to_unsigned(currentFrame, 6)), sm_cs, arrayOutput, result);
end architecture;

