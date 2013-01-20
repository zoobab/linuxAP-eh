//----------------------------------------------------------------------
// udhcpd.c
//----------------------------------------------------------------------
#include "setup.h"

char *udhcpd_funcs[] = {
    "option",
    "menu",
    "write",
    NULL
};

enum { UDHCPD_OPTION, UDHCPD_MENU, UDHCPD_WRITE, UDHCPD_NULL };

enum { UVK_ENABLE, UVK_INTERFACE, UVK_START, UVK_END, UVK_LEASE_FILE, UVK_DNS,
       UVK_SUBNET, UVK_ROUTER, UVK_DOMAIN, UVK_LEASE, UVK_NULL };

char *uckw[UVK_NULL+1] = {
    "enable ",
    "interface ",
    "start ",
    "end ",
    "lease_file ",
    "option  dns ",
    "option  subnet ",
    "option  router ",
    "option  domain ",
    "option  lease ",
    NULL
};

char *upkw[UVK_NULL+1] = {
    "CGI_enable",
    "CGI_interface",
    "CGI_start",
    "CGI_end",
    "CGI_lease_file",
    "CGI_dns",
    "CGI_subnet",
    "CGI_router",
    "CGI_domain",
    "CGI_lease",
    NULL
};

char *ukw[UVK_NULL+1] = {
    "enable",
    "interface",
    "start",
    "end",
    "lease_file",
    "dns",
    "subnet",
    "router",
    "domain",
    "lease",
    NULL
};

char *uv[UVK_NULL+1] = {
    "",
    "eth0",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    NULL
};


//----------------------------------------------------------------------
// UDHCPD_OPTION
//----------------------------------------------------------------------
static int udhcpd_option()
{
    otr(NULL);
    otd("<input type=\"image\" src=\"/buttons/plus.png\"\n\
	    name=\"cfg-udhcpd\" alt=\"DHCPD\">\n");
    otd("Configure DHCP Server");
    otr("/");

}


//----------------------------------------------------------------------
// UDHCPD_MENU
//----------------------------------------------------------------------
static int udhcpd_menu()
{
    read_cfg("udhcpd.conf",uckw,uv);

    header("udhcpd");

    oform(("POST", "/cgi-bin/setup", NULL));
    ohid("last_menu","udhcpd");
    printf("<h3>DHCPD Configuration Options</h3>\n");

    otbl(NULL);

    otr(NULL);
    oth("Status");
    {
	char *stat_vals[] = {
	    ukw[UVK_ENABLE], uv[UVK_ENABLE],
	    "Enabled", "yes",
	    "Disabled", "no",
	    NULL };
	    otd(sel("",stat_vals));
    }
    otr("/");

    // This should be dynamically allocated
    otr(NULL);
    oth("Network Interface");
    {
	char *ifaces[] = {
	    ukw[UVK_INTERFACE], uv[UVK_INTERFACE],
	    "Ethernet 0 (eth0)", "eth0", 
	    "Ethernet 1 (eth1)", "eth1",
	    "Wireless 0 (wlan0)", "wlan0",
	    NULL };
	    otd(sel("",ifaces));
    }
    otr("/");

    otr(NULL);
    oth("Starting Address");
    otd(itext(ukw[UVK_START],uv[UVK_START], 18, 15));
    otr("/");

    otr(NULL);
    oth("Ending Address");
    otd(itext(ukw[UVK_END],uv[UVK_END], 18, 15));
    otr("/");

    otr(NULL);
    oth("Subnet Mask");
    otd(itext(ukw[UVK_SUBNET],uv[UVK_SUBNET], 18, 15));
    otr("/");

    otr(NULL);
    oth("Default Router");
    otd(itext(ukw[UVK_ROUTER],uv[UVK_ROUTER], 18, 15));
    otr("/");

    otr(NULL);
    oth("Domain Name Server(DNS)");
    otd(itext(ukw[UVK_DNS],uv[UVK_DNS], 18, 15));
    otr("/");

    otr(NULL);
    oth("Domain Name");
    otd(itext(ukw[UVK_DOMAIN],uv[UVK_DOMAIN], 18, 15));
    otr("/");

    otr(NULL);
    oth("Lease Time (in seconds)");
    otd(itext(ukw[UVK_LEASE], uv[UVK_LEASE], 18, 15));
    otr("/");

    otbl("/");

    printf("<br>\n");
    ohid("lease_file","/var/run/udhcpd.leases");
    ohid("menu","main");
    osub("f_click","OK");
    printf("&nbsp;&nbsp;&nbsp;\n");
    osub("f_click", "CANCEL");

    oform(("/"));
    printf("</body></html>\n");
}


//----------------------------------------------------------------------
// UDHCPD_WRITE
//----------------------------------------------------------------------
static int udhcpd_write() {
    int i;
    FILE *f;
    char **p, *q;

    sprintf(bigbuf,"%s/udhcpd.conf",globs.cfgdir);
    f = fopen(bigbuf,"w");
    if(f == NULL) {
	printf("Error Opening %s\n",bigbuf);
	exit(0);
    }

    for (i=0; i < UVK_NULL; i++)
	out_config(i,f,uckw,upkw);

    fclose(f);
}


//----------------------------------------------------------------------
// UDHCPD
//----------------------------------------------------------------------
int udhcpd(char *arg)
{
    int ix;
    ix = argvindex(udhcpd_funcs, arg, strcmp);
    switch(ix) {
	case UDHCPD_OPTION:
	    udhcpd_option();
	    break;
	case UDHCPD_MENU:
	    udhcpd_menu();
	    break;
	case UDHCPD_WRITE:
	    udhcpd_write();
	    break;
    }    
}
