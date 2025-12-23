#!/bin/sh

set -e  # Stop on any error

BASE_DIR="$HOME/yoctianos-arm-none-eabi"
CTNG_DIR="$HOME/crosstool-ng"
OUTPUT_DIR="$BASE_DIR/output"
ARCHIVE_NAME="yoctianos-arm-none-eabi.tar.xz"

# ---------------------------------------------------------
# 1. Ensure the script is NOT run as root
# ---------------------------------------------------------

if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR: Do not run this script as root."
    exit 1
fi

# ---------------------------------------------------------
# 2. Ensure the system is Ubuntu 22.04
# ---------------------------------------------------------
#
# if ! command -v lsb_release >/dev/null 2>&1; then
#     echo "ERROR: lsb_release command not found. Install 'lsb-release'."
#     exit 1
# fi
#
# UBU_VERSION=$(lsb_release -rs)
#
# if [ "$UBU_VERSION" != "22.04" ]; then
#     echo "ERROR: This script must be run on Ubuntu 22.04."
#     echo "Detected version: $UBU_VERSION"
#     exit 1
# fi
#
# echo "Ubuntu 22.04 detected."
#
# ---------------------------------------------------------
# 3. Install required packages
# ---------------------------------------------------------

echo "Installing required packages..."
sudo apt update
sudo apt install -y \
    build-essential gperf bison flex texinfo libncurses5-dev python3 \
    gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf binutils-arm-linux-gnueabihf \
    help2man libtool libtool-bin automake autoconf git

# ---------------------------------------------------------
# 4. Clone crosstool-ng if missing
# ---------------------------------------------------------

echo "Cloning crosstool-ng if needed..."
if [ ! -d "$CTNG_DIR" ]; then
    git clone https://github.com/crosstool-ng/crosstool-ng.git "$CTNG_DIR"
fi

echo "Updating crosstool-ng..."
cd "$CTNG_DIR"
git pull

# ---------------------------------------------------------
# 5. Prepare crosstool-ng
# ---------------------------------------------------------

echo "Preparing crosstool-ng..."
./bootstrap
./configure --enable-local
make
./ct-ng distclean || true

# ---------------------------------------------------------
# 6. Copy the .config file
# ---------------------------------------------------------
echo "Copying .config..."

if [ ! -f "$BASE_DIR/.config" ]; then
    echo "ERROR: $BASE_DIR/.config not found."
    exit 1
fi

cp "$BASE_DIR/.config" "$CTNG_DIR/.config"

# ---------------------------------------------------------
# 7. Build the toolchain
# ---------------------------------------------------------

echo "Starting crosstool-ng build..."
cd "$CTNG_DIR"
./ct-ng build

# ---------------------------------------------------------
# 8. Move the generated toolchain
# ---------------------------------------------------------

echo "Moving build output..."

mkdir -p "$OUTPUT_DIR"

TOOLCHAIN_PATH="$HOME/x-tools/HOST-arm-linux-gnueabihf/arm-none-eabi"

if [ ! -d "$TOOLCHAIN_PATH" ]; then
    echo "ERROR: Toolchain output not found at $TOOLCHAIN_PATH"
    exit 1
fi

sudo mv "$TOOLCHAIN_PATH" "$OUTPUT_DIR/yoctianos-arm-none-eabi"

# ---------------------------------------------------------
# 9. Make all files and directories executable
# ---------------------------------------------------------

echo "Applying chmod +x to all files and directories..."

TARGET_DIR="$OUTPUT_DIR/yoctianos-arm-none-eabi"

if [ ! -d "$TARGET_DIR" ]; then
    echo "ERROR: Target directory not found: $TARGET_DIR"
    exit 1
fi

# Add execute permission to all directories
find "$TARGET_DIR" -type d -exec chmod +x {} \;

# Add execute permission to all files
find "$TARGET_DIR" -type f -exec chmod +x {} \;

echo "Permissions updated."

# ---------------------------------------------------------
# 10. Compress the final toolchain
# ---------------------------------------------------------

echo "Compressing final toolchain..."

cd "$OUTPUT_DIR"
tar -cJf "$ARCHIVE_NAME" yoctianos-arm-none-eabi

echo "Build completed successfully."
echo "Archive created at: $OUTPUT_DIR/$ARCHIVE_NAME"
