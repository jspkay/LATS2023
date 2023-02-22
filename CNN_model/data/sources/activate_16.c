#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <ctype.h>

//#define DEBUG 1

char usage[] = "Usage: activate input output\n";

int64_t read_64bit_value(char *buffer, int len){
	char c;
	int64_t res = 0;
	for(int i=0; i<len; i++){
		c = buffer[i];
		if(c <= '9' && c >= '0'){
			res += c - '0';
		}
		else if(c >= 'A' && c <= 'F'){
			res += c - 'A' + 10;
		}
		else if(c >= 'a' && c <= 'f'){
			res += c - 'a' + 10;
		}
		else{
			printf("ERROR!!! WRONG FORMAT!!!\n");
			exit(-1);
		}
		res <<= 4;
	}
	return res;
}

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
	int64_t value;
	uint16_t activated_value;
	char c;
	while( !feof(fp) ){
		fscanf(fp, "%c", &c);

		switch(c){
			case ' ':
				value = read_64bit_value(v, vi);
				if(value < 0) activated_value = 0;
				else{
					value >>= 22;
					if(value > 0xFFFF) activated_value = 0xFFFF;
					else activated_value = value;
				}
				fprintf(fout, "%04lX ", activated_value);

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
					fprintf(stderr, "Non-hex digit found!\n");
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
