#!/bin/bash -   
#title          :sub_bitcoin-daemon.sh
#description    :Install for the BITCOIN DAEMON
#author         :Steven J. Martin
#date           :20140222
#version        :${version}
#usage          :./sub_bitcoin-daemon.sh
#notes          :       
#bash_version   :4.2.45(1)-release
#============================================================================

SUBject="bitcoind"
INSTLOC=`echo ${SUBject} | tr '[:lower:]' '[:upper:]'`
RETURN="scripts/main_bitcoin"
MINEREL="bitcoind"
MINERDR=`echo ${MINEREL} | cut -d'-' -f2,3`
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

log "Inform:Starting bitcoin-daemon installation."

if [ "$(whoami)" != "root" ]; then
        MySudoCom='sudo '
else
        MySudoCom=''
fi

control_c()
{
	clear
        echo "=== [Ctrl+c] Interupt Exiting ==="
        killall bitcoind
        sleep 5
        cd ${P};${P}/${RETURN}.sh
        exit $?
}
# trap keyboard interrupt (control-c)
trap control_c SIGINT

ids=`id|sed -e 's/([^)]*)//g'`
uid=`echo "$ids" | sed -e 's/^uid=//' -e 's/ .*//'`
gid=`echo "$ids" | sed -e 's/^.* gid=//' -e 's/ .*//'`

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
		${P}/scripts/${RETURN}.sh
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
        "install libtool"      		"${MyInstaller} install" On \
        "install automake"      	"${MyInstaller} install" On \
        "install autoconf"            	"${MyInstaller} install" On \
        "clean"                         "${MyInstaller} clean" On 2> $tempfile

	retval=$?
	report-tempfile ${retval} "${MyInstaller}" ${RETURN}.sh ${RETURN}.sh ${RETURN}.sh bitcoind_installation 
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
        "install python-devel"          	"${MyInstaller} install" On \
        "clean packages"                        "${MyInstaller} clean" On 2> $tempfile

	retval=$?
	report-tempfile ${retval} "${MyInstaller}" ${RETURN}.sh ${RETURN}.sh ${RETURN}.sh bitcoind_installation 

yum -y -q groupinstall "Development Tools"

fi

if [ "$retval" = "0" ];then
clear

if [ -d "${myinstalloc}/${SUBject}" ];then
        tar zcvf /var/tmp/${SUBject}_`date +%B%d%Y`.tar.gz ${myinstalloc}/${SUBject}
        rm -rf ${myinstalloc}/${SUBject}
        rm -rf ${myinstalloc}/${SUBject}-*
fi

# directory cleanup
if [ -d ${myinstalloc}/${SUBject} ];then
	rmdir ${myinstalloc}/${SUBject}
elif [ -h "${myinstalloc}/${SUBject}" ];then
	rm -f ${myinstalloc}/${SUBject}
elif [ -f "${myinstalloc}/${SUBject}" ];then
	rm -f ${myinstalloc}/${SUBject}
fi

mkdir -p ${myinstalloc}/${SUBject}

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
make install

cd ${myinstalloc}

if [ ! "$MyOS" = "debian" ];then
        wget http://www.digip.org/jansson/releases/jansson-2.4.tar.gz
        tar -zxf jansson-2.4.tar.gz
        cd jansson-2.4/
        ./configure --prefix=/us
	make clean
	make
	${MySudoCom}make install
        ${MySudoCom}ldconfig
fi

cd ${myinstalloc}/${SUBject}

#
# Install the bitcoin software for bitcoind and bitcoin-qt
#

$DIALOG --separate-output --backtitle "${backtitle}" \
	--title "Stage(2) -- {Knary} Mining Setup Preparing for Bitcoin Checklist Box" "$@" \
        --checklist "Add the Bitcoin repository for bitcoin-qt?\
  	\nThese commands will be executed..." 12 61 5 \
        "ppa:bitcoin\/bitcoin"	"${MyAddRepo}" On 2> $tempfile

retval=$?

report-tempfile ${retval} "${MyAddRepo}" ${RETURN}.sh ${RETURN}.sh ${RETURN}.sh bitcoind_installation

$DIALOG --separate-output --backtitle "${backtitle}" \
	--title "Stage(3) -- {Knary} Mining Setup Installing Bitcoin Checklist Box" "$@" \
        --checklist "Ok, Now the bitcoin update, bitcoind daemon and bitcoin-qt.\
	\nYou can choose what to or what not to install.\
	\nI recommend leaving them all checked unless you know otherwise.\
	\nPress SPACE to toggle an option on/off.\
  	\nThese commands will be executed..." 20 61 5 \
        "update"			"${MyInstaller}" On \
        "install bitcoind"		"${MyInstaller} install" On \
        "install bitcoin-qt"		"${MyInstaller} install" On \
        "clean"				"${MyInstaller} clean" On 2> $tempfile

retval=$?

report-tempfile ${retval} "${MyInstaller}" ${RETURN}.sh ${RETURN}.sh ${RETURN}.sh bitcoind_installation

if [ -f "${HOME}/.bitcoin/bitcoin.conf" ];then
	$DIALOG --title "BITCOIN.CONF Exists -- Replace Yes/No Box" "$@" \
        --yesno "You already have a bitcoin.conf file.\
        \nFound this one [${HOME}/.bitcoin/bitcoin.conf.]\
	\nTo replace this file click yes. Knary will back up the old one and replace it." 0 0 

	retval=$?

	report-yesno $retval continue continue
	case $retval in
		$DIALOG_OK)
    			echo "Ok"
			OverW="yes"
		;;
		*)
			echo "Continue"
			OverW="no"
		;;		
	esac
else
	OverW="yes"
fi

if [ "${OverW}" = "yes" ];then
MyBCUser=bitcoinrpc
MyBCPasswd=`uuidgen -r`
cat << EOF > ${HOME}/.bitcoin/bitcoin.conf
server=1
rpcport=8332
rpctimeout=30
rpcuser=$MyBCUser
rpcpassword=$MyBCPasswd
rpcallowip=127.0.0.1
EOF
fi

cat << EOF > ${myinstalloc}/${SUBject}/bitcoin-test.sh
#!/bin/bash
#
# Start the bitcoin daemon
#
clear
bitcoind -testnet -daemon &
for i in {0..15..1}
  do
	clear
     	echo -n "Pausing for [\$i] seconds"
	sleep 1
	bitcoind getinfo
done
exit
EOF
chmod a+x ${myinstalloc}/${SUBject}/bitcoin-test.sh

# Testing

${myinstalloc}/${SUBject}/bitcoin-test.sh

read -p "Hit ENTER to continue..." ; echo "Ok"
bitcoind stop
sleep 5

fi
cd ${P};${P}/${RETURN}.sh
