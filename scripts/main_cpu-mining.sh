#!/bin/bash -   
#title          :main_cpu-mining.sh
#description    :Main Entry for CPU-MINING
#author         :Steven J. Martin
#date           :20140222
#version        :${version}
#usage          :./main_cpu-mining.sh
#notes          :       
#bash_version   :4.2.45(1)-release
#============================================================================

p=`pwd`
RETURN="scripts/main_menu"
clear
stty sane

if [ -f "${p}/include/globals" ];then
	. ${p}/include/globals
	. ${p}/include/include-all
	
elif [ -f "../include/globals" ];then
	. ../include/globals
	. ../include/include-all
	echo "Oops running stand-alone."
fi

ids=`id|sed -e 's/([^)]*)//g'`
uid=`echo "$ids" | sed -e 's/^uid=//' -e 's/ .*//'`
gid=`echo "$ids" | sed -e 's/^.* gid=//' -e 's/ .*//'`

if [ -f "${P}/data/ENTRY" ];then
	myinstalloc=`cat ${P}/data/ENTRY`
else
	myinstalloc="$HOME"
fi

#
# Present the submenu
#
$DIALOG --default-item "CPU Miner" --clear --title "{Knary} CPUMINER Menu Box" "$@" \
        --menu "Sub Menu\
        \nThis is the CPU Mining Sub Menu.\
	\n<cpuminer> is a multi-threaded, highly optimized CPU miner for Litecoin, Bitcoin and other cryptocurrencies.\
        \nhttps://sourceforge.net/projects/cpuminer. License\
	\nGNU General Public License version 2.0 (GPLv2)\
	\n\n<BFGMiner> is a modular ASIC/FPGA miner written in C, featuring dynamic clocking, monitoring, and remote interface capabilities.\
	\nhttps://github.com/luke-jr/bfgminer/blob/bfgminer. License\
	\nGNU Public License version 3. See COPYING for details.\
        \n\n[You can use the UP/DOWN arrow keys, the first letter of the choice as a hot key, or the number keys 1-9 to choose an option.]\
        \nSelect CONFIGURE to perform configuration, or INSTALL to install it now!\
        \nChoose from the List Below:" 27 75 5 \
        "RETURN"        	"Return to the PREVIOUS menu. <Cancel> will also return."\
        "BFG-INSTALL"        	"Install bfgminer."\
        "CPU-INSTALL"        	"Install cpuminer."\
        "CPU-CONFIGURE" 	"Configure cpuminer."\
        "BFG-CONFIGURE" 	"Configure bfgminer." 2>$tempfile

retval=$?
report-menu ${retval} ${RETURN}.sh ${RETURN} ${RETURN}.sh ${RETURN}.sh 

exit
