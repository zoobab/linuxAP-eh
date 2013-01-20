//----------------------------------------------------------------------
// linked_functions.h
//----------------------------------------------------------------------

char *linked_names[] = {
	"top",
	"network",
	"udhcpd",
	"wlan",
	"telnetd",
	"httpd",
#ifdef CONFIG_CIPE
	"cipe",
#endif
#ifdef CONFIG_OPENVPN
	"openvpn",
#endif
#ifdef CONFIG_KERNEL_AODV
	"kaodv",
#endif
	"status",
	NULL
};
    
void *linked_functions[] = {
	&top,
	&network,
	&udhcpd,
	&wlan,
	&telnetd,
	&httpd,
#ifdef CONFIG_CIPE
	&cipe,
#endif
#ifdef CONFIG_OPENVPN
	&openvpn,
#endif
#ifdef CONFIG_KERNEL_AODV
	&kaodv,
#endif
	&status,
	NULL
};
