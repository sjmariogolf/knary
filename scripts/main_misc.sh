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

#
# Present the submenu
#
$DIALOG --default-item "MISC Tools" --clear --title "{Knary} TOOL-BOX Menu Box" "$@" \
        --menu "Sub Menu\
        \nThis is the Toolbox Sub Menu.\
	\nGNU General Public License version 2.0 (GPLv2)\
	\n\"This is a place holder for tools.\
        \n\nYou can use the UP/DOWN arrow keys, the first letter of the choice as a hot key, or the number keys 1-9 to choose an option.\
        \Select the TOOL to perform it's task!\
        \nChoose from the List Below:" 25 75 5 \
        "RETURN"        "Return to the PREVIOUS menu. <Cancel> will also return."\
        "LIST-HARDWARE" 	"List hardware."\
        "BITCOND-TOOLS"      	"Various BITCOIN daemon Tools."\
        "LITECOIND-TOOLS"      	"Various LITECOIN daemon Tools." 2>$tempfile

retval=$?

report-menu ${retval} ${RETURN}.sh ${RETURN} ${RETURN}.sh ${RETURN}.sh 

exit
