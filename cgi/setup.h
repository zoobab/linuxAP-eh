#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <fcntl.h>
#include <stdio.h>

struct globals {
    char *cfgdir;
    char *cfg;
    char *host;
};

#define otf(s) puts(s); free(s)

#ifndef BIGBUF_SIZE
#define BIGBUF_SIZE 4096
#endif

#ifndef MAIN
extern struct globals globs;
extern char bigbuf[BIGBUF_SIZE];
#else
struct globals globs;
char bigbuf[BIGBUF_SIZE];
#endif

// Input Functions
char *form(char *method, ...);
//char *itext(char *name, char *value, int size);
char *itext(char *name, char *value, int size, int maxlength);
char *ihid(char *name, char *value);
char *isub(char *name, char *value);
#define oform(x) otf(form x)
#define otext(a,b,c,d) otf(otext(a,b,c,d))
#define ohid(a,b) otf(ihid(a,b))
#define osub(a,b) otf(isub(a,b))

// Table Functions
char *tabl(char *s1);
#define otbl(s) otf(tabl(s))
char *td(char *s1);
#define otd(s) otf(td(s))
char *th(char *s1);
#define oth(s) otf(th(s))
char *tr(char *s1);
#define otr(s) otf(tr(s))
char *sel(char *flags, char **list);

// Utility Functions
#define out_refresh_script() \
	do { printf("<SCRIPT LANGUAGE=\"javascript\">\n\
	             function send() {\n\
		     document.formw.j_click.value=\"REFRESH\";\n\
		     document.formw.submit()\n\
		     }\n\
		     </SCRIPT>\n"); } while(0)
#define out_config(num, f, ckw, pkw) \
	do { char *val=getenv(pkw[num]); \
	     fprintf(f,"%s%s\n",ckw[num],!val ? "" : val); } while(0)
char **get_file_chooser (char *dirname, char *value, char *keyword, char *newmsg);
int read_cfg (char *filename, char *keywords[], char *values[]);
void read_cfg_value (char *keywords[], char *values[], char *line);
char *retrieve_cfg_value(char **keywords, int ix, char *line);
int readline(FILE *f, char *buffer, int size);
int argvindex(char **haystack, char *needle, int (*strfunc)());

// Interfaces
#ifdef CONFIG_CIPE
int cipe(char *arg);
#endif
#ifdef CONFIG_OPENVPN
int openvpn(char *arg);
#endif
#ifdef CONFIG_KERNEL_AODV
int kaodv(char *arg);
#endif
int top(char *arg);
int network(char *arg);
int udhcpd(char *arg);
int telnetd(char *arg);
int status(char *arg);
int wlan(char *arg);
int httpd(char *arg);

#ifdef DEBUG
#define debug(lvl,args...) \
	do { syslog(lvl,##args); } while(0)
#else
#define debug(lvl,args...) \
	do { ; } while(0)
#endif
