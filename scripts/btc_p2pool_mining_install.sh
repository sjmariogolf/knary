#!/bin/bash -   
#title          :btc_p2pool_mining_install.sh
#description    :Main Shell for P2Pool BITCOIN-MINING
#author         :Steven J. Martin
#date           :20140222
#version        :${version}
#usage          :./btc_p2pool_mining_install.sh
#notes          :       
#bash_version   :4.2.45(1)-release
#============================================================================

p=`pwd`
SUBject="p2pool-bitcoin"
INSTLOC=`echo ${SUBject} | tr '[:lower:]' '[:upper:]'`
RETURN="scripts/main_solo-p2pool"

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

log "Inform:Starting P2Pool BITCOIN installation. [${myinstalloc}]."

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
server=1
rpcport=8332
rpctimeout=30
rpcuser=$MyBCUser
rpcpassword=$MyBCPasswd
rpcallowip=127.0.0.1
blockmaxsize=1000000
mintxfee=0.00001
minrelaytxfee=0.00001
EOF
	cat ${HOME}/.bitcoin/bitcoin.conf
else
	echo "Error: Please move your ${HOME}/.bitcoin/bitcoin.conf and retry."
	echo "Inform: You chose not to overwrite it."
	exit 255
fi

return 0
}

install_p2pool_prereqs(){

log "Inform: Installing the P2POOL prerequisite packages."
echo "Inform: We need to install [install screen git python-rrdtool python-pygame python-scipy python-twisted python-twisted-web python-imaging]..."
${MySudoCom}aptitude install screen git python-rrdtool python-pygame python-scipy python-twisted python-twisted-web python-imaging

return 0
}

install_p2pool(){

log "Inform: Installing the P2POOL package."

mkdir -p ${myinstalloc}/${SUBject}
cd ${myinstalloc}/${SUBject}

git clone git://github.com/forrestv/p2pool.git

return 0
}

start_p2pool(){

log "Inform: Starting P2POOL."

rpcuser=`grep "^rpcuser" ${HOME}/.bitcoin/bitcoin.conf | cut -d'=' -f2`
rpcpassword=`grep "^rpcpassword" ${HOME}/.bitcoin/bitcoin.conf | cut -d'=' -f2`

echo "Inform: ${myinstalloc}/${SUBject}/p2pool/run_p2pool.py --give-author 0 ${rpcuser} ${rpcpassword}"
cd ${myinstalloc}/${SUBject}/p2pool;nohup ${myinstalloc}/${SUBject}/p2pool/run_p2pool.py --give-author 0 ${rpcuser} ${rpcpassword} &

return 0
}

write_startup_script(){

log "Inform: Creating a startup P2POOL script."

read -p "ATTENTION: Please enter A valid BITCOIN WALLET Address? [${1}] This is for config.py ()? " MyWallet
echo "Ok: $MyWallet"


cat > ${myinstalloc}/${SUBject}/p2pool/p2pool.sh << EOF
#!/bin/bash
P=`pwd`
P2POOL_DIR=${P}/p2pool

rpcuser=`grep "^rpcuser" \${HOME}/.bitcoin/bitcoin.conf | cut -d'=' -f2`
rpcpassword=`grep "^rpcpassword" \${HOME}/.bitcoin/bitcoin.conf | cut -d'=' -f2`

EXISTINGPID=`pgrep -f run_p2pool.py`

cd $P2POOL_DIR
if git pull | grep -q 'Already up-to-date'; then
        if [[ ! -z "\$EXISTINGPID" ]]; then
                echo "No restart needed for p2pool"
        else
                echo "No update for p2pool but found no running instance, launching..."
               ./run_p2pool.py --give-author 0 \$rpcuser \$rpcpassword -a $MyWallet
        fi
else
        echo "Starting new p2pool"
        ./run_p2pool.py --give-author 0 \$rpcuser \$rpcpassword -a $MyWallet
        if [[ ! -z "\$EXISTINGPID" ]]; then
                echo "Waiting for new p2pool to be ready"
                sleep 90
                echo "Killing old p2pool"
                kill \$EXISTINGPID
        fi
fi
EOF
chmod a+x ${myinstalloc}/${SUBject}/p2pool/p2pool.sh

return 0
}

runyesorno install_bitcoin      1       "Install the bitcoin daemon."   || exit 1
runyesorno create_bitcoin_conf  2       "Create the bitcoin conf file." || exit 1
runyesorno start_bitcoind       3       "Start the bincoin daemon."     || exit 1
runyesorno install_p2pool_prereqs 4     "Install P2Pool prerequisites." || exit 1
runyesorno install_p2pool       5       "Install P2Pool."               || exit 1
runyesorno write_startup_script 6       "Create a P2Pool startup script." || exit 1
runyesorno start_p2pool         7       "Start the P2Pool service."     || exit 1

echo "Exiting ..."
read -p "Hit ENTER to continue..." ; echo "Ok"
sleep 2
cd ${P};${P}/${RETURN}.sh
exit
