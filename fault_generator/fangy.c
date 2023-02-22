#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <ctype.h>
#include <string.h>
#include <time.h>

#define HELP "Usage: fangy <fault_list> [Options]...\n"\
"\tfault_list indicate a file having a list of fault of the type /hierarchy/to/signal value\n"\
"\tvalue can be written using both VHDL and Verilog literals syntax.\n"\
"\tIt is also possibile to incorporate a random generation using the following notation: %r[lv-rv] where lv and rv"\
"represents the left-value (the smallest) and right-value (the biggest) to generate an INTEGER value between. So, "\
"if I specified %r[0-1] fangy will automatically generate a random integer between 0 and 1. It's possible to specify "\
"a seed, look at the options.\n"\
"NOTE: The extremes of the random generation are both included!"\
"\n"\
"Options:\n"\
"\t--help \tshow this help\n"\
"\t--version \tshow the version of fangy\n"\
"\t--output filename \tspecify the name for the output fault list. If not given, the default is \"output.ft\"\n"\
"\t--seed n \tspecify the seed for the random generation (by default uses time to be actually random).\n"\
"\t--stdout \tif present, stdout is used for the output. Option -output is ignored"

#define VERSION "0.2b"

#define MAX_LENGTH 1024
#define MAX_SIG_NAME 512
#define MAX_VALUE_LEN 100

void process_file(FILE *fin, FILE *fout);

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Errors in parameters!\n");
        printf("%s\n", HELP);
        return EXIT_FAILURE;
    }

    char *filename;
    char default_fn[] = "output.ft";
    char *out_filename = default_fn;
    int std_output = 0;

    int rng_seed = time(0);
    int fileFound = 0;
    for (int i = 1; i < argc; i++) {
        if (argv[i][0] != '-' || argv[i][1] != '-') {
            fileFound++;
            filename = argv[i];
            continue;
        }

        if (fileFound > 1) {
            fprintf(stderr, "Unrecognized argument %s\n", argv[i]);
            return EXIT_SUCCESS;
        }
        char *arg = argv[i] + 2;
        if (strcmp(arg, "help") == 0) {
            printf("%s\n", HELP);
            return EXIT_SUCCESS;
        } else if (strcmp(arg, "version") == 0) {
            printf("%s\n", VERSION);
            return EXIT_SUCCESS;
        } else if (strcmp(arg, "output") == 0) {
            out_filename = argv[++i];
        } else if (strcmp(arg, "seed") == 0) {
            rng_seed = atoi(argv[++i]);
        } else if (strcmp(arg, "stdout") == 0) {
            std_output=1;
        }else {
                fprintf(stderr, "Option %s malformed", argv[i]);
                return EXIT_FAILURE;
            }
        }

    FILE *f = fopen(filename, "r");
    if (f == NULL) {
        printf("Couldn't open file %s!\n", filename);
        return EXIT_FAILURE;
    }

    FILE *fout = std_output ? stdout : fopen(out_filename, "w");
    if (fout == NULL) {
        printf("Couldn't open output file %s!\n", out_filename);
        return EXIT_FAILURE;
    }

    srand(rng_seed);
    process_file(f, fout);
    return EXIT_SUCCESS;
}


int isodigit(char d) {
    int v = d - '0';
    return v >= 0 && v <= 8;
}

typedef struct hierarchy_struct {
    char obj[MAX_LENGTH];
    int len;
    struct hierarchy_struct *next;
    struct hierarchy_struct *prev;
} hierarchy_t;

typedef struct value_t {
    char val[MAX_VALUE_LEN];
    int len;
    enum val_type {
        BOTH, VHDL, VERILOG
    } type;
    int base;
    int size;
} value_t;

enum state_t {
    H_READ, // reading hierarchy
    PARENTHESIS,  // after any parenthesis we ignore any white space

    VALUE_READ, // reading the value for the hierarchy (decimal)
    VALUE_READ_VERILOG, // for verilog-like values
    VALUE_READ_VHDL, // for vhdl-like values
    /* The last three states are used to validate the type of the value */

    PRINT_STRING // we successufully parsed a single fault, so we output it now
};

void error(char *err_string) {
    fprintf(stderr, "%s\n", err_string);
    exit(-1);
}

hierarchy_t *make_hierarchy(hierarchy_t *prev) {
    hierarchy_t *tmp = (hierarchy_t *) malloc(sizeof(hierarchy_t));
    tmp->prev = prev;
    tmp->next = NULL;
    tmp->len = 0;
    return tmp;
}

void destroy_hierarchy(hierarchy_t *ptr) {
    assert(ptr != NULL);
    ptr->prev->next = NULL;
    free(ptr);
}

int generateRandom(FILE *fin, int current_line){
    // Random generation variables
    char tmp_str[100];
    int rng_lv, rng_rv, rng_value;

    int ret = fscanf(fin,"r[%d-%d]", &rng_lv, &rng_rv);
    if( ret == EOF ){
        sprintf(tmp_str, "There an error while parsing the random value (line %d)\n", current_line);
        error(tmp_str);
    }
    int dist = rng_rv - rng_lv + 1;
    rng_value = rand() % dist + rng_lv;
    return rng_value;
}

void process_file(FILE *fin, FILE *fout) {
    char current_token; // current token being processed
    int current_line = 1;

    char tmp_str[8 * MAX_LENGTH];
    hierarchy_t *hierarchy = make_hierarchy(NULL);
    hierarchy_t *current = hierarchy, *iter;

    value_t value;
    value.len = 0;
    value.size = 0;
    value.base = 0;
    value.type = BOTH;

    enum state_t state = PARENTHESIS;
    int depth = 0; // corresponds to the number of open parenthesis

    while (!feof(fin)) {
        current_token = fgetc(fin);

        if (current_token == '%') { // we are in random generation territory

        }

        switch (state) {
            case H_READ:
                switch (current_token) {
                    case '{': // we need to go deeper
                        depth++;
                        current->next = make_hierarchy(current);
                        current = current->next;
                        state = PARENTHESIS;
                        break;

                    case ' ': // after a bunch of spaces we expect a value
                    case '\t':
                        state = VALUE_READ;
                        break;

                    case '\n': // if new line, there's an error
                    case '\r':
                        sprintf(tmp_str, "unexpected %c. Currently reading hierarchy, no spaces allowed! (line %d)",
                                current_token,
                                current_line);
                        error(tmp_str);
                        break;

                    case '%': // Random number generation
                        value.base = generateRandom(fin, current_line); // We use value.base just not to allocate another variable.
                        value.len = sprintf(current->obj+current->len, "%d", value.base);
                        if( value.len < 0 ) error("Couldn't write output file!");
                        current->len += value.len;
                        break;

                    default: // add the new token
                        // Actually we should check if the charachter is legal... Here we just assume it is
                        current->obj[current->len++] = current_token;
                        break;

                }
                break;

            case PARENTHESIS:
                switch (current_token) {
                    case '\n': // new lines are allowed
                        current_line++;
                    case '\r':
                    case ' ': // spaces are allowed
                    case '\t':
                        break;

                    case '}': // done. wake up!
                        depth--;
                        current = current->prev;
                        destroy_hierarchy(current->next);
                        current->len = 0;
                        state = PARENTHESIS;
                        break;

                    default: // everything else indicates a new hierarchy level
                        state = H_READ;
                        current->obj[current->len++] = current_token;
                        break;
                }
                break;

            case VALUE_READ:
                if (current_token == ';') {
                    if (value.len > 0) {
                        state = PRINT_STRING;
                    } else error("value expected!");
                } else if (current_token == ' ' || current_token == '\t') {
                    // spaces before the value are allowed at will
                } else if (current_token == '%') { // Random number generation
                    value.base = generateRandom(fin, current_line); // We use value.base just not to allocate another variable.
                    value.len = sprintf(value.val, "%d", value.base);
                    if( value.len < 0 ) error("Couldn't write output file!");
                }else if (current_token == '\n' || current_token == '\r') {
                        sprintf(tmp_str, "New lines are illegal between values! (maybe you forgot a ';' at the end of the line?) (line %d)",
                                current_line);
                        error(tmp_str);
                } else if (isdigit(current_token)) {
                    value.val[value.len++] = current_token;

                    int v = current_token - '0';

                    value.base = value.base * 10 + v;

                    // only if Verilog syntax
                    value.size += v;
                } else if (current_token == '\'') {
                    value.val[value.len++] = current_token;
                    state = VALUE_READ_VERILOG;
                    value.type = VERILOG;
                    value.base = 0; // to be determined
                    // length is set already
                } else if (current_token == '#') {
                    value.val[value.len++] = current_token;
                    state = VALUE_READ_VHDL;
                    value.type = VHDL;
                    value.size = 0; // only for verilog syntax
                } else {
                    sprintf(tmp_str, "Unexpected charachter %c. Legal value expected. (line %d)",
                            current_token,
                            current_line);
                    error(tmp_str);
                }

                break;

            case VALUE_READ_VERILOG:
                if (value.base == 0) {
                    if (current_token == 's' || current_token == 'S') {
                        // ignored, modelsim doesn't like it
                    } else if (current_token == 'b' || current_token == 'B') value.base = 2;
                    else if (current_token == 'o' || current_token == 'O') value.base = 8;
                    else if (current_token == 'd' || current_token == 'D') value.base = 10;
                    else if (current_token == 'h' || current_token == 'H') value.base = 16;
                    else error("Error parsing veriog syntax literal. Wrong radix");
                } else if (current_token == '_') value.val[value.len++] = current_token;
                else if (value.base == 2 && (current_token == '0' || current_token == '1'))
                    value.val[value.len++] = current_token;
                else if (value.base == 10 && isdigit(current_token)) value.val[value.len++] = current_token;
                else if (value.base == 16 && isxdigit(current_token)) value.val[value.len++] = current_token;
                else if (value.base == 8 && isodigit(current_token)) value.val[value.len++] = current_token;
                else if (current_token == ';') state = PRINT_STRING;
                else error("Error parsing Verilog literal. Not a number (maybe you forgot a ';' at the end of the line?)");
                break;

            case VALUE_READ_VHDL:
                if (current_token == '_') value.val[value.len++] = current_token;
                else if (value.base == 2 && (current_token == '0' || current_token == '1'))
                    value.val[value.len++] = current_token;
                else if (value.base == 10 && isdigit(current_token)) value.val[value.len++] = current_token;
                else if (value.base == 16 && isxdigit(current_token)) value.val[value.len++] = current_token;
                else if (value.base == 8 && isodigit(current_token)) value.val[value.len++] = current_token;
                else if (current_token == '#' && value.val[value.len] != '#')
                    value.val[value.len++] = current_token;
                else if (current_token == ';') state = PRINT_STRING;
                else error("Error parsing VHDL literal. Not a number (maybe you forgot a ';' at the end of the line?)");
                break;

            case PRINT_STRING:
                current->obj[current->len++] = 0;
                ungetc(current_token, fin); // push character back
                iter = hierarchy;
                value.val[value.len++] = 0;
                sprintf(tmp_str, "");
                while (iter != NULL) {
                    strcat(tmp_str, iter->obj);
                    iter = iter->next;
                }
                fprintf(fout, "force -freeze %s %s;\n", tmp_str, value.val);

                // reset variables
                state = PARENTHESIS;
                current->len = 0;
                value.len = 0;
                value.type = 0;
                value.base = 0;
                value.size = 0;

                break;

            default:
                break;

        }


    }
}

