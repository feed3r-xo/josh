#!/usr/bin/perl -w

my $script_name = 'parse_velvet_contig_info.1.pl';

# Chih-Horng Kuo <chkuo@lifedev.org>
# parse velvet contig info
# v1 2013/11/19

use strict;
use warnings;

use Getopt::Long;
use File::Basename;

my $in_dir;
my $in_file_ext;
my $out_dir;
my $out_file_ext;
my $verbose;
my $debug;

GetOptions(
    "in_dir=s"            => \$in_dir,
    "in_file_ext=s"       => \$in_file_ext,
    "out_dir=s"           => \$out_dir,
    "out_file_ext=s"      => \$out_file_ext,
    "verbose=i"           => \$verbose,
    "debug=i"             => \$debug,
);

system "mkdir -p $out_dir" unless -e $out_dir;
$in_file_ext  = $in_file_ext  ? $in_file_ext  : 'fasta';
$out_file_ext = $out_file_ext ? $out_file_ext : 'txt';

my $count_file = 0;
chdir $in_dir or die "cannot chdir to $in_dir: $!";
my @in_files = glob "*.$in_file_ext";
foreach my $in_file (sort @in_files) {
    $in_file =~ m/(.*)\.$in_file_ext/;
	my $file_id = $1;
	$in_file = $in_dir . $in_file;
	$count_file++;
	my $count_seq = 0;
	
	my $out_file = $out_dir . $file_id . '.' . $out_file_ext;
	open OUT, ">$out_file" or die "Can't open output file $out_file\n";
	{
		# redefine the record separator
		local $/ = ">";
		open IN, "<$in_file" or die "Can't open input file $in_file: $!\n";
		my $in_line = <IN>; # toss the first record, which only consists of ">"
		while ( $in_line = <IN> ) {
			chomp $in_line; # remove the ">" character in the end 
			my ( $seq_name, $seq ) = split( /\n/, $in_line, 2 );
			$seq_name =~ /^NODE_(\d+)_length_(\d+)_cov_(\S+)$/;
			my ( $contig_id, $contig_length, $contig_coverage ) = ( $1, $2, $3 );
			$count_seq++;
			print OUT "$contig_id\t$contig_length\t$contig_coverage\n";
		}
		close IN;
	}
	close OUT;

	if ($verbose) {
		print "file_id = $file_id, count_seq = $count_seq\n";
	}
}

exit(0);
