#!/bin/bash -   
#title          :sub_slush0-configure.sh
#description    :Install for SLUSH0-PROXY
#author         :Steven J. Martin
#date           :20140222
#version        :${version}
#usage          :./sub_slush0-configure.sh
#notes          :       
#bash_version   :4.2.45(1)-release
#============================================================================

p=`pwd`
SUBject="stratum-mining-proxy"
RETURN="scripts/main_stratum"
USUBject=`echo ${SUBject} | tr '[:lower:]' '[:upper:]'`
TODAY=`date +%b%d%Y`

if [ -f "${p}/include/globals" ];then
	. ${p}/include/globals
	. ${p}/include/include-all
	
elif [ -f "../include/globals" ];then
	. ../include/globals
	. ../include/include-all
	echo "Oops running stand-alone."
fi

INSLOC=`cat ${P}/data/${USUBject}`

log "Inform:Starting \"${SUBject}\" configuration."

if [ ! -z "${INSLOC}" ];then
	myinstalloc=`cat ${P}/data/${USUBject}`
	log "Inform: INSLOC found in data directory [${INSLOC}]."
else
	myinstalloc=${P}/exec/${SUBject}
fi

log "Inform: Install location for [${SUBject}] is [$myinstalloc]. INSLOC is $INSLOC"

if [ ! -d "${INSLOC}/${SUBject}" ];then
        $DIALOG --title "Stage(0) -- {Knary} Mining Setup Message Box" --clear "$@"\
        --msgbox "Please return to the ${SUBject} menu.\
                  \n$The install location: [${INSLOC}/${SUBject}] cannot be located.\
		  \nIt must be installed prior to configuration. :)\
                  \nPlease return to the previous menu." 8 70
        retval=$?
	read -p "Hit ENTER to continue..." ; echo "Ok"
	cd ${P};${RETURN}.sh
fi

#
# Use filelist widget from skels dir
# 

FILE=$($DIALOG --title "Select a confifiguration file" --stdout --title "Please choose a file using SPACE BAR to select." --fselect ${P}/skels/${SUBject} 10 80)
 
if [ -z ${FILE} ] ;then FILE=$($DIALOG --title "Select a confifiguration file" --stdout --title "Please choose a file using SPACE BAR to select.\nCtrl+c to exit." --fselect ${P}/skels/${SUBject} 10 80);fi

DIALOG_ERROR=254
export DIALOG_ERROR

input=`tempfile 2>/dev/null` || input=/tmp/input$$
output=`tempfile 2>/dev/null` || output=/tmp/test$$
trap "rm -f $input $output;cd ${P};${P}/${RETURN}.sh" EXIT

cat ${FILE} > $input

$DIALOG --title "{${SUBject}} SIMPLE EDIT BOX" \
	--fixed-font "$@" --editbox $input 0 0 2>$output
retval=$?

case $retval in
  $DIALOG_OK)
 	diff -c $input $output
	$DIALOG --title "${SUBject} Message Box" --clear "$@" \
        --msgbox "A script inside [${INSLOC}] \"${SUBject}.sh\"\
                  has been created. This script is now ready to run to start ${SUBject} mining using the configuration file\
                  [${SUBject}_${TODAY}.conf.]" 10 50
retval=$?
	cat $output> ${INSLOC}/${SUBject}/${SUBject}.${TODAY}.conf
	POOLPort=`grep "^# POOL=" ${INSLOC}/${SUBject}/${SUBject}.${TODAY}.conf | cut -d'=' -f2 | head -n 1` 
	if [ -z "${POOLPort}" ];then
		POOLPort="stratum.btcguild.com:3333"
	fi
	POOL=`echo ${POOLPort} | cut -d':' -f1`
	if [ -z "${POOL}" ];then
		POOL="stratum.btcguild.com"
	fi
	PORT=`echo ${POOLPort} | cut -d':' -f2`
	if [ -z "${PORT}" ];then
		PORT="3333"
	fi
	log "inform: POOLPort: ${POOLPort}, POOL: ${POOL}, PORT: ${PORT}"
	echo "#!/bin/bash">${INSLOC}/${SUBject}/${SUBject}.sh
	echo "${INSLOC}/${SUBject}/mining_proxy.py -o ${POOL} -p ${PORT}">>${INSLOC}/${SUBject}/${SUBject}.sh
	chmod a+x ${INSLOC}/${SUBject}/${SUBject}.sh
    	;;
  $DIALOG_CANCEL)
	retval=1
	log "Cancel pressed. ${RETURN}.sh,${0}"
	${P}/${RETURN}.sh
        exit;;
  *)
        echo "Something else pressed."
        exit;;
esac
echo "Testing ..."
${INSLOC}/${SUBject}/${SUBject}.sh &
read -p "Hit ENTER to continue..." ; echo "Ok"
killall python
sleep 5
cd ${P};${P}/${RETURN}.sh
