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

#!/bin/bash
# sudo apt-get update
# sudo apt-get install gcc
# wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1204/x86_64/cuda-repo-ubuntu1204_5.5-0_amd64.deb
# sudo dpkg -i cuda-repo-ubuntu1204_5.5-0_amd64.deb
# sudo apt-get update
# sudo apt-get install cuda
# export PATH=/usr/local/cuda-5.5/bin:$PATH
# export LD_LIBRARY_PATH=/usr/local/cuda-5.5/lib64:$LD_LIBRARY_PATH
# sudo apt-get install opencl-headers python-pip python-dev python-numpy python-mako
# wget https://pypi.python.org/packages/source/p/pyopencl/pyopencl-2013.1.tar.gz#md5=c506e4ec5bc56ad85bf005ec40d4783b
# tar -vxzf pyopencl-2013.1.tar.gz
# cd pyopencl-2013.1
# sudo python setup.py install

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
