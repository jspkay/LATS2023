#ifndef OPTS_H
#define OPTS_H

extern char usage[];

extern int OPT_ONLY_FIRST_LAYER,
	OPT_FIRST_LAYER_FROM_FILE,
	OPT_SAVE_FIRST_LAYER_OUTPUT,
	OPT_SAVE_FIRST_LAYER_INPUT,
    OPT_SAVE_WEIGHTS,
    OPT_SAVE_PROB_VEC;
extern char *OPT_SFLO_DIR,
	*OPT_FLFF_DIR,
	*OPT_SFLI_DIR,
    *OPT_SW_DIR,
    *OPT_SPV_FILENAME;

#endif //OPTS_H
