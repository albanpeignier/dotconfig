#!/bin/sh

xrandr --output HDMI-0 --off --output DP-0 --mode 2560x1440 --pos 0x0 --rotate normal \
       --output DP-1 --off \
       --output DP-2 --primary --mode 5120x1440 --pos 0x1440 --rotate normal \
       --output DP-3 --off \
       --output DP-4 --mode 2560x1440 --pos 2560x0 --rotate normal \
       --output DP-5 --off