//----------------------------------------------------------------------
// wlan.c
//----------------------------------------------------------------------
#include "setup.h"
#include "dirent.h"

static char *wlan_funcs[] = {
    "option",
    "menu",
    "write",
    NULL
};

enum { WLAN_OPTION, WLAN_MENU, WLAN_WRITE, WLAN_NULL };

enum { WLK_ESSID, WLK_SECURITY, WLK_CHANNEL, WLK_ANTSEL_RX, WLK_ANTSEL_TX,
       WLK_RATE, WLK_TXPOWER, WLK_WEP, WLK_NWDS, WLK_NULL };

char *wckw[WLK_NULL+1] = {
	"essid=",
	"security=",
	"channel=",
	"antsel_rx=",
	"antsel_tx=",
	"rate=",
	"txpower=",
	"wep=",
	"nwds=",
	NULL
};

char *wpkw[WLK_NULL+1] = {
	"CGI_essid",
	"CGI_security",
	"CGI_channel",
	"CGI_antsel_rx",
	"CGI_antsel_tx",
	"CGI_rate",
	"CGI_txpower",
	"CGI_wep",
	"CGI_nwds",
	NULL
};

char *wkw[WLK_NULL+1] = {
	"essid",
	"security",
	"channel",
	"antsel_rx",
	"antsel_tx",
	"rate",
	"txpower",
	"wep",
	"nwds",
	NULL
};

char *wv[WLK_NULL+1] = {
	"",
	"",
	"",
	"",
	"",
	"",
	"auto",
	"",
	"",
	NULL
};

static char *interface_sel;


//----------------------------------------------------------------------
// WLAN_OPTION
//----------------------------------------------------------------------
static int wlan_option()
{
    otr(NULL);
    otd("<input type=\"image\" src=\"/buttons/plus.png\"\n\
	    name=\"cfg-wlan\" alt=\"Wireless\">\n");
    otd("Configure Wireless Interfaces");
    otr("/");
}


//----------------------------------------------------------------------
// WLAN_MENU
//----------------------------------------------------------------------
static int wlan_menu() {
    char **interface_list;
    char *filename;

    sprintf(bigbuf,"%s/wlan", globs.cfgdir);
    interface_sel = getenv("CGI_interface_sel");
    interface_list = get_file_chooser(bigbuf,interface_sel,"interface_sel","New Interface");
    if(interface_sel == NULL) {
	interface_sel = strdup(interface_list[1]);
    }

    sprintf(bigbuf,"wlan/%s", interface_sel);
    filename = strdup(bigbuf);
    read_cfg(filename,wckw,wv);
    free(filename);


    header("wlan");

    out_refresh_script();

    oform(("POST", "/cgi-bin/setup", "formw"));
    ohid("last_menu","wlan");
    ohid("j_click", "IGNORE");

    printf("<h3>Wireless Configuration Options</h3>\n");

    otbl(NULL);

    otr(NULL);
    oth("Wireless Interface");
    if (interface_sel[0] == 0 || strcmp(interface_sel,"__new") == 0) {
	otd(itext("interface_sel", "New Interface", 15, 15));
    } else {	
	otd(sel("onchange=\"send()\"", interface_list));
    }
    otr("/");

    otr(NULL);
    oth("Station ID (ESSID)");
    otd(itext(wkw[WLK_ESSID], wv[WLK_ESSID], 15, 12));
    otr("/");

    otr(NULL);
    oth("Security options (*)");
    {
	char *sec_sel[] = {
	    wkw[WLK_SECURITY], wv[WLK_SECURITY],
	    "None",                             "0",
	    "Hide SSID in beacon frames",       "1",
	    "Ignore clients with \"ANY\" SSID", "2",
	    "Both",                             "3",
	    NULL };
	    otd(sel("",sec_sel));
    }
    otr("/");

    otr(NULL);
    oth("Channel");
    {
	char *chan_sel[] = {
	    wkw[WLK_CHANNEL], wv[WLK_CHANNEL],
	    "Chan 1", "1",
	    "Chan 2", "2",
	    "Chan 3", "3",
	    "Chan 4", "4",
	    "Chan 5", "5",
	    "Chan 6", "6",
	    "Chan 7", "7",
	    "Chan 8", "8",
	    "Chan 9", "9",
	    "Chan 10", "10",
	    "Chan 11", "11",
	    "Chan 12", "12",
	    "Chan 13", "13",
	    NULL };
	    otd(sel("",chan_sel));
    }
    otr("/");

    otr(NULL);
    oth("Antenna Select RX");
    {
	char *aslr_list[] = {
	    wkw[WLK_ANTSEL_RX], wv[WLK_ANTSEL_RX],
	    "Default", "0", "Diversity", "1", "Low", "2", "High", "3",
	    NULL };
	    otd(sel("",aslr_list));
    }
    otr("/");

    otr(NULL);
    oth("TX");
    {
	char *aslt_list[] = {
	    wkw[WLK_ANTSEL_TX], wv[WLK_ANTSEL_TX],
	    "Default", "0", "Diversity", "1", "Low", "2", "High", "3",
	    NULL };
	    otd(sel("",aslt_list));
    }
    otr("/");

    otr(NULL);
    oth("Data Rate");
    {
	char *rate_list[] = {
	    wkw[WLK_RATE], wv[WLK_RATE],
	    "auto", "auto", "11Mb", "11Mb", "5Mb", "5Mb", "2Mb", "2Mb", "1Mb", "1Mb",
	    NULL };
	    otd(sel("",rate_list));
    }
    otr("/");

    otr(NULL);
    oth("Transmit Power");
    otd(itext(wkw[WLK_TXPOWER], wv[WLK_TXPOWER], 5, 4));
    otr("/");

    otr(NULL);
    oth("WEP Key<br>0x0x-0x0x-0x0x-0x0x-0x0x-0x0x-0x");
    otd(itext(wkw[WLK_WEP], wv[WLK_WEP], 40, 32));
    otr("/");

    otr(NULL);
    oth("Number of WDS Entries (AP Mode)");
    otd(itext(wkw[WLK_NWDS], wv[WLK_NWDS], 4, 2));
    otr("/");

    otbl("/");

    printf("(*) This option requires STA f/w ver 1.6.3 or newer\n");

    printf("<br><br>\n");
    ohid("menu","main");
    osub("f_click","OK");
    printf("&nbsp;&nbsp;&nbsp;\n");
    osub("f_click","CANCEL");
    oform(("/"));
}


//----------------------------------------------------------------------
// WLAN_WRITE
//----------------------------------------------------------------------
static int wlan_write() {
    FILE *f;
    int i;
    char **p, *q;

    interface_sel = getenv("CGI_interface_sel");
    if(interface_sel == NULL) {
	printf("CGI_interface_sel is NULL!\n");
	exit(0);
    }

    umask(0077);
    sprintf(bigbuf,"[ ! -d %s/wlan/ ] && mkdir -p %s/wlan",
	    globs.cfgdir, globs.cfgdir);
    system(bigbuf);

    sprintf(bigbuf,"%s/wlan/%s", globs.cfgdir, interface_sel);
    f = fopen(bigbuf,"w");
    if(f == NULL) {
	printf("Error Opening %s\n",bigbuf);
	exit(0);
	return(-1);
    }

    fprintf(f, "#\n# %s\n#\n", interface_sel);
    for (i=0; i < WLK_NULL; i++)
	out_config(i,f,wckw,wpkw);

    fclose(f);
}

//----------------------------------------------------------------------
// WLAN
//----------------------------------------------------------------------
int wlan(char *arg)
{
    int ix;
    ix = argvindex(wlan_funcs, arg, strcmp);
    // printf("call wlan arg = %s\n", arg); exit(0);
    switch(ix) {
	case WLAN_OPTION:
	    wlan_option();
	    break;
	case WLAN_MENU:
	    wlan_menu();
	    break;
	case WLAN_WRITE:
	    wlan_write();
	    break;
    }    
}
