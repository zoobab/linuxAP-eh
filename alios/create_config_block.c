/********************************************************************
 *  Copyright (c) 2001 telos EDV Systementwicklung GmbH (telos),    *
 *  Hamburg (Germany)
 *                                                                  *
 *                     http://www.telos.de                          *
 *                                                                  *
 *  alios is free software; you can redistribute it and/or modify   *
 *  it under the terms of the GNU General Public License as         *
 *  published by the Free Software Foundation; either version 2 of  *
 *  the License, or (at your option) any later version.             *
 *                                                                  *
 *  alios is distributed in the hope that it will be useful,        *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of  *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the   *
 *  GNU General Public License for more details.                    *
 *                                                                  *
 *  You should have received a copy of the GNU General Public       *
 *  License along with this program; if not, write to the Free      *
 *  Software Foundation, Inc., 59 Temple Place - Suite 330,         *
 *  Boston, MA 02111-1307, USA                                      *
 *                                                                  *
 *  Author(s): Marco Budde                                          *
 *  Version:                                                        *
 *    $Id: create_config_block.c,v 1.2 2003/09/29 21:52:20 xscript Exp $
 *                                                                  *
 *  This program can be used to create config block images, which   *
 *  are used to configure the alios bootloader.                     *
 ********************************************************************/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <unistd.h>

#define MY_BYTE unsigned char
#define MY_WORD unsigned short
#define MY_DWORD unsigned int


void print_help (const char *name)
{
  printf ("\n%s\n\n"
          "  -f <filename of the config block image>\n"
          "  -v <valid: 0 (yes), 1 (no)>\n"
          "  -k <kernel image start address>\n"
          "  -i <initrd image start address>\n"
          "  -s <size of the initrd image>\n"
          "  -c <kernel command line>\n"
          "  -h\n\n"
          " Copyright (c) 2001 telos EDV Systementwicklung GmbH, Hamburg\n\n", 
          name);
}


int main (int argc, char *argv[])
{
  int      getopt_value;
  MY_BYTE  valid_flag = 0;
  MY_DWORD kernelimg_s = 0;
  MY_DWORD initrdimg_s = 0;
  MY_DWORD our_rd_size = 0;
  MY_BYTE  commandline[256];
  char     filename[1000];
  FILE     *out;


  if (argc <= 1)
  {
    print_help (argv[0]);
    return 1;
  }

  bzero (commandline, sizeof (commandline));
  strcpy (filename, "");

  while ((getopt_value = getopt (argc, argv, "f:v:k:i:s:c:h")) != -1)
  {
    switch (getopt_value)
    {
      case 'f':
        strncpy (filename, optarg, sizeof (filename) - 1);
        filename [sizeof (filename) - 1] = '\0';
        break;
      case 'v':
        valid_flag = strtol (optarg, NULL, 0);
        printf ("Is valid (1: no, 0: yes): %u\n", valid_flag);
        break;
      case 'k':
        kernelimg_s = strtol (optarg, NULL, 0);
        printf ("Start address of kernel image within ROM: %u (0x%X)\n", 
                kernelimg_s, kernelimg_s);
        break;
      case 'i':
        initrdimg_s = strtol (optarg, NULL, 0);
        printf ("Start address of initrd image within ROM: %u (0x%X)\n", 
                initrdimg_s, initrdimg_s);
        break;
      case 's':
        our_rd_size = strtol (optarg, NULL, 0);
        printf ("Size of the initrd image in bytes: %u (0x%X)\n", 
                our_rd_size, our_rd_size);
        break;
      case 'c':
        strncpy (commandline, optarg, sizeof (commandline) - 1);
        commandline[sizeof (commandline) - 1] = '\0';
        printf ("Kernel command line: %s\n", commandline);
        break;
      case 'h':
	print_help (argv[0]);
	return 0;
    }
  }

  if ((out = fopen (filename, "wb")) == NULL)
  {
    printf ("Cannot open file: %s\n", filename);
    return 1;
  }

  fwrite (&valid_flag, sizeof (valid_flag), 1, out);
  fwrite (&kernelimg_s, sizeof (kernelimg_s), 1, out);
  fwrite (&initrdimg_s, sizeof (initrdimg_s), 1, out);
  fwrite (&our_rd_size, sizeof (our_rd_size), 1, out);
  fwrite (&commandline, sizeof (commandline), 1, out);

  fclose (out);

  printf ("\nConfig block image \"%s\" created.\n\n", filename);

  return 0;
}
