#!/bin/bash



# ---
# Snort3 installer using apt package manager
# 
# Manage : installation, update and removal
# Add-on : hyperscan for fast pattern matching
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


set_variables() {
    snort_install="${HOME}/snort_repo"
    snort_default_path="/usr/local/snort"
    daq_default_path="/usr/local/lib/daq_s3"
    pulledpork_bin="/usr/local/bin/pulledpork/"
    pulledpork_etc="/usr/local/etc/pulledpork/"
}

<<<<<<< Updated upstream
install_dependencies() {
    for i in "$@"; do
=======
install_depedencies() {
    for i in "$1"
    do
>>>>>>> Stashed changes
        if ! dpkg -s "${i}" >/dev/null 2>&1; then
            sudo apt install "${i}" -y -qq
        fi
    done
    echo -e "${GREEN}[✔] Dependencies installed!${NC}"
    return 0
}

<<<<<<< Updated upstream

install_libdaq() {
    if ! git clone -q https://github.com/snort3/libdaq.git; then 
=======
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
>>>>>>> Stashed changes
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
    sudo ldconfig
    echo -e "${GREEN}[✔] Libdaq installed !${NC}" 
}

install_snort() {
    if ! git clone -q https://github.com/snort3/snort3.git; then 
        echo -e "${RED}[✘] Error : couldn't get snort3 repository${NC}"
        return 0
    fi
    cd snort3
    ./configure_cmake.sh --prefix=${snort_default_path} --with-daq-includes=${daq_default_path}/include/ --with-daq-libraries=${daq_default_path}/lib/
    cd build
    make -j $(( $(nproc) / 2 )) -s
    sudo make install -s
    
    echo 'export PATH=$PATH:/usr/local/snort/bin' >> ${HOME}/.bashrc
    source ${HOME}/.bashrc
    echo -e "${GREEN}[✔] Snort3 installed !${NC}" 
}

set_up_snort() {
    sudo mkdir /etc/snort
    sudo mkdir /var/log/snort
    sudo mkdir /usr/local/lib/snort_dynamicrules
    sudo mkdir /etc/snort/rules
    sudo touch /etc/snort/white_list.rules  
    sudo touch /etc/snort/black_list.rules
}

install_pulledpork3() {
    if ! git clone -q https://github.com/shirkdog/pulledpork3.git; then 
        echo -e "${RED}[✘] Error : couldn't get pulledpork repository${NC}"
        return 0
    fi
    cd pulledpork3/

    sudo mkdir ${pulledpork_etc}
    sudo cp etc/pulledpork.conf ${pulledpork_etc}

    sudo mkdir ${pulledpork_bin}
    sudo cp pulledpork.py ${pulledpork_bin}
    sudo cp -r lib/ ${pulledpork_bin}

    ./pulledpork.py -V
}

remove() {
    sudo rm -rf ${snort_default_path}
    sudo rm -rf ${daq_default_path}
    sudo rm -rf ${snort_install}
    sudo rm -rf ${pulledpork_bin}
    sudo rm -rf ${pulledpork_etc}
    echo -e "Snort, libdaq and PulledPork have been removed"
}

start_install() {
    set_variables

    install_dependencies "${snort_required_packages[@]}"

    mkdir ${snort_install} && cd ${snort_install}
    install_libdaq

    cd ${snort_install}
    install_snort
    set_up_snort()

    cd ${snort_install}
    install_pulledpork3
    snort -V
}


<<<<<<< Updated upstream
remove
start_install

=======
remove_snort
install_snort
>>>>>>> Stashed changes
