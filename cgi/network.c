//----------------------------------------------------------------------
// network.c
//----------------------------------------------------------------------
#include "setup.h"

char *network_funcs[] = {
    "option",
    "menu",
    "write",
    NULL
};

enum { NETWORK_OPTION, NETWORK_MENU, NETWORK_WRITE, NETWORK_NULL };

enum { NV_P_DHCP, NV_P_ADDRESS, NV_P_NETMASK, NV_P_BROADCAST, NV_S_DHCP,
       NV_S_ADDRESS, NV_S_NETMASK, NV_S_BROADCAST, NV_TFTPHOST, NV_LOGSVR,
       NV_TIMESVR, NV_ROUTER, NV_SWAPSVR, NV_SWAPPORT, NV_MASQ_NET,
       NV_IW_WATCHDOG_IF, NV_IW_WATCHDOG_TIME, NV_NULL };

char *nckw[] = {
	"p_dhcp=",
	"p_address=",
	"p_netmask=",
	"p_broadcast=",
	"s_dhcp=",
	"s_address=",
	"s_netmask=",
	"s_broadcast=",
	"tftphost=",
	"logsvr=",
	"timesvr=",
	"router=",
	"swapsvr=",
	"swapport=",
	"masq_net=",
	"iw_watchdog_if=",
	"iw_watchdog_time=",
	NULL
};

char *npkw[] = {
	"CGI_p_dhcp",
	"CGI_p_address",
	"CGI_p_netmask",
	"CGI_p_broadcast",
	"CGI_s_dhcp",
	"CGI_s_address",
	"CGI_s_netmask",
	"CGI_s_broadcast",
	"CGI_tftphost",
	"CGI_logsvr",
	"CGI_timesvr",
	"CGI_router",
	"CGI_swapsvr",
	"CGI_swapport",
	"CGI_masq_net",
	"CGI_iw_watchdog_if",
	"CGI_iw_watchdog_time",
	NULL
};

char *nkw[] = {
	"p_dhcp",
	"p_address",
	"p_netmask",
	"p_broadcast",
	"s_dhcp",
	"s_address",
	"s_netmask",
	"s_broadcast",
	"tftphost",
	"logsvr",
	"timesvr",
	"router",
	"swapsvr",
	"swapport",
	"masq_net",
	"iw_watchdog_if",
	"iw_watchdog_time",
	NULL
};

char *nv[] = {
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"wlan0",
	"30",
	NULL
};


//----------------------------------------------------------------------
// NETWORK_OPTION
//----------------------------------------------------------------------
static int network_option()
{
    otr(NULL);
    otd("<input type=\"image\" src=\"/buttons/plus.png\"\n\
	    name=\"cfg-network\" alt=\"Network\">\n");
    otd("Configure Network Interfaces");
    otr("/");
}


//----------------------------------------------------------------------
// NETWORK_MENU
//----------------------------------------------------------------------
static int network_menu()
{
    read_cfg("netcfg",nckw,nv);

    header("menu");
    oform(("POST ","/cgi-bin/setup", NULL));
    ohid("last_menu","network");
    printf("<h3>Primary Network Interface (R/L 2=wlan0 3=br0 4=eth0)</h3>");

    otbl(NULL);
    otr(NULL);
    oth("Use DHCP");
    {
	char *dhcp_sel[] = {
	    nkw[NV_P_DHCP], nv[NV_P_DHCP],
	    "Enabled", "enabled", "Disabled", "disabled",
	    NULL };
	    otd(sel("",dhcp_sel));
    }
    otr("/");

    otr(NULL);
    oth("Network Address");
    otd(itext(nkw[NV_P_ADDRESS],nv[NV_P_ADDRESS], 18, 15));
    otr("/");

    otr(NULL);
    oth("Mask Address");
    otd(itext(nkw[NV_P_NETMASK],nv[NV_P_NETMASK], 18, 15));
    otr("/");

    otr(NULL);
    oth("Broadcast Address");
    otd(itext(nkw[NV_P_BROADCAST],nv[NV_P_BROADCAST], 18, 15));
    otr("/");

    otbl("/");
    printf("<br>\n");
    printf("<h3>Secondary Network Interface (R/L 2=eth0 4=wlan0 3=N/A)</h3>\n");

    otbl(NULL);

    otr(NULL);
    oth("Use DHCP");
    {
	char *dhcp_sel[] = {
	    nkw[NV_S_DHCP], nv[NV_S_DHCP],
	    "Enabled", "enabled", "Disabled", "disabled",
	    NULL };
	    otd(sel("",dhcp_sel));
    }
    otr("/");

    otr(NULL);
    oth("Network Address");
    otd(itext(nkw[NV_S_ADDRESS],nv[NV_S_ADDRESS], 18, 15));
    otr("/");

    otr(NULL);
    oth("Mask Address");
    otd(itext(nkw[NV_S_NETMASK],nv[NV_S_NETMASK], 18, 15));
    otr("/");

    otr(NULL);
    oth("Broadcast Address");
    otd(itext(nkw[NV_S_BROADCAST],nv[NV_S_BROADCAST], 18, 15));
    otr("/");

    otbl("/");

    printf("<br>\n");
    printf("<h3>Miscellaneous Configuration Data</h3>\n");

    otbl(NULL);

    otr(NULL);
    oth("TFTP Host");
    otd(itext(nkw[NV_TFTPHOST], nv[NV_TFTPHOST], 18,15));
    otr("/");

    otr(NULL);
    oth("Log (syslog) Server");
    otd(itext(nkw[NV_LOGSVR], nv[NV_LOGSVR], 18,15));
    otr("/");

    otr(NULL);
    oth("Watchdog interfaces (sepparated with spaces)");
    otd(itext(nkw[NV_IW_WATCHDOG_IF], nv[NV_IW_WATCHDOG_IF], 18,15));
    otr("/");

    otr(NULL);
    oth("Watchdog time interval (sec)");
    otd(itext(nkw[NV_IW_WATCHDOG_TIME], nv[NV_IW_WATCHDOG_TIME], 18,15));
    otr("/");

    otr(NULL);
    oth("Remote Date Host");
    otd(itext(nkw[NV_TIMESVR], nv[NV_TIMESVR], 18,15));
    otr("/");

    otr(NULL);
    oth("Default Router");
    otd(itext(nkw[NV_ROUTER], nv[NV_ROUTER], 18,15));
    otr("/");

    otr(NULL);
    oth("SWAP (NBD) Server");
    otd(itext(nkw[NV_SWAPSVR], nv[NV_SWAPSVR], 18,15));
    otr("/");

    otr(NULL);
    oth("SWAP (NBD) Port");
    otd(itext(nkw[NV_SWAPPORT], nv[NV_SWAPPORT], 18,15));
    otr("/");

    otr(NULL);
    oth("Masquerade Network");
    otd(itext(nkw[NV_MASQ_NET], nv[NV_MASQ_NET], 18,15));
    otr("/");

    otbl("/");

    printf("<br>\n");
    ohid("menu","main");
    osub("f_click","OK");
    printf("&nbsp;&nbsp;&nbsp;\n");
    osub("f_click", "CANCEL");

    oform(("/"));
    printf("</body></html>\n");
}

//----------------------------------------------------------------------
// NETWORK_WRITE
//----------------------------------------------------------------------
network_write()
{
    FILE *f;

    sprintf(bigbuf,"%s/netcfg", globs.cfgdir);

    f = fopen(bigbuf,"w");
    fprintf(f,"#\n# netcfg\n#\n");

    fprintf(f,"\n\
# Primary Interface (RL2/wlan0, RL3/br0, RL4/eth0)\n\
# Need first 3 if not dhcp\n\
# p_dhcp should be either enabled or disabled\n");
    out_config(NV_P_DHCP,f,nckw,npkw);
    out_config(NV_P_ADDRESS,f,nckw,npkw);
    out_config(NV_P_NETMASK,f,nckw,npkw);
    out_config(NV_P_BROADCAST,f,nckw,npkw);

    fprintf(f,"\n\
# Secondary Interface (RL2/eth0, RL4/wlan0)\
# Ignored at RL3\n");
    out_config(NV_S_DHCP,f,nckw,npkw);
    out_config(NV_S_ADDRESS,f,nckw,npkw);
    out_config(NV_S_NETMASK,f,nckw,npkw);
    out_config(NV_S_BROADCAST,f,nckw,npkw);

    fprintf(f,"\n\
# These should pull from dhcp ...\n");
    out_config(NV_ROUTER,f,nckw,npkw);
    out_config(NV_TFTPHOST,f,nckw,npkw);
    out_config(NV_LOGSVR,f,nckw,npkw);

    fprintf(f,"\n");
    out_config(NV_TIMESVR,f,nckw,npkw);

    fprintf(f,"\n");
    out_config(NV_IW_WATCHDOG_IF,f,nckw,npkw);
    out_config(NV_IW_WATCHDOG_TIME,f,nckw,npkw);

    fprintf(f,"\n\
# Network Swapping\n");
    out_config(NV_SWAPSVR,f,nckw,npkw);
    out_config(NV_SWAPPORT,f,nckw,npkw);

    fprintf(f,"\n\
# Masqerading support ... Masquerade this network\n\
# ex: 10.1.0.0/27\n\
# Will Masquerade 10.1.0.0-10.1.0.31\n\
# This assumes you've set up eth0 appropriately\n\
# elsewhere\n");
    out_config(NV_MASQ_NET,f,nckw,npkw);

    fclose(f);
}


//----------------------------------------------------------------------
// NETWORK
//----------------------------------------------------------------------
int network(char *arg)
{
    int ix;
    ix = argvindex(network_funcs, arg, strcmp);
    switch(ix) {
	case NETWORK_OPTION:
	    network_option();
	    break;
	case NETWORK_MENU:
	    network_menu();
	    break;
	case NETWORK_WRITE:
	    network_write();
	    break;
    }    
}
