//----------------------------------------------------------------------
// openvpn.c
// OpenVPN Menu
//----------------------------------------------------------------------
#include "setup.h"

char *openvpn_funcs[] = {
    "option",
    "menu",
    "write",
    "refresh",
    NULL
};

enum { OPENVPN_OPTION, OPENVPN_MENU, OPENVPN_WRITE, OPENVPN_REFRESH, OPENVPN_NULL };

char *tunnel_sel=NULL;

//----------------------------------------------------------------------
// OPENVPN_OPTION
//----------------------------------------------------------------------
static int openvpn_option()
{
    otr(NULL);
    otd("<input type=\"image\" src=\"/buttons/plus.png\"\n\
	    name=\"cfg-openvpn\" alt=\"OpenVPN\">\n");
    otd("Configure OpenVPN");
    otr("/");
}


//----------------------------------------------------------------------
// OPENVPN_MENU
//----------------------------------------------------------------------
static int openvpn_menu()
{
    int fd, len=0;
    char **tunnel_list;
    char *tunnel_conf;

    sprintf(bigbuf,"%s/openvpn",globs.cfgdir);
    tunnel_list = get_file_chooser(bigbuf,tunnel_sel,"openvpn_sel","New Tunnel");
    if (tunnel_sel == NULL) {
	tunnel_sel = strdup(tunnel_list[1]);
    }

    sprintf(bigbuf,"%s/openvpn/%s",globs.cfgdir,tunnel_sel);
    fd = open(bigbuf,O_RDONLY);
    if (fd > 0) { // should never exceed 2048 bytes
	len = read(fd,bigbuf,2048);
	close(fd);
    }
    bigbuf[len]='\0';
    tunnel_conf = strdup(bigbuf);


    header("openvpn");

    out_refresh_script();

    oform(("POST", "/cgi-bin/setup", "formw"));
    ohid("last_menu","openvpn");
    ohid("j_click", "IGNORE");

    printf("<h3>OpenVPN Tunnel Configuration: %s</h3>",
	    !strcmp(tunnel_sel,"__new") ? "New Tunnel" : tunnel_sel);

    otbl(NULL);
    otr(NULL);
    oth("Tunnel");
    if (tunnel_sel[0] == 0 || strcmp(tunnel_sel,"__new") == 0) {
	otd(itext("openvpn_sel","New Tunnel",15,15));
    } else {
	otd(sel("onchange=\"send()\"", tunnel_list));
    }
    otr("/");
    otbl("/");

    printf("<textarea cols=30 rows=8 name=openvpn_conf>");
    printf("%s",tunnel_conf);
    printf("</textarea>\n");
    printf("<br>");
    printf("The contents of this file must be like as openvpn wants its normal config\
	    files (option=value, for help see 'openvpn --help', where it talks about\
		--option=value).\n");

    printf("<br><br>\n");
    ohid("menu","main");
    osub("f_click","OK");
    printf("&nbsp;&nbsp;&nbsp;\n");
    osub("f_click","CANCEL");
    oform(("/"));
}

//----------------------------------------------------------------------
// OPENVPN_WRITE
//----------------------------------------------------------------------
static void openvpn_write()
{
    char *tunnel_conf;
    int fd;

    tunnel_sel = getenv("CGI_openvpn_sel");
    if(tunnel_sel == NULL) {
	printf("CGI_openvpn_sel is NULL!\n");
	exit(0);
    }
    tunnel_conf = getenv("CGI_openvpn_conf");
    if (tunnel_conf == NULL) {
	printf("No config in write\n");
	exit(1);
    }

    umask(0077);
    sprintf(bigbuf,"[ ! -d %s/openvpn/ ] && mkdir -p %s/openvpn",
	    globs.cfgdir, globs.cfgdir);
    system(bigbuf);

    sprintf(bigbuf, "%s/openvpn/%s", globs.cfgdir, tunnel_sel);
    fd = open(bigbuf, O_WRONLY | O_CREAT, 0777);
    if (fd < 0) {
	printf("Open for write failed on %s\n", bigbuf);
	exit(1);
    }
    write(fd, tunnel_conf, strlen(tunnel_conf));
    close(fd);
}


//----------------------------------------------------------------------
// OPENVPN_REFRESH
//----------------------------------------------------------------------
static void openvpn_refresh()
{
    tunnel_sel = getenv("CGI_openvpn_sel");
    openvpn_menu();
    printf("</html>\n");
    exit(0);
}


//----------------------------------------------------------------------
// OPENVPN
//----------------------------------------------------------------------
int openvpn (char *arg)
{
    int ix;
    ix = argvindex(openvpn_funcs, arg, strcmp);
    switch(ix) {
	case OPENVPN_OPTION:
	    openvpn_option();
	    break;
	case OPENVPN_MENU:
	    openvpn_menu();
	    break;
	case OPENVPN_WRITE:
	    openvpn_write();
	    break;
	case OPENVPN_REFRESH:
	    openvpn_refresh();
	    break;
    }    
}
