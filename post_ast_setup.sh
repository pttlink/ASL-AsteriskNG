#!/bin/sh
#
# post_ast_setup.sh
# Do post install items for AllStarLink usage
# By: Stacy Olivas KG7QIN - 6/23/18
#
# Version 0.01
#
cd /usr/work/AllStarLink-Asterisk-1.8
cp ./allstar/rc.updatenodelist /etc/asterisk/
cp -R ./allstar/configs/* /etc/asterisk/
cp ./allstar/id.gsm /etc/asterisk/
tar -zxf ./allstar/sounds/ASL-RptSounds.tgz /var/lib/asterisk/sounds/

