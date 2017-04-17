#!/usr/bin/perl -w

my $script_name = 'trim_fastq_by_quality.2.pl';

# Chih-Horng Kuo <chkuo@lifedev.org>
# trim sequences in a fastq file by the quality score
# v2 2011/09/23
# 	Illumina 1.8+ uses Phred+33 
# 	'@' corresponds to a quality score of 31
# 	cannot use 'local $/ = "@";' to read input file
# 	need to change the method of reading input
# 	to read 4 lines at a time
# v1 2011/04/06

use strict;
use warnings;

use Getopt::Long;
use File::Basename;

my $in_file;
my $out_file;
my $rep_file;
my $min;
my $max;
my $offset;
my $cutoff;
my $verbose;
my $debug;

GetOptions(
    "in_file=s"      => \$in_file,
    "out_file=s"     => \$out_file,
    "rep_file=s"     => \$rep_file,
    "min=i"          => \$min,
    "max=i"          => \$max,
    "offset=i"       => \$offset,
    "cutoff=i"       => \$cutoff,
    "verbose=i"      => \$verbose,
    "debug=i"        => \$debug,
);

$min          = $min          ? $min          : '0';
$max          = $max          ? $max          : '41';
$offset       = $offset       ? $offset       : '33';
$cutoff       = $cutoff       ? $cutoff       : '20';

my $adjusted_cutoff = $cutoff + $offset;

my $out_dir = dirname($out_file);
system "mkdir -p $out_dir" unless -e $out_dir;

open OUT, ">$out_file" or die "Can't open output file $out_file: $!\n";
open IN, "<$in_file" or die "Can't open input file $in_file: $!\n";
my $count_in  = 0;
my $count_out = 0;
my %count_hash; # key = trimmed_length, value = count

while ( my $in_line_1 = <IN> ) {
	my $in_line_2 = <IN>;
	my $in_line_3 = <IN>;
	my $in_line_4 = <IN>;
	
	chomp $in_line_1;
	chomp $in_line_2;
	chomp $in_line_3;
	chomp $in_line_4;

	$count_in++;

	my $trimmed_length = 0;
	my @scores = split //, $in_line_4;
	foreach my $score (@scores) {
		if ( ord($score) >= $adjusted_cutoff ) {
			$trimmed_length++;
		}
		else {
			last;
		}
	}
	
	$count_hash{$trimmed_length}++;
	
	if ( $trimmed_length > 0 ) {
		my $trim_seq  = substr($in_line_2, 0, $trimmed_length);
		my $trim_qual = substr($in_line_4, 0, $trimmed_length);
		print OUT "$in_line_1\n$trim_seq\n$in_line_3\n$trim_qual\n";
		$count_out++;
	}
	else {
	}
}
close IN;
close OUT;

my @trimmed_lengths = sort { $a <=> $b } keys %count_hash;
my $min_trimmed_length = $trimmed_lengths[0];
my $max_trimmed_length = $trimmed_lengths[-1];
my %cum_count_hash; # key = trimmed_length, value = cum_count
my $total_count = 0;
foreach my $length ( $min_trimmed_length..$max_trimmed_length ) {
    if ( exists $count_hash{$length} ) {
    }
    else {
        $count_hash{$length} = 0;
    }
    $total_count += $count_hash{$length};
    $cum_count_hash{$length} = $total_count;
}

open REP, ">$rep_file" or die "Can't open output file $rep_file: $!\n";
foreach my $length ( $min_trimmed_length..$max_trimmed_length ) {
    print REP "$length\t$count_hash{$length}";
    printf REP "\t%.4f", ( $count_hash{$length} / $total_count );
    printf REP "\t%.4f", ( $cum_count_hash{$length} / $total_count );
    print  REP "\n";
}
close REP;

if ($verbose) {
	my $count_diff = $count_in - $count_out;
	
    print "count_in = $count_in\n";
    print "count_out = $count_out (";
    printf "%.3f", ( $count_out / $count_in );
    print ")\n";
    print "count_diff = $count_diff (";
    printf "%.3f", ( $count_diff / $count_in );
    print ")\n";
}
exit(0);

