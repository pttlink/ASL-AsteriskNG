#!/bin/sh
#
# setup.sh
# Takes care of running the necessary commands to install 
# the AllStarLink Asterisk 1.8 port on a system
# By Stacy Olivas KG7QIN - 6/23/18
#
# Version 0.01
#

# Show all the commands as they are executed
set -x

# Ensure that the necessary repos for Debian are added to sources.list
echo "deb-src http://mirrors.kernel.org/debian/ stretch main" >> /etc/apt/sources.list 
echo "deb-src http://mirrors.kernel.org/debian/ stretch-updates main" >> /etc/apt/sources.list 
echo "deb-src http://security.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list

# Update and install the requirements needed to build the system
apt-get update 
apt-get install -y git build-essential linux-headers-$(uname -r) linux-source-4.9 libss7-dev wget apt-utils \
	dahdi-source dahdi-linux aptitude tcsh gawk libusb-dev doxygen


# Creating working directory and download the sources
mkdir /usr/work 
cd /usr/work 
git clone https://git.allstarlink.org/KG7QIN/AllStarLink-Asterisk-1.8.git 
wget https://github.com/KG7QIN/AllStarLink/raw/master/dahdi/dahdi-linux-complete-2.10.2%2B2.10.2.tar.gz

# Run the Asterisk prereq install script
mkdir /etc/vpb 
cd /usr/work/AllStarLink-Asterisk-1.8 
chmod a+x /usr/work/AllStarLink-Asterisk-1.8/contrib/scripts/install_prereq 
sh /usr/work/AllStarLink-Asterisk-1.8/contrib/scripts/install_prereq install 

# Fix some dependencies that may have changes due to the prereq script running
apt-get install -y libssl1.0-dev

# Extract, build and load the DAHDI modules
cd /usr/work/ 
tar -zxf dahdi-linux-complete-2.10.2+2.10.2.tar.gz 
cd dahdi-linux-complete-2.10.2+2.10.2/linux/drivers/dahdi/voicebus/ 
echo "--- GpakApi.c.orig     2018-06-09 18:54:14.205144479 -0700\n" \
"+++ GpakApi.c  2018-06-09 18:54:28.196956036 -0700\n" \
"@@ -1560,7 +1560,7 @@\n" \
"     if (DspStatus != 0)\n" \
"         return (RmmFailure);\n" \
" \n" \
"-      for (i = 0; i < MemoryLength_Word16; i++)\n" \
"+    for (i = 0; i < MemoryLength_Word16; i++) \n" \
"         pDest[i] = (short int) MsgBuffer[2 + i]; \n"  > patch1 
patch -ful GpakApi.c patch1

cd /usr/work/dahdi-linux-complete-2.10.2+2.10.2/tools/xpp/
sed -i -e 's/inline /extern inline /g' echo_loader.c

cd /usr/work/dahdi-linux-complete-2.10.2+2.10.2/
sed -i -e 's/configure /configure CFLAGS=-Wno-error /g' Makefile
cd tools/xpp 
sed -i -e 's/-I. -Ixtalk -Wall -Werror/-I. -Ixtalk -Wno-error/g' Makefile 
cd ../../ 
make distclean 
make 
make install 
make config

# Load DAHDI module
modprobe dahdi

# Build Asterisk 1.8 with ASL port
# By default debugging code is included in this build using the -g option below
cd /usr/work/AllStarLink-Asterisk-1.8/
make distclean 
./configure LDFLAGS="-zmuldefs -lasound" CFLAGS="-Wno-unused -Wno-all -Wno-int-conversion -g" 
make menuselect.makeopts
menuselect/menuselect --enable app_rpt --enable chan_beagle --enable chan_tlb --enable chan_usrp --enable chan_rtpdir --enable chan_usbradio --enable chan_simpleusb --enable chan_echolink --enable app_gps --enable chan_voter menuselect.makeopts
make
make install
make samples
make progdocs

# Now run the post-setup script

cd /usr/work/AllStarLink-Asterisk1.8
sh ./post_ast_setup.sh


