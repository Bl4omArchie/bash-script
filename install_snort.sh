#!/bin/bash



# ~ Snort installation script ~
# Author : archie
# Description : install snort3, with gperftools and hyperscan, for linux using apt package manager 




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
                        'hwloc' 
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


config_snort_rules() {
    sudo mkdir /usr/local/etc/rules
    sudo mkdir /usr/local/etc/so_rules/
    sudo mkdir /usr/local/etc/lists/
    sudo touch /usr/local/etc/rules/local.rules
    sudo touch /usr/local/etc/lists/default.blocklist
    sudo mkdir /var/log/snort
}

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
    ./configure_cmake.sh
    cd build
    make -j $(( $(nproc) / 2 )) -s
    sudo make install -s
    sudo ldconfig
    echo -e "${GREEN}[✔] Snort3 installed !${NC}" 
}

install_libdaq() {
    if ! git clone -q https://github.com/snort3/libdaq.git; then 
        echo -e "${RED}[✘] Error : couldn't get libdaq repository${NC}"
        return 0
    fi
    cd libdaq
    ./bootstrap
    ./configure
    make -j $(( $(nproc) / 2 )) -s
    sudo make install -s
    echo -e "${GREEN}[✔] Libdaq installed !${NC}" 
}

remove_snort_installation() {
    sudo rm -rf ~/snort_src/snort3
    sudo rm -rf /usr/local/snort
    sudo rm -rf /usr/local/bin/snort*
    sudo rm -rf /usr/local/lib/snort*
    sudo rm -rf /usr/local/etc/snort/
    sudo rm -rf /var/log/snort/
}

remove_installation() {
    remove_snort_installation
    sudo rm -rf ~/snort_src
}

start_snort_installation() {
    mkdir ~/snort_src && cd ~/snort_src
    install_libdaq

    cd ~/snort_src
    install_snort

    snort -V

    config_hyperscan
}


remove_installation
start_snort_installation
config_snort_rules
