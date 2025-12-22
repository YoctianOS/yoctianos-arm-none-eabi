#!/bin/sh

BASE_DIR="$HOME/yoctianos-arm-none-eabi"

echo "1. Download DEB packages (if it's nessesary)"
sudo apt update
sudo apt install -y build-essential gperf bison flex texinfo libncurses5-dev python3 gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf binutils-arm-linux-gnueabihf help2man libtool libtool-bin automake autoconf

echo "2. GIT clone the crosstool-ng (if it's nessesary)"
cd $HOME
git clone https://github.com/crosstool-ng/crosstool-ng.git

echo "3. GIT pull the crosstool-ng (if it's nessesary)"
cd $HOME/crosstool-ng
git pull

echo "4. Prepare crosstool-ng"
cd $HOME/crosstool-ng
./bootstrap
./configure --enable-local
make

echo "5. Copy the .config to crosstool-ng"
cd $BASE_DIR
cp .config $HOME/crosstool-ng

echo "6. Start the crosstool-ng build"
cd $HOME/crosstool-ng
./ct-ng build

echo "7. Move the build folder to $BASE_DIR/output"
cd $HOME/x-tools/HOST-arm-linux-gnueabihf
mv ./arm-none-eabi $BASE_DIR/output/yoctianos-arm-none-eabi

echo "Done!"
