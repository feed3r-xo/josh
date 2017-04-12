#!/usr/bin/perl -w

my $script_name = 'rename_file_by_regex.3.pl';

# Chih-Horng Kuo <chkuo@lifedev.org>
# rename files by regex
# v3 2013/09/14
#   add prefix, suffix option
# v2 2010/12/31
#   add in_file_ext, out_file_ext option
# v1 2009/06/23

use strict;
use warnings;

use Getopt::Long;

my $in_dir;
my $out_dir;
my $in_file_ext;
my $out_file_ext;
my $regex;
my $prefix;
my $suffix;
my $mode;
my $verbose;
my $debug;

GetOptions(
    "in_dir=s"       => \$in_dir,
    "out_dir=s"      => \$out_dir,
    "in_file_ext=s"  => \$in_file_ext,
    "out_file_ext=s" => \$out_file_ext,
    "regex=s"        => \$regex,
    "prefix=s"       => \$prefix,
    "suffix=s"       => \$suffix,
    "mode=s"         => \$mode,
    "verbose=i"      => \$verbose,
    "debug=i"        => \$debug,
);

system "mkdir -p $out_dir" unless -e $out_dir;

my $count_in  = 0;
my $count_out = 0;
opendir( DIR, $in_dir ) or die "can't open $in_dir: $!";
while ( defined( my $in_file = readdir(DIR) ) ) {
    if ( $in_file =~ m/$regex\.$in_file_ext/ ) {
    	my $file_name = $1;

	    $count_in++;
        $count_out++;

    	if ( defined $prefix ) {
    		$file_name = $prefix . $file_name;
    	}
    	if ( defined $suffix ) {
    		$file_name = $file_name . $suffix;
    	}
        my $out_file = $out_dir . $file_name . '.' . $out_file_ext;

        $in_file  = $in_dir . $in_file;

        if ( $mode eq 'cp' ) {
            system "cp -p $in_file $out_file";
        }
        elsif ( $mode eq 'mv' ) {
            system "mv $in_file $out_file";
        }
        else {
            die "unknown mode\n";
        }
    }
}

if ($verbose) {
    print "count_in = $count_in, count_out = $count_out \n";
}

exit(0);

