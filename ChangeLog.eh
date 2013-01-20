21-02-2004
  * Minor fixes
  * Added iwlist support
  * Added tunning of wireless security options
  * Added tunning of iw_watch time
  * Added hostap(d|-drivers|-utils) 0.1.3 support
  * Added binary package release files

17-02-2004
  * Updated and adapted linuxAP-eh to original linuxAP version 2003-09-13
  * Reversed the order of directory deletion on clean operation (bottom-up)
  * Fixed corruption of terminal bug because of an unselected config option
    ('%m' to 'strerror(errno)' conversion) on uClibc 0.9.21
  * Added support for busybox-1.00-pre7 (deleting pre2)

24-11-2003
  * Default wlan's txpower to auto (as changing power is sometimes bad for
    certain cards)

23-11-2003
  * Modified configuration, init scripts and web configuration files to get back to the splitted file format

10-11-2003
  * fixed nbd/swap included in base kernel even if unselected
  * added option to exclude httpd support and cgis
  * now WL11000 is the default platform for make config

01-11-2003
  * images directory created
  * removed largefiles support on uClibc 0.9.21
  * added malloc-glibc compatibility on uClibc to fix openvpn compilation
  * size optimization for openvpn hostap hostapd
  * fixed make distclean for RW.default hostap squashfs
  * fixed startup links for hostapd

31-10-2003
  * conf files on tar.gz format

30-10-2003
  * removed ./network msg from pcmcia-cs
  * fiexed wireless_tools with CFLAGS=-Os
  * removed brctld from bridge-utils
  * added support to hostad

27-10-2003
  * Fix to scripts/util_dev
  * Now kaodv fits flash image with http support
  * Global date/time format

26-10-2003
  * Another fix to scripts/util_cond so it doesn't needs echo/sed

24-10-2003
  * Added support to vtun as tunneling software
  * fixedo some problems in squashfs and config.in
  * Added suport to hostap 0.1.1 with txpower activated thanks to ed0

22-10-2003
  * Now works with squashfs, in a non aodv config and with openvp the flash image have 38kb free comparing with 5 kb in cramfs
  * Fiexed util_cond to work with ';' instead of ' ' 

21-10-2003
  * Changed kernel's iptables support to conditional patching

20-10-2003
  * Added script ./pack_links.sh to automate links.tgz creation

17-10-2003
  * now images have the speed and the date and are packages at images directory

15-10-2003
  * dhcpd.conf at br0 now by default
  * Added ln to dhcpd at runlevel 3 and removed /rw from image final

10-10-2003
  * changed pcmcia-cs patch to delete modutils tests

06-10-2003
  * Changed openvpn default version to 1.4.3 (It's smaller)
  * Added support to use uClibc 0.9.21
  * Added support to select the iptables extensions to use with linuxAP-eh at
    menuconfig
  * If Kernel AODV is selected, move all httpd support away
  * Added iptables' mac address, multiple port, and connection state match
    support
  * Minor Kernel AODV's scripts fixes

01-10-2003
  * Various fixes to adapt distribution to CVS

30-09-2003
  * Añadido parche para poder compilar con con busybox 1.0-pre3

26-09-2003
  * Cipe y Kernel AODV pasan a utilizar el nuevo scripts/util_setup para sus
    ficheros
  * Añadido soporte para OpenVPN version 1.5-beta7 (con parcheado condicional
    al nucleo)
  * Los scripts de inicio br0.i, iw_watch, wlan.i y kernel_aodv modificados
    para coger sus parametros de netcfg
  * Las paginas de configuracion de red (netcfg), wireless (wlan0) y Kernel
    AODV (kaodv) se han modificado para usar solamente los parametros de
    netcfg
  * Ficheros de configuracion netcfg, wlan0 y kernel_aodv fundidos en un unico 
    netcfg (para ahorrar espacio en la zona de R/W)
  * La parte de configuracion de kernel_aodv es ahora un parche a netcfg
  * Todos los botones de la interficie web se han eliminado y reemplazado por
    una sola imagen (y se han modificado las correspondientes paginas para
    usar solo este)
  * Añadida pagina de configuracion de httpd en la interficie web
  * Añadida la salida de ifconfig en la pagina de estado de red de la
    interficie web
  * Ahora hay un unico lugar para la interficie web en Image_Static de la raiz
    (pero se pueden poner modificaciones/ampliaciones en la parte dependiente
    de la arquitectura $(AP_BUILD)/Image_static/html)
  * Modificados makefiles de Mk para utilizar $(STRIP) en lugar de strip y
    añadir, cuando es posible, el uso de $(STRIPFLAGS) (que se ha extendido
    añadiendole --strip-debig) o el mayor strip posible sin inutilizar el
    codigo (a veces tb --strip-all)
  * Borrados todos los directorios dev de las imagenes estaticas, ahora se
    crean directamente en Image_final (desde Makefile.full) con el script
    util_dev
  * El script de creacion de imagenes (build_flash.pl) ahora muestra tb el
    tamaño de la zona de R/W
  * Quitadas las opciones CONFIG_DF, CONFIG_SYNC, CONFIG_MESG,
    CONFIG_FEATURE_HTTPD_SETUID, CONFIG_FEATURE_SH_FANCY_PROMPT y
    CONFIG_LOGGER y añadida CONFIG_WC en busybox 1.00-pre2
  * Deseleccionado en compilacion codigo de debug de hostap

09-09-2003
  * Revision de los parches para su aplicacion a la nueva version 2003-09-01
    del linuxAP de Keith Smith
  * Añadido sistema de parcheado condicional a traves del script
    scripts/util_cond
  * Añadida la configuracion de K. AODV a traves de la interficie web
  * Añadida la posibilidad de configurar timehost (servidor remoto de fecha)
    en el menu html i netcfg
  * Añadida la libreria libipt_multiport.so de iptables para utilizar la
    opcion 'Multiple port match support' del nucleo
  * Restaurados todos los comandos y caracteristicas quitaddos de busybox en
    las tres anteriores versiones

02-09-2003
  * Eliminacion de udhcp por el uso de busybox-1.00-pre2 (que ya lo lleva
    incorporado)
  * Añadido soporte para el protocolo de enrutamiento dinamico Kernel AODV
    (version 2.1)
  * Eliminados el comando 'df' y 'whoami' (salida equivalente con el ya
    presente 'id'), la salida "humana" de ls, df, du, etc (Kb, Mb, etc) y
    el soporte para la personalizacion del prompt con tal de hacer espacio al
    protocolo Kernel AODV
  * Modificado el script scripts/build_flash.pl para que muestre espacio libre
    en Kilo bytes y bytes

30-08-2003
  * Eliminados los links a ficheros no utilizados por busybox en el Makefile
    principal (/etc/shadow, /etc/gshadow, /etc/securetty) y movidos los
    restantes (/etc/passwd, /etc/groups, /etc/nologin, /etc/motd) a la regla
    busybox-install de Mk/busybox.mk
  * Arreglado busybox para poder cambiar el password de un usuario y aceptar
    conexiones por telnet a nuevos usuarios (hay que añadirlos manualmente)
  * Arreglado reflash (la version anterior tiene un error, si este ya existe,
    copiar reflash en /etc/rw y modificarlo tal como lo hace el parche, luego
    ejecutar y borrar una vez reflasheado)

19-08-2003

  * Revision de todos los parches para su aplicacion en la version 2003-06-10
    de linuxAP de Keith Smith (http://linuxap.ksmith.com/)
  * Fijadas versiones de uClibc (0.9.20) y PCMCIA-CS (3.2.3) (ahora no se
    pueden escojer en el menu de configuracion)
  * Eliminacion de net-tools por el uso de busybox-1.00-pre2  (que ya lleva
    netstat incorporado)
  * Reinsercion de loggeado remoto en busybox
  * Cambiados /etc/passwd y /etc/groups para que puedan ser reescritos (usados
    por el telnetd de busybox); lo mismo con /etc/shadow, /etc/gshadow,
    /etc/nologin, /etc/securetty, /etc/motd (tambien usados por busybox)
  * Quitados los scripts uname y uptime porque ya estan en busybox
  * Reinsercion del parche para hostap 0.0.3 (version por defecto)
  * Añadida opcion Multiple port match support (CONFIG_IP_NF_MATCH_MULTIPORT)
    de iptables
  * Arreglado parche de wl11000/patches/linux/2.4.20/20 en limits.h (daba
    error al aplicarlo)
  * Cambiadas las configuraciones del nucleo
    (wl11000/kernel-config/2.4.20/{base,sram}) para que explicitamente
    deseleccionen la opcion CONFIG_BIGPHYS_AREA (sino el make oldconfig
    pregunta si queremos la opcion, evitando una compilacion totalmente
    automatizada)

13-08-2003

  * Ahora se puede compilar con busybox 1.00-pre2 por lo que hay suficiente
    espacio para incluir cipe (viene empotrado en busybox netstat y udhcp),
    además hay 20 kas de espacio libre si se usa esa configuración y hostap
    0.0.4.
  * Nota: si se usa el udhcp de busybox y el netstat, hay que acordarse de no
    hacer que compile tanto udhcp como net-tools, sino sobreescribirán las de
    busybox.
  * Cambiada la lectura de variables POST en el html, para que sea compatible
    tanto para la versión 1.00-pre2 como para la 0.60 de busybox.
  * Nota: el error de txpower con hostap 0.0.4 es debido a que han quitado del
    código del driver la parte que se encargaba de cambiar la potencia debido
    a que causaba distorsión en la señal, en futura "entregas" de hostap
    aparecerá de nuevo.

31-07-2003

  * Incluida la posibilidad de compilar la versión 0.0.4 de hostap, para que
    para la que ha de eliminarse de la compilación cipe o net-tools.

28-07-2003 
 
  * Gracias a Lluis <xscript@gmx.net>, que se ha puesto mano a mano conmigo
    (Su mano es grande y poderosa ) con todo el tema de los parches, los
    parches siguen siendo para la versión 2003-02-11 debido principalmente a
    que aplicándole parches y edemas historias a la 2003-06-10 se queda sin
    espacio y tampoco incluye muchos cambios ya que la mayoría son para
    soekris y itx. Esta versión contiene cambios para una compilación mucho
    mas flexible y cómoda. 
  * Reestructurado el script parchear, ya no existe la opción de parche_único
    por ser una chorrada, se mueve un par de scripts que no lincaban sino que
    se copiaban, unificado el proceso de cambiar permisos con
    SCRIPTS_TOOLS="clientes uname uptime" 
  * parche_hostap: hace que se olvide de buscar hostap_cs.conf cuando compila
  * parche_uclibc: hace posible la compilación con las versiones 0.9.18 y
    0.9.20 de dichas librerías (las imágenes están compiladas con la versión
    0.9.20) 
  * parche_config: con este parche nos saldrá la opción de elegir las versiones
    tanto de "pcmcia"  como de las "net-tools" a la hora de compilar el linuxap
  * parche_util_config: permite la inclusión de partes del linuxap que no quieres 
    que vuelva a recompilar cuando recompilas todo el linuxap, tales como por
    ejemplo la imagen del kernel. 

15-05-2003 
 
  * Arreglado parchear, para que funcione
  * Arreglado parche iw_watch para que parchee
  * Gracias a Jose Luu

28-03-2003 
 
  * Incluidos los scripts ositools (excepto netstat), posteados en la lista
    linuxap@redlibre.net por "coder" nerv@ono.com 
  * Incluido netstat de las net-tools (netstat bueno y verdadero)  
    Nota: para usar netstat te lo has de bajar de aquí 
    http://www.tazenda.demon.co.uk/phil/net-tools/ y renombrarlo como 
    net-tools-"version".tar.gz y meter la nueva versión en el archivo .config   
 
25-03-2003 
 
  * Incluido iw_watch que reinicia el ap si se ha quedado muerto el interface
    wlan0 
  * Añade 3 links del nuevo script a los 3 runlevels. 

11-03-2003 
 
  * Parches para el linuxAP de Keith Smith, version 2003-02-11
  * Link en etc/rc.d/3 para que incluya cipe al arrancar 
 
