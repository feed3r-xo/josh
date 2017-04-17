#!/usr/bin/perl -w

my $script_name = 'partition_paired_fastq.1.pl';

# Chih-Horng Kuo <chkuo@lifedev.org>
# read two input fastq files
# partition into paired/unpaired reads
# v1 2013/05/06

use strict;
use warnings;

use Getopt::Long;
use File::Basename;

my $in_file_1;
my $in_file_2;
my $out_dir;
my $regex;
my $verbose;
my $debug;

GetOptions(
    "in_file_1=s" => \$in_file_1,
    "in_file_2=s" => \$in_file_2,
    "out_dir=s"   => \$out_dir,
    "regex=s"     => \$regex,
    "verbose=i"   => \$verbose,
    "debug=i"     => \$debug,
);

my $count_in_1 = 0;
my $count_in_2 = 0;
my $count_pair = 0;
my $count_un_1 = 0;
my $count_un_2 = 0;

my %seq_hash; # key = pair_id, value = seq in fastq format
open IN1, "<$in_file_1" or die "Can't open input file $in_file_1: $!\n";
while ( my $in_line = <IN1> ) {
	if ( $in_line =~ /$regex/ ) {
		$seq_hash{$1} = $in_line;
		$in_line = <IN1>;
		$seq_hash{$1} = $seq_hash{$1} . $in_line;
		$in_line = <IN1>;
		$seq_hash{$1} = $seq_hash{$1} . $in_line;
		$in_line = <IN1>;
		$seq_hash{$1} = $seq_hash{$1} . $in_line;
		$count_in_1++;
	}
	else {
		die "error parsing $in_line\n";
	}
}
close IN1;

system "mkdir -p $out_dir" unless -e $out_dir;
my $out_file_p1 = $out_dir . 'paired_1.fastq';
open OUTP1, ">$out_file_p1" or die "Can't open output file $out_file_p1: $!\n";
my $out_file_p2 = $out_dir . 'paired_2.fastq';
open OUTP2, ">$out_file_p2" or die "Can't open output file $out_file_p2: $!\n";
my $out_file_u1 = $out_dir . 'unpaired_1.fastq';
open OUTU1, ">$out_file_u1" or die "Can't open output file $out_file_u1: $!\n";
my $out_file_u2 = $out_dir . 'unpaired_2.fastq';
open OUTU2, ">$out_file_u2" or die "Can't open output file $out_file_u2: $!\n";

open IN2, "<$in_file_2" or die "Can't open input file $in_file_2: $!\n";
while ( my $in_line = <IN2> ) {
	if ( $in_line =~ /$regex/ ) {
		if ( exists $seq_hash{$1} ) {
			print OUTP1 $seq_hash{$1};
			delete $seq_hash{$1};
			
			print OUTP2 $in_line;
			$in_line = <IN2>;
			print OUTP2 $in_line;
			$in_line = <IN2>;
			print OUTP2 $in_line;
			$in_line = <IN2>;
			print OUTP2 $in_line;
			
			$count_pair++;
		}
		else {
			print OUTU2 $in_line;
			$in_line = <IN2>;
			print OUTU2 $in_line;
			$in_line = <IN2>;
			print OUTU2 $in_line;
			$in_line = <IN2>;
			print OUTU2 $in_line;
			
			$count_un_2++;		
		}
		$count_in_2++;
	}
	else {
		die "error parsing $in_line\n";
	}
}
close IN2;

foreach my $key ( sort keys %seq_hash ) {
	print OUTU1 $seq_hash{$key};
	
	$count_un_1++;
}
close OUTP1;
close OUTP2;
close OUTU1;
close OUTU2;

if ($verbose) {
	print "count_in_1 = $count_in_1, count_in_2 = $count_in_2\n";
	print "count_pair = $count_pair\n";
	print "count_un_1 = $count_un_1, count_un_2 = $count_un_2\n";
}

exit(0);

