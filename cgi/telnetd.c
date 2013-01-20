//----------------------------------------------------------------------
// telnetd.c
//----------------------------------------------------------------------
#include "setup.h"

char *telnetd_funcs[] = {
    "option",
    "menu",
    "write",
    NULL
};
#define TELNETD_OPTION 0
#define TELNETD_MENU 1
#define TELNETD_WRITE 2
#define TELNETD_NULL 3

static int telnetd_option()
{
    otr(NULL);
    otd("<input type=\"image\" src=\"/buttons/plus.png\"\n\
	    name=\"cfg-telnetd\" alt=\"Telnetd\">\n");
    otd("Configure telnet server access");
    otr("/");

}

static int telnetd_menu() {
    int chan,len;
    char *thosts;

    sprintf(bigbuf,"%s/telnetd.hosts", globs.cfgdir);
    chan = open(bigbuf, O_RDONLY);
    //printf("open of %s returns %d\n", bigbuf, chan);
    if(chan != -1) {
	// This should *never* exceed, but . . .
	len = read(chan, bigbuf, 2048);
	//printf("read %d chars\n",len);
	bigbuf[len] = 0;
	//printf("bigbuf = %s\n", bigbuf);
	close(chan);
    } else {
	bigbuf[0] = 0;
    }
    thosts = strdup(bigbuf);
    header("telnetd");
    oform(("POST","/cgi-bin/setup",NULL));
    ohid("last_menu","telnetd");
    printf("<h3>TELNETD Hosts list</h3>\n");
    printf("<textarea cols=30 rows=8 name=telnetd_hosts>");
    printf("%s", thosts);
    printf("</textarea>\n");
    ohid("menu","main");
    printf("<br><br>\n");
    osub("f_click","OK");
    printf("&nbsp;&nbsp;&nbsp;\n");
    osub("f_click","CANCEL");

    oform(("/"));
}

static int telnetd_write() {
    char *tlist;
    int chan;

    tlist = getenv("CGI_telnetd_hosts");
    if(tlist == NULL) {
	printf("No list in write\n");
	exit(1);
    }

    sprintf(bigbuf,"%s/telnetd.hosts", globs.cfgdir);
    chan = open(bigbuf, O_WRONLY | O_CREAT, 0777);
    if (chan == -1) {
	printf("Open for write failed on %s\n", bigbuf);
	exit(1);
    }
    write(chan, tlist, strlen(tlist));
    close(chan);
}

int telnetd(char *arg)
{
    int ix;
    ix = argvindex(telnetd_funcs, arg, strcmp);
    switch(ix) {
	case TELNETD_OPTION:
	    telnetd_option();
	    break;
	case TELNETD_MENU:
	    telnetd_menu();
	    break;
	case TELNETD_WRITE:
	    telnetd_write();
	    break;
    }    
}
