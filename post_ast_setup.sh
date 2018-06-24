#!/bin/sh
#
# post_ast_setup.sh
# Do post install items for AllStarLink usage
# By: Stacy Olivas KG7QIN - 6/23/18
#
# Version 0.01
#

set -x
/bin/cp /usr/work/AllStarLink-Asterisk-1.8/allstar/allstar/rc.updatenodelist /etc/asterisk/
/bin/cp -R /usr/work/AllStarLink-Asterisk-1.8/allstar/configs/* /etc/asterisk/
/bin/cp /usr/work/AllStarLink-Asterisk-1.8/allstar/id.gsm /etc/asterisk/
/bin/tar -zxf /usr/work/AllStarLink-Asterisk-1.8/allstar/sounds/ASL-RptSounds.tgz -C /var/lib/asterisk/sounds/

