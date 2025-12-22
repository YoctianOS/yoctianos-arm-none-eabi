#!/bin/sh

BASE_DIR="$HOME/yoctianos-arm-none-eabi"

echo "0. Download DEB packages (if it's nessesary)"
sudo apt update
sudo apt install -y git build-essential gperf bison flex texinfo libtool libncurses5-dev python3 \
                    gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf binutils-arm-linux-gnueabihf help2man

echo "1. GIT pull the yoctianos-arm-none-eabi (if it's nessesary)"
cd $BASE_DIR
git pull

echo "2a. GIT clone the crosstool-ng"
cd $HOME
git clone https://github.com/crosstool-ng/crosstool-ng.git

echo "2b. GIT pull the crosstool-ng (if it's nessesary)"
cd $HOME/crosstool-ng
git pull

echo "3. Prepare crosstool-ng"
cd $HOME/crosstool-ng
./bootstrap
./configure --enable-local
make

echo "4. Copy the .config to crosstool-ng"
cd $BASE_DIR
cp .config $HOME/crosstool-ng

echo "5. Start the crosstool-ng build"
cd $HOME/crosstool-ng
./ct-ng build

echo "6. Move the build folder to $BASE_DIR/output"
cd $HOME/x-tools/HOST-arm-linux-gnueabihf
mv ./arm-none-eabi $BASE_DIR/output/yoctianos-arm-none-eabi

echo "Done!"
