'''
This is example configuration for Stratum server.
Please rename it to config.py and fill correct values.

This is already setup with sane values for solomining.
You NEED to set the parameters in BASIC SETTINGS
'''

# ******************** BASIC SETTINGS ***************
# These are the MUST BE SET parameters!

CENTRAL_WALLET = '1nVgFOOOBAAAR1vnQZNMFOOOOBAARRdXx'        # local bitcoin address where money goes

BITCOIN_TRUSTED_HOST = 'localhost'
BITCOIN_TRUSTED_PORT = 8332
BITCOIN_TRUSTED_USER = "bitcoinrpc"
BITCOIN_TRUSTED_PASSWORD = "194f8943-fake-4662-fake-35e9b6aa9544"
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
ADMIN_PASSWORD_SHA256 = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
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
