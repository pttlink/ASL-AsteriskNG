# AllStarLink-Asterisk-1.8
Start of porting AllStarLink modules to Asterisk 1.8.32.3 

Welcome to what is intended to be the first major update of Asterisk for AllStarLink since 1.4.23-pre was forked many many years ago.
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
           Pushed Dockerfile that successfully builds this an Debian Stretch (9.4.0)
</pre>

---------------------------------------------------------------------------------------------------------------------------------
I'm placing this code here so that:

1.  It doesn't get lost
 
2.  Hopefully I can start some collaboration on porting this/squashing bugs

The code here in this porting attempt is meant to be a 'gateway' to porting it to Asterisk 13.  Since there have been
changes between 1.4 and 1.8, some things in the base code were added back in to support the proper functioning of
app_rpt.  Asterisk 1.8 also changed the way many of the channel drivers, etc are called.  Since this seems to be the norm
between version of Asterisk, I believe that 13 has a lot of changes that would render trying to compile the AllStarLink 
modules against it in their current form futile.  

Included in this repository is my attempts at porting AllStarLink to use Asterisk 1.8.32.3.

Some things to note:
This is very ALPHA quality code.  Use at your own risk!  While I have been able to successfully 
connect to the AllStarLink network with what is included here, some things don't work.

This includes:
EchoLink DTMF - the chan_echolink module currently has problems with processing DTMF passed to it
Sometimes app_rpt will fail in connecting to other sites.  This deals with some strangeness with the CODECS and how they
are neogtiated using the IAX2 channel setup.

Modules that have been ported and included:<br>
app_rpt<br>
app_gps<br>
chan_echolink<br>
chan_simpleusb<br>
chan_usbradio<br>
chan_voter<br>

Modules that have not yet been ported:<br>
chan_beagle<br>
chan_rptdir<br>
chan_tlb<br>
chan_usrp<br>


None of the modules that have been ported and deal with radios have been tested.  While they successfully compile and
load into asterisk (no panics, etc), there is NO GUARANTEE that they will actually work as intended.

There is a fair bit of debugging code in this as well.  

You will need to compile and install the DAHDI driver code located here https://github.com/KG7QIN/AllStarLink/tree/master/dahdi
 (this is DAHDI 2.10.2+2.10.2 that has been modified to replace the missing pieces needed by the AllStarLink modules to run).
 
 There currently are no plans to offer precompiled versions of this code to download an install.  To use this, you need to be able to successfully compile Asterisk 1.8.32.3 on your system.  Failure to successfully compile Asterisk will also result in you being unable to compile the code here.
 
 Also, don't attempt to just drop the ported app_ and chan_ pieces here to an existing version/install of Asterisk 1.8.32.3 and expect them to run.  The modules will load, but app_rpt will not work (see above for details).
 
 My test system is running Ubuntu 15.04 and I am using GCC 4.9 to compile this code.  Newer versions of GCC may not work with the code as it currently is.

# Using Docker to run
A Dockerfile has been created that will allow you to build this code as it currently is and run it.  
The base image is Debian Stretch (9.4.0).
There are no AllStarLink config files included in /etc/asterisk.  You will need to either import them into your Docker build yourself or share them from the host OS using -v

To build:<br/>
Grab the Dockerfile from the Docker directory and place in directory by itself
<pre>
# docker build -t asl1.8-test1 . 
</pre>

To run:
<pre>
# docker run -v /etc/asterisk:/etc/asterisk -v /var/lib/asterisk/sounds:/var/lib/asterisk/sounds -v /var/log/asterisk:/var/log/asterisk -v /dev/dahdi:/dev/dahdi -v /dev/dsp:/dev/dsp  --privileged --net=host -d --name ASL --rm -i -t asl1.8-test1 -gcvvv
</pre>

Note:  You will need to have successfully build the DAHDI kernel modules with the AllStarLink patches and have this module loaded into your host OS's kernel.  You will also need to have the required config files in /etc/asterisk, sound files in /var/lib/asterisk/sound, and a log file directory of /var/log/asterisk for this to run.

To connect to the Asterisk console:
<pre>
# docker exec -it ASL sh /usr/sbin/asterisk -cvvvr
</pre>

This container will automatically be destroyed upon exit

You will also need to run the rd.updatenodelist script before you can connect to other nodes.
Assuming you have rc.updatenodelist sitting in /etc/asterisk, you would run this:
<pre>
# docker exec -it ASL sh
# /etc/asterisk/rc.updatenodelist &
# asterisk -cvvvvr
</pre>

When exiting asterisk your terminal window may freeze due to rc.updatenodelist running in the background.  Just close the window to fix this.

# Compiling

This code has been successfully compiled on both Debian Stretch (9.4.0) and Ubuntu 16.04.  For Ubuntu 16.04, you will only need to use libdev-ssl and not libdev1.0-ssl.  The following commands below will download the files from KG7QIN's GitHub repository (soon to be updated for here), compile them and install them.

<pre>
# apt-get install git build-essential linux-headers-$(uname -r) linux-source-4.9 libss7-dev
# apt-get install dahdi-source dahdi-linux
# apt-get build-dep asterisk
# apt-get install libssl1.0-dev
# mkdir /usr/work
# git clone https://github.com/KG7QIN/AllStarLink-Asterisk-1.8.git
# wget https://github.com/KG7QIN/AllStarLink/raw/master/dahdi/dahdi-linux-complete-2.10.2%2B2.10.2.tar.gz
# tar -zxf dahdi-linux-complete-2.10.2+2.10.2.tar.gz
# cd dahdi-linux-complete-2.10.2+2.10.2
# make clean
# make
# make install
# make config

# modprobe dahdi
# modprobe dahdi-transcode 

(Note that these two are probably not needed, but if you are going to run asterisk in a VM without any hardware, I recommend adding these to the /etc/modules file so that they load at startup.  It also ensure that DAHDI is loaded in if you try to start Asterisk right after installing and getting the missing pieces over/setup)

# cd ..
# cd AllStarLink-Asterisk-1.8/
# make clean
# ./configure LDFLAGS=-zmuldefs CFLAGS=-Wno-unused
# make menuselect
  (then select save and exit.  this just rebuilds the options for making the various pieces of Asterisk which includes app_rpt.c)
# make
# make install 
</pre> 

If all goes well, you will have an Asterisk 1.8 system with the app_rpt "suite" of ported modules/software installed on your system.  You will still need to bring over the necessary config files from AllStarLink for your node to function.

