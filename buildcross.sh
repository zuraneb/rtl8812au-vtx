#!/bin/bash
#This file is the install instruction for the CHROOT build
#We're using cloudsmith-cli to upload the file in CHROOT


#install dependencies
sudo apt update --allow-releaseinfo-change
sudo apt install build-essential tree bc u-boot-tools gcc-python3-plugin bison ccache fakeroot flex git kmod libelf-dev libssl-dev make python3-pip gcc-10-aarch64-linux-gnu ruby
sudo gem install --no-document fpm
sudo pip3 install --upgrade cloudsmith-cli

#choosing architecture
sed -i 's/CONFIG_PLATFORM_I386_PC = y/CONFIG_PLATFORM_I386_PC = n/g' Makefile
sed -i 's/CONFIG_PLATFORM_ARM64_RPI = n/CONFIG_PLATFORM_ARM64_RPI = y/g' Makefile
sed -i 's/u8 fixed_rate = MGN_1M, sgi = 0, bwidth = 0, ldpc = 0, stbc = 0;/u8 fixed_rate = MGN_1M, sgi = 0, bwidth = 0, ldpc = 0, stbc = 1;/' core/rtw_xmit.c

#using fixed directories for simplification
mkdir -p /opt/rtl8812au
cp -r * /opt/rtl8812au/

#installing crosscompiler
mkdir -p /opt/crosscompiler
cd /opt/crosscompiler
wget -q --show-progress --progress=bar:force:noscroll http://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/aarch64-linux-gnu/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
tar xf gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
export ARCH=arm64
PACKAGE_ARCH=arm64
export CROSS_COMPILE=/opt/crosscompiler/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
cd /opt/rtl8812au/

#prepping kernel
cd /opt/
git clone https://github.com/OpenHD/RK_Kernel kernel --depth=1
cd kernel
make rockchip_linux_defconfig && make prepare
cd /opt/rtl8812au/

#dirty path hack
mkdir -p /opt/rtl8812au/drivers/net/wireless/rtl8812au
rsync -av --progress * /opt/rtl8812au/drivers/net/wireless/rtl8812au/ --exclude drivers

#build driver
mkdir -p /opt/package
export KERNEL_VERSION="5.10.110-99-rockchip"
make KSRC=/opt/kernel -j $J_CORES M=$(pwd) modules
mkdir -p /opt/package/lib/modules/${KERNEL_VERSION}/kernel/drivers/net/wireless/realtek/rtl8812au
install -p -m 644 88XXau_wfb.ko "/opt/package/lib/modules/${KERNEL_VERSION}/kernel/drivers/net/wireless/88XXau_wfb.ko"

fpm -a arm64 -s dir -t deb -n rtl8812au -v 2.5-$(date '+%m%d%H%M') -C /opt/packagedir/ -p rtl8812au.deb