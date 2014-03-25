#!/bin/bash -  
#title          :main_menu.sh
#description    :Main Menu
#author         :Steven J. martin
#date           :20140221
#version        :${version}
#usage          :./main_menu.sh
#notes          :       
#bash_version   :4.2.45(1)-release
#============================================================================

p=`pwd`
RETURN="scripts/exit"
stty sane
clear

. ${p}/include/globals
. ${P}/include/include-all

log "Inform:Installing::MAIN. Start."

$DIALOG --default-item "CPU-MINING" --clear --title "{Knary} Mining Setup Menu Box" "$@" \
        --menu "Main Menu\
	\nThis is the Main Menu.\
	\nPlease choose from the available options below.\
	\nUse the UP/DOWN arrow keys, the first letter of the choice as a hot key, or the number keys 1-9 to choose an option.\
        \nChoose from the List Below:" 25 75 10 \
        "QUIT"  	"This is the TOP LEVEL menu. <QUIT/Cancel> will exit."\
        "CPU-MINING"  	"Install and - or Configure cpuminer/bfgminer cpu enabled."\
        "ASICS-MINING" 	"Install and - or Configure cgminer/bfgminer for ASICs."\
        "GPU-MINING" 	"Install and - or Configure cgminer/bfgminer."\
        "BITCOIN" 	"Install and - or Configure the Bitcoin daemon, and Client."\
        "LITECOIN" 	"Install and - or Configure the Litecoin daemon, and Client."\
        "PEERCOIN" 	"Install and - or Configure the Peercoin daemon, and Client."\
        "STRATUM"  	"Install and - or Configure a Stratum Proxy."\
        "SOLO-P2POOL"  	"Install and - or Execute SOLO and P2Pool Mining."\
        "MISC"  	"Misc Tools  - tools for the miner." 2>$tempfile

retval=$?

report-menu ${retval} ${RETURN}.sh ${RETURN}.sh ${RETURN}.sh 1

exit 0
