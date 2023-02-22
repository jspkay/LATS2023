// N2D2 auto-generated file.
// @ Mon Sep 16 12:44:48 2019

#include "network.h"

//#define TIME_ANALYSIS
//#define DATA_DYN_ANALYSIS
//#define ACC_DYN_ANALYSIS
#define ACC_DYN_REPORT CHW

#include <stdlib.h>
#include <opts.h>
#include <errno.h>
#include <ctype.h>

static DATA_T conv1_data[CONV1_NB_OUTPUTS][CONV1_OUTPUTS_HEIGHT][CONV1_OUTPUTS_WIDTH];
static DATA_T pool1_data[POOL1_NB_OUTPUTS][POOL1_OUTPUTS_HEIGHT][POOL1_OUTPUTS_WIDTH];
static DATA_T conv2_data[CONV2_NB_OUTPUTS][CONV2_OUTPUTS_HEIGHT][CONV2_OUTPUTS_WIDTH];
static DATA_T pool2_data[POOL2_NB_OUTPUTS][POOL2_OUTPUTS_HEIGHT][POOL2_OUTPUTS_WIDTH];
static DATA_T conv3_data[CONV3_NB_OUTPUTS][CONV3_OUTPUTS_HEIGHT][CONV3_OUTPUTS_WIDTH];
static DATA_T fc1_data[FC1_NB_OUTPUTS];
DATA_T output_data[NB_OUTPUTS*OUTPUTS_HEIGHT*OUTPUTS_WIDTH]; 
static DATA_T output_spatial_data[NB_OUTPUTS][OUTPUTS_HEIGHT][OUTPUTS_WIDTH]; 

void network(DATA_T in_data[ENV_NB_OUTPUTS][ENV_SIZE_Y][ENV_SIZE_X], uint32_t out_data[OUTPUTS_HEIGHT][OUTPUTS_WIDTH]) {
#ifdef SAVE_OUTPUTS
    convcell_outputs_save("in_data.txt", ENV_NB_OUTPUTS, ENV_SIZE_Y, ENV_SIZE_X, in_data);
#endif

#ifdef TIME_ANALYSIS
    struct timeval start, end;
#endif
/************************************LAYER (1)***/
#ifdef TIME_ANALYSIS
   gettimeofday(&start, NULL);
#endif

if( OPT_SAVE_FIRST_LAYER_INPUT ){
	FILE *fp;

	DIR* dir = opendir(OPT_SFLI_DIR);
	if( errno == ENOENT ){
		fprintf(stderr, "Directory %s doesn't exist. Making the new dir\n", OPT_SFLI_DIR);
        exit(2);
	}

	char filename[100];

	// main sequence
	sprintf(filename, "./%s/HW_SIM_MAIN_SEQ.DAT", OPT_SFLI_DIR);
	fprintf(stderr, "Writing MAIN Image sequence file...");
	fp = fopen(filename, "w");
	if(fp == NULL) fprintf(stderr, "Error opening the file");
	int outputs=0;
	for(int j=0; j<ENV_SIZE_X; j++)
	    for(int k=0; k<CONV1_KERNEL_HEIGHT; k++){

	        fprintf(fp, "%d\n", in_data[outputs][k][j]);

	    }
	fclose(fp);
	fprintf(stderr, "OK\n");
    // Complete sequences
    fprintf(stderr, "Writing Image sequences files...");
    for(int seq=1; seq<CONV1_OX_SIZE; seq++){
        sprintf(filename, "./%s/HW_SIM_SEQ_%d.DAT", OPT_SFLI_DIR, seq+1);
        fp = fopen(filename, "w");
        if(fp == NULL) fprintf(stderr, "Error opening the file");

        for(int j=0; j<ENV_SIZE_X; j++)
            for(int k=seq; k<CONV1_KERNEL_HEIGHT+seq; k++){

                fprintf(fp, "%d\n", in_data[outputs][k][j]);

            }

        fclose(fp);
    }
    fprintf(stderr, "OK\n");

    // Reduced sequences
    fprintf(stderr, "Writing Image REDUCED sequences files...");
    for(int frame=0; frame<4; frame++) {

        for(int seq=0; seq<CONV1_OX_SIZE/2; seq++){
            sprintf(filename, "./%s/HW_SIM_RED_%d_SEQ_%d.DAT", OPT_SFLI_DIR, frame, seq+1);
            fp = fopen(filename, "w");
            if(fp == NULL) fprintf(stderr, "Error opening the file");

            int firstJ = frame%2 ? ENV_SIZE_X/2-CONV1_KERNEL_WIDTH/2 : 0;
            int lenghtJ = CONV1_OX_SIZE/2 + CONV1_KERNEL_WIDTH - 1;

            int firstK = frame/2 ? ENV_SIZE_Y/2-CONV1_KERNEL_HEIGHT/2 : 0;
            firstK += seq;

            for(int j=firstJ; j<firstJ+lenghtJ; j++)
                for(int k=firstK; k<CONV1_KERNEL_HEIGHT+firstK; k++){

                    fprintf(fp, "%d\n", in_data[outputs][k][j]);

                }

            fclose(fp);
        }
    }
	fprintf(stderr, "OK\n");
}

    // weights
    if(OPT_SAVE_WEIGHTS){
        char filename[100];
        FILE *fp;

        fprintf(stderr, "Writing Weights sequence file...");
        for(int f=0; f<CONV1_NB_OUTPUTS; f++) {
            sprintf(filename, "./%s/WEIGHTS_%d.DAT", OPT_SW_DIR, f + 1);
            DIR* dir = opendir(OPT_SW_DIR);
            if( errno == ENOENT ){
                fprintf(stderr, "Directory %s doesn't exist. Create the directory and run again!\n", OPT_SW_DIR);
                exit(2);
            }
            fp = fopen(filename, "w");
            if (fp == NULL){
                fprintf(stderr, "eheh, there was an error in opening the DAT file, ehehe\n");
                exit(3);
            }

            //fprintf(fp, "#ks\n%d %d\n", CONV1_KERNEL_HEIGHT, CONV1_KERNEL_WIDTH);
            //fprintf(fp, "#weights\n");Intel Starter FPGA Edition recommended capacity is 5000 non-OEM instances. There are 9490 non OEM instances. Expect performance to be severely impacted

            for (int i = 0; i < CONV1_OX_SIZE + CONV1_OY_SIZE; ++i) {
                WDATA_T w = 0;

                int j = i % CONV1_KERNEL_HEIGHT;
                int k = i / CONV1_KERNEL_WIDTH;

                if (j < CONV1_KERNEL_HEIGHT && k < CONV1_KERNEL_WIDTH) w = (*conv1_weights[f][0])[j][k];

                fprintf(fp, "%d\n", w);
            }
            fclose(fp);
        }
    }

    if( !OPT_FIRST_LAYER_FROM_FILE)
        convcell_upropagate(CONV1_NB_CHANNELS, CONV1_CHANNELS_HEIGHT, CONV1_CHANNELS_WIDTH, CONV1_PADDING_Y, CONV1_PADDING_X, CONV1_STRIDE_Y, CONV1_STRIDE_X, CONV1_SUB_SAMPLE_Y, CONV1_SUB_SAMPLE_X, in_data, CONV1_OY_SIZE, CONV1_OX_SIZE, CONV1_NB_OUTPUTS, CONV1_OUTPUTS_HEIGHT, CONV1_OUTPUTS_WIDTH, CONV1_NB_OUTPUTS, CONV1_OUTPUT_OFFSET, conv1_data, CONV1_KERNEL_HEIGHT, CONV1_KERNEL_WIDTH, conv1_biases, conv1_weights, CONV1_ACTIVATION, CONV1_SHIFT);
    else {
        char tmp_string[100];
        FILE *fp;
        for (int i = 0; i < CONV1_NB_OUTPUTS; i++) {
            sprintf(tmp_string, "%s/%s%d%s", OPT_FLFF_DIR, "HW_SIM_ACTIVATED_", i+1,".DAT");
            fp = fopen(tmp_string, "r");
            if(fp == NULL){
                if (fp == NULL){
                    fprintf(stderr, "eheh, there was an error in opening the DAT file (--first-layer-from-file)\n");
                    exit(3);
                }
            }

            int row = 0, col = 0;
            uint16_t c;
            uint16_t v = 0;
            while(!feof(fp)){
                c = fgetc(fp);
                if(c == ' '){
                    conv1_data[i][row][col] = *( (DATA_T*) &v);
                    col++;
                    v = 0;
                }
                else if(c == '\n'){
                    row++;
                    col = 0;
                }
                else if(isxdigit(c)){
                    v *= (DATA_T) 16;
                    if(c >= '0' && c <= '9') v = v + c - '0';
                    else if(c >= 'A' && c <= 'F') v += c-'A'+10;
                    else if(c >= 'a' && c <= 'f') v += c-'a'+10;
                }
            }
            fclose(fp);
        }
    }

    // activated outputs
    if(OPT_SAVE_FIRST_LAYER_OUTPUT){
        FILE *fp;
        char filename[100];

        fprintf(stderr, "Writing ACTIVATED... ");

        for( int output=0; output<CONV1_NB_OUTPUTS; output++) {
            sprintf(filename, "./%s/ACTIVATED_%d", OPT_SFLO_DIR, output+1);
            fp = fopen(filename, "w");
            if (fp == NULL) {
                fprintf(stderr, "Error opening the file. ");
                exit(-1);
            }

            for (int y = 0; y < CONV1_OY_SIZE; y++) {
                for (int x = 0; x < CONV1_OX_SIZE; x++) {
                    fprintf(fp, "%04hX ", conv1_data[output][y][x]);
                }
                fprintf(fp, "\n");
            }

            fclose(fp);
        }
        fprintf(stderr, "Done!\n");
    }

    // Exit if only first layer is requested
    if(OPT_ONLY_FIRST_LAYER){
        fprintf(stderr, "The program was ran with --only-first-layer option. The execution will stop now\n");
        exit(0);
    }


#ifdef TIME_ANALYSIS
    gettimeofday(&end, NULL);
    static RUNNING_MEAN_T conv1_timing = {0.0, 0};
    time_analysis("conv1", start, end, &conv1_timing);
#endif
#ifdef ACC_DYN_ANALYSIS
    static SUM_T conv1_acc_min = 0;
    static SUM_T conv1_acc_max = 0;
    static SUM_T conv1_presat_min = 0;
    static SUM_T conv1_presat_max = 0;
    convcell_propagate_accs_report("conv1", CONV1_NB_CHANNELS, CONV1_CHANNELS_HEIGHT, CONV1_CHANNELS_WIDTH, CONV1_PADDING_Y, CONV1_PADDING_X, CONV1_STRIDE_Y, CONV1_STRIDE_X, CONV1_SUB_SAMPLE_Y, CONV1_SUB_SAMPLE_X, in_data, CONV1_OY_SIZE, CONV1_OX_SIZE, CONV1_OUTPUTS_HEIGHT, CONV1_OUTPUTS_WIDTH, CONV1_NB_OUTPUTS, &conv1_acc_min, &conv1_acc_max, &conv1_presat_min, &conv1_presat_max, CONV1_KERNEL_HEIGHT, CONV1_KERNEL_WIDTH, conv1_biases, conv1_weights, ACC_DYN_REPORT);
#endif
#ifdef DATA_DYN_ANALYSIS
    static DATA_T conv1_min = DATA_T_MAX;
    static DATA_T conv1_max = DATA_T_MIN;
    static RUNNING_MEAN_T conv1_mean = {0.0, 0};
    convcell_outputs_dynamic_print("conv1", CONV1_NB_OUTPUTS, CONV1_OUTPUTS_HEIGHT, CONV1_OUTPUTS_WIDTH, conv1_data, &conv1_min, &conv1_max, &conv1_mean);
#endif
#ifdef SAVE_OUTPUTS
    convcell_outputs_save("conv1.txt", CONV1_NB_OUTPUTS, CONV1_OUTPUTS_HEIGHT, CONV1_OUTPUTS_WIDTH, conv1_data);
#endif
/************************************LAYER (2)***/
#ifdef TIME_ANALYSIS
   gettimeofday(&start, NULL);
#endif
    poolcell_upropagate_unitmap(POOL1_NB_CHANNELS, POOL1_CHANNELS_HEIGHT, POOL1_CHANNELS_WIDTH, POOL1_STRIDE_Y, POOL1_STRIDE_X, conv1_data, POOL1_NB_OUTPUTS, POOL1_OUTPUTS_HEIGHT, POOL1_OUTPUTS_WIDTH, POOL1_NB_OUTPUTS, POOL1_OUTPUT_OFFSET, pool1_data, POOL1_POOL_HEIGHT, POOL1_POOL_WIDTH, POOL1_POOLING, POOL1_ACTIVATION, POOL1_SHIFT);
#ifdef TIME_ANALYSIS
    gettimeofday(&end, NULL);
    static RUNNING_MEAN_T pool1_timing = {0.0, 0};
    time_analysis("pool1", start, end, &pool1_timing);
#endif
/************************************LAYER (3)***/
#ifdef TIME_ANALYSIS
   gettimeofday(&start, NULL);
#endif
    convcell_upropagate(CONV2_NB_CHANNELS, CONV2_CHANNELS_HEIGHT, CONV2_CHANNELS_WIDTH, CONV2_PADDING_Y, CONV2_PADDING_X, CONV2_STRIDE_Y, CONV2_STRIDE_X, CONV2_SUB_SAMPLE_Y, CONV2_SUB_SAMPLE_X, pool1_data, CONV2_OY_SIZE, CONV2_OX_SIZE, CONV2_NB_OUTPUTS, CONV2_OUTPUTS_HEIGHT, CONV2_OUTPUTS_WIDTH, CONV2_NB_OUTPUTS, CONV2_OUTPUT_OFFSET, conv2_data, CONV2_KERNEL_HEIGHT, CONV2_KERNEL_WIDTH, conv2_biases, conv2_weights, CONV2_ACTIVATION, CONV2_SHIFT);
#ifdef TIME_ANALYSIS
    gettimeofday(&end, NULL);
    static RUNNING_MEAN_T conv2_timing = {0.0, 0};
    time_analysis("conv2", start, end, &conv2_timing);
#endif
#ifdef ACC_DYN_ANALYSIS
    static SUM_T conv2_acc_min = 0;
    static SUM_T conv2_acc_max = 0;
    static SUM_T conv2_presat_min = 0;
    static SUM_T conv2_presat_max = 0;
    convcell_propagate_accs_report("conv2", CONV2_NB_CHANNELS, CONV2_CHANNELS_HEIGHT, CONV2_CHANNELS_WIDTH, CONV2_PADDING_Y, CONV2_PADDING_X, CONV2_STRIDE_Y, CONV2_STRIDE_X, CONV2_SUB_SAMPLE_Y, CONV2_SUB_SAMPLE_X, pool1_data, CONV2_OY_SIZE, CONV2_OX_SIZE, CONV2_OUTPUTS_HEIGHT, CONV2_OUTPUTS_WIDTH, CONV2_NB_OUTPUTS, &conv2_acc_min, &conv2_acc_max, &conv2_presat_min, &conv2_presat_max, CONV2_KERNEL_HEIGHT, CONV2_KERNEL_WIDTH, conv2_biases, conv2_weights, ACC_DYN_REPORT);
#endif
#ifdef DATA_DYN_ANALYSIS
    static DATA_T conv2_min = DATA_T_MAX;
    static DATA_T conv2_max = DATA_T_MIN;
    static RUNNING_MEAN_T conv2_mean = {0.0, 0};
    convcell_outputs_dynamic_print("conv2", CONV2_NB_OUTPUTS, CONV2_OUTPUTS_HEIGHT, CONV2_OUTPUTS_WIDTH, conv2_data, &conv2_min, &conv2_max, &conv2_mean);
#endif
#ifdef SAVE_OUTPUTS
    convcell_outputs_save("conv2.txt", CONV2_NB_OUTPUTS, CONV2_OUTPUTS_HEIGHT, CONV2_OUTPUTS_WIDTH, conv2_data);
#endif
/************************************LAYER (4)***/
#ifdef TIME_ANALYSIS
   gettimeofday(&start, NULL);
#endif
    poolcell_upropagate_unitmap(POOL2_NB_CHANNELS, POOL2_CHANNELS_HEIGHT, POOL2_CHANNELS_WIDTH, POOL2_STRIDE_Y, POOL2_STRIDE_X, conv2_data, POOL2_NB_OUTPUTS, POOL2_OUTPUTS_HEIGHT, POOL2_OUTPUTS_WIDTH, POOL2_NB_OUTPUTS, POOL2_OUTPUT_OFFSET, pool2_data, POOL2_POOL_HEIGHT, POOL2_POOL_WIDTH, POOL2_POOLING, POOL2_ACTIVATION, POOL2_SHIFT);
#ifdef TIME_ANALYSIS
    gettimeofday(&end, NULL);
    static RUNNING_MEAN_T pool2_timing = {0.0, 0};
    time_analysis("pool2", start, end, &pool2_timing);
#endif
/************************************LAYER (5)***/
#ifdef TIME_ANALYSIS
   gettimeofday(&start, NULL);
#endif
    convcell_upropagate(CONV3_NB_CHANNELS, CONV3_CHANNELS_HEIGHT, CONV3_CHANNELS_WIDTH, CONV3_PADDING_Y, CONV3_PADDING_X, CONV3_STRIDE_Y, CONV3_STRIDE_X, CONV3_SUB_SAMPLE_Y, CONV3_SUB_SAMPLE_X, pool2_data, CONV3_OY_SIZE, CONV3_OX_SIZE, CONV3_NB_OUTPUTS, CONV3_OUTPUTS_HEIGHT, CONV3_OUTPUTS_WIDTH, CONV3_NB_OUTPUTS, CONV3_OUTPUT_OFFSET, conv3_data, CONV3_KERNEL_HEIGHT, CONV3_KERNEL_WIDTH, conv3_biases, conv3_weights, CONV3_ACTIVATION, CONV3_SHIFT);
#ifdef TIME_ANALYSIS
    gettimeofday(&end, NULL);
    static RUNNING_MEAN_T conv3_timing = {0.0, 0};
    time_analysis("conv3", start, end, &conv3_timing);
#endif
#ifdef ACC_DYN_ANALYSIS
    static SUM_T conv3_acc_min = 0;
    static SUM_T conv3_acc_max = 0;
    static SUM_T conv3_presat_min = 0;
    static SUM_T conv3_presat_max = 0;
    convcell_propagate_accs_report("conv3", CONV3_NB_CHANNELS, CONV3_CHANNELS_HEIGHT, CONV3_CHANNELS_WIDTH, CONV3_PADDING_Y, CONV3_PADDING_X, CONV3_STRIDE_Y, CONV3_STRIDE_X, CONV3_SUB_SAMPLE_Y, CONV3_SUB_SAMPLE_X, pool2_data, CONV3_OY_SIZE, CONV3_OX_SIZE, CONV3_OUTPUTS_HEIGHT, CONV3_OUTPUTS_WIDTH, CONV3_NB_OUTPUTS, &conv3_acc_min, &conv3_acc_max, &conv3_presat_min, &conv3_presat_max, CONV3_KERNEL_HEIGHT, CONV3_KERNEL_WIDTH, conv3_biases, conv3_weights, ACC_DYN_REPORT);
#endif
#ifdef DATA_DYN_ANALYSIS
    static DATA_T conv3_min = DATA_T_MAX;
    static DATA_T conv3_max = DATA_T_MIN;
    static RUNNING_MEAN_T conv3_mean = {0.0, 0};
    convcell_outputs_dynamic_print("conv3", CONV3_NB_OUTPUTS, CONV3_OUTPUTS_HEIGHT, CONV3_OUTPUTS_WIDTH, conv3_data, &conv3_min, &conv3_max, &conv3_mean);
#endif
#ifdef SAVE_OUTPUTS
    convcell_outputs_save("conv3.txt", CONV3_NB_OUTPUTS, CONV3_OUTPUTS_HEIGHT, CONV3_OUTPUTS_WIDTH, conv3_data);
#endif
/************************************LAYER (6)***/
#ifdef TIME_ANALYSIS
   gettimeofday(&start, NULL);
#endif
    fccell_upropagate_2d(CONV3_NB_OUTPUTS, CONV3_OUTPUTS_HEIGHT, CONV3_OUTPUTS_WIDTH, conv3_data, FC1_NB_OUTPUTS, FC1_NB_OUTPUTS, FC1_OUTPUT_OFFSET, fc1_data, FC1_NB_CHANNELS, fc1_biases, fc1_weights, FC1_ACTIVATION, FC1_SHIFT);
#ifdef TIME_ANALYSIS
    gettimeofday(&end, NULL);
    static RUNNING_MEAN_T fc1_timing = {0.0, 0};
    time_analysis("fc1", start, end, &fc1_timing);
#endif
#ifdef DATA_DYN_ANALYSIS
    static DATA_T fc1_min = DATA_T_MAX;
    static DATA_T fc1_max = DATA_T_MIN;
    static RUNNING_MEAN_T fc1_mean = {0.0, 0};
    fccell_outputs_dynamic_print("fc1", FC1_NB_OUTPUTS, fc1_data, &fc1_min, &fc1_max, &fc1_mean);
#endif
#ifdef SAVE_OUTPUTS
    fccell_outputs_save("fc1.txt", FC1_NB_OUTPUTS, fc1_data);
#endif
/************************************LAYER (7)***/
#ifdef TIME_ANALYSIS
   gettimeofday(&start, NULL);
#endif
    fccell_upropagate(FC2_NB_CHANNELS, fc1_data, OUTPUTS_SIZE*NB_OUTPUTS, FC2_NB_OUTPUTS, FC2_OUTPUT_OFFSET, output_data, fc2_biases, fc2_weights, FC2_ACTIVATION, FC2_SHIFT);


    if(OPT_SAVE_PROB_VEC) {
        FILE * fp = fopen(OPT_SPV_FILENAME, "w");
        if(fp == NULL){
            fprintf(stderr, "Cannot open file %s. Exit.", OPT_SPV_FILENAME);
            exit(3);
        }
        for(int i=0; i<NB_OUTPUTS*OUTPUTS_HEIGHT*OUTPUTS_WIDTH; i++){
            fprintf(fp, "%d ", output_data[i]);
        }
        fclose(fp);

    }

#ifdef TIME_ANALYSIS
    gettimeofday(&end, NULL);
    static RUNNING_MEAN_T fc2_timing = {0.0, 0};
    time_analysis("fc2", start, end, &fc2_timing);
#endif
#ifdef DATA_DYN_ANALYSIS
    static DATA_T fc2_min = DATA_T_MAX;
    static DATA_T fc2_max = DATA_T_MIN;
    static RUNNING_MEAN_T fc2_mean = {0.0, 0};
    fccell_outputs_dynamic_print("fc2", FC2_NB_OUTPUTS, output_data, &fc2_min, &fc2_max, &fc2_mean);
#endif
#ifdef SAVE_OUTPUTS
    fccell_outputs_save("fc2.txt", FC2_NB_OUTPUTS, output_data);
#endif

    output_max(FC2_NB_OUTPUTS, output_data, out_data);
}
