#!/usr/bin/env bash
# blurlock = blurred screenshot as i3lock background
# REQUIREMENTS: imagemagick

# take screenshot
import -quality 1 -window root /tmp/screenshot.png

# manipulate image data
# magick /tmp/screenshot.png -blur 0x8 /tmp/screenshot.png
# magick /tmp/screenshot.png -type Grayscale /tmp/screenshot.png
# magick /tmp/screenshot.png -blur 0x8 -type Grayscale /tmp/screenshot.png
# magick /tmp/screenshot.png -gravity center -composite -matte /tmp/screenshot.png
magick /tmp/screenshot.png -scale 10% -scale 1000% /tmp/screenshot.png

# lock the screen
i3lock -i /tmp/screenshot.png

# sleep 1 adds a small delay to prevent possible race conditions with suspend
sleep 1

rm /tmp/screenshot.png

exit 0
