#!/bin/bash -   
#title          :knary_execution.sh
#description    :Man entry point
#author         :Steven J. Martin
#date           :20140222
#version        :${version}
#usage          :./knary_execution.sh
#notes          :       
#bash_version   :4.2.45(1)-release
#============================================================================

p=`pwd`
DEBUG=1

. ${p}/include/globals
. ${P}/include/include-all

echo "${P}">${P}/data/ENTRY

#
# We need to install dialog for the script itself. I do this outside of dialog.
#

if [ ${MyOS} = "debian" ];then
	command="dpkg -s dialog"
elif [ ${MyOS} = "redhat" ];then
	command="rpm -q dialog"
else
	log "Error: Cannot determine command to install the dialog package on this OS [`uname -s`]."
	exit 255
fi
safeRunCommand "$command"
case ${?} in
	1)
		clear
		echo -e "\033[31m"
		echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		echo "{Knary} -- Prepping the system. {Knary} Mining must have dialog installed. It is a small package."
		echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		echo -e "\033[30m"
		yesorno "${MyInstaller} install dialog" exit
	;;
	0)
		echo "Ok to proceed..."
		if [ ${MyOS} = "debian" ];then
			dpkg-query -l dialog | tail -n 2
		else
        		rpm -qa | grep dialog | tail -n 2
		fi
	;;
	*)
		echo "Cannot proceed..."
		exit 255
	;;
esac

$DIALOG --sleep 1 \
        --title "`date +%B%d%Y` -- {Knary} Mining Setup Info Box." "$@"\
        --infobox "\n                   {Knary} version [${VERSION}].\
    	\n
    	\nThis program comes with ABSOLUTELY NO WARRANTY; for details refer to the GNU public license for open source FREE software.\
    	\nThis is free software, and you are welcome to redistribute it under certain conditions.\
    	\nAll of this code was written by me in my spare time for \"my education\", as well as automation, reuse, and rapid deployment of rigs.\
	\nPlease you enjoy it. Copy it, help me improve it, augment it, whatever...\
        \nHit ENTER to continue..." 16 70

read -p "Hit ENTER to continue..." ; echo "Ok"

${P}/scripts/main_menu.sh

exit 0
