#define MAIN
#include "setup.h"

#include "linked_functions.h"

#define NUM_CFGS 3
char *cfgdirs[] = {
    "../../../RW.example",
    "../../etc/conf",
    "../../etc/rw",
    NULL
};

char *f_click_values[] = {
    "OK",
    "REFRESH",
    "CANCEL",
    "RETURN",
    "SAVE",
    "GO",
    NULL
};

#define FC_OK 0
#define FC_REFRESH 1
#define FC_CANCEL 2
#define FC_RETURN 3
#define FC_SAVE 4
#define FC_GO 5
#define FC_NULL 6

char *header_values[] = {
    "save",
    "status",
    NULL
};
#define HEADER_SAVE 0
#define HEADER_STATUS 1
#define HEADER_NULL 2

//--------------------------------------------------------------------
// FETCH_RUNLEVEL
//--------------------------------------------------------------------
char *fetch_runlevel() {
    int chan;
    sprintf(bigbuf,"%s/%s",globs.cfgdir,"runlevel");
    chan = open(bigbuf,O_RDONLY);
    read(chan,bigbuf,10);
    close(chan);
    bigbuf[1] = 0;
    chan = atoi(bigbuf);
    sprintf(bigbuf,"%d", chan);
    return(strdup(bigbuf));
}


//--------------------------------------------------------------------
// HEADER
//--------------------------------------------------------------------
header(char *which) {
    int ix;

    printf("Content-Type: text/html\n\n");

    printf("<! CFGDIR=%s>\n", globs.cfgdir == NULL ? "UNSET" : globs.cfgdir);
    ix = argvindex(header_values,which,strcmp);
    switch(ix) {
      case HEADER_SAVE:
        printf("<META HTTP-EQUIV=REFRESH CONTENT=\"70; URL=/index.html\">\n");
        printf("<html>\n");
        printf("<body background=/linuxap.png>\n");
        printf("<center>\n");
        printf("<h2>SAVING CONFIGURATION</h2>\n");
        printf("</center>\n");
        printf("<hr>\n");
        break;

      case HEADER_STATUS:
        printf("\
<META HTTP-EQUIV=REFRESH CONTENT=\"30; URL=/cgi-bin/setup?cfg-status.\">\n\
<html>\n\
<body background=/linuxap.png>\n\
<center>\n\
<h2>Current <i>wlan0</i> Status</h2>\n\
</center>\n\
<hr>\n");
        break;

      default:
        printf("<html>\n");
        printf("<body background=/linuxap.png>\n");
        printf("<center>\n");
        printf("<h2>linuxAP-eh Setup Screen</h2>\n");
        printf("</center>\n");
        printf("<hr>\n");
    }
}


//--------------------------------------------------------------------
// MENU
//--------------------------------------------------------------------
menu() {
    char *runlevel;
    int (*func)();
    int i;

    runlevel = fetch_runlevel();
    oform(("post","/cgi-bin/setup",NULL));
    otbl(NULL);
    otr(NULL);
    oth("Running As");
    {
        char *rl[] = {
        "runlevel", runlevel,
        "Station/Router (RL 2)", "2",
        "AP/Bridge (RL 3)", "3",
        "AP/Router (RL 4)", "4",
        NULL};
        otd(sel("",rl));
    }
    otr("/");
    otbl("/");
    puts("<br>");
    ohid("last_menu","top");
    osub("f_click","OK");
    printf("<br><br>Select Configuration Item\n");
    otbl(NULL);
    for(i = 0 ; linked_functions[i] != NULL; i++) {
        func = linked_functions[i];
        (*func)("option");
    }
    otbl("/");
    printf("<br>Click SAVE to save configuration changes and reboot<br>\n");
    osub("f_click","SAVE");
    oform(("/",NULL));
    printf("</body></html>\n");
}


//----------------------------------------------------------------------
// PARSE_QUERY
//----------------------------------------------------------------------
int parse_query()
{
    char *q=NULL, *p, *p1, *p2;

    p = getenv("CGI_ARGLIST_");
    if(p == NULL) {
        globs.cfg = NULL;
        return(1);
    }
    q = strdup(p);
    p = p1 = q;
    while(*p){
        while(*p && *p != ' ') p++;
        p2 = p;
        if(*p) *p++ = 0;
        if(strncmp(p1, "cfg-", 4) == 0) {
            while(p2 > p1 && *p2 != '.') p2--;
            *p2 = 0;
            globs.cfg = strdup(p1 + 4);
        }
        p1 = p;
    }
    free(q);
    return(1);
}

//--------------------------------------------------------------------
// DISPATCH
// Dispatch to the module function
//--------------------------------------------------------------------
dispatch(char *what) {
    int ix;
    void (*func)();

    ix = argvindex(linked_names, globs.cfg, strcmp);
    debug(1,"DEBUG: dispatch(%s)=linked_names[%s]=%s",what,globs.cfg,linked_names[ix]);
    if(linked_names[ix] == NULL) {
        header("menu");
        menu();
        exit(0);
    }
    func = linked_functions[ix];
    (*func)(what);
}


//--------------------------------------------------------------------
// TOP
// Top Level Dispatch routine, only write.
//--------------------------------------------------------------------
int top(char *arg) {
    int chan;
    char *v;

    if(strcmp(arg,"write")) return;

    sprintf(bigbuf,"%s/runlevel", globs.cfgdir);
    chan = open(bigbuf,O_WRONLY | O_CREAT |O_TRUNC, 0777);
    if(chan == -1) {
        return;
    }
    v = getenv("CGI_runlevel");
    if(v == NULL) {
        return;
    }
    sprintf(bigbuf,"%s\n", v);
    write(chan, bigbuf, strlen(bigbuf));
    close(chan);
}


//----------------------------------------------------------------------
// SAVE_CONFIG
//----------------------------------------------------------------------
int save_config() {
    header("save");
    printf("<pre>\n");
    system("/bin/save_config");
    printf("</pre>\n");
    printf("<h3><center><blink>\n");
    printf("Rebooting, takes about 60 seconds\n");
    printf("</blink></center></h3></html>\n");
    system("/sbin/reboot");
    sleep(10);
}


//--------------------------------------------------------------------
// MAIN
//--------------------------------------------------------------------
main()
{
    struct stat sb;
    int i,ix;
    char *f_click;
    
    debug(1,"DEBUG: +++");

    parse_query();
    for(i=0; i < NUM_CFGS; i++) {
        if(stat(cfgdirs[i],&sb) == 0) {
            break;
	}
    }
    globs.cfgdir = cfgdirs[i];
    debug(1,"DEBUG: globs.cfgdir=%s",globs.cfgdir);
// Look for the Java Applet
    f_click = getenv("CGI_j_click");
    if(f_click == NULL || strcmp(f_click, "IGNORE") == 0) {
        f_click = getenv("CGI_f_click");
    }
    debug(1,"DEBUG: f_click=%s",f_click);
    if(f_click != NULL) {
        globs.cfg = getenv("CGI_last_menu");
        ix = argvindex(f_click_values, f_click, strcmp);
	debug(1,"DEBUG: ix=%d",ix);
        switch(ix) {
          case FC_GO:
            break;
          case FC_CANCEL:
          case FC_RETURN:
            globs.cfg = NULL;
            break;
          case FC_REFRESH:
            dispatch("refresh");
            break;
          case FC_SAVE:
            save_config();
	    exit(0);
            break;
          case FC_OK:
            dispatch("write");
            globs.cfg = NULL;
            break;
        }
    }
    if(globs.cfg == NULL) {
        header("menu");
        menu();
        exit(0);
    } else {
        dispatch("menu");
    }
}
