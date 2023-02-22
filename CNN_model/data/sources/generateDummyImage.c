#include <stdio.h>
#include <stdlib.h>

int main(){
	FILE *fp = fopen("dummy.pgm", "w");

	fprintf(fp, "%s\n", "P5");
	fprintf(fp, "%s\n", "32 32");

	int maxvalue = 65535; // or 255
	fprintf(fp, "%d\n", maxvalue);

	union{
		char c[2];
		int d;
	} value;

	for(int i=0; i<32; i++){
		for(int j=0; j<32; j++){
			if( i < 5 ){
				value.d = (j*5 + i) % maxvalue;
				// assuming little-endian
				if(maxvalue > 255)
					for(int k=0; k<2; k++) fprintf(fp, "%c", value.c[k]);
				else fprintf(fp, "%c", value.c[1]);
			}else{
				value.d = (i*10 + j) % maxvalue;
				if(maxvalue > 255)
					for(int k=0; k<2; k++) fprintf(fp, "%c", value.c[k]);
				else fprintf(fp, "%c", value.c);
			}
		}
	}
	// Label data
	for(int i=0; i<4; i++)	fprintf(fp, "%c", 0);
}
