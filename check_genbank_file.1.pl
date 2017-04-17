#!/usr/bin/perl -w

my $script_name = 'check_genbank_file.1.pl';

# Chih-Horng Kuo <chkuo@lifedev.org>
# check genbank file integrity
# v1 2010/07/12

use strict;
use warnings;

use Getopt::Long;
use File::Basename;

my $in_dir;
my $in_file_ext;
my $verbose;
my $debug;

GetOptions(
    "in_dir=s"         => \$in_dir,
    "in_file_ext=s"    => \$in_file_ext,
    "verbose=i"        => \$verbose,
    "debug=i"          => \$debug,
);
$in_file_ext = $in_file_ext ? $in_file_ext : 'gb';


my $count_in  = 0;
my $count_err = 0;
opendir( DIR, $in_dir ) or die "can't open $in_dir: $!";
while ( defined( my $in_file = readdir(DIR) ) ) {
    if ( $in_file =~ /(\S+)\.$in_file_ext$/ ) {
    	my $file_id = $1;
        $count_in++;
        $in_file = $in_dir . $in_file;
		open IN, "<$in_file" or die "Can't open input file $in_file: $!\n";
		my @in_lines = <IN>;
		
		my $flag_head_error;
		my $line_1 = shift @in_lines;
		if ( $line_1 =~ /^LOCUS/ ) {
			$flag_head_error = 0;
		}
		else {
			$flag_head_error = 1;
		}
		
		my $flag_tail_error;
		foreach my $in_line ( reverse @in_lines ) {
	        chomp $in_line;
	        next unless $in_line; # skip empty lines
	        if ( $in_line =~ /^\/\// ) {
				$flag_tail_error = 0;
	        }
	        else {
				$flag_tail_error = 1;
	        }
	        last;
		}
		
		if ( $flag_head_error || $flag_tail_error ) {
			$count_err++;
			warn "$file_id\t$flag_head_error\t$flag_tail_error\n";
		}
    }
}
closedir(DIR);

if ($verbose) {
	print "count_in = $count_in, count_err = $count_err\n";
}

exit(0);

