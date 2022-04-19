#!/bin/bash

# https://www.tdkyo.com/raspberry-pi/auto-check-and-reconnect-wifi/
# https://forums.raspberrypi.com/viewtopic.php?t=262979

if [ $? != 0 ]
then
    sudo ip link set wlan0 down
    sleep 15
    sudo ip link set wlan0 up
    sleep 15
    sudo dhcpcd
else
    echo "nothing wrong"
fi
