#!/bin/bash



# ---
# Snort3 installer using apt package manager
# 
# Manage : installation, update and removal
# Add-on : hyperscan for fast pattern matching, more to come
#
# Author : archie - 2024
# ---



#colors
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

#depedencies
snort_required_packages=('cmake'            #snort requirements
                        'libdaq-dev' 
                        'libdnet-dev' 
                        'flex' 
                        'g++' 
                        'libhwloc-dev' 
                        'libluajit-5.1-dev' 
                        'libssl-dev' 
                        'libpcap-dev' 
                        'libpcre3-dev' 
                        'pkg-config'
                        'zlib1g-dev'
                        'ragel'            #hyperscan requirements
                        'build-essential'
                        'libboost-all-dev'
                        'libhyperscan-dev')


set_variables() {
    snort_default_path="/usr/local/snort"
    daq_default_path="/usr/local/lib/daq_s3"
}

install_depedencies() {
    for i in "$1"
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
    ./configure_cmake.sh --prefix=${snort_default_path} --with-daq-includes=${daq_default_path}/include/ --with-daq-libraries=${daq_default_path}/lib/
    cd build
    make -j $(( $(nproc) / 2 )) -s
    sudo make install -s
    sudo ldconfig
    echo -e "${GREEN}[✔] Snort3 installed !${NC}" 
}

install_libdaq() {
    if ! git clone -q https://github.com/snort3/libdaq.git; then 
        echo -e "${RED}[✘] Error : couldn't get libdaq repository${NC}"
        echo -e "${RED}[✘] Error : couldn't get libdaq repository${NC}"
        return 0
    fi
    cd libdaq
    ./bootstrap
    ./configure
    make -j $(( $(nproc) / 2 )) -s
    sudo make install -s
    ./configure
    make -j $(( $(nproc) / 2 )) -s
    sudo make install -s
    echo -e "${GREEN}[✔] Libdaq installed !${NC}" 
}

remove_snort_installation() {
    sudo rm -rf ${snort_default_path}
}


remove_libdaq_installation() {
    sudo rm -rf ${daq_default_path}
}

remove_snort() {
    remove_snort_installation
    remove_libdaq_installation
    sudo rm -rf ~/snort_src
}

install_snort() {
    set_variables

    mkdir ~/snort_src && cd ~/snort_src
    install_libdaq

    cd ~/snort_src
    install_snort
    snort -V
}


remove_snort
install_snort
