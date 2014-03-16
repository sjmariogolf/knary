knary-0.0.1
===========

Knary


knary_execution.sh

The MAIN entry to the Knary application. Execute this script as ./knary_execution.sh to invoke the app.

Currently this is a work in beta testing.

https://github.com/sjmariogolf/knary.git

git clone https://github.com/sjmariogolf/knary.git

This is a complete installation, configuration and execution scripting environment for cryptocoin minin rigs.

Tested with Debian, Ubuntu, and CentOS Server and Desktop. Ubuntu 12.10 Server/Desktop has additionally been tested for longevity without problems, and for this reason only, it is the authors recommended Distribution.

Installation notes for the impatient:)

=====================================================================
Download the Ubuntu 12.10 Server LiveCD.

Install Ubuntu 12.10. "http://releases.ubuntu.com/12.10/"

For GPU ... "sudo apt-get install tasksel;tasksel" # Choose a desktop

Login to Linux and cd $HOME

git clone https://github.com/sjmariogolf/knary.git

cd knary

./knary_execution.sh
=====================================================================

It is a complete "rig" Automation application written in SHELL for ease of read, extendability and reuse. It utilizes "dialog" as a Command User Interface. This application was written as a mechanism to quickly setup mining rigs from bare metal Linux Installations. It includes support for cpuminer, bfgminer, cgminer ASICs, cgminer GPU, bitcoin and litecoin daemons and clients, P2Pool, and SOLO Mining.

The directory structure
Following is the basic directory structure for the application.  Below is a detailed functional explanation specific to each of the directoies.


knary 			      The Knary top level directory
knary/include 		The Knary Include files
knary/var/log 		Logging
knary/results 		Results files from Installations
knary/scripts 		The Scripts directory
knary/doc 			  Documents README LICENSE
knary/exec		    The Executable top level
knary/skels		    Skeletal Configurations for executables 
knary/git 			  git files
knary/downloads 	A directory for download storage
knary/data 		    Data and directory information
knary/temp 	  	  Temporary storage
knary/config 	  	Private configuration specific to Knary


knary is the top level directory of the application. Normally this directory will be extracted or otherwise downloaded into the $HOME of your UNIX login. For example /home/unixuser. With knary extracted to /home/unixuser/knary. Change directory into the knary top level directory to start the application by entering this command: ./knary_execution.sh.

knary/include  is the include file directory and contains include files for the application. Parsing menus, logging, etc. have been segregated into include files so as not to clutter the main scripting. Using include files is also a good method of code reuse. To extend the application we will be making minor changes to at least one of these include files.

knary/var/log is a local directory for logging.

knary/results is a results directory to hold the results of “forked” installation scripts. Mini scripts are created by the application then executed to perform install steps like adding packages or updating the operating system. The output is sent to a UNIX “tee” which much like a “T” pipe that sends water in two directions, the UNIX “tee” command routes a copy of the executable output into this results directory for storage.

knary/scripts is the scripts directory. This is where ALL of the scripts reside. The scripts are categorized by their prefix. Either main or sub indicating a main call or a subordinate call. Main scripts are menus while sub scripts do work. Sub scripts are further divided into install and configure and are appropriately named for their individual jobs.

knary/doc is where we programmers like to keep ALL of our documentation. I've highlighted all here as an indicator that we programmers generally do not like to document. Thus you may find this directory a bit empty.

knary/exec is where ALL executable directories should be located. Having said that, the application allows you to place your executable directories anywhere you like. It keeps track of where they are installed in the knary/data directory in an ALL CAPITAL similar name. If you feel you would like organization then may I suggest that ALL of your installation directories are installed under exec. The application can install cgminer, bfgminer, cgminer-gpu, cpuminer, amd-drivers, cuda-drivers, stratum-mining-proxy, solo-mining, etc. This is a lot to keep track of. So please keep this in mind.

knary/skels is skeleton configuration files for the various applications Knary can install and configure. They are appropriately named by the application they represent. Any number of these skeleton files can be placed within this directory. As well, they can be named anything you choose to name them. The syntax is of course governed by the receiving application.

knary/git is only used by the application for retrieving files it requires for installation.

knary/downloads is a downloads, or archive directory to store locally zip and tar files downloaded as a result of any specific install.

knary/temp is a temporary area. No files within this directory are necessary for long term storage. Hence the name temp.

knary/config is a configuration directory used only by the application.

Execution

The main executable script is within the knary directory as: knary_execution.sh.

./knary_execution.sh
This main script determines where we are executing from and by whom. That is to say are we the root user or not. This main script attempts to determine the OS as either a Debian or Redhat clone. This is actually performed by an include file that is included as part of this and all scripts. The main script will install the dialog package, then call from the scripts directory “main_menu.sh”
The script main_menu.sh will display the main menu and pause for user input. The user input is to select from the main menu which subordinate menu to call. For example. From the main menu you can navigate to the cpu menu. From the cpu menu you can navigate to cpu installation or configuration and so on.

From the main menu

1. QUIT Return or Exit the application.
2. CPU-MINING Navigate to the CPU Mining sub menu.
3. GPU-MINING Navigate to the GPU Mining sub menu.
4. ASICS-MINING Navigate to the ASICs Mining sub menu.
5. BITCOIN Navigate to the BITCOIN sub menu.
6. LITECOIN Navigate to the LITECOIN sub menu.
7. STRATUM Navigate to the STRATUM sub menu.
8. P2Pool-SOLO Navigate to the P2POOL-SOLO sub menu.
9. MISC Navigate to the Miscellaneous sub menu


