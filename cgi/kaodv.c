//----------------------------------------------------------------------
// kaodv.c
// Kernel AODV Menu
//----------------------------------------------------------------------
#include "setup.h"

char *kaodv_funcs[] = {
    "option",
    "menu",
    "write",
    "refresh",
    NULL
};

enum { KAODV_OPTION, KAODV_MENU, KAODV_WRITE, KAODV_REFRESH, KAODV_NULL };

enum { KV_KAODV, KV_KAODV_GW, KV_KAODV_LO, KV_KAODV_IF, KV_KAODV_BL,
       KV_KAODV_GW_GIF, KV_KAODV_GW_AIF, KV_KAODV_GW_SUBNET, KV_NULL };

char *kckw[KV_NULL+1] = {
    "kaodv=",
    "kaodv_gw=",
    "kaodv_lo=",
    "kaodv_if=",
    "kaodv_bl=",
    "kaodv_gw_gif=",
    "kaodv_gw_aif=",
    "kaodv_gw_subnet=",
    NULL
};

char *kpkw[KV_NULL+1] = {
    "CGI_kaodv",
    "CGI_kaodv_gw",
    "CGI_kaodv_lo",
    "CGI_kaodv_if",
    "CGI_kaodv_bl",
    "CGI_kaodv_gw_gif",
    "CGI_kaodv_gw_aif",
    "CGI_kaodv_gw_subnet",
    NULL
};

char *kkw[KV_NULL+1] = {
    "kaodv",
    "kaodv_gw",
    "kaodv_lo",
    "kaodv_if",
    "kaodv_bl",
    "kaodv_gw_gif",
    "kaodv_gw_aif",
    "kaodv_gw_subnet",
    NULL
};

char *kv[KV_NULL+1] = {
    "disabled",
    "disabled",
    "disabled",
    "wlan0",
    "eth0",
    "eth0",
    "eth0",
    "10.0.1.0",
    NULL
};

char *kaodv_gw_sel=NULL;


//----------------------------------------------------------------------
// KAODV_OPTION
//----------------------------------------------------------------------
static int kaodv_option()
{
    otr(NULL);
    otd("<input type=\"image\" src=\"/buttons/plus.png\"\n\
	    name=\"cfg-kaodv\" alt=\"KAODV\">\n");
    otd("Configure Kernel AODV");
    otr("/");
}


//----------------------------------------------------------------------
// KAODV_MENU
//----------------------------------------------------------------------
static int kaodv_menu()
{
    read_cfg("kaodv",kckw,kv);

    if (kaodv_gw_sel != NULL)
	kv[KV_KAODV_GW] = kaodv_gw_sel;

    header("kaodv");

    out_refresh_script();

    oform(("POST ","/cgi-bin/setup", "formw"));
    ohid("last_menu","kaodv");
    ohid("j_click", "IGNORE");

    printf("<h3>General Setup</h3>\n");

    otbl(NULL);

    otr(NULL);
    oth("Use Kernel AODV");
    {
	char *kaodv_sel[] = {
	    kkw[KV_KAODV], kv[KV_KAODV],
	    "Enabled", "enabled", "Disabled", "disabled",
	    NULL };
	    otd(sel("",kaodv_sel));
    }
    otr("/");

    otr(NULL);
    oth("Kernel AODV Mode");
    printf("Gateway mode redirects traffic from AODV enabled interface to the exterior (internet) through the gatewaying interface\n");
    {
	char *kaodv_gw_sel[] = {
	    kkw[KV_KAODV_GW], kv[KV_KAODV_GW],
	    "Gateway Mode", "enabled", "Normal Mode", "disabled",
	    NULL };
	    otd(sel("onchange=\"send()\"",kaodv_gw_sel));
    }
    otr("/");

    otr(NULL);
    oth("Use loopback Interface");
    {
	char *kaodv_lo_sel[] = {
	    kkw[KV_KAODV_LO], kv[KV_KAODV_LO],
	    "Enabled", "enabled", "Disabled", "disabled",
	    NULL };
	    otd(sel("",kaodv_lo_sel));
    }
    otr("/");

    otbl("/");

    printf("<br>\n");

    if (strcmp(kv[KV_KAODV_GW],"disabled") == 0)  {
	printf("<h3>Normal Mode Setup</h3>\n");

	otbl(NULL);

	otr(NULL);
	oth("Kernel AODV Interfaces (*)");
	otd(itext(kkw[KV_KAODV_IF],kv[KV_KAODV_IF],18,15));
	otr("/");

	otr(NULL);
	oth("Block Kernel AODV Interfaces' Hello Messages");
	otd(itext(kkw[KV_KAODV_BL],kv[KV_KAODV_BL],18,15));
	otr("/");

	otbl("/");

	printf("(*) Sepparated by commas\n");
	printf("<br>&nbsp;&nbsp;&nbsp;&nbsp;If no interfaces present, will use all\n");

	{ // hide the rest of values
	    int i;
	    for (i=KV_KAODV_GW_GIF; i < KV_NULL; i++)
		ohid(kkw[i],kv[i]);
	}
    } else {
	printf("<h3>Gatewaying Mode Setup</h3>");

	otbl(NULL);

	otr(NULL);
	oth("Gatewaying Interface (*)");
	otd(itext(kkw[KV_KAODV_GW_GIF],kv[KV_KAODV_GW_GIF],18,15));
	otr("/");

	otr(NULL);
	oth("Kernel AODV Interface");
	otd(itext(kkw[KV_KAODV_GW_AIF],kv[KV_KAODV_GW_AIF],18,15));
	otr("/");

	otr(NULL);
	oth("AODV Subnet (use 0's as wildcards)");
	otd(itext(kkw[KV_KAODV_GW_SUBNET],kv[KV_KAODV_GW_SUBNET],18,15));
	otr("/");

	otbl("/");

	printf("(*) Will disable Hello Messages\n");
	{ // hide the rest of values
	    int i;
	    for (i=KV_KAODV_IF; i < KV_KAODV_GW_GIF; i++)
		ohid(kkw[i],kv[i]);
	}
    }

    printf("<br><br>\n");
    ohid("menu","main");
    osub("f_click","OK");
    printf("&nbsp;&nbsp;&nbsp;\n");
    osub("f_click", "CANCEL");
    oform(("/"));
}

//----------------------------------------------------------------------
// KAODV_WRITE
//----------------------------------------------------------------------
static void kaodv_write()
{
    FILE *f;

    sprintf(bigbuf,"%s/kaodv", globs.cfgdir);
    f = fopen(bigbuf,"w");
    if(f == NULL) {
	printf("Error Opening %s\n",bigbuf);
	exit(0);
    }

    fprintf(f,"#\n# kaodv\n#\n");

    fprintf(f,"\n\
# Use Kernel AODV\n");
    out_config(KV_KAODV,f,kckw,kpkw);

    fprintf(f,"\n\
# Use internet gatewaying mode\n");
    out_config(KV_KAODV_GW,f,kckw,kpkw);

    fprintf(f,"\n\
# Use loopback\n");
    out_config(KV_KAODV_LO,f,kckw,kpkw);

    fprintf(f,"\n\
# NORMAL MODE\n");

    fprintf(f,"\n\
# AODV interfaces sparated by commas,\
# if no interfaces present, will use all\n");
    out_config(KV_KAODV_IF,f,kckw,kpkw);

    fprintf(f,"\n\
# Block interfaces' Hello Messages\n");
    out_config(KV_KAODV_BL,f,kckw,kpkw);

    fprintf(f,"\n\
# GATEWAY MODE\n");

    fprintf(f,"\n\
# Gatewaying interface\
# (will disable hello sending)\n");
    out_config(KV_KAODV_GW_GIF,f,kckw,kpkw);

    fprintf(f,"\n\
# AODV interface\n");
    out_config(KV_KAODV_GW_AIF,f,kckw,kpkw);

    fprintf(f,"\n\
# AODV subnet (0's as wildcards)\n");
    out_config(KV_KAODV_GW_SUBNET,f,kckw,kpkw);

    fclose(f);
}


//----------------------------------------------------------------------
// KAODV_REFRESH
//----------------------------------------------------------------------
static void kaodv_refresh()
{
    kaodv_gw_sel = getenv(kpkw[KV_KAODV_GW]);
    kaodv_menu();
    printf("</html>\n");
    exit(0);
}


//----------------------------------------------------------------------
// KAODV
//----------------------------------------------------------------------
int kaodv (char *arg)
{
    int ix;
    ix = argvindex(kaodv_funcs, arg, strcmp);
    switch(ix) {
	case KAODV_OPTION:
	    kaodv_option();
	    break;
	case KAODV_MENU:
	    kaodv_menu();
	    break;
	case KAODV_WRITE:
	    kaodv_write();
	    break;
	case KAODV_REFRESH:
	    kaodv_refresh();
	    break;
    }    
}
