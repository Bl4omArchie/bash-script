#!/bin/bash


# --- SAFETY ---
set -euo pipefail


# --- COLORS ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BLANK='\033[0m'


# --- DEPENDENCIES ---
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
                        'zlib1g-dev')


hyperscan_required_packages=('ragel'            #hyperscan requirements
                            'build-essential'
                            'libboost-all-dev'
                            'libhyperscan-dev')


# --- DEFAULT PATH ---
DEFAULT_REPO_INSTALL_PATH="/opt/"
SNORT_DEFAULT_PATH="/usr/local/snort"
LIBDAQ_DEFAULT_PATH="/usr/local/lib/daq_s3"
PULLEDPORK_BIN="/usr/local/bin/pulledpork/"
PULLEDPORK_ETC="/usr/local/etc/pulledpork/"


check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}ERROR: This script must be run as root.${BLANK}"
        exit 1
    fi
}


install_snort() {
    install_path=${1:-}
    libdaq_path=${2:-}

    if [[ -n ${install_path} ]]; then
        mkdir -p $install_path
    else
        install_path=${SNORT_DEFAULT_PATH}
    fi

    if [[ -z ${libdaq_path} ]]; then
        libdaq_path=${LIBDAQ_DEFAULT_PATH}
    fi

    cd ${DEFAULT_REPO_INSTALL_PATH}

    if ! git clone https://github.com/snort3/snort3 >/dev/null 2>&1 ; then
        echo -e "${RED}ERROR: Couldn't install snort3 repository.${BLANK}"
        exit 1
    fi

    cd snort3
    ./configure_cmake.sh --prefix=${install_path} --with-daq-includes=${libdaq_path}/include/ --with-daq-libraries=${libdaq_path}/lib/
    cd build
    make -j $(( $(nproc) / 2 )) -s
    sudo make install -s
}


install_libdaq() {
    install_path=${1:-}

    if [[ -n ${install_path} ]]; then
        echo install_path > /etc/ld.so.conf.d/
    else
        install_path=${LIBDAQ_DEFAULT_PATH}
    fi

    cd ${DEFAULT_REPO_INSTALL_PATH}

    if ! git clone https://github.com/snort3/libdaq >/dev/null 2>&1; then
        echo -e "${RED}ERROR: Couldn't install libdaq repository.${BLANK}"
        exit 1
    fi

    cd libdaq
    ./bootstrap
    ./configure --prefix=install_path
    make -j $(( $(nproc) / 2 )) -s
    make install -s
    sudo ldconfig
}


install_pulledpork3() {
    cd ${DEFAULT_REPO_INSTALL_PATH}

    if ! git clone -q https://github.com/shirkdog/pulledpork3.git >/dev/null 2>&1; then 
        echo -e "${RED}[✘] Error : couldn't get pulledpork3 repository${NC}"
        return 0
    fi

    cd pulledpork3/
    sudo mkdir ${PULLEDPORK_ETC}
    sudo cp etc/pulledpork.conf ${PULLEDPORK_ETC}

    sudo mkdir ${PULLEDPORK_BIN}
    sudo cp pulledpork.py ${PULLEDPORK_BIN}
    sudo cp -r lib/ ${PULLEDPORK_BIN}

    ./pulledpork.py -V
}


install_dependencies() {
    echo ""
}


remove_snort() {
    echo ""
}


help() {
    echo -e "help"
}


main() {
    feature=${1:-}

    if [[ -z $feature ]]; then
        echo -e "${RED}ERROR: You must indicates one of the following feature : install snort | remove snort | help.${BLANK}"
        exit 1
    fi

    check_root

    case ${feature} in
        "install")
            install_dependencies
            install_libdaq
            install_snort
            ;;
    
        "remove")
            remove_snort
            ;;
        
        *)
            echo -e "${RED}ERROR: usage : ./install-snort3.sh install | remove | help${BLANK}"
            exit 1
            ;;
    esac
}

main "$@"
