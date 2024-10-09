#!/bin/bash

# You can install snort and libdaq in your current path
# Or specify a single path for both
# Or specify a path for libdaq and snort
err_usage="[!] Usage: $0 /path/to/libdaq /path/to/snort | $0 /path/to/libdaq_and_snort"


install_snort() {
    # Update packages and install depencies
    sudo apt update
    sudo apt install build-essential libpcap-dev libpcre3-dev libdnet-dev zlib1g-dev

    # Install libdaq
    git clone https://github.com/snort3/libdaq.git
    cd libdaq
    ./bootstrap
    ./configure --prefix=/usr/local/lib/daq_s3
    sudo make install
    sudo ldconfig

    # Install snort
    cd ..
    git clone https://github.com/snort3/snort3.git
    cd snort3
    ./configure_cmake.sh

    # Compile snort
    cd build
    make -j $(nproc)
    sudo make install

    # Verify version
    snort -V
}

echo $err_usage;
#install_snort $1 $2