//----------------------------------------------------------------------
// cipe.c
// Cipe Menu
//----------------------------------------------------------------------
#include "setup.h"
#include "dirent.h"

char *cipe_funcs[] = {
    "option",
    "menu",
    "write",
    "refresh",
    NULL
};

enum { CIPE_OPTION, CIPE_MENU, CIPE_WRITE, CIPE_REFRESH, CIPE_NULL };

static struct cipe_vars {
    char *host;
    char *ipaddr;
    char *ptpaddr;
    char *peer;
    char *port;

    char *ping;
    char *cttl;
    char *key;
} cv;

static char *cipe_keywords[] = {
    "host",
    "ipaddr",
    "ptpaddr",
    "peer",
    "ping",
    "cttl",
    "key",
    NULL
};
#define CKW_HOST 0
#define CKW_IPADDR 1
#define CKW_PTPADDR 2
#define CKW_PEER 3
#define CKW_PING 4
#define CKW_CTTL 5
#define CKW_KEY 6


//----------------------------------------------------------------------
// CIPE_OPTION
//----------------------------------------------------------------------
static int cipe_option()
{
    otf(tr(NULL));
    otf(
	    td("<input type=\"image\" src=\"/buttons/plus.png\"\n\
		name=\"cfg-cipe\" alt=\"CIPE\">\n")
       );
    otf(td("Configure CIPE Tunnel Interfaces"));
    otf(tr("/"));
}


//----------------------------------------------------------------------
// GET_PEERS
//----------------------------------------------------------------------
static char **get_peers() {
    DIR *dirp;
    struct dirent *entry;
    char **p, **q, *first;
    int buflen;

    first = NULL;
    p = (char **)bigbuf;
    sprintf(bigbuf,"%s/cipe/peers", globs.cfgdir);
    dirp = opendir(bigbuf);
    //	printf("Peers: bigbuf %s is %s\n", bigbuf, dirp == NULL ? "Closed" : "Open"); exit(0);	
    // Copy in the field name && default
    *p++ = strdup("c_host");
    buflen += sizeof(char *);
    // q is Placeholder for default value
    q = p++; *q = NULL;
    buflen += sizeof(char *);
    if(dirp != NULL) {
	while((entry = readdir(dirp)) != NULL) {
	    if(entry->d_name[0] == '.') continue;
	    *p++ = strdup(entry->d_name);
	    buflen += sizeof(char *);
	    *p++ = strdup(entry->d_name);
	    buflen += sizeof(char *);
	    if(first == NULL) first = *(p-1);
	}
	closedir(dirp);
    }
    *p++ = strdup("New Host");
    buflen += sizeof(char *);
    *p++ = strdup("__new");
    buflen += sizeof(char *);
    *p++ = NULL;
    // Now set the default value
    if(cv.host != NULL) {
	*q = strdup(cv.host);
    } else if (first != NULL) {
	*q = strdup(first);
    } else {
	*q = strdup("__new");
    }
    buflen = p - (char **)bigbuf;
    //	printf("Peers: bigbuf len=%d\n", buflen); exit(0);
    // And malloc & copy the pointers for the char ** array;
    q = malloc(buflen * sizeof(char *));
    memcpy(q, bigbuf, buflen *sizeof(char *));
    return(q);
}

//----------------------------------------------------------------------
// READ_PEER
//----------------------------------------------------------------------
static int read_peer(char *peer) {
    FILE *f;
    int ix,x;

    //	printf("Read Peer: %s\n", peer); exit(0);	
    if(peer == NULL) return(0);
    sprintf(bigbuf,"%s/cipe/peers/%s", globs.cfgdir, peer);
    f = fopen(bigbuf,"r");
    if(f == NULL) return(0);
    while(fgets(bigbuf, 4096, f) != NULL) {
	//		printf("%s\n",bigbuf);
	ix = argvindex(cipe_keywords,bigbuf,strncmp);
	switch(ix) {
	    case CKW_HOST:
		cv.host = retrieve_cfg_value(cipe_keywords,ix, bigbuf);
		break;
	    case CKW_IPADDR:
		cv.ipaddr = retrieve_cfg_value(cipe_keywords, ix, bigbuf);
		break;
	    case CKW_PTPADDR:
		cv.ptpaddr = retrieve_cfg_value(cipe_keywords, ix, bigbuf);
		break;
	    case CKW_PEER:
		cv.peer = retrieve_cfg_value(cipe_keywords, ix, bigbuf);
		x = strcpos(cv.peer,':');
		if(x > -1) {
		    cv.port = cv.peer + x + 1;
		    cv.peer[x] = 0;
		}
		break;
	    case CKW_PING:
		cv.ping = retrieve_cfg_value(cipe_keywords, ix, bigbuf);
		break;
	    case CKW_CTTL:
		cv.cttl = retrieve_cfg_value(cipe_keywords, ix, bigbuf);
		//			printf("cttl caught with value = %s\n", cv.cttl); exit(0);
		break;
	    case CKW_KEY:
		cv.key = retrieve_cfg_value(cipe_keywords, ix, bigbuf);
		break;
	}
    }
    fclose(f);
    return(1);
}

//----------------------------------------------------------------------
// CIPE_MENU
//----------------------------------------------------------------------
static int cipe_menu()
{
    char **peer_list;

    //printf("cipe menu\n");exit (0);
    peer_list = get_peers();
    if(cv.host == NULL) {
	cv.host = strdup(peer_list[1]);
    }
    read_peer(cv.host);

    header("cipe");
    printf("<SCRIPT LANGUAGE=\"javascript\">\n\
	    function send() {\n\
	    document.forma.j_click.value=\"REFRESH\";\n\
	    document.forma.submit()\n\
	    }\n\
	    </SCRIPT>\n");
	    otf(form("POST", "/cgi-bin/setup", "forma", NULL));
	    otf(ihid("last_menu", "cipe"));
	    otf(ihid("j_click", "IGNORE"));
	    printf("<h3>CIPE Tunnel Configuration %s</h3>\n",
		    strcmp(cv.host,"__new") == 0 ? "New Host" : cv.host);
	    otf(tabl(NULL));
	    otf(tr(NULL));
	    otf(th("Host"));
	    if ( cv.host[0] == 0 || strcmp(cv.host,"__new") == 0) {
		otf(td(itext("c_host", "New", 15, 15)));
	    } else {	
		otf(td(sel("onchange=\"send()\"", peer_list)));
	    }
	    otf(tr("/"));

	    otf(tr(NULL));
	    otf(th("Our IP Address"));
	    otf(td(itext("c_ipaddr", cv.ipaddr == NULL ? "" : cv.ipaddr, 17,40)));
	    otf(tr("/"));

	    otf(tr(NULL));
	    otf(th("PTP IP Address"));
	    otf(td(itext("c_ptpaddr", cv.ptpaddr == NULL ? "" : cv.ptpaddr, 17,40)));
	    otf(tr("/"));

	    otf(tr(NULL));
	    otf(th("Peer Real IP Address"));
	    otf(td(itext("c_peer", cv.peer == NULL ? "" : cv.peer, 17,40)));
	    otf(tr("/"));

	    otf(tr(NULL));
	    otf(th("Peer UDP Port"));
	    otf(td(itext("c_port", cv.port == NULL ? "" : cv.port, 6, 5)));
	    otf(tr("/"));

	    otf(tr(NULL));
	    otf(th("Keep Alive Timer"));
	    otf(td(itext("c_ping", cv.ping == NULL ? "" : cv.ping , 6, 5)));
	    otf(tr("/"));

	    otf(tr(NULL));
	    otf(th("CIPE TTL Value"));
	    // printf("cv.cttl is |%s|\n", cv.cttl); exit(0);
	    {
		char *ttl_list[] = {
		    "c_cttl", cv.cttl == NULL ? "64" : cv.cttl,
		    "32","32","64","64","96","96","128","128",
		    NULL
		};
		otf(td(sel("",ttl_list)));
	    }

	    otf(tr(NULL));
	    otf(th("Key (32 Hex Digits)"));
	    otf(td(itext("c_key", cv.key == NULL ? "" : cv.key, 40, 32)));
	    otf(tr("/"));

	    otf(tabl("/"));

	    otf(ihid("menu","main"));
	    osub("f_click","OK");
	    printf("&nbsp;&nbsp;&nbsp;\n");
	    osub("f_click","CANCEL");

	    form("/");
}


//----------------------------------------------------------------------
// CIPE_REFRESH
//----------------------------------------------------------------------
static int cipe_refresh() {
    cv.host = getenv("CGI_c_host");
    //    printf("refresh host = %s\n", cv.host); exit(0);
    cipe_menu();
    printf("</html>\n");
    exit(0);
}


//----------------------------------------------------------------------
// CIPE_WRITE
//----------------------------------------------------------------------
cipe_write()
{
    FILE *f;

    umask(0077);
    cv.host = getenv("CGI_c_host");
    sprintf(bigbuf,"[ ! -d %s/cipe/peers ] && mkdir -p %s/cipe/peers",
	    globs.cfgdir, globs.cfgdir);
    system(bigbuf);

    sprintf(bigbuf,"%s/cipe/peers/%s", globs.cfgdir, cv.host);
    f = fopen(bigbuf,"w");
    // printf("scribble to %s is %s\n", bigbuf, f == NULL ? "Fail" : "Open"); exit(0);
    if(f == NULL) {
	return(-1);
    }
    fprintf(f, "#\n");
    fprintf(f, "# %s\n", cv.host);
    fprintf(f, "#\n");
    fprintf(f, "ipaddr  %s\n", getenv("CGI_c_ipaddr"));
    fprintf(f, "ptpaddr %s\n", getenv("CGI_c_ptpaddr"));
    fprintf(f, "peer    %s:%s\n",getenv("CGI_c_peer"), getenv("CGI_c_port"));
    fprintf(f, "cttl    %s\n", getenv("CGI_c_cttl"));
    fprintf(f, "dynip   1\n");
    fprintf(f, "ping    60\n");
    fprintf(f, "maxerr  2\n");
    fprintf(f, "mtu     1500\n");
    fprintf(f, "key     %s\n", getenv("CGI_c_key"));
    fclose(f);
}

//----------------------------------------------------------------------
// CIPE
// Main Dispatcher
//----------------------------------------------------------------------
int cipe(char *what) {
    int ix;

    // printf("cipe(%s)\n", what); exit(0);

    ix = argvindex(cipe_funcs,what,strcmp);

    switch(ix) {
	case CIPE_OPTION:
	    cipe_option();
	    break;
	case CIPE_WRITE:
	    cipe_write();
	    break;
	case CIPE_REFRESH:
	    cipe_refresh();
	    exit(0);		
	    // Drop thru
	case CIPE_MENU:
	    cipe_menu();
	    break;
    }
}
