#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <ctype.h>

//#define DEBUG 1

char usage[] = "Usage: activate input output\n"
;

int main(int argv, char **argc){
	if( argv != 3){
		fprintf(stdout, "%s", usage);
		return 2;
	}

	int foundDiff = 0;
	FILE *fp, *fout;
	fp = fopen(argc[1], "r");
	fout = fopen(argc[2], "w");
	if(fp == NULL || fout == NULL){
		fprintf(stdout,"Error opening files!\n");
		return 4;
	}

	int row=0, col=0;
	char v[100] = {0};
	int vi=0;
	int32_t value;
	uint8_t activated_value;
	char c;
	while( !feof(fp) ){
		fscanf(fp, "%c", &c);

		switch(c){
			case ' ':
				// Activate the value
				sscanf(v, "%x", &value);		
				if(value < 0) activated_value = 0;
				else{
					value >>= 9;
					if( value > 0xFF ) activated_value = 0xFF;
					else activated_value = value;
				}
				
				fprintf(fout, "%02hhX ", activated_value);

				// The compiler automatically optimizes if these functions are not needed
				bzero(v, sizeof(v));
				vi = 0;

				col++;
				break;
			case '\n':
				row++;
				col = 0;
				fprintf(fout, "\n");
				break;
			default:
				if( !isxdigit(c) ){
					fprintf(stderr, "Non-hex digit found!");
					return 3;
				}
				v[vi++] = c;
				break;
		}

	}
	fclose(fp);
	fclose(fout);
	return 0;
}
