#!/bin/bash


err_usage="[!] Usage: ./linux_tools.sh [apt|pacman|dnf|yum] [-i|-u]"
err_package="[!] Unsupported package manager."

packages=(
    "curl"
    "git"
    "jupyter"
    "libssl-dev"
)

codium_extensions=(
    "CryptoHack.cryptohack-theme"
    "ms-python.python"
    "ms-python.vscode-pylance"
    "unthrottled.doki-theme"
    "ms-toolsai.jupyter"
    "ms-toolsai.jupyter-keymap"
    "ms-toolsai.jupyter-renderers"
    "ms-toolsai.vscode-jupyter-cell-tags"
    "ms-toolsai.vscode-jupyter-slideshow"
)

python_modules=(
    "pycryptodome"
    "numpy"
    "matplotlib"
    "jupyter"
    "numba"
)

select_package_manager() {
    if [ "$#" -ne 2 ]; then

        if [ "$1" == "apt" ] || command -v apt &> /dev/null; then
            package_manager="apt"
        elif [ "$1" == "pacman" ] || command -v pacman &> /dev/null; then
            package_manager="pacman"
        elif [ "$1" == "dnf" ] || command -v dnf &> /dev/null; then
            package_manager="dnf"
        elif [ "$1" == "yum" ] || command -v yum &> /dev/null; then
            package_manager="yum"

        else
            echo $err_package
            exit 1
        fi

    else
        echo $err_usage
        exit 1
    fi
}

install_packages() {
    # Packages installation
    for package in "${packages[@]}"; do
        if ! dpkg -s $package &> /dev/null; then
            sudo $package_manager -qq -y install $package
        fi
    done

    # Codium extensions
    for extension in "${codium_extensions[@]}"; do
        codium --install-extension $extension
    done

    # Python modules: install new package or upgrade them
    pip3 install --upgrade -q "${python_modules[@]}"

    echo ">_ Installation done !"
    # Make an update
    update_packages
}

update_packages() {
    case $package_manager in
        "apt"|"dnf"|"yum")
            sudo $package_manager autoremove -y
            sudo $package_manager update
            sudo $package_manager upgrade -y
            ;;
        "pacman")
            paccache -r
            sudo pacman -Syu --noconfirm
            ;;
        *)
            echo $err_usage
            exit 1
            ;;
    esac
    echo ">_ Update done !"
}


#Two parameters
main() {
    package_manager=""
    select_package_manager $1

    case $2 in
        "-i")
            install_packages
            ;;
    
        "-u")
            update_packages
            ;;
        
        *)
            echo $err_usage
            exit 1
            ;;
    esac
}

main $1 $2