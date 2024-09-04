# ical2rem
The original iCal to Remind script, first released in 2005.

Reads iCal files and outputs remind-compatible files.   Tested ONLY with
  calendar files created by Mozilla Calendar/Sunbird. Use at your own risk.

## License
In 2005, this was released with the Gnu Public License V2.  However, I am changing it to the MIT License, since that provides greater freedom to do with this code what you want.

Copyright (c) 2005, 2007, 2019 Justin B. Alcorn

## How I use Remind and Google Calendar together

  - My family has a Google Email domain, and our email addresses all end in the same domain. We all use Google Calendars and I want to mail reminders to each of the family members containing both Google Calendar and .reminder information.
  - Under my ~/.rem/ directory each family member has a directory.  Each directory contains a standard remind file called 'reminders' that at the very least has the line "INCLUDE /home/jalcorn/.rem/<username>/ical2rem" and flag files indicating whether they want Daily or Weekly reminders.  My reminders files references my standard .reminders file, and I also have a flag so if I run a Test run I'll get it.  There's actually a lot more files (I have a big family).
````
  ./rem
    ./son1:
      drwxrwxr-x  2 jalcorn jalcorn 4096 Dec 12 14:02 .
      drwxr-xr-x 12 jalcorn jalcorn 4096 Dec 12 14:13 ..
      -rw-rw-r--  1 jalcorn jalcorn   51 Mar  3 06:10 ical2rem
      lrwxrwxrwx  1 jalcorn jalcorn   33 Oct 27  2016 son1.ics -> /home/jalcorn/calendars/son1.ics
      -rw-rw-r--  1 jalcorn jalcorn  976 Dec 12 14:02 reminders
      -rw-rw-r--  1 jalcorn jalcorn    0 Oct 27  2016 Weekly

    ./justin:
      drwxrwxr-x  2 jalcorn jalcorn  4096 Feb 27 08:29 .
      drwxr-xr-x 12 jalcorn jalcorn  4096 Dec 12 14:13 ..
      lrwxrwxrwx  1 jalcorn jalcorn    32 Oct 27  2016 son1.ics -> /home/jalcorn/calendars/son1.ics
      -rw-rw-r--  1 jalcorn jalcorn     0 Nov  7  2016 Daily
      lrwxrwxrwx  1 jalcorn jalcorn    34 Oct 27  2016 family.ics -> /home/jalcorn/calendars/family.ics
      -rw-rw-r--  1 jalcorn jalcorn 37320 Mar  3 06:10 ical2rem
      lrwxrwxrwx  1 jalcorn jalcorn    34 Oct 27  2016 justin.ics -> /home/jalcorn/calendars/justin.ics
      lrwxrwxrwx  1 jalcorn jalcorn    24 Nov  7  2016 reminders -> /home/jalcorn/.reminders
      lrwxrwxrwx  1 jalcorn jalcorn    34 Oct 27  2016 vmd.ics -> /home/jalcorn/calendars/vmd.ics
      -rw-rw-r--  1 jalcorn jalcorn     0 Oct 27  2016 Test
      -rw-rw-r--  1 jalcorn jalcorn     0 Nov  7  2016 Weekly
````
  - bin/getgooglecals.sh runs out of crontab and downloads whatever calendars I want. Note that we can also download organization calendars, I've included a public one here (Cleveland Heights Vocal Music Department calendar).
  - dailyreminders.sh is linked to weeklyreminders.sh and testreminders.sh so I can run it in different modes. The concatenate the various calendar outputs as a single remind file then send the reminders via email.
### Example: .rem/son1/reminders file:
````
INCLUDE /home/jalcorn/.rem/defs.rem
INCLUDE /home/jalcorn/.rem/float
INCLUDE /home/jalcorn/.rem/son1/ical2rem
fset _weeks() coerce("STRING", (trigdate()-today())/7) + plural((trigdate()-today())/7, " week")
FSET _sfun(x) choose(x, -60, 30, 5, 0)
FSET oldfloat(y,m,d) trigger(MAX(realtoday(), date(y,m,d)))
FSET due(y,m,d) "(" + (date(y,m,d)-trigdate()) + ")"
SET fullmoon moondate(2)
REM [trigger(realtoday())] SPECIAL SHADE 145 70 100 %
REM [float(2019,4,15,105)] MSG File tax return [due(2017,4,15)]%
REM PRIORITY 9999 MSG %"%"%
INCLUDE /home/jalcorn/.rem/bdays
SET $LongDeg 81
SET $LongMin 11
SET $LongSec 11
SET $LatDeg 41
SET $LatMin 11
SET $LatSec 11
REM [trigger(moondate(2))] +1 MSG %"Full Moon%" %b%
fset _srtd() coerce("STRING", _no_lz(_am_pm(sunrise(today()))))
fset _sstd() coerce("STRING", _no_lz(_am_pm(sunset(today()))))
MSG Sun is up today from [_srtd()] to [_sstd()].%"%"%
````
## Revision History
### Version 0.7 2024-09-04
  - ISSUE 8: New version of remind complains if _sfun isn't defined. Output a header
	to define a function that does nothing if the function doesn't exist.
### Version 0.6 2019-03-01
  - Publish on GitHub and change license to MIT License
  - Add supporting files and explanation of how I use it
### version 0.5.2 2007-03-23
      - BUG: leadtime for recurring events had a max of 4 instead of DEFAULT_LEAD_TIME
      - remove project-lead-time, since Category was a non-standard attribute
      - NOTE: There is a bug in iCal::Parser v1.14 that causes multiple calendars to
              fail if a calendar with recurring events is followed by a calendar with no
              recurring events.  This has been reported to the iCal::Parser author.
### version 0.5.1 2007-03-21
      - BUG: Handle multiple calendars on STDIN
      - add --heading option for priority on section headers
### version 0.5 2007-03-21
      - Add more help options
      - --project-lead-time option
      - Supress printing of heading if there are no todos to print
### version 0.4
      - Version 0.4 changes all written or inspired by, and thanks to Mark Stosberg
      - Change to GetOptions
      - Change to pipe
      - Add --label, --help options
      - Add Help Text
      - Change to subroutines
      - Efficiency and Cleanup
### version 0.3
      - Convert to GPL (Thanks to Mark Stosberg)
      - Add usage
### version 0.2
      - add command line switches
      - add debug code
      - add SCHED _sfun keyword
      - fix typos
### version 0.1 - ALPHA CODE.

