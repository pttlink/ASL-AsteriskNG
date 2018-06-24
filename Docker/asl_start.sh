#!/bin/sh
#
# Asterisk 1.8 start script for AllStarLink
# By: Stacy Olivas - KG7QIN - 6/23/18
#
# Version 0.01
#

# Start /etc/asterisk/rc.updatenodelist in the background
/etc/asterisk/rc.updatenodelist &

# Start asterisk
/usr/sbin/asterisk -gc


