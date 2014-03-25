#!/bin/bash -   
#title          :main_litecoin.sh
#description    :Main Entry for LITECOIN
#author         :Steven J. Martin
#date           :20140222
#version        :${version}
#usage          :./main_stratum-mining.sh
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
$DIALOG --default-item "The LITECOIN Daemon and Client" --clear --title "{Knary} LitecoinD Menu Box" "$@" \
        --menu "Sub Menu\
        \nThis is the LITECOIN Daemon Sub Menu.\
	\n<Litecoin> is a Daemon process that can run on this server.\
	\nThis Daemon process can be used in SOLO mining.\
	\nThe daemon and client processes download the entire BLOCK CHAIN.\
 	\nThis prcess can take more that a day to complete.\
        \n\n//http://www.litecoin.com.\
	\nLicense: GPL open source (unknown) tbd.\
        \n\n[You can use the UP/DOWN arrow keys, the first letter of the choice as a hot key, or the number keys 1-9 to choose an option.]\
        \nSelect CONFIGURE to perform configuration, or INSTALL to install it now!\
        \nChoose from the List Below:" 30 75 5 \
        "RETURN"        	"Return to the PREVIOUS menu. <Cancel> will also return."\
        "LITECOIN-INSTALL"      "Install the LITECOIN Daemon and client."\
        "LITECOIN-CONFIGURE" 	"Configure the LITECOIN Daemon." 2>$tempfile

retval=$?
report-menu ${retval} ${RETURN}.sh ${RETURN} ${RETURN}.sh ${RETURN}.sh

exit
