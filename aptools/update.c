///----------------------------------------------------------------------  
//     update.c - userspace front-end to flash device.
//
//     Copyright (C) 2001-2001 Instant 802 Networks, All Rights Reserved.
//        
//
// Modification History:
//
// 2002-08-13 Keith Edwin Smith
// o Seek in copy routine s/b start not 0
// o Hacked in ignore of rw section
// o Hacked argument processing in main
// o No longer generic.
//----------------------------------------------------------------------

#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <fcntl.h>
#include <time.h>
#include <sys/ioctl.h>
#include <sys/mount.h>
#include <sys/types.h>
#include <sys/signal.h>
#include <sys/reboot.h>
#include <string.h>

#include <linux/mtd/mtd.h>

// #undef DEBUG
#ifndef DEBUG 
#define printf(arg, ...) ;
#define fprintf(arg, ...) ;
#define perror(arg) ;
#endif

#define THRESH_INCR	65536


//----------------------------------------------------------------------
// Supported command line arguments && defines
// Only -s stuff for now KES
//----------------------------------------------------------------------
char *arg_list[] = {
    "-d",
    "--debug",
    "-s",
    "--save-config",
    "-z",
    "--decompress",
    NULL
};

#define ARG_D 0
#define ARG_DEBUG 1
#define ARG_S 2
#define ARG_SAVE 3
#define ARG_Z 4
#define ARG_DECOMPRESS 5
#define ARG_NULL 6


//----------------------------------------------------------------------
// Stuff to backup configuration info
//----------------------------------------------------------------------
#define CONFIG_START (8192 * 124)
#define CONFIG_LEN 16384
char *config;


//----------------------------------------------------------------------
// ARGVINDEX
// argvindex - Find string s on NULL terminated argv style list argvlist
// Stolen from my liba/libax -- KES
//----------------------------------------------------------------------
int argvindex(argvlist, s, strfunc)
char *argvlist[];
char *s;
int (*strfunc)();
{
    int index;
    for(index = 0; argvlist[index] != NULL; index++ ) {
        if ( (strfunc)(argvlist[index], s, strlen(argvlist[index])) == 0)
            break;
    }
    return(index);
}


//----------------------------------------------------------------------
// GET_CONFIG
//----------------------------------------------------------------------
int get_config(dev_fd)
int dev_fd;
{
    printf("Getting current configuration information\n");
    config = malloc(CONFIG_LEN);
    if(config == NULL) {
        fprintf(stderr, "Error allocating memory to for config data\n");
        exit(1);
    }
    lseek(dev_fd, CONFIG_START, SEEK_SET);
    read(dev_fd, config, CONFIG_LEN);
    return(0);
}


//----------------------------------------------------------------------         
// BOUNDARY_CHECK
// returns if the offset is on a block boundary or not
//----------------------------------------------------------------------         
int boundary_check(region_info_t *regioninfo, unsigned int region_count,
		   unsigned int offset, 
		   unsigned int *ret_region, unsigned int *ret_block) {
	region_info_t *r = NULL;
	unsigned int region_start = 0;
	unsigned int region_end = 0;
	unsigned int region_blocksize = 0;
	int i = 0;
	
	for (i=0; i<region_count; i++) {
		r = &regioninfo[i];
		region_start = r->offset;
		region_end   = r->offset + (r->numblocks * r->erasesize);
		region_blocksize = r->erasesize;

		// we need a special case if the offset is at the very end of the flash
		if ( (offset == region_end) && (i == region_count-1) ) {
			if (ret_region) 
				*ret_region = i;
			if (ret_block)
				*ret_block = r->numblocks;
			goto success;
		}
		// if offset is at the beginning or within this current region
		else if( (offset >= region_start) && (offset < region_end) )
		{
			// and if offset lands on a block boundary
			if ( ((region_end - offset) % region_blocksize) == 0) {
				if (ret_region) 
					*ret_region = i;
				if (ret_block)
					*ret_block = (offset - region_start) / region_blocksize;
				goto success;
			}
		}

	}
//fail:
	printf("boundary check for offset %d(0x%x) failed\n",
	       offset, offset);
	return 0; // fail

 success:
	// printf("boundary check for offset %d(0x%x) returning region %d block %d\n",
	//     offset, offset, i, (offset - region_start) / region_blocksize);
	return 1; // success

}



//----------------------------------------------------------------------
// REGION_ERASE
//----------------------------------------------------------------------
int region_erase(int fd, int start, int length)
{
	region_info_t *regioninfo = NULL;
	region_info_t *r = NULL;
	int region_count = 0;
	int i = 0;

	// find the region count
	if (ioctl(fd,MEMGETREGIONCOUNT, &region_count)) {
		printf("there are no regions in this mtd device\n");
		return 1;
	}
	printf("%d regions found in this mtd device\n", region_count);

	
	// allocate and clear the regioninfo
	regioninfo = malloc(sizeof(region_info_t)*region_count);
//	memset(regioninfo, 0, sizeof(region_info_t)*region_count);


	// get the info for each region
	for (i=0; i<region_count; i++) {
		r = &regioninfo[i];

		// read in the region info
		r->regionindex = i;
		if (ioctl(fd, MEMGETREGIONINFO, r) != 0) {
			printf("failed printing out region summaries\n");
			free(regioninfo);
			return 1;
		}
		// print out the region info
		printf("region %d is at %d(0x%x) of %d sectors "
		       "with sector size %d(0x%x)\n", 
		       i, r->offset, r->offset, 
		       r->numblocks,
		       r->erasesize, r->erasesize);
	}


	// safety checks
	if (!boundary_check(regioninfo, region_count, start, NULL, NULL)) {
 		printf("start %d(0x%x)is not on a boundary\n", 
		       start, start);
		return 1;
	}
	if (!boundary_check(regioninfo, region_count, start+length, NULL, NULL)) {
		printf("start+length %d(0x%x)is not on a boundary\n", 
		       start+length, start+length);
		return 1;
	}


	// do the erasing
	{
//		region_info_t * r = NULL;
		erase_info_t erase;
		u_int32_t region_num = 0;
		u_int32_t block_num  = 0;
		u_int32_t offset = start; // increment as we go

		while (offset < start+length)
		{
//			memset(&erase, 0, sizeof(erase_info_t));
			if (!boundary_check(regioninfo, region_count, offset,
					    &region_num, &block_num)) 
			{
				printf("could not find region in middle of erase\n");
				printf("we are fucked!\n");
				close(fd);
				return 1;
			}

			printf("boundary check for offset %d(0x%x) returning region %d block %d\n",
			       offset, offset, region_num, block_num);


			erase.start = offset;
			erase.length = regioninfo[region_num].erasesize;

			printf("erasing region %d block %d at offset %d(0x%x) length %d(0x%x)\n",
			       region_num, block_num,
			       erase.start, erase.start,
			       erase.length, erase.length);
			
			if( ioctl(fd, MEMERASE, &erase) ) 
			{
				perror("region block erase failure\n");
				printf("we are fucked!\n");
				close(fd);
				return 1;
			}
			
			offset += erase.length;
		}
	}
 	return 0;
}


//----------------------------------------------------------------------
// COPY
//----------------------------------------------------------------------
#define COPY_BUFSIZ 1024
int copy(int to, int from, int start)
{
    char buf[COPY_BUFSIZ];
    long tot_written, msg_thresh;
    off_t of;
    ssize_t s, w;
    

    of = lseek(to, start, SEEK_SET);
    if (of != start) return 2;

    tot_written = 0;
    msg_thresh = THRESH_INCR;

    for(;;) {
        s = read(from, buf, COPY_BUFSIZ);
        if (s == -1) return 3;
        if (s == 0) break;
        w = write(to, buf, s);
        tot_written += s;
        if( tot_written >= msg_thresh ) {
            printf("Written: %ld chars\n", tot_written);
            msg_thresh += THRESH_INCR;
        }; 
        if (s != w) return 4;
    }
    return 0;
}


//----------------------------------------------------------------------
// USAGE
//----------------------------------------------------------------------
void usage() {
    printf("update [-s|--save-config] <device> <start> <length> "
        "{ - | <filename> }\n"
        "Erases the bytes specified in the mtd device, and optionally\n"
        "writes new data from a file or stdin. Start and length must\n"
        "be on sector boundries\n");
}


//----------------------------------------------------------------------
// MAIN
//----------------------------------------------------------------------
int main(int argc,char *argv[])
{
    int fd       = 0;
    int fd2      = -1;
    int start    = 0;
    int length    = 0;
    int res      = 0; 
    int i, ix, x;
    char *device_path, *image_path;
    int save_config, debug;

    debug = save_config = 0;
    device_path = image_path = NULL;

    for(i = 1,x = 0; i < argc; i++) {
        ix = argvindex(arg_list, argv[i], strcmp );
        switch(ix) {
          case ARG_D:
          case ARG_DEBUG:
            debug = 1;
            break;
          case ARG_S:
          case ARG_SAVE:
            save_config = 1;
            break;
          default:
            switch(x++) {
              case 0:
                device_path = argv[i];
                break;
              case 1:
                start = strtol(argv[i], NULL, 0);
                break;
              case 2:
                length = strtol(argv[i], NULL, 0);
                break;
              case 3:
                image_path = argv[i];
                break;
            }
        }
    }
    if (x < 3) {
        usage();
        return 1;
    }

// open the device
    if ((fd = open(device_path,O_RDWR)) < 0) {
        fprintf(stderr,"device %s open error\n", device_path);
        return 1;
    }
// open the file
    if (image_path != NULL) {
        if (strcmp(image_path,"-") == 0) {
            fd2 = 0;
        } else {
            fd2 = open(image_path, O_RDWR);
            if (fd2 < 0) {
                fprintf(stderr,"file %s open error\n", image_path);
                return 1;
            }
        }
    }
    if(save_config) {
        get_config(fd);
    }
    printf("MTD start erase\n");
    res = region_erase(fd, start, length);
    printf("MTD finish erase\n");
    if (res) return res;

    if (fd2 >= 0) {
        int ret = 0;
        printf("MTD start write\n");
        ret = copy(fd, fd2, start);
        printf("MTD finish write\n\n");
        if (ret) return ret;
    }

    if(save_config) {
        printf("Restoring Configuration Data\n");
        res = region_erase(fd, CONFIG_START, CONFIG_LEN);
        if(res) {
            fprintf(stderr, "-- Error erasing Configuration Section\n");
        } else {
            if(lseek(fd, CONFIG_START, 0) == CONFIG_START) {
                write(fd, config, CONFIG_LEN);
            } else {
                fprintf(stderr,"-- Error seeking to config block\n");
            }
        }
    }
    if (length == 1048576 ) {
        fprintf(stderr,"Hard Reboot in 2 seconds ...");
        sync(); sync();
        sleep(2);
        reboot(RB_AUTOBOOT);
//        printf("rebooting: killing init\n");
//        return(kill(1, SIGTERM));
    }

    return 0;

}
