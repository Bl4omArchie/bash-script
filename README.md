# Linux tools

This bash script allow you to install and update all your packages, extension and more in a single command.

How to run the script: 
```
chmod +x linux_tools.sh
./linux_tools apt -i
```

Currently, my script support the followingg package manager: **sudo, pacman, dnf and yum**.
Since python3.12 requires virtuel env, the install_packages function will install python packages sucessfully only for python 3.11<=


# Install snort
Automatic installation of snort with apt package manager.
This script will install hyperscan plugin and pulledpork3.
