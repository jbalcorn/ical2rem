#!/usr/bin/perl -w
#
# cal_futureonly.pl - 
# Reads iCal files and outputs events between 1 month ago and 1 year from now.
# Copyright (c) 2005, 2007, 2019 Justin B. Alcorn

=head1 SYNOPSIS

 cal_futureonly.pl --file=filname.ics > output.ics

 --help				   Usage
 --man				   Complete man page
 --infile				   (REQUIRED) name of input calendar file
 --file				   (REQUIRED) name of output calendar file

Expects an ICAL stream on STDIN. Converts it to the format
used by the C<remind> script and prints it to STDOUT. 

=head2 --infile

Input file

=head2 --file 

Output File

=cut 

use strict;
use Data::ICal;
use Data::ICal::Entry;
use DateTime::Span;
use Data::ICal::DateTime;
use DateTime;
use Getopt::Long 2.24 qw':config auto_help';
use Pod::Usage;
use Data::Dumper;
use vars '$VERSION';
$VERSION = "0.1";

my $help;
my $man;
my $infile;
my $file;
my $debug = 0;

GetOptions (
	"help|?" 	  => \$help, 
	"man" 	 	  => \$man,
    "debug"       => \$debug,
    "infile=s"    => \$infile,
	"file=s"      => \$file
);
pod2usage(1) if $help;
pod2usage(1) if (! $file);
pod2usage(-verbose => 2) if $man;

my $limit = DateTime->now();
$limit->subtract( months => 1);
my $endlimit = DateTime->now()->add(years =>1);
print STDERR "including events from: ",$limit->ymd," to: ".$endlimit->ymd,"\n" if $debug;
my $span  = DateTime::Span->from_datetimes( start => $limit, end => $endlimit );
print STDERR "Parsing $infile\n" if $debug;
my $cal = Data::ICal->new(filename => $infile);
if (! $cal) {
	die "Died Trying to read $infile :".$cal->error_message;
}
#my $archive = Data::ICal->new(filename => 'archive.ics');
print "Output = $file\n" if $debug;
my $new = Data::ICal->new();
if (! $new) {
	die $new->error_message;
}

my @events = $cal->events($span);
$new->add_entries(@events);

open(NEW, ">$file");
print NEW $new->as_string;
close NEW;
exit 0;
#:vim set ft=perl ts=4 sts=4 expandtab :
