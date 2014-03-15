#!/bin/bash -   
#title          :sub_slush0-install.sh
#description    :Install for SLUSH0-PROXY
#author         :Steven J. Martin
#date           :20140222
#version        :${version}
#usage          :./sub_slush0-install.sh
#notes          :       
#bash_version   :4.2.45(1)-release
#============================================================================

SUBject="stratum-mining-proxy"
INSTLOC=`echo ${SUBject} | tr '[:lower:]' '[:upper:]'`
RETURN="scripts/main_stratum"
MINEREL="stratum-mining-proxy"
MINERDR=`echo ${MINEREL} | cut -d'-' -f1,2,3`
CFLAGS="-O3"
p=`pwd`

if [ -f "${p}/include/globals" ];then
	. ${p}/include/globals
	. ${p}/include/include-all
	
elif [ -f "../include/globals" ];then
	. ../include/globals
	. ../include/include-all
	echo "Oops running stand-alone."
fi

log "Inform:Starting slush0 stratum mining proxy installation."

if [ "$(whoami)" != "root" ]; then
        MySudoCom='sudo '
else
        MySudoCom=''
fi

if [ -f "${P}/data/ENTRY" ];then
	myinstalloc=`cat ${P}/data/ENTRY`
	myinstalloc="${myinstalloc}/exec"
else
	myinstalloc="$HOME"
fi
for f in pooler
do
	rm -f ${myinstalloc}/${f}*
	rm -f /etc/yum.repos.d/${f}*
done

control_c()
{
	clear
        echo "=== [Ctrl+c] Interupt Exiting ==="
        killall python
        sleep 5
        cd ${P};${P}/${RETURN}.sh
        exit $?
}
# trap keyboard interrupt (control-c)
trap control_c SIGINT

#
# Present the submenu Ask for the install location
#

returncode=0
while test $returncode != 1 && test $returncode != 250
do
exec 3>&1
value=`$DIALOG --clear --ok-label "Create" \
	  --backtitle "$backtitle" "$@" \
	  --inputmenu "Choose the desired installation path \
or continue with default values.\nThe products may work best from the default location(s)." \
12 65 10 \
	"INSTALL-PATH:"		"${myinstalloc}" \
2>&1 1>&3`
returncode=$?
exec 3>&-

	case $returncode in
	$DIALOG_CANCEL)
		retval=1
		log "Cancel pressed. ${RETURN}.sh,${0}"
		${P}/${RETURN}.sh
		exit
		;;
	$DIALOG_OK)
		echo "Ok let's do this..."
		mkdir -p ${myinstalloc}
			if [ ! $? = 0 ];then
                	"$DIALOG" \
                	--clear \
                	--backtitle "$backtitle" \
                	--yesno "Cannot create this directory ?" 10 30
                	case $? in
                	$DIALOG_OK)
				${P}/scripts/${0}
                        ;;
                	$DIALOG_CANCEL)
				${P}/scripts/${RETURN}.sh
                        ;;
                	esac
			else
				echo ${myinstalloc} > ${P}/data/${INSTLOC}
				break
			fi
		;;
	$DIALOG_EXTRA)
		tag=`echo "$value" |sed -e 's/^RENAMED //' -e 's/:.*//'`
		item=`echo "$value" |sed -e 's/^[^:]*:[ ]*//' -e 's/[ ]*$//'`

		case "$tag" in
		INSTALL-PATH*)
			myinstalloc="$item"
			;;
		esac
		;;

	$DIALOG_ESC)
                echo "ESC pressed."
                break
                ;;

	esac
done

# Save our install location information
echo ${myinstalloc} > ${P}/data/${INSTLOC}

#
# Stage(1) -- Preparing the system with general necessary packages
#

if [ "$MyOS" = "debian" ];then
$DIALOG --separate-output --backtitle "${backtitle}" \
        --title "Stage(1) [${SUBject}] -- {Knary} ... Preparing Checklist Box" "$@" \
        --checklist "Installation of the necessary prerequisite packages.\
        \nYou can choose what to or what not to install.\
        \n\n{Knary} recommends leaving them all checked unless you know otherwise.\
        \nPress SPACE to toggle an option on/off.\
        \n\nThese commands will be executed..." 20 61 9 \
        "update"                "${MyInstaller}" On \
        "install git"                   "${MyInstaller} install" On \
        "install wget"                  "${MyInstaller} install" On \
        "install build-essential"       "${MyInstaller} install" On \
        "install libcurl4-openssl-dev"  "${MyInstaller} install" On \
        "install libncurses5-dev"       "${MyInstaller} install" On \
        "install libjansson-dev"        "${MyInstaller} install" On \
        "install pkg-config"      	"${MyInstaller} install" On \
        "install automake"      	"${MyInstaller} install" On \
        "install autoconf"            	"${MyInstaller} install" On \
        "install python-dev"            "${MyInstaller} install" On \
        "clean"                         "${MyInstaller} clean" On 2> $tempfile

	retval=$?
	report-tempfile ${retval} "${MyInstaller}" ${RETURN}.sh ${RETURN}.sh ${RETURN}.sh slush0-install
else
$DIALOG --separate-output --backtitle "${backtitle}" \
        --title "Stage(1) [${SUBject}] -- {Knary} ... Preparing Checklist Box" "$@" \
        --checklist "Installation of the necessary prerequisite packages.\
        \nYou can choose what to or what not to install.\
        \n\n{Knary} recommends leaving them all checked unless you know otherwise.\
        \nPress SPACE to toggle an option on/off.\
        \n\nThese commands will be executed..." 20 61 9 \
        "update"                		"${MyInstaller}" On \
        "install git"                   	"${MyInstaller} install" On \
        "install wget"                  	"${MyInstaller} install" On \
        "install gcc"                   	"${MyInstaller} install" On \
        "install make"                  	"${MyInstaller} install" On \
        "install python-twisted"          	"${MyInstaller} install" On \
        "install python-devel*"          	"${MyInstaller} install" On \
        "clean packages"                        "${MyInstaller} clean" On 2> $tempfile

	retval=$?
	report-tempfile ${retval} "${MyInstaller}" ${RETURN}.sh ${RETURN}.sh ${RETURN}.sh slush0-install 

yum -y -q groupinstall "Development Tools"

fi
if [ "$retval" = "0" ];then
# directory cleanup
if [ -d ${myinstalloc}/${SUBject} ];then
        rmdir ${myinstalloc}/${SUBject}
elif [ -h "${myinstalloc}/${SUBject}" ];then
        rm -f ${myinstalloc}/${SUBject}
elif [ -f "${myinstalloc}/${SUBject}" ];then  
        rm -f ${myinstalloc}/${SUBject}
fi

cd ${myinstalloc}
rm -f *gz*
rm -f *zip*

# git jannson

cd ${myinstalloc}

# git json for configuratoin files
# https://github.com/json-c/json-c
rm -rf json-c
git clone https://github.com/json-c/json-c.git
cd json-c
sh autogen.sh
./configure
make
${MySudoCom}make install

cd ${myinstalloc}

if [ ! "$MyOS" = "debian" ];then
        wget http://www.digip.org/jansson/releases/jansson-2.4.tar.gz
        tar -zxf jansson-2.4.tar.gz
        cd jansson-2.4/
        ./configure --prefix=/usr
	make clean
	make
	${MySudoCom}make install
        ${MySudoCom}ldconfig
fi

cd ${myinstalloc}

# wget ${SUBject}
git clone git://github.com/slush0/stratum-mining-proxy.git
cd ${SUBject}
${MySudoCom}python distribute_setup.py 
${MySudoCom}python setup.py develop
cd midstatec
if [ ! "$MyOS" = "debian" ];then
	sed -i "s/2.7/2.6/g" Makefile
fi
make clean
make
cd ..
echo "Testing ..."
sleep 5
./mining_proxy.py
read -p "Hit ENTER to continue..." ; echo "Ok"
killall python
sleep 5
fi
cd ${P};${P}/${RETURN}.sh
