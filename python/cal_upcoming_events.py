#!/usr/bin/env python3
"""Ingests a icalendar and outputs all simplified calendar 
    that includes only events that occur within a span of time

Uses the module recurring_ical_events to calculate any older 
    recurring events that have occurrences within the defined span of time.

Args:
    infile: The file to read

    outfile: the file to write

    before: number of days before today to start the span

    after: number of days after today to start the span


"""
import sys
from datetime import datetime, timedelta, timezone
import argparse
import icalendar
import recurring_ical_events

def main():
    """main function that implements the script"""

    parser = argparse.ArgumentParser()

    # Adding optional argument
    parser.add_argument(
            "-i", "--infile", help = "Input ICS File", required=True)
    parser.add_argument(
            "-o", "--outfile", help = "Output ICS File", required=True)
    parser.add_argument(
            "-b", "--before", help = "Days Before to include in Output", default = 0, type=int)
    parser.add_argument(
            "-a", "--after", help = "Days After to include in Output", default = 30, type=int)

    # Read arguments from command line
    args = parser.parse_args()

    oldest = (datetime.now(timezone.utc) - timedelta(days=args.before)).date()
    newest = (datetime.now(timezone.utc) + timedelta(days=args.after)).date()

    cal = None
    try:
        with open(args.infile, 'r', encoding='utf-8') as fi:
            cal = icalendar.Calendar.from_ical(fi.read())
        fi.close()
    except ValueError: # reading an empty file
        pass

    if cal is not None:
        caltrim = icalendar.Calendar()
        #
        # Make sure to get the properties of the vCalendar itself
        for c in cal.walk('VCALENDAR'):
            for p in c.property_items(recursive=False):
                if p[0] not in ['BEGIN','END']:
                    caltrim.add(p[0],p[1])
        #
        # recurring_ical_events gets all events, recurring or not, that happen in the span
        for e in  recurring_ical_events.of(cal).between(oldest,newest):
            caltrim.add_component(e)

        if args.outfile != "-":
            f = open(args.outfile, 'w')
            sys.stdout = f

        sys.stdout.write(caltrim.to_ical().decode('utf-8'))
        sys.stdout = sys.__stdout__
        try:
            f.close()
        except:
            pass

if __name__ == "__main__":
    main()
