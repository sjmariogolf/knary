#!/bin/bash -   
#title          :main_asics-mining.sh
#description    :Main Entry for ASICS-MINING
#author         :Steven J. Martin
#date           :20140222
#version        :${version}
#usage          :./main_asics-mining.sh
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
$DIALOG --default-item "ASICS Miner" --clear --title "{Knary} ASICSMINER Menu Box" "$@" \
        --menu "Sub Menu\
        \nThis is the ASICS Mining Sub Menu.\
	\n<cgminer> is a multi-pool FPGA and ASIC miner for bitcoin.\
        \nhttps://github.com/ckolivas/cgminer\
	\nLicense: GPLv3. See COPYING for details.\
	\nSEE ALSO API-README, ASIC-README and FGPA-README FOR MORE INFORMATION ON EACH.\
        \n\n[You can use the UP/DOWN arrow keys, the first letter of the choice as a hot key, or the number keys 1-9 to choose an option.]\
        \nSelect CONFIGURE to perform configuration, or INSTALL to install it now!\
        \nChoose from the List Below:" 27 75 5 \
        "RETURN"        	"Return to the PREVIOUS menu. <Cancel> will also return."\
        "CGM-INSTALL"        	"Install cgminer."\
        "CGM-CONFIGURE" 	"Configure cgminer." 2>$tempfile

retval=$?
report-menu ${retval} ${RETURN}.sh ${RETURN} ${RETURN}.sh ${RETURN}.sh

exit
