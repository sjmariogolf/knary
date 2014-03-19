#
# CUDA-6.0 Drivers page
#
# http://www.nvidia.com/Download/index.aspx

# Toolkit
#
# https://developer.nvidia.com/cuda-pre-production

#
# Download, ;ctl+alt+f1; chmod a+x *run; /etc/init.d/lightdm stop; run the installs.
# Add PATH to ~/.bashrc; then LD_LIBRARY_PATH, may use /etc/ld.conf file
# cat /etc/ld.so.conf
# include /etc/ld.so.conf.d/*.conf
# sudo echo "include /usr/local/cuda-6.0/lib" >> /etc/ld.so.conf;ldconfig

# sudo echo "PATH=\$PATH:/usr/local/cuda-6.0/bin" >> ~/.bashrc
# tail -n 1 ~/.bashrc
# PATH=$PATH:/usr/local/cuda-6.0/bin

# reboot

# See CUDA cgminer notes below for clean
#
#------------------------------------------------------------------------
#cgminer 3.7.2
#------------------------------------------------------------------------

#Configuration Options Summary:

#  libcurl(GBT+getwork).: Enabled: -lcurl  
#  curses.TUI...........: FOUND: -lncurses
#  OpenCL...............: FOUND. GPU mining support enabled
#  scrypt...............: Enabled
#  ADL..................: Detection overrided. GPU monitoring support DISABLED

#  Avalon.ASICs.........: Disabled
#  BFL.ASICs............: Disabled
#  KnC.ASICs............: Disabled
#  BitForce.FPGAs.......: Disabled
#  BitFury.ASICs........: Disabled
#  Hashfast.ASICs.......: Disabled
#  Icarus.ASICs/FPGAs...: Disabled
#  Klondike.ASICs.......: Disabled
#  ModMiner.FPGAs.......: Disabled

#Compilation............: make (or gmake)
#  CPPFLAGS.............: 
#  CFLAGS...............: -I/usr/local/cuda-6.0/include
#  LDFLAGS..............: -L/usr/local/cuda-6.0/lib64 -lpthread
#  LDADD................: -ldl -lcurl   compat/jansson-2.5/src/.libs/libjansson.a -lpthread -lOpenCL    -lm  -lrt

#Installation...........: make install (as root if needed, with 'su' or 'sudo')
#  prefix...............: /usr/local

# cd to the cgminer directory
make distclean
export CFLAGS=-I/usr/local/cuda-6.0/include LDFLAGS=-L/usr/local/cuda-6.0/lib64
./configure --enable-scrypt --enable-opencl --disable-adl
make clean
make
sudo make install
