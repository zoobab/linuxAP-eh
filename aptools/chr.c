#define NOVAL   1
#define BADVAL  2

main(argc,argv)
int     argc;
char    *argv[];
{
    register char   *p;
    register int    mult;
    int    chr;
    int    i;

    if(argc < 2) exit(NOVAL);
    for(i = 1; i < argc; i++) {
        chr = 0;
        mult = 10;
        p = argv[i];
        if(*p == '%') {
            p++;
            mult=16;
        };
        while(*p) {
            if(*p >= '0' && *p <= '9') {
                chr = (chr * mult) + (*p - '0');
            } else if ( mult == 16 && (*p & 0xdf) >= 'A' && (*p & 0xdf) <= 'F') {
                chr = (chr * mult) + (10 + ( (*p & 0xdf) - 'A' ));
            } else {
                exit(BADVAL);
            }
            p++;
        }
        putchar(chr);
    }
    exit(0);
}
