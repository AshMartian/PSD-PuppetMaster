#!/bin/bash

cd /
rm -rf .SBAC/*
rm -rf SBAC.tar.bz2
wget http://staticfiles.psd401.net/puppet/SBAC.tar.bz2

tar -xjf SBAC.tar.bz2
rm -rf SBAC.tar.bz2
mv SBACS* .SBAC
cd .SBAC
source install-icon.sh
#source /etc/init.d/system-setup.sh

cp /etc/skel/Desktop/SBAC* /home/psd/Desktop

exit 0;
