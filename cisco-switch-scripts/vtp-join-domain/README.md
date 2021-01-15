# Virtual Trunking Protocol Script

Networking best practices demonstrate that a solid infrastructure should have core switches (Master) and access switches (slaves).
To avoid having to configure every single switch manually, one can enable vtp on its master switches by creating a vtp domain and allowing access switch to join the domain.
The main benefit is that any new vlan rules defined on the master switches, will automatically be passed on to the slaves. This means that the configuration doesn't have to repeated on all x amount of switches.

This script allows access switches (slaves) to join an existing vtp domain.

**Note:** Before using this script, a vtp domain on a core switch has to be available.

**info:** If you would like to remove switches from an exisiting or previously defined vtp domain, you may use the vtp transparent script ./vtpTransparent.sh

**Important:** VTP's may cause failures and loop if not implemented correctly.

