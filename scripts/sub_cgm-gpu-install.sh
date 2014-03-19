#!/bin/bash -   
#title          :sub_cgm-gpu-install.sh
#description    :Install for GPU-MINING|Scrypt
#author         :Steven J. Martin
#date           :20140222
#version        :${version}
#usage          :./sub_cgm-gpu-install.sh
#notes          :       
#bash_version   :4.2.45(1)-release
#============================================================================

SUBject="cgminer-gpu"
INSTLOC=`echo ${SUBject} | tr '[:lower:]' '[:upper:]'`
RETURN="scripts/main_gpu-mining"
MINEREL="cgminer-3.7.2";REL="3.7"
MINERDR=`echo ${MINEREL} | cut -d'-' -f1,2`
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

log "Inform:Starting cgm-installation."

if [ "$(whoami)" != "root" ]; then
        MySudoCom='sudo '
else
        MySudoCom=''
fi

control_c()
{
	clear
        echo "=== [Ctrl+c] Interupt Exiting ==="
        killall ${SUBject}
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
		${P}/scripts/${RETURN}.sh
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
        "update"         		"${MyInstaller}" On \
        "install git"                   "${MyInstaller} install" On \
        "install wget"                  "${MyInstaller} install" On \
        "install build-essential"       "${MyInstaller} install" On \
        "install libcurl4-openssl-dev"  "${MyInstaller} install" On \
        "install libncurses5-dev"       "${MyInstaller} install" On \
        "install libjansson-dev"        "${MyInstaller} install" On \
        "install libudev"            	"${MyInstaller} install" On \
        "install libudev-dev"           "${MyInstaller} install" On \
        "install pkg-config"      	"${MyInstaller} install" On \
        "install automake"      	"${MyInstaller} install" On \
        "install autoconf"            	"${MyInstaller} install" On \
        "clean"                         "${MyInstaller} clean" On 2> $tempfile

	retval=$?
	report-tempfile ${retval} "${MyInstaller}" ${RETURN}.sh ${RETURN}.sh ${RETURN}.sh cgminer_installation 

else
cat > /etc/yum.repos.d/linuxtech.repo <<EOF
[linuxtech]
name=LinuxTECH
baseurl=http://pkgrepo.linuxtech.net/el6/release/
enabled=1
gpgcheck=1
gpgkey=http://pkgrepo.linuxtech.net/el6/release/RPM-GPG-KEY-LinuxTECH.NET
EOF
$DIALOG --separate-output --backtitle "${backtitle}" \
        --title "Stage(1) [${SUBject}] -- {Knary} ... Preparing Checklist Box" "$@" \
        --checklist "Installation of the necessary prerequisite packages.\
        \nYou can choose what to or what not to install.\
        \n\n{Knary} recommends leaving them all checked unless you know otherwise.\
        \nPress SPACE to toggle an option on/off.\
        \n\nThese commands will be executed..." 20 61 9 \
        "update"                		"${MyInstaller}" On \
        "install wget"                  	"${MyInstaller} install" On \
        "install gcc"                   	"${MyInstaller} install" On \
        "install make"                  	"${MyInstaller} install" On \
        "install uthash"          		"${MyInstaller} install" On \
        "install python-devel"          	"${MyInstaller} install" On \
        "install automake"      		"${MyInstaller} install" On \
        "install autoconf"            		"${MyInstaller} install" On \
        "install libudev"            		"${MyInstaller} install" On \
        "install libudev-dev"            	"${MyInstaller} install" On \
        "clean packages"                        "${MyInstaller} clean" On 2> $tempfile

	retval=$?
	report-tempfile ${retval} "${MyInstaller}" ${RETURN}.sh ${RETURN}.sh ${RETURN}.sh cgminer_installation 

yum -y -q install uthash

fi
if [ "$retval" = "0" ];then
clear

if [ -d "${myinstalloc}/${SUBject}" ];then
	tar zcvf /var/tmp/${SUBject}_`date +%B%d%Y`.tar.gz ${myinstalloc}/${SUBject}
	rm -rf ${myinstalloc}/${SUBject}
	rm -rf ${myinstalloc}/${SUBject}-*
fi

# change directory
if [ -d ${myinstalloc}/${SUBject} ];then
	rmdir ${myinstalloc}/${SUBject}
elif [ -h ${myinstalloc}/${SUBject} ];then
	rm -f ${myinstalloc}/${SUBject}
elif [ -f ${myinstalloc}/${SUBject} ];then
	rm -f ${myinstalloc}/${SUBject}
fi

cd ${myinstalloc}
rm -f *gz*
rm -f *zip*

# git json for configuratoin files
# https://github.com/json-c/json-c
rm -rf json-c
git clone https://github.com/json-c/json-c.git
cd json-c
sh autogen.sh
./configure
${MySudoCom}make
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
rm -f *gz
rm -f *zip

mkdir -p ${myinstalloc}/${SUBject}

# git ${SUBject}
cd ${myinstalloc}/${SUBject}

wget http://ck.kolivas.org/apps/cgminer/${REL}/${MINEREL}.tar.bz2
tar xjvf ${MINEREL}.tar.bz2
mv -f ${MINEREL}.tar.bz2 ${P}/downloads
ln -s ${myinstalloc}/${SUBject}/cgminer-3.7.2 cgminer 

#git clone git://github.com/veox/cgminer.git
#git reset --hard 829f0687bfd0ddb0cf12a9a8588ae2478dfe8d99

cd cgminer
# Copy the ADL_SDK/include recursively into ADL_SDK
if [ -d "/opt/AMDAPP/include/" ];then
	cp -r /opt/AMDAPP/include ADL_SDK
fi
# uncomment to disable the ADM SDK
# -- ./autogen.sh --enable-scrypt --enable-opencl --disable-adl
./autogen.sh --enable-scrypt --enable-opencl

CFLAGS="-O2 -Wall -march=native"
# uncomment to disable the ADM SDK
#-- ./configure --enable-scrypt --enable-opencl --disable-adl
./configure --enable-scrypt --enable-opencl

read -p "Looking for GPU Enabled... Hit ENTER to continue..." ; echo "Ok"
make clean
make
${MySudoCom}make install
${MySudoCom}ldconfig
echo "Testing ..."
echo "`pwd` ..."
cat <<EOF >${SUBject}.conf
{
"pools" : [
	{
		"url" : "stratum+tcp://freedom.wemineltc.com:3339",
		"user" : "sjmariogolf.1",
		"pass" : "peeb"
	}
]
,
"intensity" : "15",
"vectors" : "1",
"worksize" : "512",
"lookup-gap" : "2",
"thread-concurrency" : "0",
"shaders" : "0",
"api-mcast-port" : "4028",
"api-port" : "4028",
"expiry" : "120",
"failover-only" : true,
"gpu-dyninterval" : "7",
"gpu-platform" : "0",
"gpu-threads" : "1",
"log" : "5",
"no-pool-disable" : true,
"queue" : "1",
"scan-time" : "60",
"tcp-keepalive" : "30",
"shares" : "0",
"kernel-path" : "/usr/local/bin"
}
EOF
${MySudoCom}fglrxinfo
${MySudoCom}aticonfig --lsa
${MySudoCom}aticonfig --adapter=all --initial
${MySudoCom}aticonfig --adapter=all --odgt

echo "... ./cgminer -c ${SUBject}.conf"
./cgminer -n
read -p "Hit ENTER to continue..." ; echo "Ok"
cat <<EOF >${SUBject}.sh
#!/bin/sh
export DISPLAY=:0
export GPU_MAX_ALLOC_PERCENT=100
export GPU_USE_SYNC_OBJECTS=1
./cgminer --scrypt -c ${SUBject}.conf &
EOF
chmod a+x ${SUBject}.sh
./${SUBject}.sh
read -p "Hit ENTER to continue..." ; echo "Ok"
killall cgminer
sleep 5
fi
cd ${P};${P}/${RETURN}.sh
