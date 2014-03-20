#!/bin/bash -   
#title          :sub_amd-install.sh
#description    :Install for AMD SDK and Catalyst Driver
#author         :Steven J. Martin
#date           :20140222
#version        :${version}
#usage          :./sub_amd-install.sh
#notes          :       
#bash_version   :4.2.45(1)-release
#============================================================================

SUBject="amd-drivers"
INSTLOC=`echo ${SUBject} | tr '[:lower:]' '[:upper:]'`
RETURN="scripts/main_gpu-mining"
MINEREL="amd-drivers"
MINERDR=`echo ${MINEREL} | cut -d'-' -f1,2,3`
CFLAGS="-O3"
DO32patch='false'
p=`pwd`

if [ -f "${p}/include/globals" ];then
	. ${p}/include/globals
	. ${p}/include/include-all
	
elif [ -f "../include/globals" ];then
	. ../include/globals
	. ../include/include-all
	echo "Oops running stand-alone."
fi

log "Inform:Starting amd stratum mining proxy installation."

if [ "$(whoami)" != "root" ]; then
        MySudoCom='sudo '
else
        MySudoCom=''
fi

if [ "${MyBIT}" = "32" ];then
	AMDSDK='AMD-APP-SDK-v2.9-lnx32.tgz'
	if [[ `uname -v` =~ "#32-Ubuntu" ]] && [[ `uname -a` =~ "3." ]];then
		#- If this is a 32 bit sytem and debian we need to do some work
		echo "Info: This is a Debian 32 bit system. A patch is required. Knary will install it..."
		DO32patch='true'
	fi
elif [ "${MyBIT}" = "64" ];then
	AMDSDK='AMD-APP-SDK-v2.9-lnx64.tgz'
else
	log "Error: Unknown Endian [$MyBIT]."
	exit
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
myinstalloc=${myinstalloc}/${SUBject}
echo ${myinstalloc} > ${P}/data/${INSTLOC}

# change directory
if [ -d ${myinstalloc}/${SUBject} ];then
        rmdir ${myinstalloc}/${SUBject}
elif [ -h ${myinstalloc}/${SUBject} ];then
        rm -f ${myinstalloc}/${SUBject}
elif [ -f ${myinstalloc}/${SUBject} ];then
        rm -f ${myinstalloc}/${SUBject}
else
	log "Inform: Creating [${myinstalloc}]"
	mkdir -p ${myinstalloc}
fi

rm -f *gz*
rm -f *zip*
cd ${myinstalloc}

#  Download the AMD SDK
retval=0
perform_debian32_patch(){

cd ${myinstalloc}
echo "Inform: Installing 32bit Debian Kernel patch"
cat > ${myinstalloc}/32bit_13.12_fglrx_patch <<EOF
--- 13.12/common/lib/modules/fglrx/build_mod/kcl_acpi.c	2013-12-17 20:05:35.000000000 +0100
+++ 13.12/common/lib/modules/fglrx/build_mod/kcl_acpi.c	2013-12-19 18:40:18.386568588 +0100
@@ -995,7 +995,11 @@
 #endif
     {
         return KCL_ACPI_ERROR;
-    }    
+    }
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(3,9,1)
+    ((acpi_tbl_table_handler)handler)(hdr);
+#else
     ((acpi_table_handler)handler)(hdr);
+#endif
     return KCL_ACPI_OK;
-}
+}
\ No newline at end of file
EOF
sudo apt-get install dpkg-dev debhelper dh-modaliases execstack
chmod a+x amd-catalyst-13.12-linux-x86.x86_64.run
sudo ./amd-catalyst-13.12-linux-x86.x86_64.run --extract 32bitpatch
sudo patch -Np1 -i 32bit_13.12_fglrx_patch 32bitpatch/common/lib/modules/fglrx/build_mod/kcl_acpi.c 
cd 32bitpatch
sudo ./ati-installer.sh 13.251 --buildpkg Ubuntu/saucy
cd ${myinstalloc}
sudo dpkg -i *deb

return 0
}

while [ ! -f "${HOME}/Downloads/${AMDSDK}" ] ;
do
if [ -f "${HOME}/Downloads/${AMDSDK}.part" ];then
	echo "Downloading [$AMDSDK}]...";sleep 5
fi
$DIALOG --cr-wrap --title "Yes/No Box" --clear "$@" \
        --yesno "This is the AMD SDK Installation.\
                 \nThe AMD Web Site for the Software REQUIRES that \"YOU\"\
DOWNLOAD the SDK. This application simply cannot.\
\nPLEASE READ -- Please download the AMD SDK from the Official SMD Download URL:\
\n'http://developer.amd.com/tools-and-sdks/heterogeneous-computing/amd-accelerated-parallel-processing-app-sdk/downloads/#appsdkdownloads'\
\nCHOOSE this FILE [${AMDSDK}].\
\nKnary will look for it in [${HOME}/Downloads/${AMDSDK}].\
\nThe Installation will continue when the file is located above.\
                 \nCtrl+c will abort." 15 125
retval=$?
if [ "$retval" = "0" ];then
clear
echo "Inform: Waiting for [${HOME}/Downloads/${AMDSDK}]..."
echo "Inform: 'http://developer.amd.com/tools-and-sdks/heterogeneous-computing/amd-accelerated-parallel-processing-app-sdk/downloads/#appsdkdownloads'"
echo "Inform: Please Download to [${HOME}/Downloads], as [${AMDSDK}]..."
read -p "Please Hit ENTER when the file has completely Downloaded..." ; echo "Ok"
while [ ! -f "${HOME}/Downloads/${AMDSDK}" ] ;
do
	echo "Inform: Waiting..."
	sleep 5
done
else
	break
fi
done

cd ${myinstalloc}

if [ "$retval" = "0" ];then
	cd ${myinstalloc}
	if [ -d "${myinstalloc}" ];then
		${MySudoCom}rm -f ${myinstalloc}/*
	fi
	${MySudoCom}mv ${HOME}/Downloads/${AMDSDK} ${myinstalloc}
	${MySudoCom}tar zxvf ${AMDSDK}
	${MySudoCom}tar zxvf icd-registration.tgz
	${MySudoCom}sh Install-AMD-APP.sh

# -- Untar command executed succesfully, The SDK package available
# -- Untar command executed succesfully, The ICD package available 
# -- Copying files to /opt/AMDAPP/ ... 
# -- SDK files copied successfully at /opt/AMDAPP/
# -- Installing AMD APP CPU runtime under /opt/AMDAPP/lib 
# -- Updating Environment variables... 
# -- xx-bit path is :/opt/AMDAPP/lib/x86
# -- Environment variables updated successfully
# -- AMD APPSDK v2.9 installation  Completed

	if [ ! -d /usr/include/CL ];then
		${MySudoCom}ln -s /opt/AMDAPP/include/CL /usr/include
	else
		${MySudoCom}ln -s /opt/AMDAPP/include/CL/* /usr/include/CL 2>/dev/null 1>&2
	fi
	if [ "${MyBIT}" = "32" ];then
		${MySudoCom}ln -s /opt/AMDAPP/lib/x86/* /usr/lib/
	elif [ "${MyBIT}" = "64" ];then
		${MySudoCom}ln -s /opt/AMDAPP/lib/x86_64/* /usr/lib/
	else
        	log "Error: Unknown Endian [$MyBIT] aboring ${0}."
        	exit
	fi
	${MySudoCom}ldconfig
	${MySudoCom}apt-get -y install unzip
	# -- Get the latest catalyst drivers
	echo "Inform: This can take some time. It will finish..."
	wget --referer='http://support.amd.com/en-us/download/desktop?os=Linux+x86' http://www2.ati.com/drivers/linux/amd-catalyst-13.12-linux-x86.x86_64.zip
	
	read -p "Prepare to interact with the AMD Catalyst install. Hit ENTER to continue..." ; echo "Ok"
        if [ "${MyBIT}" = "32" ];then
        if [ "${MyBIT}" = "32" ];then
                if [ -f "amd-catalyst-13.12-linux-x86.x86_64.zip" ];then
                        ${MySudoCom}unzip amd-catalyst-13.12-linux-x86.x86_64.zip
                        ${MySudoCom}chmod a+x amd-catalyst-13.12-linux-x86.x86_64.run
                        if [ "$DO32patch" = "true" ];then
                                perform_debian32_patch
                        else
                                ${MySudoCom}./amd-catalyst-13.12-linux-x86.x86_64.run
                        fi
                else
                        ${MySudoCom}./amd-catalyst-13.12-linux-x86.x86_64.run
                fi	
                else
                        ${MySudoCom}unzip amd-catalyst-13.12-linux-x86.x86_64.zip
                        ${MySudoCom}chmod a+x amd-catalyst-13.12-linux-x86.x86_64.run
                        ${MySudoCom}./amd-catalyst-13.12-linux-x86.x86_64.run
                fi
        elif [ "${MyBIT}" = "64" ];then
                ${MySudoCom}unzip amd-catalyst-13.12-linux-x86.x86_64.zip
                ${MySudoCom}chmod a+x amd-catalyst-13.12-linux-x86.x86_64.run
                ${MySudoCom}./amd-catalyst-13.12-linux-x86.x86_64.run
        else
                log "Error: Unknown Endian [$MyBIT] aborting ${0}."
                exit
        fi
echo "Installing ..."
${MySudoCom}dpkg -i fglrx*.deb
${MySudoCom}sudo apt-get -y -f install
${MySudoCom}ldconfig

sleep 5
$DIALOG --title "Yes/No Box" --clear "$@" \
        --yesno "At this juncture we must reboot the box.\
                 Reboot?." 15 61
retval=$?
if [ "$retval" = "0" ];then
	${MySudoCom}/reboot
else
	read -p "Hit ENTER to continue..." ; echo "Ok"
sleep 5
fi
fi
cd ${P};${P}/${RETURN}.sh
