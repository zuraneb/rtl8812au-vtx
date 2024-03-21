#!/bin/bash
# This file is the install instruction for the CHROOT build
# We're using cloudsmith-cli to upload the file in CHROOT

sudo apt install -y python3-pip ruby ruby-dev rubygems build-essential
gem install fpm
sudo pip3 install --upgrade cloudsmith-cli --break-system-packages
ls -a
API_KEY=$(cat cloudsmith_api_key.txt)
DISTRO=$(cat distro.txt)
FLAVOR=$(cat flavor.txt)
REPO=$(cat repo.txt)
CUSTOM=$(cat custom.txt)
ARCH=$(cat arch.txt)

echo ${DISTRO}
echo ${FLAVOR}
echo ${CUSTOM}
echo ${ARCH}

if [[ -e /etc/os-release && $(grep -c "Raspbian" /etc/os-release) -gt 0 ]]; then
    echo "building for the raspberry pi"
    sudo apt update 
    sudo apt install -y build-essential flex bc bison dkms raspberrypi-kernel-headers
    echo "---------------"
    echo "_____________________________________________"
    ls -a /usr/src/
elif [[ -e /etc/os-release && $(grep -c "Armbian" /etc/os-release) -gt 0 ]]; then
    sudo pip3 install --upgrade cloudsmith-cli
    echo "building for the x20"
    sudo apt update 
    sudo apt install -y build-essential flex bc bison dkms git
    wget https://fra1.digitaloceanspaces.com/openhd-images/BaseImages/OpenHD-X20-kernel.zip
    mkdir -p OpenHD-X20-kernel
    unzip OpenHD-X20-kernel.zip -d OpenHD-X20-kernel/
    rm -Rf *.zip
    echo "---------------"
    echo $PWD
    echo "_____________________________________________"
    make ARCH=arm KSRC=OpenHD-X20-kernel/OpenHD-X20-kernel
    mkdir -p package/lib/modules/5.8.0/kernel/drivers/net/
    cp *.ko package/lib/modules/5.8.0/kernel/drivers/net/
    ls -a
    fpm -a armhf -s dir -t deb -n rtl8812au-x20 -v 2.5-evo-$(date '+%m%d%H%M') -C package -p rtl8812au-x20.deb --before-install before-install.sh --after-install after-install.sh
echo "push to cloudsmith"
git describe --exact-match HEAD >/dev/null 2>&1
echo "Pushing the package to OpenHD 2.5 repository"
ls -a
cloudsmith push deb --api-key "$API_KEY" openhd/release/debian/bullseye rtl8812au-x20.deb || exit 1
else

sudo apt update 
sudo apt install -y build-essential flex bc bison dkms
make KSRC=/usr/src/linux-headers-6.3.13-060313-generic CROSS_COMPILE=arm-linux-gnueabi- O="" modules
mkdir -p package/lib/modules/6.3.13-060313-generic/kernel/drivers/net/wireless/
cp *.ko package/lib/modules/6.3.13-060313-generic/kernel/drivers/net/wireless/
ls -a
fpm -a amd64 -s dir -t deb -n rtl8812au-x86 -v 2.5-evo-$(date '+%m%d%H%M') -C package -p rtl8812au-x86.deb --before-install before-install.sh --after-install after-install.sh

echo "copied deb file"
echo "push to cloudsmith"
git describe --exact-match HEAD >/dev/null 2>&1
echo "Pushing the package to OpenHD 2.5 repository"
ls -a
cloudsmith push deb --api-key "$API_KEY" openhd/release/ubuntu/lunar rtl8812au-x86.deb || exit 1
fi
