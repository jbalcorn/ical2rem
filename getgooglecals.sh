#!/bin/sh
#
#   Get google calendars, fix issues caused by changes in Google calendars, and remove all past events.
#
#   Obviously, I've removed the private hashes from private calendars.
#
cd ~/calendars
wget -q -O full/justin.ics --no-check-certificate https://www.google.com/calendar/ical/jbalcorn\%40gmail.com/private-aaaaaaaaaaaaaaaaaaaaaaaaaa/basic.ics
wget -q -O full/family.ics --no-check-certificate https://www.google.com/calendar/ical/jalcorn.net_aaaaaaaaaaaaaaaaaaaaaaaaaa\%40group.calendar.google.com/private-6c42a79dec0b3b3bb7b9b0ebf9776bc1/basic.ics
wget -q -O full/son1.ics --no-check-certificate https://www.google.com/calendar/ical/son1\%40jalcorn.net/private-aaaaaaaaaaaaaaaaaaaaaaaaaa/basic.ics
wget -q -O full/vmd.ics --no-check-certificate https://calendar.google.com/calendar/ical/chuh.org_0pmkefjkiqc4snoel7occlslh8%40group.calendar.google.com/public/basic.ics

for i in full/*.ics;do
                cat $i 2>/dev/null | sed -e 's/DT\([A-Z]*\);TZID=UTC:\([0-9T]*\)/DT\1:\2Z/' > /tmp/temp.ics
                cp /tmp/temp.ics $i
done

~/bin/cal_futureonly.pl --infile=full/justin.ics --file=justin.ics
~/bin/cal_futureonly.pl --infile=full/family.ics --file=family.ics
~/bin/cal_futureonly.pl --infile=full/son1.ics --file=son1.ics
~/bin/cal_futureonly.pl --infile=full/vmd.ics --file=vmd.ics
