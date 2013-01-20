/* This header file is shared by client & server. They really have
 * something to share...
 * */

/* Client/server protocol is as follows:
   Send INIT_PASSWD
   Send 64-bit cliserv_magic
   Send 64-bit size of exported device
   Send 128 bytes of zeros (reserved for future use)
 */

#include "config.h"
#include <errno.h>
#include <string.h>
#include <netdb.h>

#if SIZEOF_UNSIGNED_SHORT_INT==4
typedef unsigned short u32;
#elif SIZEOF_UNSIGNED_INT==4
typedef unsigned int u32;
#elif SIZEOF_UNSIGNED_LONG_INT==4
typedef unsigned long u32;
#else
#error I need at least some 32-bit type
#endif

#ifndef	FS_32BIT
#if SIZEOF_UNSIGNED_INT==8
typedef unsigned int u64;
#elif SIZEOF_UNSIGNED_LONG_INT==8
typedef unsigned long u64;
#elif SIZEOF_UNSIGNED_LONG_LONG_INT==8
typedef unsigned long long u64;
#else
#error I need at least some 64-bit type
#endif
#endif	/* FS_32BIT */

#include <linux/nbd.h>

#ifdef	FS_32BIT
struct { unsigned char m[8]; } cliserv_magic = { { 0x00, 0x00, 0x42, 0x02, 0x81, 0x86, 0x12, 0x53 } };
#else
u64 cliserv_magic = 0x00420281861253LL;
#endif
#define INIT_PASSWD "NBDMAGIC"

#define INFO(a) do { } while(0)

void setmysockopt(int sock)
{
	int size = 1;
#if 0
	if (setsockopt(sock, SOL_SOCKET, SO_SNDBUF, &size, sizeof(int)) < 0)
		 INFO("(no sockopt/1: %m)");
#endif
#ifdef	IPPROTO_TCP
	size = 1;
	if (setsockopt(sock, IPPROTO_TCP, TCP_NODELAY, &size, sizeof(int)) < 0)
		 INFO("(no sockopt/2: %m)");
#endif
#if 0
	size = 1024;
	if (setsockopt(sock, IPPROTO_TCP, TCP_MAXSEG, &size, sizeof(int)) < 0)
		 INFO("(no sockopt/3: %m)");
#endif
}

void err(const char *s)
{
	const int maxlen = 150;
	char s1[maxlen], *s2;
	int n = 0;

	strncpy(s1, s, maxlen);
	if (s2 = strstr(s, "%m")) {
		strcpy(s1 + (s2 - s), strerror(errno));
		s2 += 2;
		strcpy(s1 + strlen(s1), s2);
	}
#if 0
#ifndef	sun
	/* Solaris doesn't have %h in syslog */
	else if (s2 = strstr(s, "%h")) {
		strcpy(s1 + (s2 - s), hstrerror(h_errno));
		s2 += 2;
		strcpy(s1 + strlen(s1), s2);
	}
#endif
#endif

	s1[maxlen-1] = '\0';
#ifdef ISSERVER
	syslog(LOG_ERR, s1);
#else
	fprintf(stderr, "Error: %s\n", s1);
#endif
	exit(1);
}

void logging(void)
{
#ifdef ISSERVER
	openlog(MY_NAME, LOG_PID, LOG_DAEMON);
#endif
	setvbuf(stdout, NULL, _IONBF, 0);
	setvbuf(stderr, NULL, _IONBF, 0);
}

#ifndef	FS_32BIT
#ifdef WORDS_BIGENDIAN
u64 ntohll(u64 a)
{
	return a;
}
#else
u64 ntohll(u64 a)
{
	u32 lo = a & 0xffffffff;
	u32 hi = a >> 32U;
	lo = ntohl(lo);
	hi = ntohl(hi);
	return ((u64) lo) << 32U | hi;
}
#endif
#define htonll ntohll
#endif	/* FS_32BIT */
