#!/bin/bash -   
#title          :main_bitcoin-mining.sh
#description    :Main Entry for BITCOIN
#author         :Steven J. Martin
#date           :20140222
#version        :${version}
#usage          :./main_bitcoin.sh
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

if [ -f "${P}/data/ENTRY" ];then
	myinstalloc=`cat ${P}/data/ENTRY`
else
	myinstalloc="$HOME"
fi

#
# Present the submenu
#
$DIALOG --default-item "The BITCOIN Daemon and Client" --clear --title "{Knary} BitcoinD Menu Box" "$@" \
        --menu "Sub Menu\
        \nThis is the BITCOIN Daemon Sub Menu.\
	\n<Bitcoin> is a Daemon process that can run on this server.\
	\nThis Daemon process can be used in SOLO mining.\
	\nThe daemon and client processes download the entire BLOCK CHAIN.\
 	\nThis prcess can take more that a day to complete.\
        \n\nhttp://www.bitcoin.com.\
	\nLicense: GPL open source (unknown) tbd.\
        \n\n[You can use the UP/DOWN arrow keys, the first letter of the choice as a hot key, or the number keys 1-9 to choose an option.]\
        \nSelect CONFIGURE to perform configuration, or INSTALL to install it now!\
        \nChoose from the List Below:" 30 75 5 \
        "RETURN"        	"Return to the PREVIOUS menu. <Cancel> will also return."\
        "BITCOIN-INSTALL"       "Install the BITCOIN Daemon and client."\
        "BITCOIN-CONFIGURE" 	"Configure the BITCOIN Daemon." 2>$tempfile

retval=$?
report-menu ${retval} ${RETURN}.sh ${RETURN} ${RETURN}.sh ${RETURN}.sh

exit
