# AllStarLink-Asterisk-1.8
Welcome to AllStar Asterisk 1.8 Beta.

This repository contains all the app_rpt code from the Asterisk 1.4 code base ported over to Asterisk 1.8.

This code has been successfully tested on Debian 9.4 and Ubuntu 16.04 systems.

This port intended to be the first major update of Asterisk for AllStarLink since 1.4.23-pre was forked many many years ago.
This repo is an import of my (KG7QIN's) repo with the same name from GitHub at https://github.com/KG7QIN/AllStarLink-Asterisk-1.8

The differences between this repo and that one are that as of 6/14/18, all the development to get this running will be done here instead of there.

This code does run, but there are some problems with it still.  The problems range from those that were "inherited" from the 1.4 code base of
the app_rpt "suite" of programs that runs AllStarLink to differences within the Asterisk 1.8 code base that are causing issue.

Right now, everything is on the "master" branch.  This is due to no version being released yet.  That will change in the future as development moves forward.
After the remaining bits are ported over, I fully intend to create the first branch in this repo to push development along.

73<br/>
Stacy<br/>
KG7QIN<br/>

---------------------------------------------------------------------------------------------------------------------------------
Updates:

<pre>
06/03/18 - Merged changes of app_rpt.c from offical AllStarLink reporitory into app_rpt.c here.  A total of three changes were merged in, and this brings the version number up from 0.325 to 0.327.

06/14/18 - Imported KG7QIN's Repository from GitHub to the private AllStarLink reporisotry to continue development.
           Pushed Dockerfile that successfully builds this on Debian Stretch (9.4.0)
           
06/18/18 - Finished porting the remaining bits over to Asterisk 1.8 - chan_rptdir, chan_tlb, chan_usrp, and chan_beagle all compile and successfully load into Asterisk 1.8.  
           The Dockerfile and compile info below have been updated to build all the modules now with debugging info enabled.

06/23/18 - radio-tune-menu and simpleusb-tune-menu added in to build process.  Building and installing will now include examples, program docs, and ASL sample config files.  setup.sh created for
           install on a Debian 9.4.0 system.  Dockerfile updated with startup file that that will run rc.updatenodes and asterisk when a container is started.
</pre>

---------------------------------------------------------------------------------------------------------------------------------

Please use the following instructions to build and install this port on a Debian 9.4 system.  Instructions for building a Docker image are also included.

# Compiling

This code has been successfully compiled on both Debian Stretch (9.4.0) and Ubuntu 16.04.  For Ubuntu 16.04, you will only need to use libdev-ssl and not libdev1.0-ssl.  The following commands below will download the files compile them and install them.

## Using setup.sh script

To automatically build and install the port and all associated files:
<pre>
# wget https://git.allstarlink.org/KG7QIN/AllStarLink-Asterisk-1.8/blob/master/setup.sh
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
# git clone https://git.allstarlink.org/KG7QIN/AllStarLink-Asterisk-1.8.git 
# wget https://github.com/KG7QIN/AllStarLink/raw/master/dahdi/dahdi-linux-complete-2.10.2%2B2.10.2.tar.gz

# Run the Asterisk prereq install script
# mkdir /etc/vpb 
# cd /usr/work/AllStarLink-Asterisk-1.8 
# sh /usr/work/AllStarLink-Asterisk-1.8/contrib/scripts/install_prereq install 

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

# Build Asterisk 1.8 with ASL port
# By default debugging code is included in this build using the -g option below
# cd /usr/work/AllStarLink-Asterisk-1.8/
# make distclean 
# ./configure LDFLAGS="-zmuldefs -lasound" CFLAGS="-Wno-unused -Wno-all -Wno-int-conversion -g" 
# make menuselect.makeopts
# menuselect/menuselect --enable app_rpt --enable chan_beagle --enable chan_tlb --enable chan_usrp --enable chan_rtpdir --enable chan_usbradio --enable chan_simpleusb --enable chan_echolink --enable app_gps --enable chan_voter --enable radio-tune-menu --enable simpleusb-tune-menu  menuselect.makeopts
# make
# make install
# make samples
# make progdocs

# Now run the post-setup script
# cd /usr/work/AllStarLink-Asterisk1.8
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

Please test and abuse this and let me know what problems you find. Ideally, we can use the issues page at https://git.allstarlink.org/KG7QIN/AllStarLink-Asterisk-1.8/issues to track any problems that are found and resolved.


There are also some changes that you will need to make to your extensions.conf file (or you an opt to convert it to either extensions.ael or extensions.lua).

One of these changes is how app_rpt is called.

Convert any of your lines that are similar to this:
Rpt(${EXTEN:1}|Pv|${CALLERID(name)}-P)

To this:

Rpt(${EXTEN:1},Pv,${CALLERID(name)}-P)

Commas have replaced the | in Astersk 1.8's dialplan.  Failure to update your extensions.conf will result in Asterisk not loading it correctly. 
