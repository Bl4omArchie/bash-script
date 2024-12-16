#!/bin/bash


###################################################################################################
#                               ~ Snort installation script ~
# Author : archie
# Description : install snort3, with gperftools and hyperscan,  for linux using apt package manager 
###################################################################################################



#colors
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

#depedencies
snort_required_packages=('cmake' 'libdaq-dev' 'libdnet-dev' 'flex' 'g++' 'hwloc' 'libluajit-5.1-dev' 'libssl-dev' 'libpcap-dev' 'libpcre3-dev' 'pkg-config' 'zlib1g-dev')
hypperscan_required_packages=('cmake' 'ragel' 'libboost-all-dev' 'build-essential')


install_depedencies() {
    for i in "$1"
    do
        if ! dpkg -s "${i}" >/dev/null 2>&1; then
            sudo apt install "${i}" -y -qq
        fi
    done
    echo -e "${GREEN}[✔] Depedencies installed !${NC}"
    return 1
}

install_snort() {
    install_depedencies $snort_required_packages
    if ! git clone -q https://github.com/snort3/snort3.git; then 
        echo -e "${RED}[✘] Error : couldn't get snort3 repository${NC}"
        return 0
    fi
    cd snort3
    ./configure_cmake.sh --prefix=/usr/local --enable-tcmalloc
    cd build
    make -j 8 -s
    sudo make install -s
    sudo ldconfig
    echo -e "${GREEN}[✔] Snort3 installed !${NC}" 
}

install_hyperscan() {
    install_depedencies $hypperscan_required_packages
    if  ! git clone -q https://github.com/intel/hyperscan.git; then 
        echo -e "${RED}[✘] Error : couldn't get hyperscan repository${NC}"
        return 0
    fi
    cd hyperscan
    mkdir build && cd build
    cmake ..
    make -j $(nprocs) -s
    sudo make install -s
    echo -e "${GREEN}[✔] Hyperscan installed !${NC}" 
}

install_gperftools() {
    wget https://github.com/gperftools/gperftools/releases/download/gperftools-2.9.1/gperftools-2.9.1.tar.gz
    tar xzf gperftools-2.9.1.tar.gz
    cd gperftools-2.9.1/
    ./configure
    make -j $(nprocs) -s
    sudo make install -s
    echo -e "${GREEN}[✔] Gperftools installed !${NC}" 
}

install_libdaq() {
    if ! git clone -q https://github.com/snort3/libdaq.git; then 
        echo -e "${RED}[✘] Error : couldn't get libdaq repository${NC}"
        return 0
    fi
    cd libdaq
    ./bootstrap
    ./configure
    make -j $(nprocs) -s
    sudo make install -s
    echo -e "${GREEN}[✔] Libdaq installed !${NC}" 
}

start_snort_installation() {
    #mkdir ~/snort_src && cd ~/snort_src
    #install_libdaq

    #cd ~/snort_src
    #install_gperftools

    cd ~/snort_src
    install_hyperscan

    cd ~/snort_src
    install_snort

    snort -V
}


start_snort_installation
