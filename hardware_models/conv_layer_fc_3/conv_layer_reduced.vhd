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
	generic( rowTot, colTot : positive;
		kernelHeight, kernelWidth : positive;
		completeRowTot, completeColTot : positive; -- output width and height
		depth : positive;
		n_channels : positive; --output channels
		main_dir : string;
		REDUCED_STRING, SEQS_FILENAMES, WEIGHTS_FILENAMES : string; 
		RESULT_FILENAMES : string;
		ACTIVATED_FILENAMES : string;
		FILE_EXTENSION : string );
end conv_layer_reduced;

architecture conv_layer_reduced of conv_layer_reduced is
	-- Constants
	constant CLOCK_SEMI_PERIOD : time := 5 ns;
	constant memoryAddrDepth : positive := 8;

	-- synchronization signals
	signal clk : std_logic := '0';
	signal rst : std_logic := '0';
	signal done : std_logic := '0';
 	signal channel_finished : std_logic_vector(1 to n_channels);

	signal fire : std_logic := '0';
	signal fire_line : std_logic_vector(2 to rowTot+1);

	signal currentFrame : integer := 0;
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
			WEIGHTS_FILENAMES, RESULT_FILENAMES, ACTIVATED_FILENAMES: string;
			FILE_EXTENSION : string );
		port( clk, rst : in std_logic;
			done : in std_logic; -- write to memory
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
	assert( ACTIVATED_FILENAMES(ACTIVATED_FILENAMES'right) = '_' )
		report "ACTIVATED_FILENAMES must end with a '_' character!"
		severity failure;


	-------------------------------------------------------------------- synchronization processes
	ResetProcess : process
	begin
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
		currentFrame <= currentFrame + 1;
		wait until falling_edge(clk);
		frameReset <= '1'; 
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		frameReset <= '0';
	end process;

	WriteInMemory : process
		variable writeResult : boolean;
	begin
		wait until currentFrame = 4;
		wait until rising_edge(clk);
		done <= '1';
		for i in 1 to n_channels loop -- wait for all the channels to write the result and end the simulation
			wait until channel_finished(i) = '1';
		end loop;
		finish;
	end process;

	------------------------------------------------------------------ Input sequences	
	weightAddress : counter port map(clk, frameReset or rst, weights_addr); -- Directly forwarded to the channels

	seqsAdrrs : for i in 1 to rowtot generate
		c : counter generic map (initial_value => 2**memoryAddrDepth-i)
			port map(clk, frameReset or rst, seqs_addrs(i));
	end generate;

	sequencesInputs : for frame in 0 to 3 generate
		roms : for row in 1 to rowTot generate
			r : rom generic map(filename => main_dir & REDUCED_STRING & integer'image(frame)  & SEQS_FILENAMES & integer'image(row) & FILE_EXTENSION )
				port map(seqs_addrs(row), std_logic_vector(value) => seqs_mem_values( 4*(row-1) + frame) );
		end generate;
	end generate;

	muxers : for row in 1 to rowTot generate
		muxs : muxer_generic port map( std_logic_vector(to_unsigned(currentFrame, 2)), 
						seqs_mem_values( (row-1)*4 to (row-1)*4+3 ), 
						sequences_inputs(row-1) );
	end generate;

 	channels_generate : for i in 1 to n_channels generate
 		C : channel generic map(rowTot, colTot, kernelHeight, kernelWidth,
				completeRowTot, completeColTot,
				depth, memoryAddrDepth,
				i, -- ID
				main_dir,
				WEIGHTS_FILENAMES, RESULT_FILENAMES, ACTIVATED_FILENAMES,
				FILE_EXTENSION )
			port map(clk, frameReset or rst, done, currentFrame,
				sequences_inputs, weights_addr, channel_finished(i) );
 
 	end generate;

end architecture;

--############ Activation block #################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library thesis;
use thesis.bitArrays.all;
use thesis.fileFunctions.all;

entity activation_block is
	generic( in_depth, out_depth : positive );
	port( in_data : in std_logic_vector(1 to in_depth);
		out_data : out std_logic_vector(1 to out_depth) );
end activation_block;

architecture rectifier of activation_block is
	constant lsb : natural := in_depth-9;
	constant msb : natural := lsb-out_depth+1;
begin
	-- Assume the input signal is signed
	out_data <= in_data( msb to lsb ) when in_data(1) = '0' and or(in_data(2 to msb-1)) = '0' else
			(others => '1') when in_data(1) = '0' else -- saturation if out_depth is not enough
			(others => '0'); -- 0 if negative 

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
		WEIGHTS_FILENAMES, RESULT_FILENAMES, ACTIVATED_FILENAMES : string;
		FILE_EXTENSION : string );
	port( clk, rst : in std_logic;
		done : in std_logic; -- write to memory
		currentFrame : in  integer; 
		sequences_inputs : in std_logic_arr_t(0 to rowTot-1)(1 to depth);
		weights_addr : in unsigned(0 to memoryAddrDepth-1);
		write_finish : out std_logic );
end channel;

architecture channel of channel is
	constant res_depth : positive := word;

	signal result : std_logic_mat_t(0 to rowTot-1, 0 to ColTot-1)(1 to res_depth);
	signal activated : std_logic_mat_t(0 to rowTot-1, 0 to colTot-1)(1 to depth);
	signal weights_mem_value : signed(1 to depth); 
	signal weights_inputs : std_logic_arr_t(0 to colTot-1)(1 to depth); -- systolic array's column input
	
	signal completeActivated : std_logic_mat_t(0 to completeRowTot-1, 0 to completeColTot-1)(1 to depth);

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
	component activation_block is
		generic(in_depth : positive := res_depth;
			out_depth : positive := depth );
		port( in_data : in std_logic_vector(1 to in_depth);
			out_data : out std_logic_vector(1 to out_depth) );
	end component;
begin
	-------------------------------------------------------------- Write in memory
	WriteInMemory : process
		variable writeResult : boolean;
	begin
		wait until rising_edge(done);
		writeResult := writeMatrixContent(
			main_dir & ACTIVATED_FILENAMES & integer'image(ID) & FILE_EXTENSION,
			completeActivated,
			hexadecimal );
		write_finish <= '1';
		wait until falling_edge(done);
	end process;

	--------------------------------------------------------------- Memory management
	weightsMemory : rom generic map(filename => main_dir & WEIGHTS_FILENAMES & integer'image(ID) & FILE_EXTENSION )
			port map(weights_addr, weights_mem_value);

	partialMemoryWrite : process(rst)
		variable frame : integer;
	begin
		if currentFrame >= 1 and currentFrame <= 4 and rising_edge(rst) then 
		frame := currentFrame - 1;
		for i in activated'low(1) to activated'high(1) loop
			for j in activated'low(2) to activated'high(2) loop
				completeActivated(i + (frame / 2)*14, j + (frame mod 2) * 14 ) <= activated(i,j) after 0 ns;
			end loop;
		end loop;
		end if;
	end process;


	--------------------------------------------------------------- Systolic array and its inputs
	weightsIn : j_shift_register
			port map(clk, rst, std_logic_vector(weights_mem_value), weights_inputs);

	systolicArray : systolic_generic
			port map(clk, rst, weights_inputs, sequences_inputs, result);

	AB_rows : for i in 0 to rowTot-1 generate -- activation blocks and partial memory
		AB_cols : for j in 0 to colTot-1 generate 
			ab : activation_block port map(result(i,j), activated(i,j));
		end generate;
	end generate;
end architecture;

