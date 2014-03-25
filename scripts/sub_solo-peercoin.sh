#!/bin/bash -   
#title          :btc_solo_mining_install.sh
#description    :Main Shell for SOLO PEERCOIN-MINING
#author         :Steven J. Martin
#date           :20140222
#version        :${version}
#usage          :./btc_solo_mining_install.sh
#notes          :       
#bash_version   :4.2.45(1)-release
#============================================================================

SUBject="solo-litecoin"
INSTLOC=`echo ${SUBject} | tr '[:lower:]' '[:upper:]'`
RETURN="scripts/main_solo-p2pool"
p=`pwd`

clear
stty sane
STEPs=10
I=1

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
	myinstalloc="${myinstalloc}/exec"
else
	myinstalloc="$HOME"
fi

log "Inform:Starting SOLO PEERCOIN installation. [${myinstalloc}]."

if [ "$(whoami)" != "root" ]; then
        MySudoCom='sudo '
else
        MySudoCom=''
fi

control_c()
{
        clear
        echo "=== [Ctrl+c] Interupt Exiting ==="
	stty sane
        sleep 5
        cd ${P};${P}/${RETURN}.sh
        exit $?
}
# trap keyboard interrupt (control-c)
trap control_c SIGINT

clear

runyesorno(){

if [ "${1}" ] ; then
	yesorno="n"
	read -p "Inform: Would you like to run this step? [\"${3}\"] Enter y/n (n)? " yesorno
		case "$yesorno" in
	y*|Y*)  ${1} ${2};;
		n*|N*)  echo "Skipped";;
	esac
fi

return 0
}

yesorno()
{

while true; do
    read -p "Please enter Y/N ${1}? (y/n)" yn
    case $yn in
        [Yy]* ) echo "Ok";OK=1;break;;
        [Nn]* ) echo "Ignore";OK=0;break;;
        * ) echo "Please answer yes or no.";;
    esac
done

return ${OK}
}

left=10
unit="seconds"
while test $left != 0
do

$DIALOG --sleep 1 \
	--title "Knary Info Box" "$@" \
        --infobox "The stratum mining proxy is not supported with PEERCOIN.\
		\nHowever it is possible to SOLO Mine PeerCoin by simply pointing your cgminer configured\
		  as ASICs to these configuration settings:\
		\n\"url\" : \"192.168.1.6:9902\",\
                \n\"user\" : \"ppcoinrpc\",\
                \n\"pass\" : \"4e32c804-your-password-here-a529cfa2\"\
		\n\n\n            You have $left $unit to read this..." 14 64
left=`expr $left - 1`
test $left = 1 && unit="second"
done

echo "Exiting ..."
read -p "Hit ENTER to continue..." ; echo "Ok"
sleep 2
cd ${P};${P}/${RETURN}.sh
exit
