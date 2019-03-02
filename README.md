# ical2rem
The original iCal to Remind script, first released in 2005.

Reads iCal files and outputs remind-compatible files.   Tested ONLY with
  calendar files created by Mozilla Calendar/Sunbird. Use at your own risk.

## License
In 2005, this was released with the Gnu Public License V2.  However, I am changing it to the MIT License, since that provides greater freedom to do with this code what you want.

Copyright (c) 2005, 2007, 2019 Justin B. Alcorn
### Version 0.6 2019-03-01
  - Publish on GitHub and change license to MIT License
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

