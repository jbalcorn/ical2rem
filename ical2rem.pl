#!/usr/bin/perl -w
#
# ical2rem.pl - 
# Reads iCal files and outputs remind-compatible files.   Tested ONLY with
#   calendar files created by Mozilla Calendar/Sunbird. Use at your own risk.
# MIT License
# 
# Copyright (c) 2005, 2007, 2019 Justin B. Alcorn
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# version 0.7.1 2024-09-19
#       - Made sure license statements were consistent
# version 0.7 2024-09-04
#       - Added dummy _sfun to resolve Issue #8
# version 0.6 2019-03-01
#       - Updates to put on GitHub
# version 0.5.2 2007-03-23
# 	- BUG: leadtime for recurring events had a max of 4 instead of DEFAULT_LEAD_TIME
#	- remove project-lead-time, since Category was a non-standard attribute
#	- NOTE: There is a bug in iCal::Parser v1.14 that causes multiple calendars to
#		fail if a calendar with recurring events is followed by a calendar with no
#		recurring events.  This has been reported to the iCal::Parser author.
# version 0.5.1 2007-03-21
#	- BUG: Handle multiple calendars on STDIN
#	- add --heading option for priority on section headers
# version 0.5 2007-03-21
#	- Add more help options
#	- --project-lead-time option
#	- Supress printing of heading if there are no todos to print
# version 0.4
#	- Version 0.4 changes all written or inspired by, and thanks to Mark Stosberg
#	- Change to GetOptions
#	- Change to pipe
#	- Add --label, --help options
#	- Add Help Text
#	- Change to subroutines
#	- Efficiency and Cleanup
# version 0.3
#	- Convert to GPL (Thanks to Mark Stosberg)
#	- Add usage
# version 0.2
#	- add command line switches
#	- add debug code
#	- add SCHED _sfun keyword
#	- fix typos
# version 0.1 - ALPHA CODE.  

=head1 SYNOPSIS

 cat /path/to/file*.ics | ical2rem.pl > ~/.ical2rem

 All options have reasonable defaults:
 --label	       Calendar name (Default: Calendar)
 --start               Start of time period to parse (parsed by str2time)
 --end                 End of time period to parse
 --lead-time	       Advance days to start reminders (Default: 3)
 --todos, --no-todos   Process Todos? (Default: Yes)
 --iso8601			   Use YYYY-MM-DD date format
 --locations, --no-locations  Include location? (Default: Yes)
 --end-times, --no-end-times  Include event end times in reminder text
                              (Default: No)
 --heading             Define a priority for static entries
 --help		       Usage
 --debug	       Enable debug output
 --man		       Complete man page

Expects an ICAL stream on STDIN. Converts it to the format
used by the C<remind> script and prints it to STDOUT. 

=head2 --label

  ical2rem.pl --label "Bob's Calendar"

The syntax generated includes a label for the calendar parsed.
By default this is "Calendar". You can customize this with 
the "--label" option.

=head2 --iso8601

Use YYYY-MM-DD date format in output instead of Mmm DD YYYY

=head2 --locations, --no-locations

Whether or not to include locations in events

=head2 --lead-time 

  ical2rem.pl --lead-time 3
 
How may days in advance to start getting reminders about the events. Defaults to 3. 

=head2 --no-todos

  ical2rem.pl --no-todos

If you don't care about the ToDos the calendar, this will surpress
printing of the ToDo heading, as well as skipping ToDo processing. 

=head2 --heading

  ical2rem.pl --heading "PRIORITY 9999"

Set an option on static messages output.  Using priorities can made the static messages look different from
the calendar entries.  See the file defs.rem from the remind distribution for more information.

=cut 

use strict;
use iCal::Parser;
use Date::Parse;
use DateTime;
use Getopt::Long 2.24 qw':config auto_help';
use Pod::Usage;
use Data::Dumper;
use vars '$VERSION';
$VERSION = "0.5.2";

# Declare how many days in advance to remind
my $DEFAULT_LEAD_TIME = 3;
my $PROCESS_TODOS     = 1;
my $HEADING           = "";
my $help;
my $debug;
my $man;
my $iso8601;
my $do_location = 1;
my $do_end_times;
my $start;
my $end;

my $label = 'Calendar';
GetOptions (
	"label=s"     => \$label,
        "start=s"     => \$start,
        "end=s"       => \$end,
	"lead-time=i" => \$DEFAULT_LEAD_TIME,
	"todos!"	  => \$PROCESS_TODOS,
	"iso8601!"        => \$iso8601,
	"locations!"      => \$do_location,
        "end-times!"      => \$do_end_times,
	"heading=s"	  => \$HEADING,
	"help|?" 	  => \$help, 
        "debug"           => \$debug,
	"man" 	 	  => \$man
) or pod2usage(1);
pod2usage(1) if $help;
pod2usage(-verbose => 2) if $man;

my $month = ['None','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

my @calendars;
my $in;

while (<>) {
	$in .= $_;
	if (/END:VCALENDAR/) {
		push(@calendars,$in);
		$in = "";
	}
}
print STDERR "Read all calendars\n" if $debug;
my(%parser_opts) = ("debug" => $debug);
if ($start) {
    my $t = str2time($start);
    die "Invalid time $start\n" if (! $t);
    $parser_opts{'start'} = DateTime->from_epoch(epoch => $t);
}
if ($end) {
    my $t = str2time($end);
    die "Invalid time $end\n" if (! $t);
    $parser_opts{'end'} = DateTime->from_epoch(epoch => $t);
}
print STDERR "About to parse calendars\n" if $debug;
my $parser = iCal::Parser->new(%parser_opts);
my $hash = $parser->parse_strings(@calendars);
print STDERR "Calendars parsed\n" if $debug;

##############################################################
#
# Subroutines 
#
#############################################################
#
# _process_todos()
# expects 'todos' hashref from iCal::Parser is input
# returns String to output
sub _process_todos {
	my $todos = shift; 
	
	my ($todo, @newtodos, $leadtime);
	my $output = "";

	$output .=  'REM '.$HEADING.' MSG '.$label.' ToDos:%"%"%'."\n";

# For sorting, make sure everything's got something
#   To sort on.  
	my $now = DateTime->now;
	for $todo (@{$todos}) {
		# remove completed items
		if ($todo->{'STATUS'} && $todo->{'STATUS'} eq 'COMPLETED') {
			next;
		} elsif ($todo->{'DUE'}) {
			# All we need is a due date, everything else is sugar
			$todo->{'SORT'} = $todo->{'DUE'}->clone;
		} elsif ($todo->{'DTSTART'}) {
			# for sorting, sort on start date if there's no due date
			$todo->{'SORT'} = $todo->{'DTSTART'}->clone;
		} else {
			# if there's no due or start date, just make it now.
			$todo->{'SORT'} = $now;
		}
		push(@newtodos,$todo);
	}
	if (! (scalar @newtodos)) {
		return "";
	}
# Now sort on the new Due dates and print them out.  
	for $todo (sort { DateTime->compare($a->{'SORT'}, $b->{'SORT'}) } @newtodos) {
		my $due = $todo->{'SORT'}->clone();
		my $priority = "";
		if (defined($todo->{'PRIORITY'})) {
			if ($todo->{'PRIORITY'} == 1) {
				$priority = "PRIORITY 1000";
			} elsif ($todo->{'PRIORITY'} == 3) {
				$priority = "PRIORITY 7500";
			}
		}
		if (defined($todo->{'DTSTART'}) && defined($todo->{'DUE'})) {
			# Lead time is duration of task + lead time
			my $diff = ($todo->{'DUE'}->delta_days($todo->{'DTSTART'})->days())+$DEFAULT_LEAD_TIME;
			$leadtime = "+".$diff;
		} else {
			$leadtime = "+".$DEFAULT_LEAD_TIME;
		}
		$output .=  "REM ".$due->month_abbr." ".$due->day." ".$due->year." $leadtime $priority MSG \%a $todo->{'SUMMARY'}\%\"\%\"\%\n";
	}
	$output .= 'REM '.$HEADING.' MSG %"%"%'."\n";
	return $output;
}


#######################################################################
#
#  Main Program
#
######################################################################

# Issue 8 https://github.com/jbalcorn/ical2rem/issues/8
# Make sure there is a _sfun function declared in the reminder file.  We'll just make it do nothing here.
print 'IF args("_sfun") < 1
    FSET _sfun(x) choose(x,0)
ENDIF
';

print _process_todos($hash->{'todos'}) if $PROCESS_TODOS;

my ($leadtime, $yearkey, $monkey, $daykey,$uid,%eventsbyuid);
print 'REM '.$HEADING.' MSG '.$label.' Events:%"%"%'."\n";
my $events = $hash->{'events'};
foreach $yearkey (sort keys %{$events} ) {
    my $yearevents = $events->{$yearkey};
    foreach $monkey (sort {$a <=> $b} keys %{$yearevents}){
        my $monevents = $yearevents->{$monkey};
        foreach $daykey (sort {$a <=> $b} keys %{$monevents} ) {
            my $dayevents = $monevents->{$daykey};
            foreach $uid (sort {
                            DateTime->compare($dayevents->{$a}->{'DTSTART'}, $dayevents->{$b}->{'DTSTART'})    
                            } keys %{$dayevents}) {
                my $event = $dayevents->{$uid};
               if ($eventsbyuid{$uid}) {
                    my $curreventday = $event->{'DTSTART'}->clone;
                    $curreventday->truncate( to => 'day' );
                    $eventsbyuid{$uid}{$curreventday->epoch()} =1;
                    for (my $i = 0;$i < $DEFAULT_LEAD_TIME && !defined($event->{'LEADTIME'});$i++) {
                        if ($eventsbyuid{$uid}{$curreventday->subtract( days => $i+1 )->epoch() }) {
                            $event->{'LEADTIME'} = $i;
                        }
                    }
                } else {
                    $eventsbyuid{$uid} = $event;
                    my $curreventday = $event->{'DTSTART'}->clone;
                    $curreventday->truncate( to => 'day' );
                    $eventsbyuid{$uid}{$curreventday->epoch()} =1;
                }

            }
        }
    }
}
foreach $yearkey (sort keys %{$events} ) {
    my $yearevents = $events->{$yearkey};
    foreach $monkey (sort {$a <=> $b} keys %{$yearevents}){
        my $monevents = $yearevents->{$monkey};
        foreach $daykey (sort {$a <=> $b} keys %{$monevents} ) {
            my $dayevents = $monevents->{$daykey};
            foreach $uid (sort {
                            DateTime->compare($dayevents->{$a}->{'DTSTART'}, $dayevents->{$b}->{'DTSTART'})
                            } keys %{$dayevents}) {
                my $event = $dayevents->{$uid};
                if (exists($event->{'LEADTIME'})) {
                    $leadtime = "+".$event->{'LEADTIME'};
                } else {
                    $leadtime = "+".$DEFAULT_LEAD_TIME;
                }
                my $start = $event->{'DTSTART'};
                my $end = $event->{'DTEND'};
                my $duration = "";
                if ($end and ($start->hour or $start->minute or $end->hour or $end->minute)) {
                    # We need both an HH:MM version of the delta, to put in the
                    # DURATION specifier, and a human-readable version of the
                    # delta, to put in the message if the user requested it.
                    my $seconds = $end->epoch - $start->epoch;
                    my $minutes = int($seconds / 60);
                    my $hours = int($minutes / 60);
                    $minutes -= $hours * 60;
                    $duration = sprintf("DURATION %d:%02d ", $hours, $minutes);
                }
                print "REM ";
                if ($iso8601) {
                    print $start->strftime("%F ");
                } else {
                    print $start->month_abbr." ".$start->day." ".$start->year." ";
                }
                print "$leadtime ";
                if ($duration or $start->hour > 0 or $start->minute > 0) {
                    print "AT ";
                    print $start->strftime("%H:%M");
                    print " SCHED _sfun ${duration}MSG %a %2 ";
                } else {
                    print "MSG %a ";
                }
                print "%\"", &quote($event->{'SUMMARY'});
                print(" at ", &quote($event->{'LOCATION'}))
                    if ($do_location and $event->{'LOCATION'});
                print "\%\"";
                if ($do_end_times and ($start->hour or $start->minute or
                                       $end->hour or $end->minute)) {
                    my $start_date = $start->strftime("%F");
                    my $start_time = $start->strftime("%k:%M");
                    my $end_date = $end->strftime("%F");
                    my $end_time = $end->strftime("%k:%M");
                    # We don't want leading whitespace; some strftime's support
                    # disabling the pdding in the format string, but not all,
                    # so for maximum portability we do it ourselves.
                    $start_time =~ s/^\s+//;
                    $end_time =~ s/^\s+//;
                    my(@pieces);
                    if ($start_date ne $end_date) {
                        push(@pieces, $end_date);
                    }
                    if ($start_time ne $end_time) {
                        push(@pieces, $end_time);
                    }
                    print " (-", join(" ", @pieces), ")";
                }
                print "%\n";
            }
        }
    }
}

sub quote {
    local($_) = @_;
    s/\[/["["]/g;
    return $_;
}

exit 0;
#:vim set ft=perl ts=4 sts=4 expandtab :
