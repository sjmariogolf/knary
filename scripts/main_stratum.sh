#!/bin/bash -   
#title          :main_stratum-mining.sh
#description    :Main Entry for STRATUM
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
$DIALOG --default-item "STRATUM Proxy" --clear --title "{Knary} STRATUM Menu Box" "$@" \
        --menu "Sub Menu\
        \nThis is the STRATUM Proxy Sub Menu.\
	\n<stratum> is a bridge between old HTTP/getwork protocol and the Stratum mining protocol.\
        \nhttps://github.com/slush0/stratum-mining-proxy.\
	\nLicense: GPL open source (unknown) tbd.\
        \n\n[You can use the UP/DOWN arrow keys, the first letter of the choice as a hot key, or the number keys 1-9 to choose an option.]\
        \nSelect CONFIGURE to perform configuration, or INSTALL to install it now!\
        \nChoose from the List Below:" 27 75 5 \
        "RETURN"        	"Return to the PREVIOUS menu. <Cancel> will also return."\
        "SLUSH0-INSTALL"        	"Install the SLUSH0 Stratum Proxy."\
        "SLUSH0-CONFIGURE" 	"Configure the SHUSH0 Stratum Proxy." 2>$tempfile

retval=$?
report-menu ${retval} ${RETURN}.sh ${RETURN} ${RETURN}.sh ${RETURN}.sh

exit
