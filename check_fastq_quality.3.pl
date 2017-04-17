#!/usr/bin/perl -w

my $script_name = 'check_fastq_quality.3.pl';

# Chih-Horng Kuo <chkuo@lifedev.org>
# check the quality score distribution in fastq files
# v3 2011/09/23
# 	Illumina 1.8+ uses Phred+33 
# 	'@' corresponds to a quality score of 31
# 	cannot use 'local $/ = "@";' to read input file
# 	need to change the method of reading input
# 	to read 4 lines at a time
# v2 2011/04/01
#   style change
# v1 2010/04/21

use strict;
use warnings;

use Getopt::Long;
use File::Basename;

my $in_dir;
my $out_dir;
my $in_file_ext;
my $out_file_ext;
my $min;    
my $max;    
my $offset;    
my $verbose;
my $debug;

GetOptions(
    "in_dir=s"       => \$in_dir,
    "out_dir=s"      => \$out_dir,
    "in_file_ext=s"  => \$in_file_ext,
    "out_file_ext=s" => \$out_file_ext,
    "min=i"          => \$min,
    "max=i"          => \$max,
    "offset=i"       => \$offset,
    "verbose=i"      => \$verbose,
    "debug=i"        => \$debug,
);

$in_file_ext  = $in_file_ext  ? $in_file_ext  : 'fastq';
$out_file_ext = $out_file_ext ? $out_file_ext : 'txt';
$min          = $min          ? $min          : '0';
$max          = $max          ? $max          : '41';
$offset       = $offset       ? $offset       : '33';

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

	my %count_hash; # key = char, value = count
	foreach my $value ( $min..$max ) {
		$count_hash{ chr( ( $value + $offset) ) } = 0;
	}
	
	# read input
	open IN, "<$in_file" or die "Can't open input file $in_file: $!\n";
	while ( my $in_line_1 = <IN> ) {
		my $in_line_2 = <IN>;
		my $in_line_3 = <IN>;
		my $in_line_4 = <IN>;
		
		chomp $in_line_1;
		chomp $in_line_2;
		chomp $in_line_3;
		chomp $in_line_4;

		my @scores = split //, $in_line_4;
		foreach my $score (@scores) {
			$count_hash{$score}++;
		}
	}
	close IN;

	my $total_count = 0;
	my %cum_count_hash; # key = char, value = cum_count
	foreach my $value ( $min..$max ) {
		$total_count += $count_hash{ chr( ( $value + $offset) ) };
		$cum_count_hash{ chr( ( $value + $offset) ) } = $total_count;
	}
	
	open OUT, ">$out_file" or die "Can't open output file $out_file: $!\n";
	print OUT "Phred\tASCII\tCount\tFreq\tCum_Freq\n";
	foreach my $value ( $min..$max ) {
		my $char = chr( ( $value + $offset) );
		print  OUT "$value\t$char\t$count_hash{$char}";
		printf OUT "\t%.4f", ( $count_hash{$char} / $total_count );
		printf OUT "\t%.4f", ( $cum_count_hash{$char} / $total_count );
		print  OUT "\n";
	}
	close OUT;
}

if ($verbose) {
    print "count_file = $count_file\n";
}
exit(0);

