#!/usr/bin/perl -w

my $script_name = 'merge_paired_fastq.4.pl';

# Chih-Horng Kuo <chkuo@lifedev.org>
# assemble paired fastq files
# v4 2012/01/17
#   pipeline update
#   take in_file_1 and in_file_2
# v3 2011/09/23
# 	Illumina 1.8+ uses Phred+33 
# 	'@' corresponds to a quality score of 31
# 	cannot use 'local $/ = "@";' to read input file
# 	need to change the method of reading input
# 	to read 4 lines at a time
# v2 2011/04/01
#   style change
#   check sequence_id
# v1 2010/04/22

use strict;
use warnings;

use Getopt::Long;
use File::Basename;

my $in_file_1;
my $in_file_2;
my $out_file;
my $verbose;
my $debug;

GetOptions(
    "in_file_1=s" => \$in_file_1,
    "in_file_2=s" => \$in_file_2,
    "out_file=s"  => \$out_file,
    "verbose=i"   => \$verbose,
    "debug=i"     => \$debug,
);

my $out_dir = dirname($out_file);
system "mkdir -p $out_dir" unless -e $out_dir;

open IN1, "<$in_file_1" or die "Can't open input file $in_file_1: $!\n";
open IN2, "<$in_file_2" or die "Can't open input file $in_file_2: $!\n";
open OUT, ">$out_file" or die "Can't open output file $out_file: $!\n";
my $count_pair = 0;
while ( my $in_line_1 = <IN1> ) {
	print OUT $in_line_1;
	$in_line_1 = <IN1>;
	print OUT $in_line_1;
	$in_line_1 = <IN1>;
	print OUT $in_line_1;
	$in_line_1 = <IN1>;
	print OUT $in_line_1;

	my $in_line_2 = <IN2>;
	print OUT $in_line_2;
	$in_line_2 = <IN2>;
	print OUT $in_line_2;
	$in_line_2 = <IN2>;
	print OUT $in_line_2;
	$in_line_2 = <IN2>;
	print OUT $in_line_2;
	
	$count_pair++;
}
close OUT;
close IN2;
close IN1;

if ($verbose) {
	print "count_pair = $count_pair\n";
}

exit(0);

