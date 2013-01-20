//----------------------------------------------------------------------
// status.c
//----------------------------------------------------------------------
#include "setup.h"

char *status_funcs[] = {
    "option",
    "menu",
    "write",
    NULL
};
#define STATUS_OPTION 0
#define STATUS_MENU 1
#define STATUS_WRITE 2
#define STATUS_NULL 3

//----------------------------------------------------------------------
// STATUS_OPTION
//----------------------------------------------------------------------
static int status_option()
{
    otr(NULL);
    otd("<input type=\"image\" src=\"/buttons/plus.png\"\n\
	    name=\"cfg-status\" alt=\"Status\">\n");
    otd("AP/Station Status Information");
    otr("/");

}


//----------------------------------------------------------------------
// STATUS_MENU
//----------------------------------------------------------------------
static int status_menu() {
    FILE *f;
    int chan, len;
    int uptime, upx, hours, minutes, seconds, days;
    char *p;

    header("status");
    printf("<pre>\n");
    fflush(stdout);
    // Wlan status
    system("[ -x /usr/sbin/iwconfig ] && /usr/sbin/iwconfig wlan0");
    system("[ -x /sbin/ifconfig ] && /sbin/ifconfig");
    // Uptime
    chan = open("/proc/uptime",O_RDONLY);
    if(chan != -1) {
	len = read(chan,bigbuf,1024);
	bigbuf[len] = 0;
	for(p = bigbuf; *p != 0 && isspace(*p) == 0; p++);
	*p = 0;
	uptime = atoi(bigbuf);
	close(chan);
    } else {
	uptime = 0;
    }
    days = uptime / 86400;
    upx = uptime % 86400;
    hours = upx / 3600;
    upx = uptime % 3600;
    minutes = upx / 60;
    seconds = upx % 60;
    printf("UP: %d + %02d:%02d:%02d (%d)\n\n",
	    days, hours, minutes, seconds, uptime);
    // Meminfo
    chan = open("/proc/meminfo",O_RDONLY);
    if(chan != -1) {
	len = read(chan,bigbuf,2048);
	bigbuf[len] = 0;
	printf("%s",bigbuf);
	close(chan);
    }
    printf("</pre>\n");
    printf("\
	    <form method=\"POST\" action=\"/cgi-bin/setup\">\n\
	    <input type=\"submit\" name=\"submit\" value=\"RETURN\">\n\
	    </form>\n");
}


//----------------------------------------------------------------------
// STATUS
//----------------------------------------------------------------------
int status(char *arg)
{
    int ix;
    ix = argvindex(status_funcs, arg, strcmp);
    //    printf("called status w/arg = %s\n", arg); exit(0);
    switch(ix) {
	case STATUS_OPTION:
	    status_option();
	    break;
	case STATUS_MENU:
	    status_menu();
	    break;
	case STATUS_WRITE:
	    break;
    }    
}
