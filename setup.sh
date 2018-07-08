#!/bin/sh
#
# setup.sh
# Takes care of running the necessary commands to install 
# the AllStarLink Asterisk 1.8 port on a system
# By Stacy Olivas KG7QIN - 6/23/18
#
# Version 0.03

# Revision history
# v0.01 - Stacy Olivas KG7QIN - 6/23/18
#         * Initial release
# v0.02 - Stacy Olivas KG7QIN - 07/03/18
#         * Added distro checks for debian based installs and distro based dependencies
# v0.03 - Stacy Olivas KG7QIN - 07/06/18
#         * Added in flag to use Asterisk prereq_install or apt-get build-dep for installing
#           the dependencies needed for Asterisk
#

# Show all the commands as they are executed
#set -e

MYNAME="AllStarLink-Asterisk 1.8 Beta v0.0.02-20180703"

#change this to false to turn off adding debugging symbols to asterisk
DEBUG=true

#change this to false to use the asterisk pre-requisite install script instead
USE_APT=true

#query system information
OS=`uname -s`
REV=`uname -r`
MACH=`uname -m`

#confirmation routine
confirm() {
	# call with a prompt string or use a default
    	read -r -p "${1:-Are you sure? [y/N]} " response
    	case "$response" in
        	[yY][eE][sS]|[yY]) 
            		true
        	    	;;
        	*)
           		 false
            		;;
    esac
}

#OS and release checks
if [ "$OS" != "Linux" ]; then
	echo >&2 "Your OS ($OS) is currently not supported by this script.  Aborting."
	exit 1
fi

if [ -f /etc/debian_version ]; then
	DIST="Debian `cat /etc/debian_version`"
	REV=$(grep '^VERSION_ID=' /etc/os-release | cut -d= -f2- | tr -d '"')
	ID=`lsb_release -si`
else
	echo >&2 "Sorry, only Debian based releases are currently supported by this script.  Aborting."
	exit 1
fi

if [ -f /etc/os-release ] ; then
        DIST=$(grep '^NAME=' /etc/os-release | cut -d= -f2- | tr -d '"')
        REV=$(grep '^VERSION_ID=' /etc/os-release | cut -d= -f2- | tr -d '"')
fi

LSB_DIST=$(lsb_release -si)
LSB_REV=$(lsb_release -sr)
LSB_CODENAME=$(lsb_release -sc)
if [ "$LSB_DIST" != "" ] ; then
	DIST=$LSB_DIST
fi
if [ "$LSB_REV" != "" ] ; then
	REV=$LSB_REV
fi
if [ "$LSB_CODENAME" != "" ]; then
	CODENAME=$LSB_CODENAME
fi

#Print out detected OS information
echo "System detected:"
echo "----------------"
echo "OS           : $OS"
echo "DIST         : $DIST"
echo "REV          : $REV"
echo "ID           : $ID"
echo "CODENAME     : $CODENAME"
#echo "LSB_DIST     : $LSB_DIST"
#echo "LSB_REV      : $LSB_REV"
#echo "LSB_CODENAME : $LSB_CODENAME"
echo " "

if [ "$CODENAME" = "" ] ; then
        echo >&2 " "
        echo >&2 "**** Cannot detect distrbution!  Ensure deb-src lines for <distro> main, <distro>-updates main, and security are present in your sources.list!"
        echo >&2 "**** Otherwise this script will fail."
        echo >&2 " "
fi

if confirm "Do you want to proceed with attempting to setup $MYNAME [y/N]?"; then
	echo >&2 " "
	echo >&2 "Continuting with setup...."
else
	echo >&2 " "
	echo >&2 "Exiting..."
	exit 1
fi

echo >&2 "*** Adding sources, updating, and installing prerequisites..."
case "$DIST" in
	Debian|debian)
		# Ensure that the necessary repos for Debian sources are added
		echo "deb-src http://mirrors.kernel.org/debian/ $CODENAME main" > /etc/apt/sources.list.d/asl-distro-sources.list
		echo "deb-src http://mirrors.kernel.org/debian/ ${CODENAME}-updates main" >> /etc/apt/sources.list.d/asl-distro-sources.list
		echo "deb-src http://security.debian.org/debian-security ${CODENAME}/updates main" >> /etc/apt/sources.list.d/asl-distro-sources.list
		;;
	Ubuntu|ubuntu)
		# Ensure that the necessary report for Ubuntu sources are added
		echo "deb-src http://us.archive.ubuntu.com/ubuntu $CODENAME main restricted" > /etc/apt/sources.list.d/asl-distro-sources.list
		echo "deb-src http://us.archive.ubuntu.com/ubuntu ${CODENAME}-updates main restricted" >> /etc/apt/sources.list.d/asl-distro-sources.list
		echo "deb-src http://security.ubuntu.com/ubuntu ${CODENAME}-security main restricted" >> /etc/apt/sources.list.d/asl-distro-sources.list
		;;
	*)
		echo >&2 "Unknown distro.  Aborting."
		exit 1
esac

# Update and install the requirements needed to build the system
apt-get update 
apt-get install -y git build-essential linux-headers-$(uname -r) linux-source libss7-dev wget apt-utils \
	dahdi-source dahdi-linux aptitude tcsh gawk libusb-dev doxygen

# Creating working directory and download the sources
mkdir /usr/work 
cd /usr/work 
git clone https://git.allstarlink.org/KG7QIN/AllStarLink-Asterisk-1.8.git 
wget https://github.com/KG7QIN/AllStarLink/raw/master/dahdi/dahdi-linux-complete-2.10.2%2B2.10.2.tar.gz

mkdir /etc/vpb
chmod a+x /usr/work/AllStarLink-Asterisk-1.8/contrib/scripts/install_prereq
if $USE_APT; then
        echo >&2 "*** Running apt-get build-dep asterisk..."
	apt-get build-dep asterisk
else

	echo >&2 "*** Running Asterisk prereq_install script..."
	# Run the Asterisk prereq install script
	cd /usr/work/AllStarLink-Asterisk-1.8 
	sh /usr/work/AllStarLink-Asterisk-1.8/contrib/scripts/install_prereq install 
fi

echo ?&2 "*** Installing unpackaged modules..."
sh /usr/work/AllStarLink-Asterisk-1.8/contrib/scripts/install_prereq install-unpackaged

# Fix some dependencies that may have changes due to the prereq script running
LIBSSL="libssl1.0-dev"
if [ "$DIST" = "Ubuntu" ]; then
	LIBSSL="libssl-dev"
fi

echo >&2 "Fixing $LIBSSL dependency..."

apt-get install -y --force-yes --reinstall $LIBSSL

echo >&2 "*** Building and installing DAHDI modules..."
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

echo -n >&2 "Building and installing $MYNAME"
if $DEBUG; then
	echo >&2 " with debugging..."
	L_DF="-g"
else
	echo >&2 "..."
	L_DF=" "
fi

# Build Asterisk 1.8 with ASL port
# By default debugging code is included in this build using the -g option below
cd /usr/work/AllStarLink-Asterisk-1.8/
make distclean 
./configure LDFLAGS="-zmuldefs -lasound" CFLAGS="-Wno-unused -Wno-all -Wno-int-conversion $L_DF" 
make menuselect.makeopts
menuselect/menuselect --enable app_rpt --enable chan_beagle --enable chan_tlb --enable chan_usrp --enable chan_rtpdir --enable chan_usbradio --enable chan_simpleusb --enable chan_echolink --enable app_gps --enable chan_voter --enable radio-tune-menu --enable simpleusb-tune-menu menuselect.makeopts
make
make install
make samples
make progdocs

# Now run the post-setup script

echo >&2 "*** Running post-setup script..."

cd /usr/work/AllStarLink-Asterisk-1.8
sh ./post_ast_setup.sh


