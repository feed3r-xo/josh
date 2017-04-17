#!/usr/bin/perl -w

my $script_name = 'check_fastq_format.2.pl';

# Chih-Horng Kuo <chkuo@lifedev.org>
# check fastq files for formatting issues
# v2 2011/09/23
# 	Illumina 1.8+ uses Phred+33 
# 	'@' corresponds to a quality score of 31
# 	cannot use 'local $/ = "@";' to read input file
# 	need to change the method of reading input
# 	to read 4 lines at a time
# v1 2011/04/01

use strict;
use warnings;

use Getopt::Long;
use File::Basename;

my $in_dir;
my $out_dir;
my $in_file_ext;
my $out_file_ext;
my $verbose;
my $debug;

GetOptions(
    "in_dir=s"       => \$in_dir,
    "out_dir=s"      => \$out_dir,
    "in_file_ext=s"  => \$in_file_ext,
    "out_file_ext=s" => \$out_file_ext,
    "verbose=i"      => \$verbose,
    "debug=i"        => \$debug,
);

$in_file_ext  = $in_file_ext  ? $in_file_ext  : 'fastq';
$out_file_ext = $out_file_ext ? $out_file_ext : 'txt';

system "mkdir -p $out_dir" unless -e $out_dir;

my $count_file = 0;
# get list of in_files
chdir $in_dir or die "cannot chdir to $in_dir: $!";
my @in_files = glob "*.$in_file_ext";
foreach my $in_file (sort @in_files) {
    $count_file++;
    $in_file =~ m/(.*)\.$in_file_ext/;
    my $file_id = $1;
	my $out_file = $out_dir . $file_id . '.' . $out_file_ext;
	$in_file = $in_dir . $in_file;

	my $count_good = 0;
	my $count_bad  = 0;

	open OUT, ">$out_file" or die "Can't open output file $out_file: $!\n";
	open IN, "<$in_file" or die "Can't open input file $in_file: $!\n";
	while ( my $in_line_1 = <IN> ) {
		my $in_line_2 = <IN>;
		my $in_line_3 = <IN>;
		my $in_line_4 = <IN>;
		
		chomp $in_line_1;
		chomp $in_line_2;
		chomp $in_line_3;
		chomp $in_line_4;

		# check seq_id
		my $seq_id;
		if ( $in_line_1 =~ m/^\@(.*)$/ ) {
			$seq_id = $1;
		}
		else {
			$count_bad++;
			print OUT "error parsing seq_id: $in_line_1\n";  
			next;
		}
		
		# check length
		my $seq_length  = length $in_line_2;
		my $qual_length = length $in_line_4;
		if ( $seq_length == $qual_length ) {
			# do nothing
		}
		else {
			$count_bad++;
			print OUT "$seq_id: ",
			  "seq_length = $seq_length, ",
			  "qual_length = $qual_length\n";
			next;
		}
		
		# passed all tests
		$count_good++;
	}
	close IN;
	close OUT;
	
	if ($verbose) {
		print "file_id = $file_id, ",
		  "count_good = $count_good, ",
		  "count_bad = $count_bad\n";
	}

}

if ($verbose) {
    print "count_file = $count_file\n";
}

exit(0);

