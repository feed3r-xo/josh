#!/usr/bin/perl -w

my $script_name = 'filter_fastq_by_length.3.pl';

# Chih-Horng Kuo <chkuo@lifedev.org>
# filter fastq file by sequence length
# v3 2012/04/02
#   add the option of filtering by --min and --max
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
my $out_format;
my $min;
my $max;
my $verbose;
my $debug;

GetOptions(
    "in_file=s"      => \$in_file,
    "out_file=s"     => \$out_file,
    "rep_file=s"     => \$rep_file,
    "out_format=s"   => \$out_format,
    "min=i"          => \$min,
    "max=i"          => \$max,
    "verbose=i"      => \$verbose,
    "debug=i"        => \$debug,
);

$out_format = $out_format ? $out_format : 'fastq';

if ( $out_format eq 'fastq' || $out_format eq 'fasta' ) {
}
else {
    die "--out_format must be set to fastq or fasta\n";
}

my $out_dir = dirname($out_file);
system "mkdir -p $out_dir" unless -e $out_dir;

open OUT, ">$out_file" or die "Can't open output file $out_file: $!\n";
open IN, "<$in_file" or die "Can't open input file $in_file: $!\n";
my $count_in  = 0;
my $count_min = 0;
my $count_max = 0;
my $count_out = 0;
my %count_hash; # key = length, value = count
while ( my $in_line_1 = <IN> ) {
	chomp $in_line_1;
	my $seq_id;
	if ( $in_line_1 =~ m/^\@(.*)$/ ) {
		$seq_id = $1;
	}
	else {
		warn "error parsing seq_id: $in_line_1";
		next;
	}

	my $in_line_2 = <IN>;
	my $in_line_3 = <IN>;
	my $in_line_4 = <IN>;
	
	chomp $in_line_2;
	chomp $in_line_3;
	chomp $in_line_4;

	$count_in++;
	
	# check the length of sequence and quality
	my $seq_length  = length $in_line_2;
	my $qual_length = length $in_line_4;
	if ( $seq_length == $qual_length ) {
        if ( $seq_length < $min ) {
            $count_min++;
        }
        elsif ( $seq_length > $max ) {
            $count_max++;
		}
		else {
			$count_out++;
			$count_hash{$seq_length}++;
			if ( $out_format eq 'fastq' ) {
				print OUT "$in_line_1\n$in_line_2\n$in_line_3\n$in_line_4\n";
			}
			elsif ( $out_format eq 'fasta' ) {
				print OUT "\>$seq_id\n$in_line_2\n";
			}
			else {
				die "--out_format must be set to fastq or fasta\n";
			}
		}
	}
	else {
		warn "$seq_id: seq_length = $seq_length, qual_length = $qual_length!\n";
	}
}
close IN;
close OUT;

my @lengths = sort { $a <=> $b } keys %count_hash;
my %cum_count_hash; # key = length, value = cum_count
my $total_count = 0;
foreach my $length ( $lengths[0]..$lengths[-1] ) {
    if ( exists $count_hash{$length} ) {
    }
    else {
        $count_hash{$length} = 0;
    }
    $total_count += $count_hash{$length};
    $cum_count_hash{$length} = $total_count;
}

open REP, ">$rep_file" or die "Can't open output file $rep_file: $!\n";
foreach my $length ( $lengths[0]..$lengths[-1] ) {
    print REP "$length\t$count_hash{$length}";
    printf REP "\t%.4f", ( $count_hash{$length} / $total_count );
    printf REP "\t%.4f", ( $cum_count_hash{$length} / $total_count );
    print  REP "\n";
}
close REP;

if ($verbose) {
    print "count_in = $count_in\n";
    print "count_min = $count_min (";
    printf "%.3f", ( $count_min / $count_in );
    print ")\n";
    print "count_max = $count_max (";
    printf "%.3f", ( $count_max / $count_in );
    print ")\n";
    print "count_out = $count_out (";
    printf "%.3f", ( $count_out / $count_in );
    print ")\n";
}
exit(0);

