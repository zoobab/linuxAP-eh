//----------------------------------------------------------------------
// httpd.c
// HTTPD Menu
//----------------------------------------------------------------------
#include "setup.h"

char *httpd_funcs[] = {
    "option",
    "menu",
    "write",
    NULL
};

#define HTTPD_OPTION 0
#define HTTPD_MENU 1
#define HTTPD_WRITE 2
#define HTTPD_NULL 4

//----------------------------------------------------------------------
// HTTPD_OPTION
//----------------------------------------------------------------------
static int httpd_option()
{
    otr(NULL);
    otd("<input type=\"image\" src=\"/buttons/plus.png\"\n\
	    name=\"cfg-httpd\" alt=\"HTTPD\">\n");
    otd("Configure Http Daemon");
    otr("/");
}


//----------------------------------------------------------------------
// HTTPD_MENU
//----------------------------------------------------------------------
static int httpd_menu()
{
    int fd, len=0;
    char *httpd_conf;

    sprintf(bigbuf,"%s/httpd.conf",globs.cfgdir);
    fd = open(bigbuf,O_RDONLY);
    if (fd > 0) { // should never exceed 2048 bytes
	len = read(fd,bigbuf,2048);
	close(fd);
    }
    bigbuf[len]='\0';
    httpd_conf = strdup(bigbuf);

    header("httpd");
    oform(("POST","/cgi-bin/setup",NULL));
    ohid("last_menu","httpd");
    printf("<h3>Http Daemon Config File</h3>");
    printf("<textarea cols=30 rows=8 name=httpd_conf>");
    printf("%s",httpd_conf);
    printf("</textarea>\n");
    printf("<br>");
    printf("<h4>Allow/Deny:</h4>");
    printf("Format:");
    printf("<br>[AD]:ip -> allow (A) or deny (D) an ip");
    printf("<br>- first char is case unsensitive");
    printf("<br>- A:172.2.0 -> Allow any address that begins with 172.20");
    printf("<br>- A:10.20 -> Allow any address that previous set and 10.200-209.X.X");
    printf("<br>Logic:");
    printf("<br>- Default is to allow all.  No addresses are denied unless denied with a D: rule.");
    printf("<br>- Order of Deny/Allow rules is significant");
    printf("<br>- Deny rules take precedence over allow rules.");
    printf("<br>- If a deny all rule (D:*) is used it acts as a catch-all for unmatched addresses.");
    printf("<br>- Specification of Allow all (A:*) is a no-op");
    printf("<h4>Password requirements:</h4>");
    printf("Format:");
    printf("<br>/cgi-bin:foo:bar -> Require user foo, pwd bar on urls starting with /cgi-bin/");
    printf("<h4>Additional mime-types:</h4>");
    printf("Format:");
    printf("<br>.au:audio/basic -> additional mime type for audio.au files");
    ohid("menu","main");
    printf("<br><br>\n");
    osub("f_click","OK");
    printf("&nbsp;&nbsp;&nbsp;\n");
    osub("f_click","CANCEL");
    oform(("/"));
}


//----------------------------------------------------------------------
// HTTPD_WRITE
//----------------------------------------------------------------------
static int httpd_write()
{
    char *httpd_conf;
    int fd;

    httpd_conf = getenv("CGI_httpd_conf");
    if (httpd_conf == NULL) {
	printf("No config in write\n");
	exit(1);
    }

    sprintf(bigbuf, "%s/httpd.conf", globs.cfgdir);
    fd = open(bigbuf, O_WRONLY | O_CREAT, 0664);
    if (fd < 0) {
	printf("Open for write failed on %s\n", bigbuf);
	exit(1);
    }
    write(fd, httpd_conf, strlen(httpd_conf));
    close(fd);
}

//----------------------------------------------------------------------
// HTTPD
// Main Dispatcher
//----------------------------------------------------------------------
int httpd (char *what)
{
    int ix;
    ix = argvindex(httpd_funcs,what,strcmp);

    switch(ix) {
	case HTTPD_OPTION:
	    httpd_option();
	    break;
	case HTTPD_WRITE:
	    httpd_write();
	    break;
	case HTTPD_MENU:
	    httpd_menu();
	    break;
    }
}
