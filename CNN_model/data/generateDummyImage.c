#include <stdio.h>
#include <stdlib.h>

int main(){
	FILE *fp = fopen("dummy.pgm", "w");

	fprintf(fp, "%s\n", "P5");
	fprintf(fp, "%s\n", "32 32");
	fprintf(fp, "%s\n", "255");

	char c;
	for(int i=0; i<32; i++){
		for(int j=0; j<32; j++){
			if( i < 5 ){
				c = (j*5 + i) % 255;
				fprintf(fp, "%c", c);
			}else{
				c = (i*10 + j) % 255;
				fprintf(fp, "%c", c);
			}
		}
	}
	// Label data
	for(int i=0; i<4; i++)	fprintf(fp, "%c", 0);
}
