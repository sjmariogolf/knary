#!/bin/bash -   
#title          :make_common_directory_structure.sh
#description    :Make the directory Structure for Knary
#author         :Steven J. Martin
#date           :20140221
#version        :${version}
#usage          :./make_common_directory_structure.sh
#notes          :       
#bash_version   :4.2.45(1)-release
#============================================================================

P=$(pwd)
DEBUG=1

if [ ! "$UID" -eq 0 ];then
	echo "Got root?"
	exit 255
fi

mylogfile=/var/log/Knary_syslog

log()
{
	local now=$(date +"%a %b %d %Y %H:%M:%S")
	printf "Knary::%s\n", "${now}",${BASH_SOURCE[1]##*/},${BASH_LINENO[0]},$(whoami),"${1}"  >> "${mylogfile}"
	if [ "$DEBUG" = "1" ];then
		printf "Knary::%s\n", "${now}",${BASH_SOURCE[1]##*/},${BASH_LINENO[0]},$(whoami),"${1}"
	fi
}

log "Inform:Starting Installation. Making the Directory Structure."

mkdir -p Knary
mkdir -p Knary/scripts
mkdir -p Knary/config
mkdir -p Knary/include
mkdir -p Knary/temp
mkdir -p Knary/git

exit 0
