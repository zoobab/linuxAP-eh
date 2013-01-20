#include <stdio.h>
#include <stdlib.h>

void usage(void) {
	printf("usage: image_mm bzImage major# minor#\n");
}

int main ( int argc, char *argv[] ) {
	char *image = NULL;
	int major = 0;
	int minor = 0;
	FILE *bzImage = NULL;

	if (argc < 4) {	usage(); return 1; }
		
	image = argv[1];
	major = atoi(argv[2]);
	minor = atoi(argv[3]);

	bzImage = fopen(image, "r+");
	if (! bzImage) {
		printf("error opening bzImage\n");
		return -1;
	}
	fseek(bzImage, 0x1FC, SEEK_SET);
	fwrite(&minor, sizeof(char), 1, bzImage);
	fwrite(&major, sizeof(char), 1, bzImage);
	fclose(bzImage);
	return 0;
}
