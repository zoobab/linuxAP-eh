#!/usr/bin/perl
#
# build_flash.pl
#
# Modification History:
#
# 2003/09/12 Keith Edwin Smith
# o gz RW.default
#
# 2002/06/11 Keith Edwin Smith
# o Add RW.default into image to flash
#
use strict;
use FileHandle;

my $kernel_img;
my $add_kernel_args = '';

my $mksquasfs          = "./squashfs/squashfs-tools/mksquashfs";
my ($flash_size, $flash) = @ARGV;
# 2 * 1024 * 1024;

# $add_kernel_args  = 'reserve=0x3e0,32 init=/bin/hello';

if ( $flash eq 'sram' ) {
    $kernel_img = "./kernel-sram";
} else {
    $kernel_img = "./kernel";
}

my $rootfs_dir        = "./Image_final";
my $rw_dir            = "./RW.default";

my $kernel = "linux";

my $loader_dir        = "./alios";
my $loader_bin        = "$loader_dir/alios.bin";

my $port_speed        = "4800";


# check if all the initial required files are there
my @initial_files = ($rootfs_dir,
		     $rw_dir,
		     $kernel_img,
		     $loader_dir,
		     $loader_bin
		     );

foreach my $file (@initial_files) {
    check_file($file);
}



# create the Filesystem Image
{
    exe_prn("$mksquasfs $rootfs_dir $flash");
}

# create configuration file:

    exe_prn("cd $rw_dir ; tar cvf - `find . -type f | grep -v CVS` | gzip | dd ibs=16384 of=../RW.tar.gz conv=sync" );

# prepare the kernel
{ 

    my $kernel_size = get_size_b($kernel_img);



# pad the kernel and initrd

# create the configuration blocks

# memory map of flash (1MBx8):
#
# 0xfffff  +-------------+
#          | bootloader  | (16K)
# 0xfc000  +-------------+
#          | unused      | (8K) -+
# 0xfa000  +-------------+       |-- these regions will
#          | unused      | (8k) -+   contain persistent
# 0xf8000  +-------------+           configuration
#      |   | <512b pad,  |
#      |   |   kernel    |
#      V   |  justified  | (~450K)
#          | to top of   |
#          |   region,   |
#          +-------------+
#          | unused      |
#          / ...         / (expansion space)
#          |             |
#          +-------------+
#          | ROM disk    |
#     ^    | justified   | (~400K)
#     |    | from bottom |
#     |    | of flash    |
# 0x00000  +-------------+


    my $rootfs_size_b = get_size_b($flash);
    my $rootfs_size_kb = int(($rootfs_size_b + 1023) / 1024);
    my $kernel_pad_size = (512 - (get_size_b($kernel_img) % 512) % 512);
    my $kernel_size_kb = int((get_size_b($kernel_img) + 1023) / 1024);
    my $kernel_location = $flash_size - get_size_b($loader_bin) - 512 - 
	16*1024  - get_size_b($kernel_img) - $kernel_pad_size;
    my $free = int((1023+$flash_size - 32 * 1024 - $rootfs_size_b - get_size_b($kernel_img))/1024);
    my $free_b = int(1023+$flash_size - 32 * 1024 - $rootfs_size_b - get_size_b($kernel_img));

# concatenate the images

    pad_file($flash, $kernel_location - get_size_b($flash));
    exe_prn("cat $kernel_img >> $flash");
    pad_file($flash, $kernel_pad_size);
#    pad_file($flash, 16*1024); # pad over the two config blocks
    exe_prn("cat ./RW.tar.gz >> $flash");

# example of bootargs that do ip autoconfig then mount rootfs over nfs
# "console=ttyS0,${port_speed}n8 root=/dev/nfs rw nfsroot=192.168.0.104:/var/nfsroot/dwhedon ip=192.168.0.58:192.168.0.104:192.168.0.1:255.255.255.0:i802ap:eth0:none" );
    my $kernel_args = sprintf("console=ttyS0,%sn8 %s",
        $port_speed, $add_kernel_args);
    make_kconf_file( $flash, 
		     $kernel_location, 
		     "$kernel_args" );

    pad_file($flash, 512 - (get_size_b($flash) % 512));
    exe_prn("cat $loader_bin >> $flash");

    print "filesystem image is $rootfs_size_kb Kb\n"; 
    print "kernel image is $kernel_size_kb Kb\n";
    print "free space in flash = $free Kb ($free_b b)\n";
    my $RW_tar_size_kb = int(get_size_b("./RW.tar.gz")/1024);
    print "configs dir is $RW_tar_size_kb Kb\n";
}

### (WMM) print the size of the kernel and ROM disk to the kernel:


#####################################################################
#####################################################################
#####################################################################
#####################################################################
#####################################################################


sub exe_prn {
    my $command = shift(@_);
    
    print "$command\n";
    `$command`;

}


# input file, output file, number of bytes to pad, 
sub pad_file {
    my ($output, $num_bytes) = @_;
    my $char = pack "H2", "ff";

    open(output_fh, ">>$output");
# RH 8.0 / Perl Kludge
    binmode(output_fh);

    # add the byte padding
    while ($num_bytes > 0) { print output_fh $char; $num_bytes--; }
    
    close(output_fh);
    return;
}

# input: file name, kernel size, kernel command line argument string: 
sub make_kconf_file {
    my ($output, $ksize, $kargs) = @_;
    my $zero = pack "H2", "00";

    # valid must be 1 byte, kaddr must be 4 bytes:
    my $kaddr = pack "L", $ksize;

    open output_fh, ">>$output";
# RH 8.0 / Perl Kludge
    binmode output_fh;

    print output_fh $kaddr;

    # put the command line string in the file:
    print output_fh $kargs;
    print output_fh $zero;
    close(output_fh);

    return;
}

sub check_file {
    my $file = shift(@_);
    if (`file $file` =~ /can\'t stat/) {
	print("file {$file} does not exist. exiting\n");
  	exit;
    }
    return;
}


sub get_field {
    my $command = shift(@_);
    my $field_num = shift(@_);

    my $result = `$command | awk '{print \$$field_num}'`;
    chomp $result;
    if ($result eq "") { $result = 0; }
    return $result;
}

# files or dir, provides overestimate
sub get_size_kb {
    my $file_or_dir = shift(@_);
    my $result = get_field("du -sk $file_or_dir", 1);
    if ($result eq "") { $result = 0; }
    return $result;
}


# files only
sub get_size_b {
    my $file = shift(@_);
    my $result = get_field("ls -la $file", 5);
    if ($result eq "") { $result = 0; }
    return $result;
}
