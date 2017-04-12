#!/usr/bin/perl -w

my $script_name = 'find_empty_file.2.pl';

# Chih-Horng Kuo <chkuo@lifedev.org>
# find empty files in the "--in_dir"
# use the "--regex" option to set search regex (e.g., --regex="*.txt")
# set "--opt_rm=1" to remove those files
# v2 2010/07/12
#   style change
# v1 2007/05/25

use strict;
use warnings;

use Getopt::Long;

my $in_dir;
my $regex;
my $opt_rm;
my $verbose;
my $debug;

GetOptions(
    "in_dir=s"  => \$in_dir,
    "regex=s"   => \$regex,
    "opt_rm=i"  => \$opt_rm,
    "verbose=i" => \$verbose,
    "debug=i"   => \$debug,
);

my $count_in        = 0;
my $count_non_empty = 0;
my $count_empty     = 0;

# get list of in_files
chdir $in_dir or die "cannot chdir to $in_dir: $!";
my @in_files = glob "$regex";
foreach my $in_file (@in_files) {
    $count_in++;
    if ( -z $in_file ) {
        $count_empty++;
        print "$in_dir$in_file\n" if ($verbose);
        unlink $in_file if ($opt_rm);
    }
    else {
        $count_non_empty++;
    }
}

print "count_in = $count_in\n";
print "count_non_empty = $count_non_empty\n";
print "count_empty = $count_empty\n";

exit(0);
