entity tb is end tb;
architecture tb of tb is 
	constant rows : positive := 28;
	constant cols : positive := 28;
	constant kerR : positive := 5;
	constant kerC : positive := 5;
	constant depth : positive := 8;

	constant n_channels : positive := 1; --6;

	constant main_dir : string := "./data/HW_SIM_FILES/";

	constant MAIN_SEQ_FILENAME : string := "HW_SIM_MAIN_SEQ";
	constant OTHER_SEQS_FILENAMES : string := "HW_SIM_SEQ_";
	constant WEIGHTS_FILENAMES : string := "WEIGHTS_";
	constant RESULT_FILENAMES : string := "HW_SIM_OUTPUT_";
	constant ACTIVATED_FILENAMES : string := "HW_SIM_ACTIVATED_";
	constant FILE_EXTENSION : string := ".DAT";
	
	component conv_layer is
		generic( rowTot, colTot : positive;
			kernelHeight, kernelWidth : positive;
			depth : positive := depth;
			n_channels : positive; --output channels
			main_dir : string;
			MAIN_SEQ_FILENAME, OTHER_SEQS_FILENAMES, WEIGHTS_FILENAMES : string;
			RESULT_FILENAMES, ACTIVATED_FILENAMES : string;
			FILE_EXTENSION : string );
	end component;
begin
	CL : conv_layer generic map(rows, cols, kerR, kerC, 
				depth, n_channels, main_dir,
				MAIN_SEQ_FILENAME, OTHER_SEQS_FILENAMES, WEIGHTS_FILENAMES,
				RESULT_FILENAMES, ACTIVATED_FILENAMES,
				FILE_EXTENSION
				);
end architecture;

