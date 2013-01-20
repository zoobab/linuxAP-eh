/*
; wrflash.c	
;
; Utility to copy a binary file to linear flash memory PC Card
;
; Copyright (C) 1999 telos EDV Systementwicklung GmbH (telos)
;
; Author(s):
;  Kolja Waschk, telos (KW),
;  Karl-Werner Ahlers, telos (KA)
;
; $Revision: 1.2 $
;
; History (yyyymmdd au desc):
;
;  19991019 KA workaround non-working ioctl
;  19991019 KA turn off 'interrogate' after first 'y'
;  19991006 KW fixed syntax help
;  19991004 KW creation, derived from ftl_format.c of the PCMCIA utilities
;
*/

#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/time.h>
#include <sys/ioctl.h>
#include <sys/stat.h>

#include <pcmcia/cs_types.h>
#include <pcmcia/bulkmem.h>
#include <pcmcia/ftl.h>
#include <pcmcia/memory.h>

/*====================================================================*/

static void print_size(u_int s)
{
    if ((s > 0x100000) && ((s % 0x100000) == 0))
	printf("%d mb", s / 0x100000);
    else if ((s > 0x400) && ((s % 0x400) == 0))
	printf("%d kb", s / 0x400);
    else
	printf("%d bytes", s);
}

/*====================================================================*/

#define READBUF 1024


static int format_partition(
  int fd, int in_fd, int quiet, int interrogate, int erase_before,
  unsigned long start_address) {

    unsigned char bbuf[READBUF];
    region_info_t region;
    long length;
    erase_info_t erase;
    
    /* Get partition size, block size */
    if (ioctl(fd, MEMGETINFO, &region) != 0) {
	perror("get info failed");
	return -1;
    }

/*
    region.RegionSize=16*1024*1024;
    region.BlockSize=128*1024;
*/

    if (!quiet) {
	printf("Partition size = ");
	print_size(region.RegionSize);
	printf(", erase unit size = ");
	print_size(region.BlockSize);
	printf(", start address 0x%lX\n", start_address);
	printf("\n");
	fflush(stdout);
    }

    erase.Size = region.BlockSize;
    erase.Offset = erase.Size * (start_address / erase.Size);

    do {
      length = read(in_fd,&bbuf,READBUF);
      
      while(length>0 && erase_before && erase.Offset < start_address+length) {

        printf("\nerasing block %lu of %u (0x%lX-0x%lX)\n", 
          erase.Offset/region.BlockSize+1,
          region.RegionSize/region.BlockSize,
          erase.Offset,
  	  erase.Offset+erase.Size-1
        );

        fflush(stdout);

        if (interrogate) {
  	  char str[3];
	  printf("This will destroy data on the target device.  "
	    "Confirm (y/n): ");
	  if (fgets(str, 3, stdin) == NULL)
	    return -1;
	  if ((strcmp(str, "y\n") != 0) && (strcmp(str, "Y\n") != 0))
	    return -1;
	  else
	    interrogate = 0;
         }

         if(ioctl(fd,MEMERASE,&erase)!=0) {
         if(ioctl(fd,MEMERASE,&erase)!=0) {
         if(ioctl(fd,MEMERASE,&erase)!=0) {
          perror("block erase failed");
          return -1;
        }
        }
        }
        erase.Offset += erase.Size;

	if(erase.Offset > start_address+length) {
          printf("writing, beginning at 0x%lX;", start_address);
          fflush(stdout);
        }
      }

      if (length>0) {
        if(lseek(fd, start_address, SEEK_SET)==-1) {
          perror("lseek failed");
          return -1;
        }

        if (write(fd,bbuf,length) != length) {
          perror("write failed");
          return -1;
        } 

        printf("."); fflush(stdout);
        start_address += length;
      }
    } while(length>0);

    printf("\n");
    fflush(stdout);
    
    if (length) return -1;
    return 0;
}

/*====================================================================*/

int main(int argc, char *argv[])
{
    int quiet, interrogate;
    int optch, errflg, fd, in_fd, erase, ret;
    unsigned long start_address;
    char *filename;
    extern char *optarg;
    struct stat buf;

    erase = 0;
    quiet = 0;
    interrogate = 1;
    start_address = 0L;
    filename = NULL;
    errflg = 0;
    
    while ((optch = getopt(argc, argv, "eqis:f:")) != -1) {
	switch (optch) {
        case 'e':
            erase = 1; break;
	case 'q':
	    quiet = 1; break;
	case 'i':
	    interrogate = 0; break;
	case 's':
	    start_address = strtoul(optarg, NULL, 0); break;
        case 'f':
            filename = optarg; break;
	default:
	    errflg = 1; break;
	}
    }
    if (errflg || (optind != argc-1)) {
	fprintf(stderr, "usage: %s [-e(rase)] [-q(uiet)] "
	  "[(don't) -i(nterrogate)] [-s start-addr] [-f inputfile] device\n", 
         argv[0]);
	exit(EXIT_FAILURE);
    }

    if (stat(argv[optind], &buf) != 0) {
	perror("status check failed");
	exit(EXIT_FAILURE);
    }
    if (!(buf.st_mode & S_IFCHR)) {
	fprintf(stderr, "%s is not a character special device\n",
		argv[optind]);
	exit(EXIT_FAILURE);
    }

    fd = open(argv[optind], O_RDWR);
    if (fd == -1) {
	perror("open failed");
	exit(EXIT_FAILURE);
    }

    if(filename) {
      in_fd = open(filename, O_RDONLY);
    } else {
      in_fd = STDIN_FILENO;
    }

    if(in_fd == -1) {
      perror("open in failed");
      close(fd);
      exit(EXIT_FAILURE);
    }

    ret = format_partition(fd, in_fd, quiet, interrogate, erase, 
                           start_address);

    if (!quiet) {
	if (ret)
	    printf("---> failure.\n");
	else
	    printf("---> success.\n");
    }
    close(fd);
    
    exit((ret) ? EXIT_FAILURE : EXIT_SUCCESS);
    return 0;
}
