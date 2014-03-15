#!/bin/bash -   
#title          :main_solo-p2pool.sh
#description    :Main Entry for P2POOL SOLO
#author         :Steven J. Martin
#date           :20140222
#version        :${version}
#usage          :./main_solo-p2pool.sh
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
$DIALOG --default-item "P2POOL SOLO Mining" --clear --title "{Knary} SOLO Menu Box" "$@" \
        --menu "Sub Menu\
        \nThis is the SOLO Sub Menu.\
        \n\nhttps://bitcointalk.org/index.php?topic=62842.0.\
	\nLicense: GPL open source (unknown) tbd.\
        \n\n[You can use the UP/DOWN arrow keys, the first letter of the choice as a hot key, or the number keys 1-9 to choose an option.]\
        \nSelect CONFIGURE to perform configuration, or INSTALL to install it now!\
        \nChoose from the List Below:" 30 75 5 \
        "RETURN"        	"Return to the PREVIOUS menu. <Cancel> will also return."\
        "P2POOL-BITCOIN"       	"Install for SOLO Bitcoin Mining."\
        "SOLO-BITCOIN" 		"Install for SOLO Bitcoin Mining." 2>$tempfile

retval=$?
report-menu ${retval} ${RETURN}.sh ${RETURN} ${RETURN}.sh ${RETURN}.sh

exit
