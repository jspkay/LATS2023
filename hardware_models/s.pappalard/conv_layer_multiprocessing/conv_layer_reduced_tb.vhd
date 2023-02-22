entity tb is end tb;
architecture tb of tb is 
	constant rows : positive := 28;
	constant cols : positive := 28;
	constant completeRows : positive := 28;
	constant completeCols : positive := 28;
	constant kerR : positive := 5;
	constant kerC : positive := 5;
	constant depth : positive := 8;

	constant n_channels : positive := 1;

	constant main_dir : string := "./work_juliett/HW_SIM_FILES/";

	constant SEQS_FILENAMES : string := "HW_SIM_SEQ_";
	constant WEIGHTS_FILENAMES : string := "WEIGHTS_";
	constant RESULT_FILENAMES : string := "HW_SIM_OUTPUT_";
	constant FILE_EXTENSION : string := ".DAT";
	
	component conv_layer_reduced is
		generic( rowTot, colTot : positive;
			kernelHeight, kernelWidth : positive;
			completeRowTot, completeColTot : positive;
			depth : positive := depth;
			n_channels : positive; --output channels
			main_dir : string;
			SEQS_FILENAMES, WEIGHTS_FILENAMES : string;
			RESULT_FILENAMES: string;
			FILE_EXTENSION : string );
	end component;
begin
	CL : conv_layer_reduced generic map(rows, cols, kerR, kerC, 
				completeRows, completeCols,
				depth, n_channels, main_dir,
				SEQS_FILENAMES, WEIGHTS_FILENAMES,
				RESULT_FILENAMES, 
				FILE_EXTENSION
				);
end architecture;

