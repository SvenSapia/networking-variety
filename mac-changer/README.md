# MAC address changer script

This repository contains two scripts that will tweak your default network interface.

1. The **main.sh** script will do the following:
    - identify your default network interface (currently in use)
    - generate a new random mac address
    - temporarily shut your default network interface
    - apply newly generated mac address
    - up your default network interface

2. The **reset.sh** script will simply reset your mac address to its default vendor mac address. 
