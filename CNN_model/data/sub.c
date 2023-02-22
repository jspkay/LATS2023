#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <ctype.h>

//#define DEBUG 1

char usage[] = "Usage: sub file1 file2\n"
"Return values:\n"
"\t0 - The files are equal\n"
"\t1 - There is at least one difference\n"
"\t2 - Not enough argument for the program\n"
"\t3 - The file have different formatting\n"
"\t4 - Error opening at least one of the two files\n"
;

int main(int argv, char **argc){
	if( argv != 3){
		fprintf(stdout, "%s", usage);
		return 2;
	}

	int foundDiff = 0;
	FILE *fp1, *fp2;
	fp1 = fopen(argc[1], "r");
	fp2 = fopen(argc[2], "r");
	if(fp1 == NULL || fp2 == NULL){
		fprintf(stdout,"Error opening files!\n");
		return 4;
	}

	int row = 0, col = 0;
	char v1[100] = {0}, v2[100] = {0};
	int v1i=0, v2i=0;
	char c1, c2;
	enum {VALUE, CHARACTER} state = 0;
	while( !feof(fp1) && !feof(fp2) ){
		fscanf(fp1, "%c", &c1);
		fscanf(fp2, "%c", &c2);

		if(c1 != c2 && !isxdigit(c1) && !isxdigit(c2) ){
			fprintf(stderr, "There is a difference in the format of the two files (%d %d)", row, col);
			return 3;
		}

		switch(c1){
			case ' ':
				// compare the values
				if(v1i != 0 && strncmp(v1, v2, 100) != 0 ){
					fprintf(stdout, "Difference found! %s | %s (%d %d)\n", v1, v2, row, col);
					foundDiff = 1;
				}	
				
				// The compiler automatically optimizes if these functions are not needed
				bzero(v1, sizeof(v1));
				bzero(v2, sizeof(v2));
				v1i = 0;
				v2i = 0;

				col++;
				break;
			case '\n':
				row++;
				col = 0;
				break;
			default:
				if( !isxdigit(c1) ){
					fprintf(stderr, "Non-hex digit found!");
					return 3;
				}
				v1[v1i++] = c1;
				v2[v2i++] = c2;
				break;
		}

	}
	if(foundDiff){
		return 1;
	}
	fprintf(stdout, "No difference found! =D\n");
	return 0;
}
