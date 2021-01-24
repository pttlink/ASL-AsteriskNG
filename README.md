<p align="right">
    <a href="https://github.com/pttlink/ASL-AsteriskNG/stargazers"><img src="https://img.shields.io/github/stars/pttlink/ASL-AsteriskNG.svg?style=social&label=Star" style="margin-left:5em"></a>
    <a href="https://github.com/pttlink/ASL-AsteriskNG/network/members"><img src="https://img.shields.io/github/forks/pttlink/ASL-AsteriskNG.svg?style=social&label=Fork"></a>
    <a href="https://github.com/pttlink/ASL-AsteriskNG/watchers"><img alt="GitHub watchers" src="https://img.shields.io/github/watchers/pttlink/ASL-AsteriskNG?style=social"></a>
</p>

<p align="center">
    <a href="https://wiki.pttlink.org/wiki/ASL-AsteriskNG/"><img src="https://img.shields.io/badge/Docs-wiki-brightgreen.svg?style=for-the-badge"></a>
    <a href="https://github.com/pttlink/ASL-AsteriskNG/issues"><img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg?style=for-the-badge"></a>
    <a href="https://github.com/pttlink/ASL-AsteriskNG/issues"><img src="https://img.shields.io/github/issues-closed/pttlink/ASL-AsteriskNG.svg?style=for-the-badge"></a>
    <a href="https://github.com/pttlink/ASL-AsteriskNG/pulls"><img src="https://img.shields.io/github/issues-pr-closed/pttlink/ASL-AsteriskNG.svg?style=for-the-badge"></a>
</p>
<p align="center">
    <a href="https://github.com/pttlink/ASL-AsteriskNG/blob/master/LICENSE"><img src="https://img.shields.io/badge/License-GPL-blue.svg?style=for-the-badge"></a>
    <a href="https://github.com/pttlink/ASL-AsteriskNG/releases"><img alt="GitHub all releases" src="https://img.shields.io/github/downloads/pttlink/ASL-AsteriskNG/total?color=lightgreen&style=for-the-badge"></a>
</p>



# ASL-AsteriskNG
Welcome to the ASL-AsteriskNG "Next Generation" client.  

This code is the basis for what will be the ASL 1.10 client release known asl the ASL-NG Client.

## Wiki Page

Visit the ASL-AsteriskNG Wiki page at https://wiki.pttlink.org/wiki/ASL-AsteriskNG

This page contains the latest information on ASL-AsteriskNG.

## History

The work in this repository is the result of Stacy Olivas, KG7QIN, having spent the time to port the available app_rpt code from the
ASL Asterisk 1.4 code base to Asterisk 1.8.  This repo is an import of my (KG7QIN's) repo with the same name from GitHub at 
https://github.com/KG7QIN/AllStarLink-Asterisk-1.8.  However this repo contains updates since the fork and should be considered the
main upstream for this code.  Additionally, this repository was renamed as ASL-AsteriskNG to reflect that it is the Next Generation
client for app_rpt.

The code in this repository should be considered ALPHA quality code.   While it has been successully compiled and tested on
Deban 9.4 and Ubuntu 16.04 system and should have no issues running on later versions of these distros, there are still bugs in this code
that need to be addressed before it is considered stable.

* This code is what runs the PTTLink telephone portal and formerly ran the AllStarLink telephone portal.

This code does run, but there are some problems with it still.  The problems range from those that were "inherited" from the 1.4 code base of
the app_rpt "suite" of programs that runs AllStarLink to differences within the Asterisk 1.8 code base that are causing issue.

If you submit PR please make sure they are done against the devel branch.  The master branch will be used to track releases of code
once it is considered stable enough for a release.

---------------------------------------------------------------------------------------------------------------------------------

Note:  The following is from the original repo.  These directions will be updated in the near future and placed in the repository wiki to
make it easier to maintain.

Please use the following instructions to build and install this port on a Debian 9.4 system.  Instructions for building a Docker image are also included.

# Compiling

This code has been successfully compiled on both Debian Stretch (9.4.0) and Ubuntu 16.04.  For Ubuntu 16.04, you will only need to use libdev-ssl and not libdev1.0-ssl.  The following commands below will download the files compile them and install them.

## Using setup.sh script

To automatically build and install the port and all associated files:
<pre>
# https://github.com/pttlink/ASL-AsteriskNG/raw/master/setup.sh
# sh setup.sh 
</pre>

## Compiling by hand

If you prefer to do all the steps yourself:

<pre>
# Ensure that the necessary repos for Debian are added to sources.list
# echo "deb-src http://mirrors.kernel.org/debian/ stretch main" >> /etc/apt/sources.list 
# echo "deb-src http://mirrors.kernel.org/debian/ stretch-updates main" >> /etc/apt/sources.list 
# echo "deb-src http://security.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list

# Update and install the requirements needed to build the system
# apt-get update 
# apt-get install -y git build-essential linux-headers-$(uname -r) linux-source-4.9 libss7-dev wget apt-utils \
	dahdi-source dahdi-linux aptitude tcsh gawk libusb-dev doxygen

# Download the sources
# cd /usr/work 
# git clone https://github.com/pttlink/ASL-AsteriskNG.git 
# wget https://github.com/KG7QIN/AllStarLink/raw/master/dahdi/dahdi-linux-complete-2.10.2%2B2.10.2.tar.gz

# Run the Asterisk prereq install script
# mkdir /etc/vpb 
# cd /usr/work/ASL-AsteriskNG
# sh /usr/work/ASL-AsteriskNG/contrib/scripts/install_prereq install 

# Fix some dependencies that may have changed due to the prereq script running
# apt-get install -y libssl1.0-dev

# Extract, build and load the DAHDI modules
# cd /usr/work/ 
# tar -zxf dahdi-linux-complete-2.10.2+2.10.2.tar.gz 
# cd /usr/work/dahdi-linux-complete-2.10.2+2.10.2/tools/xpp/
# sed -i -e 's/inline /extern inline /g' echo_loader.c

# cd /usr/work/dahdi-linux-complete-2.10.2+2.10.2/
# sed -i -e 's/configure /configure CFLAGS=-Wno-error /g' Makefile
# cd tools/xpp 
# sed -i -e 's/-I. -Ixtalk -Wall -Werror/-I. -Ixtalk -Wno-error/g' Makefile 
# cd ../../ 
# make distclean 
# make 
# make install 
# make config

# Load DAHDI module
# modprobe dahdi

# Build ASL-AsteriskNG with ASL port
# By default debugging code is included in this build using the -g option below
# cd /usr/work/ASL-AsteriskNG/
# make distclean 
# ./configure LDFLAGS="-zmuldefs -lasound" CFLAGS="-Wno-unused -Wno-all -Wno-int-conversion -g" 
# make menuselect.makeopts
# menuselect/menuselect --enable app_rpt --enable chan_beagle --enable chan_tlb --enable chan_usrp --enable chan_rtpdir --enable chan_usbradio --enable chan_simpleusb --enable chan_echolink --enable app_gps --enable chan_voter --enable radio-tune-menu --enable simpleusb-tune-menu  menuselect.makeopts
# make
# make install
# make samples
# make progdocs

# Now run the post-setup script
# cd /usr/work/ASL-AsteriskNG
# sh ./post_ast_setup.sh
</pre> 

# Using Docker to run
A Dockerfile has been created that will allow you to build this code as it currently is and run it.  
The base image is Debian Stretch (9.4.0).

To build:<br/>
Grab the Dockerfile from the Docker directory and place in directory by itself
<pre>
# docker build -t asl1.8-test3 . 
</pre>

To run:
<pre>
# docker run -v /dev/dahdi:/dev/dahdi -v /dev/dsp:/dev/dsp  --privileged --net=host -d --name ASL -i -t asl1.8-test3
</pre>

Note:  You will need to have successfully built the DAHDI kernel modules with the AllStarLink patches and have this module loaded into your host OS's kernel. 

Make sure that you connect to the container's shell and configure the node's rpt.conf and other required files under /etc/asterisk.  Example files are included.

To connect to the Asterisk console:
<pre>
# docker exec -it ASL sh /usr/sbin/asterisk -cvvvr

For just a shell prompts on the running container:
# docker exec -it ASL sh
</pre>

When the container is started, it will automatically kick off running the /etc/asterisk/rc.updatenodelist file and asterisk as well.

You can cleanly shutdown Asterisk and stop the container by running from the Asterisk CLI "core stop gracefully" or "core stop now"

Once you configure the node you will need to either reload asterisk or stop and start the container again.

- - - -

Congratulations!  If all went well, you will have a complete install of Asterisk 1.8 with the AllStarLink app_rpt programs on your computer.

Note that these steps are purposely compiling Asterisk and modules with debugging info (-g).  This is to make it easier to collect information about various problems while testing the port out.

Please test and abuse this and let me know what problems you find.

There are also some changes that you will need to make to your extensions.conf file (or you an opt to convert it to either extensions.ael or extensions.lua).

One of these changes is how app_rpt is called.

Convert any of your lines that are similar to this:
Rpt(${EXTEN:1}|Pv|${CALLERID(name)}-P)

To this:

Rpt(${EXTEN:1},Pv,${CALLERID(name)}-P)

Commas have replaced the | in Astersk 1.8's dialplan.  Failure to update your extensions.conf will result in Asterisk not loading it correctly. 
