#!/bin/bash -   
#title          :sub_misc.sh
#description    :Misc performa Hardware Inventory
#author         :Steven J. Martin
#date           :20140222
#version        :${version}
#usage          :./sub_misc.sh
#notes          :       
#bash_version   :4.2.45(1)-release
#============================================================================

SUBject="Misc lshw"
p=`pwd`
RETURN="scripts/main_menu"

if [ -f "${p}/include/globals" ];then
	. ${p}/include/globals
	. ${p}/include/include-all
	echo "weird..."
elif [ -f "../include/globals" ];then
	. ../include/globals
	. ../include/include-all
	echo "Oops running stand-alone."
fi

log "Inform:Starting misc hardware inventory."

#
# Stage(M.1) -- Perform a Hardware Inventory and TEST Only if the user wants it
#

if [ "${MyOS}" = "debian" ];then
$DIALOG --separate-output --backtitle "${backtitle}" \
        --title "Stage(1) [${SUBject}] -- {Knary} Hardware Inventory Checklist Box" "$@" \
        --checklist "Perform a Hardware Inventory READ ONLY?\
        \nThese commands will be executed..." 12 61 5 \
        "lshw"   		"lshw   - list hardware" Off \
        "lshw -enable TEST"   	"lshw   - list hardware and TEST" Off\
        "dmesg"   		"dmesg  - Dump Messages" On 2> $tempfile

retval=$?

report-tempfile ${retval} "time" ${RETURN}.sh ${RETURN}.sh 1 lshw  
else
$DIALOG --separate-output --backtitle "${backtitle}" \
        --title "Stage(1) [${SUBject}] -- {Knary} Hardware Inventory Checklist Box" "$@" \
        --checklist "Perform a Hardware Inventory READ ONLY?\
        \nThese commands will be executed..." 12 61 5 \
        "lspci"   	"lspci  - list PCI" On\
        "lscpu"   	"lscpu  - list CPU" Off\
        "lshal"   	"lshal  - list device DB" Off\
        "lsinitrd"   	"lsinitrd  - list kernel" Off\
        "lsmod"   	"lshw   - list modules" Off\
        "lsusb"   	"lshw   - list hardware and TEST" Off\
        "dmesg"   	"dmesg  - Dump Messages" Off 2> $tempfile

retval=$?
fi

report-tempfile ${retval} "time" ${RETURN}.sh ${RETURN}.sh 1 lshw  

cat << EOF > $tempfile
This is a simple text file viewer, with these keys implemented:

PGDN/SPACE     - Move down one page
PGUP/'b'       - Move up one page
ENTER/DOWN/'j' - Move down one line
UP/'k'         - Move up one line
LEFT/'h'       - Scroll left
RIGHT/'l'      - Scroll right
'0'            - Move to beginning of line
HOME/'g'       - Move to beginning of file
END/'G'        - Move to end of file
'/'            - Forward search
'?'            - Backward search
'n'            - Repeat last search (forward)
'N'            - Repeat last search (backward)

Following is the text file:

EOF

cat ${P}/results/lshw.sh_`date +%b%d%Y`_results.txt >> $tempfile

$DIALOG --clear --title "Hardware Inventory Text Box" "$@" --textbox "$tempfile" 22 77

retval=$?

report-button ${retval} "date" return return

read -p "Hit ENTER to continue..." ; echo "Ok"
cd ${P};${P}/${RETURN}.sh
