#!/bin/bash

P=`pwd`
UN=`uname -a`

. ../include/version
. ../include/tempfiles
. ../include/dialog_top

log()
{
        local now=$(date +"%a %b %d %Y %H:%M:%S")
        printf "Knary::%s\n", "${now}",${BASH_SOURCE[1]##*/},${BASH_LINENO[0]},$(whoami),"${1}"  >> "${mylogfile}"
        if [ "$DEBUG" = "1" ];then
                printf "Knary::%s\n", "${now}",${BASH_SOURCE[1]##*/},${BASH_LINENO[0]},$(whoami),"${1}"
        fi
}

log "Inform:Installing::MAIN. Start."

report-yesno() 
{

retval=${1};dook=${2};docan=${3}

case $retval in
  $DIALOG_OK)
   	${dook};;
  $DIALOG_CANCEL)
    	${docan};;
  $DIALOG_HELP)
    echo "Help pressed.";;
  $DIALOG_EXTRA)
    echo "Extra button pressed.";;
  $DIALOG_ITEM_HELP)
    echo "Item-help button pressed.";;
  $DIALOG_ERROR)
    echo "ERROR!";;
  $DIALOG_ESC)
    echo "ESC pressed.";;
esac

return 0
}

report-tempfile()
{

retval=${1};doexec=${2};dook=${3};docan=${4};doout=${5}

cat /dev/null > results.txt	

case $retval in
  $DIALOG_OK)
	cat /dev/null > /root/.doexec
	while read Run
	do 
		echo "echo \"--- ${doexec} ${Run} ---\"" >> /root/.doexec
		if [ "${doout}" = "0" ];then
			echo "${doexec} ${Run}" >>/root/.doexec
		else
			echo "${doexec} ${Run} | tee ${P}/results.txt" >>/root/.doexec
		fi
	done < $tempfile
	chmod a+x /root/.doexec
	/root/.doexec
	sleep 1
	#rm -f /root/.doexec
	${dook};;
  $DIALOG_CANCEL)
    	${docan};;
  $DIALOG_HELP)
    echo "Help pressed.";;
  $DIALOG_EXTRA)
    echo "Extra button pressed.";;
  $DIALOG_ITEM_HELP)
    echo "Item-help button pressed.";;
  $DIALOG_ESC)
    if test -s $tempfile ; then
      cat $tempfile
    else
      echo "ESC pressed."
    fi
    ;;
esac

return 0
}

report-button()
{

retval=${1};doexec=${2};dook=${3};docan=${4}

case $retval in
  $DIALOG_OK)
    echo "OK";;
  $DIALOG_CANCEL)
    echo "Cancel pressed.";;
  $DIALOG_HELP)
    echo "Help pressed.";;
  $DIALOG_EXTRA)
    echo "Extra button pressed.";;
  $DIALOG_ITEM_HELP)
    echo "Item-help button pressed.";;
  $DIALOG_ERROR)
    echo "ERROR!";;
  $DIALOG_ESC)
    echo "ESC pressed.";;
esac

return 0
}

yesorno()
{

docan=${2}

while true; do
    read -p "Perform -- ${1}? (y/n)" yn
    case $yn in
        [Yy]* ) ${1}; break;;
        [Nn]* ) echo "Ok"; ${docan};;
        * ) echo "Please answer yes or no.";;
    esac
done

return 0
}

safeRunCommand() {
   cmnd=$1

   $cmnd

   if [ $? != 0 ]; then
	result=1
   else
	result=0
   fi
return $result
}


#
# We need to install dialog for the script itself. I do this outside of dialog.
#

command="dpkg -s dialog"
safeRunCommand "$command"
case ${?} in
	1)
		clear
		echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		echo "Stage(0) -- Prepping the system. Knary must have dialog installed. It is a small package."
		echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		yesorno "apt-get install dialog" exit
	;;
	0)
		echo "Ok to proceed..."
		dpkg-query -l dialog | tail -n 2
	;;
	*)
		echo "Cannot proceed..."
		exit 255
	;;
esac

left=2
unit="seconds"
while test $left != 0
do
$DIALOG --sleep 1 \
        --title "Stage(0) -- {Knary} Mining Assistant Info Box" "$@" \
        --infobox "\nKnary version [${VERSION}].\
    	\n<Knary>  Copyright (C) <2014>  <Steven J. Martin>\
    	\nThis program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.\
    	\nThis is free software, and you are welcome to redistribute it under certain\
	 conditions; type `show c' for details.\
        \nYou have $left $unit to read this..." 9 60
left=`expr $left - 1`
test $left = 1 && unit="second"
done

#
# We MUST run as the ROOT user.
#

if [ ! "$UID" -eq 0 ];then 
	$DIALOG --title "Stage(0) -- Knary Assistant Message Box" --clear "$@"\
        --msgbox "Hi, Got Root? You must be logged into the SUPER USER \"root\" Account...\
                  \nThis is easily accomplished via \"sudo su\" using your normal user password.\
                  \nThen <optional> \"passwd root\" to set the root password.\
                  \nThough do not forget what you set it to <:\ !!!" 8 70
	retval=$?

	report-yesno $retval exit exit
	exit
fi

#
# Disclaimer
#

$DIALOG --title "Stage(0) -- Knary Assistant Introduction Yes/No Box" "$@" \
        --yesno "Hello, and Welcome to Knary. 
	\n\nKnary uses dialog as an EASY way to take a Ubuntu 12.10-13.10 \
	\nInstallation and make it into a platform upon which you may EASILY mine for coins.\
	\nThis asistant script is designed Specifically for Ubuntu 12.10+ (It may work with a fresh Debian,) \
	and I offer no guarantees. It definitely will not work with RH or Centos clones.\
	\nThis Assistant can install SOLO MINING and STRATUM proxy, cgminer, bfgminer, p2pool, cpuminer, etc. \
	\n\nYou'll want to start with a fresh 12.10+ install of desktop or server. Then enjoy mining!!" 0 0

retval=$?

report-yesno ${retval} return exit

#
# Change to the /root directory of this server. It is safe there
#
cd /root

#
# Stage(1) -- Preparing the system with general necessary packages
#

$DIALOG --separate-output --backtitle "Knary" \
	--title "Stage(1) -- Knary Assistant Preparing Checklist Box" "$@" \
        --checklist "Hi, it's me. I need to install some prerequisite packages for all installs.\
	\nYou can choose what to or what not to install.\
	\nI recommend leaving them all checked unless you know otherwise.\
	\nPress SPACE to toggle an option on/off.\
  	\nThese commands will be executed..." 20 61 5 \
        "upgrade"		"apt-get" On \
        "update"		"apt-get" On \
        "install git" 			"apt-get install" On \
        "install build-essential" 	"apt-get install" On \
        "install libssl-dev" 		"apt-get install" On \
        "install libboost-all-dev" 	"apt-get install" On \
        "install libminiupnpc-dev" 	"apt-get install" On \
        "install libdb4.8++"	 	"apt-get install" On \
        "install libdb4.8++-dev" 	"apt-get install" On \
        "install sqlite2"		"apt-get install" On \
        "install python-sqlite2"	"apt-get install" On \
        "install python-pysqlite2"	"apt-get install" On \
        "clean"				"apt-get clean" On 2> $tempfile

retval=$?

report-tempfile ${retval} apt-get return exit

clear
echo -e sleep ... Z;for f in 0 1;do
	echo -n z;sleep 1
done

#
# Stage(1.1) -- Perform a Hardware Inventory and TEST Only if the user wants it
#

$DIALOG --separate-output --backtitle "Knary" \
        --title "Stage(1.1) -- Knary Assistant Hardware Inventory Checklist Box" "$@" \
        --checklist "Ok, Would you like to perform a Hardware Inventory READ ONLY?\
        \nThese commands will be executed..." 12 61 5 \
        "lshw"   		"lshw  - list hardware" Off \
        "lshw -enable TEST"   	"lshw  - list hardware and TEST" On 2> $tempfile

retval=$?

report-tempfile ${retval} "time" return return 

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

cat ${P}/results.txt >> $tempfile

$DIALOG --clear --title "Hardware Inventory Text Box" "$@" --textbox "$tempfile" 22 77

retval=$?

report-button ${retval} "date" return return

#
# Install the bitcoin software for bitcoind and bitcoin-qt
#

$DIALOG --separate-output --backtitle "Knary" \
	--title "Stage(2) -- Knary Assistant Preparing for Bitcoin Checklist Box" "$@" \
        --checklist "Ok, Would you like to install the bitcoin repository for bitcoin-qt?\
  	\nThese commands will be executed..." 10 61 5 \
        "ppa:bitcoin\/bitcoin"	"add-apt-repository" On 2> $tempfile

retval=$?

report-tempfile ${retval} add-apt-repository return exit

$DIALOG --separate-output --backtitle "Knary" \
	--title "Stage(3) -- Knary Assistant Installing Bitcoin Checklist Box" "$@" \
        --checklist "Ok, Now the bitcoin update, bitcoind daemon and butcoin-qt.\
	\nYou can choose what to or what not to install.\
	\nI recommend leaving them all checked unless you know otherwise.\
	\nPress SPACE to toggle an option on/off.\
  	\nThese commands will be executed..." 20 61 5 \
        "update"		"apt-get" On \
        "install bitcoind"	"apt-get install" On \
        "install bitcoin-qt"	"apt-get install" On \
        "clean"			"apt-get clean" On 2> $tempfile

retval=$?

report-tempfile ${retval} apt-get return exit

clear
echo -n sleep ... Z;for f in 0 1;do
	echo -n z;sleep 1
done

if [ -f "/root/.bitcoin/bitcoin.conf" ];then
	$DIALOG --title "BITCOIN.CONF Exists -- Replace Yes/No Box" "$@" \
        --yesno "Hi, I see you already have a bitcoin.conf file.\
        \nI found this one [/root/.bitcoin/bitcoin.conf.]\
	\nTo replace this file click yes. I will back up the old one\
	and replace it." 0 0 

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
cat << EOF > /root/.bitcoin/bitcoin.conf
server=1
rpcport=8332
rpctimeout=30
rpcuser=$MyBCUser
rpcpassword=$MyBCPasswd
rpcallowip=127.0.0.1
EOF
fi

cat << EOF > /root/.bitcoin/bitcoin-test.bash
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
done
exit
EOF
chmod a+x /root/.bitcoin/bitcoin-test.bash

#
# Stage(4) -- Configuring the bitcoin daemon for execution
#
$DIALOG --separate-output --backtitle "Knary" \
        --title "Stage(4) -- Knary Assistant Configuring the Bitcoin Daemon Checklist Box" "$@" \
        --checklist "Ok, Would you like to configure the bitcoin daemon for execution?\
        This will start the daemon for the first time. To error is normal. We\
        will continue to configure it. Stop and Start it several more times.\
        \nThese commands will be executed..." 20 61 5 \
        "bitcoind stop 2>/dev/null;while pidof bitcoind; do sleep 1;kill -15 `pidof bitcoind` 2>/dev/null;done"				"stop"  On \
        "bash /root/.bitcoin/bitcoin-test.bash"			"start" On \
        "chmod go-rwx /root/.bitcoin/bitcoin.conf"		"start" On \
        "bitcoind getinfo"					"start" On 2> $tempfile

retval=$?

clear
echo "Please WAIT ...This takes about 15 seconds..."
report-tempfile ${retval} "time" return exit 0
echo "Please HIT CTL+c to Continue when ready..."
read -p "Hit ENTER to continue..." ; echo "Ok"

BCP=`pidof bitcoind`

$DIALOG --sleep 1 \
	--title "Stage(4.1) -- Knary Assistant Bitcoind -TESTNET- Info Box" "$@" \
        --infobox "By this time the bitcoind daemon should be up and running.\
	\nIt is running as a TEST using the -testnet flag. Later we will configure it\
	for prduction.\
	\nThis is minor tweeks to the bitcoin.conf. Stopping, and Starting...\
	\nYou must have a valid bitcoin Wallet Identifier.\
	\nhttps://bitcoin.org/en/choose-your-wallet." 12 52

read -p "Hit ENTER to continue..." ; echo "Ok"

#
# Stage(5) -- Configuring the bitcoin daemon for production execution
#

cat << EOF > /root/.bitcoin/bitcoin-prod.bash
#!/bin/bash
#
# Start the bitcoin daemon
#
clear
bitcoind -daemon &
for i in {0..20..1}
  do
	clear
        echo -n "Pausing for [\$i] seconds"
        sleep 1
done
bitcoind getinfo
exit
EOF
chmod a+x /root/.bitcoin/bitcoin-prod.bash

$DIALOG --separate-output --backtitle "Knary" \
        --title "Stage(5) -- Knary Assistant Configuring the Bitcoin Daemon Checklist Box" "$@" \
        --checklist "Ok, Now let's restart the bitcoin daemon for production.\
	\nThis will stop then start the daemon. More information about the\
	\nbitcoin.conf can be found here.\
	\nhttp://manpages.ubuntu.com/manpages/precise/en/man5/bitcoin.conf.5.html\
	\nThese commands will be executed..." 20 61 5 \
        "bitcoind stop 2>/dev/null;while pidof bitcoind; do sleep 1;kill -15 `pidof bitcoind` 2>/dev/null;done"                         "stop"  On \
        "bash /root/.bitcoin/bitcoin-prod.bash &"   "start" On \
        "bitcoind getinfo"                      "start" On 2> $tempfile

retval=$?

echo "Please WAIT ...This takes about 30 seconds..."
report-tempfile ${retval} "time" return exit 0

read -p "Hit ENTER to continue..." ; echo "Ok"

#
# Stage(6) -- Installing the Stratum Mining Proxy
#

$DIALOG --separate-output --backtitle "Knary" \
        --title "Stage(6) -- Knary Assistant Installing the Stratum Mining Proxy Checklist Box" "$@" \
        --checklist "This stage is to install the Stratum Mining Proxy.\
	\nhttps://github.com/slush0/stratum-mining-proxy\
        \nThese commands will be executed..." 20 70 5 \
        "mkdir /root/git"    	"make directory" On \
        "cd /root/git;git clone https://github.com/slush0/stratum.git" "git stratum" On\
        "cd /root/git;git clone https://github.com/generalfault/stratum-mining.git" "git stratum mining" On\
        "apt-get install python-dev"		"apt-get install" On \
        "apt-get install python-setuptools"  	"apt-get install" On \
        "apt-get install python-crypto"  	"apt-get install" On \
        "easy_install -U distribute"		"easy_install" On \
        "easy_install stratum"  		"easy_install" On \
        "easy_install simplejson"  		"easy_install" On 2> $tempfile

retval=$?

report-tempfile ${retval} "time" return exit

read -p "Hit ENTER to continue..." ; echo "Ok"

$DIALOG --title "Enter YOUR Bitcoin Wallet ID Input Box" --clear "$@" \
        --inputbox "Enter you VALID Bitcoin Address.\n
	CENTRAL BITCOIN WALLET:" 6 51 2> $tempfile

retval=$?

case $retval in
  $DIALOG_OK)
    	echo "Result: `cat $tempfile`"
	MyBCWallet=`cat $tempfile`
	;;
  $DIALOG_CANCEL)
	exit
	;;
esac

cat <<EOF > /root/git/stratum-mining/conf/config/config.py
'''
This is example configuration for Stratum server.
Please rename it to config.py and fill correct values.
This is already setup with sane values for solomining.
'''
CENTRAL_WALLET = 'set_valid_addresss_in_config!'	# local bitcoin address where money goes
BITCOIN_TRUSTED_HOST = 'localhost'
BITCOIN_TRUSTED_PORT = 8332
BITCOIN_TRUSTED_USER = "$MyBCUser"
BITCOIN_TRUSTED_PASSWORD = "$MyBCPasswd"
DEBUG = False
LOGDIR = 'log/'
LOGFILE = None		# eg. 'stratum.log'
LOGLEVEL = 'INFO'
THREAD_POOL_SIZE = 30
ENABLE_EXAMPLE_SERVICE = True
HOSTNAME = 'localhost'
LISTEN_SOCKET_TRANSPORT = 3333
LISTEN_HTTP_TRANSPORT = None
LISTEN_HTTPS_TRANSPORT = None
LISTEN_WS_TRANSPORT = None
LISTEN_WSS_TRANSPORT = None
ADMIN_PASSWORD_SHA256 = None
IRC_NICK = None
DATABASE_DRIVER = 'sqlite'	# Options: none, sqlite, postgresql or mysql
DATABASE_EXTEND = True		# False = pushpool db layout, True = pushpool + extra columns
DB_SQLITE_FILE = 'pooldb.sqlite'
DB_PGSQL_HOST = 'localhost'
DB_PGSQL_DBNAME = 'pooldb'
DB_PGSQL_USER = 'pooldb'
DB_PGSQL_PASS = '**empty**'
DB_PGSQL_SCHEMA = 'public'
DB_MYSQL_HOST = 'localhost'
DB_MYSQL_DBNAME = 'pooldb'
DB_MYSQL_USER = 'pooldb'
DB_MYSQL_PASS = '**empty**'
DB_LOADER_CHECKTIME = 15	# How often we check to see if we should run the loader
DB_LOADER_REC_MIN = 10		# Min Records before the bulk loader fires
DB_LOADER_REC_MAX = 50		# Max Records the bulk loader will commit at a time
DB_STATS_AVG_TIME = 300		# When using the DATABASE_EXTEND option, average speed over X sec
				#	Note: this is also how often it updates
DB_USERCACHE_TIME = 600		# How long the usercache is good for before we refresh
USERS_AUTOADD = True		# Automatically add users to db when they connect.
				# 	This basically disables User Auth for the pool.
USERS_CHECK_PASSWORD = False	# Check the workers password? (Many pools don't)
COINBASE_EXTRAS = '/stratumPool/'			# Extra Descriptive String to incorporate in solved blocks
ALLOW_NONLOCAL_WALLET = False				# Allow valid, but NON-Local wallet's
PREVHASH_REFRESH_INTERVAL = 5 	# How often to check for new Blocks
				#	If using the blocknotify script (recommended) set = to MERKLE_REFRESH_INTERVAL
				#	(No reason to poll if we're getting pushed notifications)
MERKLE_REFRESH_INTERVAL = 60	# How often check memorypool
				#	This effectively resets the template and incorporates new transactions.
				#	This should be "slow"
INSTANCE_ID = 31		# Not a clue what this is for... :P
POOL_TARGET = 1			# Pool-wide difficulty target int >= 1
VARIABLE_DIFF = True		# Master variable difficulty enable
VDIFF_TARGET = 30		# Target time per share (i.e. try to get 1 share per this many seconds)
VDIFF_RETARGET = 300		# Check to see if we should retarget this often
VDIFF_VARIANCE_PERCENT = 50	# Allow average time to very this % from target without retarget
BASIC_STATS = True		# Enable basic stats page. This has stats for ALL users.
BASIC_STATS_PORT = 8889		# Port to listen on
GW_ENABLE = False		# Enable the Proxy (If enabled you MUST run update_submodules)
GW_PORT = 8331			# Getwork Proxy Port
GW_DISABLE_MIDSTATE = False	# Disable midstate's (Faster but breaks some clients)
GW_SEND_REAL_TARGET = False	# Propigate >1 difficulty to Clients (breaks some clients)
ARCHIVE_SHARES = False		# Use share archiving?
ARCHIVE_DELAY = 86400		# Seconds after finding a share to archive all previous shares
ARCHIVE_MODE = 'file'		# Do we archive to a file (file) , or to a database table (db)
ARCHIVE_FILE = 'archives/share_archive'	# Name of the archive file ( .csv extension will be appended)
ARCHIVE_FILE_APPEND_TIME = True		# Append the Date/Time to the end of the filename (must be true for bzip2 compress)
ARCHIVE_FILE_COMPRESS = 'none'		# Method to compress file (none,gzip,bzip2)
NOTIFY_EMAIL_TO = ''		# Where to send Start/Found block notifications
NOTIFY_EMAIL_TO_DEADMINER = ''	# Where to send dead miner notifications
NOTIFY_EMAIL_FROM = 'root@localhost'	# Sender address
NOTIFY_EMAIL_SERVER = 'localhost'	# E-Mail Sender
NOTIFY_EMAIL_USERNAME = ''		# E-Mail server SMTP Logon
NOTIFY_EMAIL_PASSWORD = ''
NOTIFY_EMAIL_USETLS = True
EOF

cat << EOF > /root/git/stratum-mining/twisted.bash
#!/bin/bash
#
# Start the twisted stratum proxy
#
cd /root/git/stratum-mining

twistd -ny launcher.tac -l -
for i in {0..30..1}
  do
        echo "Pausing for [\$i] seconds"
        sleep 1
done
exit
EOF
chmod a+x /root/git/stratum-mining/twisted.bash

#
# Stage(7) -- Starting the Stratum Mining Proxy
#

$DIALOG --separate-output --backtitle "Knary" \
        --title "Stage(7) -- Knary Assistant Starting the Stratum Mining Proxy Checklist Box" "$@" \
        --checklist "Ok, Now let's start the Stratum Proxy.\
        \nThese commands will be executed..." 20 61 5 \
        "nohup bash /root/git/stratum-mining/twisted.bash &"   "start" On \
        "bitcoind getinfo"                      "start" On 2> $tempfile

retval=$?

echo "Please WAIT ...This takes about 30 seconds..."
report-tempfile ${retval} "time" return exit

read -p "Hit ENTER to continue..." ; echo "Ok"

