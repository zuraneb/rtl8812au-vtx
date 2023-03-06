#!/bin/bash
echo "We're now compiling the rtl8812au driver into your stock kernel"

# Load the kernel headers for the target system
sudo apt install -y dkms linux-headers-$(uname -r)
sudo ./usr/src/rtl8812au-5.2.20.2/ > /opt/installrtl.log
systemctl disable rtl8812auEasyCompile
sudo rm -Rf /etc/systemd/system/rtl8812auEasyCompile.service
sudo rm -Rf /usr/local/bin/rtl8812auEasyCompile.sh
echo "cleanup done"