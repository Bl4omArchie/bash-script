#!/bin/bash

package_manager=""
err_usage="[!] Usage: $0 [apt|pacman|dnf|yum]"
err_package="[!] Unsupported package manager."

packages=(
    "curl"
    "git"
    "sagemath"
    "jupyter"
    "libssl-dev"
)

codium_extensions=(
    "CryptoHack.cryptohack-theme"
    "HackMD.vscode-hackmd"
    "ms-python.python"
    "ms-python.vscode-pylance"
    "unthrottled.doki-theme"
    "background"
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
    if [ "$#" -eq 1 ]; then

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
            sudo $package_manager install -y $package
        fi
    done

    # Codium extensions
    for extension in "${codium_extensions[@]}"; do
        codium --install-extension $extension
    done

    # Python modules
    pip3 install --upgrade "${python_modules[@]}"

    # Make an update
    update_packages
}

update_packages() {
    case package_manager in
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
}

# first argument is your package manager
select_package_manager $1
install_packages
echo ">_ Installation complet !"