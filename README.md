# AllStarLink-Asterisk-1.8
Start of porting AllStarLink modules to Asterisk 1.8.32.3 

Welcome to what is intended to be the first major update of Asterisk for AllStarLink since 1.4.23-pre was forked many many years ago.
This repo is an import of my (KG7QIN's) repo with the same name from GitHub at https://github.com/KG7QIN/AllStarLink-Asterisk-1.8

The differences between this repo and that one are that as of 6/14/18, all the development to get this running will be done here instead of there.

This code does run, but there are some problems with it still.  The problems range from those that were "inherited" from the 1.4 code base of
the app_rpt "suite" of programs that runs AllStarLink, to differences within Asterisk 1.8 not working correctly due to internal changes.

Right now, everything is on the "master" branch.  This is due to no version being released yet.  That will change in the future as development moves forward.
After the remaining bits are ported over, I fully intend to create the first branch in this repo to push development along.

73s
Stacy
KG7QIN

---------------------------------------------------------------------------------------------------------------------------------
Updates:

06/03/18 - Merged changes of app_rpt.c from offical AllStarLink reporitory into app_rpt.c here.  A total of three changes were merged in, and this brings the version number up from 0.325 to 0.327.
06/14/18 - Imported KG7QIN's Repository from GitHub to the private AllStarLink reporisotry to continue development.
           Pushed Dockerfile that successfully builds this an Debian Stretch (9.4.0)

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

# Compiling
When compiling this code with a version of GCC that is newer than 4.9, you will likely encounter an error and everything will stop.
<br>
To fix this, you will need to have GCC-4.9 installed on your system and execute the following commands:
<br>
make clean<br>
export PTLIB_CONFIG=/usr/share/ptlib/make/ptlib-config<br>
./configure CC=gcc-4.9 CPP=cpp-4.9<br>
export CC=gcc-4.9<br>
export CPP=cpp-4.9<br>
make<br>
<br>
The code *should* compile with out problems -- just ignore the warnings.
