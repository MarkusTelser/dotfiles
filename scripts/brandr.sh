#!/usr/bin/env bash
# brandr = xrandr + brightness

BRIGHTNESS=`xrandr --verbose | grep -m 1 -i brightness | cut -f2 -d ' '`
OUTPUT=`xrandr -q | grep " connected" | cut -f1 -d ' '`

# adjust value to range 0-1
VALUE=$(echo "$BRIGHTNESS + $1" | bc -l)
if [ $(echo "$VALUE < 0.0" | bc -l) -eq 1 ]; then
	VALUE="0.0"
elif [ $(echo "$VALUE > 1.0" | bc -l) -eq 1 ]; then
	VALUE="1.0"
fi

xrandr --output $OUTPUT --brightness $VALUE
notify-send -t 750 "brightness $( echo "$VALUE * 100 / 1" | bc )%"
echo "$VALUE * 100 / 1" | bc
