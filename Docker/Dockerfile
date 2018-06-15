# AllStarLink 1.8 Test Port
#
# VERSION 0.0.12
#
FROM debian:stretch

MAINTAINER Stacy Olivas <kg7qin@arrl.net>

# What command to run when container is started
ENTRYPOINT ["/usr/sbin/asterisk"]

# Expose SIP and IAX2 Ports
EXPOSE 4060 4569

# update debian and install requirements/dependencies to build
RUN echo "deb-src http://mirrors.kernel.org/debian/ stretch main" >> /etc/apt/sources.list \
    	&& echo "deb-src http://mirrors.kernel.org/debian/ stretch-updates main" >> /etc/apt/sources.list \
    	&& echo "deb-src http://security.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list

RUN apt-get update \
    	&& apt-get install -y git build-essential linux-headers-$(uname -r) linux-source-4.9 libss7-dev wget apt-utils \
         dahdi-source dahdi-linux aptitude tcsh gawk

RUN mkdir /usr/work \
	&& cd /usr/work \
	&& git clone https://github.com/KG7QIN/AllStarLink-Asterisk-1.8.git \
    	&& wget https://github.com/KG7QIN/AllStarLink/raw/master/dahdi/dahdi-linux-complete-2.10.2%2B2.10.2.tar.gz 
# Run Asterisk Prereq install script
RUN mkdir /etc/vpb \
    	&& cd /usr/work/AllStarLink-Asterisk-1.8 \
    	&& chmod a+x /usr/work/AllStarLink-Asterisk-1.8/contrib/scripts/install_prereq \
    	&& /usr/work/AllStarLink-Asterisk-1.8/contrib/scripts/install_prereq install \
    	&& apt-get install -y libssl1.0-dev

# Extract, build and load DAHDI modules
RUN cd /usr/work/ \
    	&& tar -zxf dahdi-linux-complete-2.10.2+2.10.2.tar.gz \
    	&& cd dahdi-linux-complete-2.10.2+2.10.2/linux/drivers/dahdi/voicebus/ \ 
	&& echo "--- GpakApi.c.orig	2018-06-09 18:54:14.205144479 -0700\n" \
"+++ GpakApi.c	2018-06-09 18:54:28.196956036 -0700\n" \
"@@ -1560,7 +1560,7 @@\n" \
"     if (DspStatus != 0)\n" \
"         return (RmmFailure);\n" \
" \n" \
"-	for (i = 0; i < MemoryLength_Word16; i++)\n" \
"+    for (i = 0; i < MemoryLength_Word16; i++) \n" \
"         pDest[i] = (short int) MsgBuffer[2 + i]; \n"  > patch1 \
	&& patch -ful GpakApi.c patch1

RUN cd /usr/work/dahdi-linux-complete-2.10.2+2.10.2/tools/xpp/ \
	&& sed -i -e 's/inline /extern inline /g' echo_loader.c
	
RUN cd /usr/work/dahdi-linux-complete-2.10.2+2.10.2/ \
	&& sed -i -e 's/configure /configure CFLAGS=-Wno-error /g' Makefile \
	&& cd tools/xpp \
	&& sed -i -e 's/-I. -Ixtalk -Wall -Werror/-I. -Ixtalk -Wno-error/g' Makefile \
	&& cd ../../ \
    	&& make distclean \
    	&& make \
	&& make install \
    	&& make config 

# Build Asterisk 1.8 port
RUN cd /usr/work/AllStarLink-Asterisk-1.8/ \
    	&& make distclean \
    	&& ./configure LDFLAGS=-zmuldefs CFLAGS=-Wno-unused \
        && make menuselect.makeopts || : \
        && menuselect/menuselect --enable app_rpt --disable chan_beagle --disable chan_tlb --disable chan_usrp --disable chan_rtpdir menuselect.makeopts || : \
	&& rm channels/chan_usrp.c \
	&& rm channels/chan_rtpdir.c \
        && make \ 
	&& make install

