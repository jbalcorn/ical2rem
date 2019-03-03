#!/bin/bash

r=`basename $0`

if [ $r == 'weeklyreminders.sh' ];
then
	t=14;
	w=Weekly;
elif [ $r ==  'dailyreminders.sh' ];
then
	t=3;
	w=Daily;
else
	t=5
	w=Test;
fi

cd .rem
for d in * ;
do
	if [ "$( ls -A $d/$w 2>/dev/null )" ];
	then
		echo "Sending a $w reminder to $d"
		ft=/tmp/$d-t-$$.txt
		f=/tmp/$d-$$.txt
		echo "Reminders for next $t days:" >> $f
		cat /dev/null > $d/ical2rem
		for c in $d/*.ics
		do
			calname=`basename $c .ics | tr a-z A-Z`
			cat $c 2>/dev/null | sed -e "s/^SUMMARY:/SUMMARY: {${calname}} /" \
				| sed -e 's/DT\([A-Z]*\);TZID=UTC:\([0-9T]*\)/DT\1:\2Z/' >> $ft
		done
		cat $ft | ~/bin/ical2rem.pl --label "Online Calendar" --heading "PRIORITY 9999" --lead-time $t >> $d/ical2rem
			if [ -e $d/reminders ];then r="${d}/reminders"; else r="${d}/ical2rem";fi
			/usr/bin/remind -q -iplain=1 $r >> $f
		echo "
All calendars can be accessed by logging into https://calendar.google.com/ as $d@jalcorn.net
" >> $f
		cat $f	| mail -s "$w Reminders for $d" $d@jalcorn.net;
		cat $f
		rm $f
		rm $ft
	fi; 
done
