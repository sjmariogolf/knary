#!/bin/bash -   
#title          :btc_solo_mining_install.sh
#description    :Main Shell for SOLO BITCOIN-MINING
#author         :Steven J. Martin
#date           :20140222
#version        :${version}
#usage          :./btc_solo_mining_install.sh
#notes          :       
#bash_version   :4.2.45(1)-release
#============================================================================

SUBject="solo-bitcoin"
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

log "Inform:Starting SOLO BITCOIN installation. [${myinstalloc}]."

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
	read -p "Inform: Would you like to run theis step? [\"${3}\"] Enter y/n (n)? " yesorno
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

start_bitcoind()
{

echo "Inform: Attempting to start the bitcoin daemon."
nohup bitcoind -daemon
COIN_RESULT="INITIAL"
sleep 5
while true; do
	bitcoind getinfo 2> ./bitcoind.out 1>&2
	if [[ $COIN_RESULT != "INITIAL" ]]; then
    		break
  	fi
  	sleep 1
	# read in the file containing the std out
  	while read line; do
	${MySudoCOm}bitcoind getinfo 2> ./bitcoind.out 1>&2
    	if [[ $line == *version* ]]; then
      		echo "Inform: bitcoind has been successfully started..."
      		COIN_RESULT="success"
		bitcoind getinfo > ./bitcoind.out
		bitcoind getinfo
      		break
    	elif [[ $line == *error:\ could* ]]; then
      		echo "Inform: bitcoind not yet communicating..."
      		COIN_RESULT="failed"
    	elif [[ $line == *error:\ incorrect* ]]; then
      		echo "Inform: bitcoind is restarting..."
		${MySudoCom}killall bitcoind
		sleep 5
		nohup bitcoind -daemon
      		COIN_RESULT="restarted"
    	elif [[ $line == *Cannot\ obtain\ a\ lock* ]]; then
      		echo "Inform: bitcoind is already running and has a lock..."
		bitcoind stop
		${MySudoCom}killall bitcoind
      		COIN_RESULT="already running restarted"
		sleep 5
		nohup bitcoind -daemon
    	fi
	sleep 5
  	done < <( cat ./bitcoind.out )
done
echo "Inform: The bitcoin daemon's result [${COIN_RESULT}]..."
echo "Inform: These commands are now available to you via the bitcoin daemon."
sleep 5
bitcoind getinfo
bitcoind help | grep "^get"

rm -f ./bitcoind.out
return 0
}


if [ ! "$MyOS" = "debian" ];then
	log "Error: I apologize, but this script has ONLY been tested on a Debian clone..."
	exit 255
else
	log "Inform: Ok, we are running on a Debian clone [`uname -m`]. Proceed."
fi
log "Inform: This is a rather long and tedious undertaking. Please be patient..."
echo "Inform: The very first thing we must do is to make certain we have the Bitcoin Daemon Installed and operational." 


install_bitcoin(){
I=${1}
echo "Inform: Step# $[I] of [$STEPs] ... Installing Bitcoin."
dpkg-query -l bitcoind 2> /dev/null 1>&2
if [ ! $? = 0 ];then 
	echo "python-software-properites, update, bitcoind..."
	${MySudoCom}aptitude install python-software-properties
	${MySudoCom}add-apt-repository ppa:bitcoin/bitcoin 
	${MySudoCom}aptitude update
	${MySudoCom}aptitude install bitcoind
else
	echo "Inform: Step# $[I] of [$STEPs] ... Nothing to do."
fi

dpkg-query -l bitcoin-qt 2> /dev/null 1>&2
if [ ! $? = 0 ];then 
	echo "bitcoin-qt client..."
	${MySudoCom}aptitude install bitcoin-qt
else
	echo "Inform: Step# $[I] of [$STEPs] ... Nothing to do."
fi

return 0
}

create_bitcoin_conf(){
I=${1}

mkdir -p ${HOME}/.bitcoin 2>/dev/null 1>&2

if [ -f "${HOME}/.bitcoin/bitcoin.conf" ];then

echo "Inform: Replace existing [\"${HOME}/.bitcoin/bitcoin.conf\"]?"
yesorno
case $OK in
	1)
		echo "Ok"
		OverW="yes"
	;;
	0)
		echo "Continue"
		OverW="no"
	;;
esac
else
	echo "Inform: Touch the .bitcoin/bitcoin.conf..."
	OverW="yes"
fi
if [ "${OverW}" = "yes" ];then
	MyBCUser=bitcoinrpc
	MyBCPasswd=`uuidgen -r`
	echo "Inform: Creating the initial [\"${HOME}/.bitcoin/bitcoin.conf\"] configuration file."
	cat << EOF > ${HOME}/.bitcoin/bitcoin.conf
gen=1
server=1
rpcport=8332
rpctimeout=30
rpcuser=$MyBCUser
rpcpassword=$MyBCPasswd
rpcallowip=127.0.0.1
EOF
	cat ${HOME}/.bitcoin/bitcoin.conf
else
	echo "Error: Please move your ${HOME}/.bitcoin/bitcoin.conf and retry."
	echo "Inform: You chose not to overwrite it."
	exit 255
fi

return 0
}

install_solo_prereqs(){

log "Inform: Installing the SOLO prerequisite packages."
echo "Inform: We need to install [install screen git python-rrdtool python-pygame python-scipy python-twisted python-twisted-web python-imaging]..."

${MySudoCom}aptitude install screen git python-rrdtool python-pygame python-scipy python-twisted python-twisted-web python-imaging
${MySudoCom}apt-get install libboost-all-dev
${MySudoCom}apt-get install libminiupnpc-dev
${MySudoCom}apt-get install libdb4.8++
${MySudoCom}apt-get install libdb4.8++-dev
${MySudoCom}apt-get install sqlite
${MySudoCom}apt-get install sqlite2
${MySudoCom}apt-get install python-sqlite2
${MySudoCom}apt-get install python-pysqlite2
${MySudoCom}apt-get install python-dev
${MySudoCom}apt-get install python-setuptools
${MySudoCom}apt-get install python-crypto

return 0
}

install_solo(){

log "Inform: Installing the SOLO package."

mkdir -p ${myinstalloc}/${SUBject}
cd ${myinstalloc}/${SUBject}

git clone https://github.com/slush0/stratum.git
git clone https://github.com/generalfault/stratum-mining.git 

${MySudoCom}/usr/bin/easy_install-2.7 -U distribute
${MySudoCom}/usr/bin/easy_install-2.7 stratum
${MySudoCom}/usr/bin/easy_install-2.7 simplejson

# TWISTED https://github.com/Crypto-Expert/stratum-mining/issues/90
${MySudoCom}sudo cp /usr/local/lib/python2.7/dist-packages/stratum-0.2.15-py2.7.egg/stratum/websocket_transport.py /usr/local/lib/python2.7/dist-packages/stratum-0.2.15-py2.7.egg/stratum/websocket_transport.py.bu.`date +%B%d%Y`
${MySudoCom}sed -i "s/from autobahn.websocket import/from autobahn.twisted.websocket import/" /usr/local/lib/python2.7/dist-packages/stratum-0.2.15-py2.7.egg/stratum/websocket_transport.py


return 0
}

create_config_py()
{

log "Inform: Configuring the SOLO proxy."

read -p "ATTENTION: Please enter A valid BITCOIN WALLET Address? [${1}] This is for config.py ()? " MyWallet
echo "Ok: $MyWallet"

rpcuser=`grep "^rpcuser" ${HOME}/.bitcoin/bitcoin.conf | cut -d'=' -f2`
rpcpassword=`grep "^rpcpassword" ${HOME}/.bitcoin/bitcoin.conf | cut -d'=' -f2`

cat <<EOF > ${myinstalloc}/${SUBject}/stratum-mining/conf/config.py
'''
This is example configuration for Stratum server.
Please rename it to config.py and fill correct values.
This is already setup with sane values for solomining.
'''
CENTRAL_WALLET = "$MyWallet"	# local bitcoin address where YOUR money goes
BITCOIN_TRUSTED_HOST = 'localhost'
BITCOIN_TRUSTED_PORT = 8332
BITCOIN_TRUSTED_USER = "$rpcuser"
BITCOIN_TRUSTED_PASSWORD = "$rpcpassword"
DEBUG = False
LOGDIR = 'log/'
LOGFILE = None
LOGLEVEL = 'INFO'
THREAD_POOL_SIZE = 30
ENABLE_EXAMPLE_SERVICE = True
HOSTNAME = 'localhost'
LISTEN_SOCKET_TRANSPORT = 3333
LISTEN_HTTP_TRANSPORT = None
LISTEN_HTTPS_TRANSPORT = None
LISTEN_WS_TRANSPORT = None
LISTEN_WSS_TRANSPORT = None
ADMIN_PASSWORD_SHA256 = '#ADMIN_HASH#'
IRC_NICK = None
DATABASE_DRIVER = 'sqlite'
DATABASE_EXTEND = True
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
ALLOW_NONLOCAL_WALLET = True				# Allow valid, but NON-Local wallet's
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

return 0
}

start_solo(){

log "Inform: Starting SOLO."

rpcuser=`grep "^rpcuser" ${HOME}/.bitcoin/bitcoin.conf | cut -d'=' -f2`
rpcpassword=`grep "^rpcpassword" ${HOME}/.bitcoin/bitcoin.conf | cut -d'=' -f2`

echo "Inform: ${myinstalloc}/${SUBject}/stratum-mining/twisted.bash"
cd ${myinstalloc}/${SUBject}/stratum-mining;nohup ${myinstalloc}/${SUBject}/stratum-mining/twisted.bash &

return 0
}

write_startup_script(){

log "Inform: Creating a startup SOLO script."

cat << EOF > ${myinstalloc}/${SUBject}/stratum-mining/twisted.bash
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
chmod a+x ${myinstalloc}/${SUBject}/stratum-mining/twisted.bash

return 0
}

generate_random_hash(){

log "Inform: Generating a random hash."

rpcuser=`grep "^rpcuser" ${HOME}/.bitcoin/bitcoin.conf | cut -d'=' -f2`
rpcpassword=`grep "^rpcpassword" ${HOME}/.bitcoin/bitcoin.conf | cut -d'=' -f2`

echo -n "$rpcpassword" | shasum -a 256 | awk '{print $1}' > ${myinstalloc}/${SUBject}/ADMIN_HASH
MyAdminHash=`cat ${myinstalloc}/${SUBject}/ADMIN_HASH`
sed -i "s/#ADMIN_HASH#/${MyAdminHash}/g" ${myinstalloc}/${SUBject}/stratum-mining/conf/config.py 

return 0
}

block_notify(){

log "Inform: Setting up block notify."

rpcuser=`grep "^rpcuser" ${HOME}/.bitcoin/bitcoin.conf | cut -d'=' -f2`
rpcpassword=`grep "^rpcpassword" ${HOME}/.bitcoin/bitcoin.conf | cut -d'=' -f2`

echo "Inform: ${myinstalloc}/${SUBject}/stratum-mining/scripts/blocknotify.sh --password $rpcpassword --host localhost --port 3333"
${myinstalloc}/${SUBject}/stratum-mining/scripts/blocknotify.sh --password $rpcpassword --host localhost --port 3333

echo "Inform: Restarting the bitcoind."
${MySudoCom}bitcoind stop;sleep 10;${MySudoCom}bitcoind stop 2>/dev/null 1>&2
echo "Inform: bitcoind -blocknotify=\"${myinstalloc}/${SUBject}/stratum-mining/scripts/blocknotify.sh --password $rpcpassword --host localhost --port 3333\" -daemon"
bitcoind -blocknotify="${myinstalloc}/${SUBject}/stratum-mining/scripts/blocknotify.sh --password $rpcpassword --host localhost --port 3333" -daemon
echo "Inform: Waiting for bitcoin. Please wait 60 seconds."

for i in {0..60..1}
  do
        echo -n "Pausing for [$i] seconds"
        sleep 1
done

echo "Inform: Attempt to communicate. The daemon may still be starting. Check the debug.log in the .bitcoin directory."
ps -ef | grep bitcoind
bitcoind getinfo

return 0
}


runyesorno install_bitcoin 1 	"Install the Bitcoin daemon."	|| exit 1
runyesorno create_bitcoin_conf 2	"Create the Bitcoin config file." || exit 1
runyesorno start_bitcoind 3	"Start the Bitcoin daemon."	|| exit 1
runyesorno install_solo_prereqs 4 "Install the SOLO prequisites."	|| exit 1
runyesorno install_solo	5 "Install SOLO Mining."		|| exit 1
runyesorno write_startup_script 6 "Write the startup script." || exit 1
runyesorno create_config_py 7 "Create the config.py config file." 	|| exit 1
runyesorno generate_random_hash 8  "Generate a random hash password."|| exit 1
runyesorno start_solo 9	"Start the SOLO Miner." 		|| exit 1
runyesorno block_notify 10	"Setup the stratum for block notifications." 		|| exit 1

echo "Exiting ..."
read -p "Hit ENTER to continue..." ; echo "Ok"
sleep 2
cd ${P};${P}/${RETURN}.sh
exit
