#!/bin/bash

#####################################################################
#                   ~ Snort installation script ~                   #
#                                                                   #
# Author : archie                                                   #
# Description : install snort3 for linux using apt package manager  #
#####################################################################


#depedencies
required_packages=('cmake' 'libdaq-dev' 'libdnet-dev' 'flex' 'g++' 'hwloc' 'libluajit-5.1-dev' 'libssl-dev' 'libpcap-dev' 'libpcre3-dev' 'pkg-config' 'zlib1g-dev')

#default path for snort3 repository and libdaq library
snort3_repository_path="/home/cryptx/snort3"
libdaq_repository_path="/home/cryptx/libdaq"
libdaq_lib_path="/usr/local/lib/daq_s3"

#colors
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"



install_depedencies() {
    for i in "${required_packages[@]}"
    do
        if ! dpkg -s "${i}" >/dev/null 2>&1; then
            sudo apt install "${i}" -y -qq
        fi
    done
    echo -e "${GREEN}[✔] Depedencies installed !${NC}"
    return 1
}

install_libdaq() {
    cd /home/cryptx
    if ! git clone -q https://github.com/snort3/libdaq.git; then 
        echo -e "${RED}[✘] Error : couldn't get libdaq${NC}"
        return 0
    fi

    cd libdaq
    ./bootstrap
    ./configure --prefix=/usr/local/lib/daq_s3
    make install 
    sudo ldconfig

    echo -e "${GREEN}[✔] Libdaq installed !${NC}" 
    return 1
}

# args :
# $1 (optional) = path_install_snort
# If you don't indicates manually the path, the default one will be used.
install_snort3() {
    cd /home/cryptx
    if ! git clone -q https://github.com/snort3/snort3.git; then
        echo -e "${RED}[✘] Error : couldn't get snort3${NC}"
        exit 1
    fi

    mkdir -p "${snort3_repository_path}"
    cd snort3
    ./configure_cmake.sh --prefix="${snort3_repository_path}"

    cd build
    make -j $(nproc)
    make install

    "${snort3_repository_path}"/bin/snort -V
    "${snort3_repository_path}"/bin/snort --daq-list

    echo -e "${GREEN}[✔] Snort3 installed !${NC}" 
    return 1
}


verify_paths() {
    res=0
    if [ ! -d "$snort3_path" ]; then
        echo -e "${RED}[✘] Snort3 is missing. Update path or use install_snort3${NC}"
        res+=1
    fi

    if [ ! -d "$libdaq_path" ]; then
        echo -e "${RED}[✘] Libdaq is missing. Update path or use install_libdaq${NC}"
        res+=1
    fi
    return $res
}

install() {
    if install_depedencies == 0; then
        return 0
    elif install_libdaq == 0; then
        return 0
    elif install_snort3 == 0; then
        return 0
    fi
    return 1
}

remove() {
    if [ -d "${snort3_repository_path}" ]; then
        sudo rm -rf "${snort3_repository_path}"
        echo -e "${GREEN}[✔] Snort3 repository correcly removed !${NC}"
    fi

    if [ -d "${libdaq_repository_path}" ]; then
        sudo rm -rf "${libdaq_repository_path}"
        echo -e "${GREEN}[✔] Libdaq repository correcly removed !${NC}"
    fi

    if [ -d "${libdaq_lib_path}" ]; then
        sudo rm -rf "${libdaq_lib_path}"
        echo -e "${GREEN}[✔] Libdaq library correcly removed !${NC}"
    fi
}

main() {
    remove
    install
}


main
