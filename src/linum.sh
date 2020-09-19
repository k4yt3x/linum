#!/bin/bash
# Name: Linum
# Author: K4YT3X
# Date Created: September 16, 2020
# Last Modified: September 18, 2020
#
# Licensed under the GNU General Public License Version 3 (GNU GPL v3),
#     available at: https://www.gnu.org/licenses/gpl-3.0.txt
# (C) 2020 K4YT3X
#
# Description: Linum is a Linux enumeration script.

VERSION='1.1.0'

# parse arguments and set flags
while test $# -gt 0; do
    case "$1" in
    -h)
        HELP=true
        ;;
    --help)
        HELP=true
        ;;
    -v)
        VERBOSE=true
        ;;
    --verbose)
        VERBOSE=true
        ;;
    --*)
        echo "unrecognized argument $1"
        exit 1
        ;;
    *)
        echo "unrecognized option $1"
        exit 1
        ;;
    esac
    shift
done

# print help message if -h, --help is specified
if [ "$HELP" == true ]; then
    echo -e "usage: $0"
    echo -e "    -h, --help\tshow this help message and exit"
    echo -e "    -v, --verbose\tinclude verbose information (extra iptables tables, full packages list)"
    exit 0
fi

# print banner
echo '  _       ___   _   _   _   _   __  __'
echo ' | |     |_ _| | \ | | | | | | |  \/  |'
echo ' | |      | |  |  \| | | | | | | |\/| |'
echo ' | |___   | |  | |\  | | |_| | | |  | |'
echo ' |_____| |___| |_| \_|  \___/  |_|  |_|'
echo ''
echo "        Linux Enumeration Script"
echo "                $VERSION"

# include more paths
export PATH=$PATH:/usr/sbin
export PATH=$PATH:$HOME/.local/bin

# standard foreground colors
BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"

# set format
BOLD="\033[1m"
DIM="\033[2m"
UNDERLINED="\033[4m"

# reset format
RESET="\033[0m"
RBOLD="\033[21m"
RDIM="\033[22m"
RUNDERLINED="\033[24m"

# print section header
print_section() {
    echo -e "\n$BOLD$BLUE"
    printf %${#1}s | tr " " "#"
    echo -e "##############\n#      $1      #"
    printf %${#1}s | tr " " "#"
    echo -e "##############$RESET"
}

# print subsection header
print_subsection() {
    echo -e "\n$BOLD$YELLOW"
    printf %${#1}s | tr " " "="
    echo -e "\n$1"
    printf %${#1}s | tr " " "="
    echo -e "$RESET"
}

################################
# host information
# OS version/release level, kernel version used
print_section "Basic Information"

print_subsection "uname"
echo "Kernel name: $(uname -s)"
echo "Node name (Hostname): $(uname -n)"
echo "Kernel release: $(uname -r)"
echo "Kernel version: $(uname -v)"
echo "Machine: $(uname -m)"
echo "Processor: $(uname -p)"
echo "Hardware platform: $(uname -i)"
echo "Operating system: $(uname -o)"

# stat cannot display file birth time on ext4
# therefore, %y (file last modified time) is used
if [ -d "/var/log/installer" ] && command -v ip &>/dev/null; then
    print_subsection "System Installation Time (/var/log/installer)"
    stat /var/log/installer -c %y
elif [ -f "/root/install.log" ]; then
    print_subsection "System Installation Time (/root/install.log)"
    stat /root/install.log -c %y
fi

# disk/partition size, usage, and mount points
print_subsection "File Systems Usages"
df -h

print_subsection "Block Devices and Partitions"
lsblk -pf

print_subsection "Mount Points"
mount

print_subsection "SELinux"
sestatus

print_subsection "Available Shells"
cat /etc/shells

################################
# networking
print_section "Networking"

# network devices (name)
# IP address, broadcast, and netmask for each active device
print_subsection "Interfaces"
if command -v ip &>/dev/null; then
    ip address
elif command -v ifconfig &>/dev/null; then
    ifconfig
fi

print_subsection "DNS Servers"
cat /etc/resolv.conf | egrep "^nameserver" | sed "s/^nameserver *//g"

print_subsection "Firewall Status"
if command -v iptables &>/dev/null; then
    echo -e "\n${BOLD}${GREEN}Filter Table${RESET}"
    iptables -nvL -t filter
    echo -e "\n${BOLD}${GREEN}NAT Table${RESET}"
    iptables -nvL -t nat

    if [ "$VERBOSE" == true ]; then
        echo -e "\n${BOLD}${GREEN}Mangle Table${RESET}"
        iptables -nvL -t mangle
        echo -e "\n${BOLD}${GREEN}Raw Table${RESET}"
        iptables -nvL -t raw
        echo -e "\n${BOLD}${GREEN}Security Table${RESET}"
        iptables -nvL -t security
    fi
elif command -v nft &>/dev/null; then
    echo "nftables"
    nft -a list ruleset
fi

print_subsection "Hosts"
cat /etc/hosts | egrep -v "^\ *#|^$"

print_subsection "ARP/Neighbour Table"
if command -v ip &>/dev/null; then
    ip neigh
else
    cat /proc/net/arp
fi

print_subsection "Listening Sockets"
if command -v ss &>/dev/null; then
    ss -anltup
elif command -v netstat &>/dev/null; then
    netstat -antup
fi

################################
# users and groups
print_section "Users and Groups"

echo "Current user: $(whoami)"
echo "Current groups: $(groups)"
echo "IDs: $(id)"

print_subsection "Logged-On Users"
who

print_subsection "Recent Logins"
last -n 20

print_subsection "passwd File"
cat /etc/passwd

print_subsection "shadow File"
cat /etc/shadow

print_subsection "Groups"
cat /etc/group

if [ -f "/var/log/auth.log" ]; then
    print_subsection "Recent Successful Logins"
    cat /var/log/auth.log | egrep sshd | egrep "Accepted" | tail -20

    if [ "$VERBOSE" == true ]; then
        print_subsection "Recent Failed Logins"
        cat /var/log/auth.log | egrep sshd | egrep "Failed" | tail -20
    fi
fi

if [ -f "/var/log/secure" ]; then
    print_subsection "Recent Successful Logins"
    cat /var/log/secure | egrep sshd | egrep "Accepted" | tail -20

    if [ "$VERBOSE" == true ]; then
        print_subsection "Recent Failed Logins"
        cat /var/log/secure | egrep sshd | egrep "Failed" | tail -20
    fi
fi

################################
# files
print_section "Interesting Files"

print_subsection "SUID Files"
find / -type f -perm -4000 -exec ls -lah {} + 2>/dev/null

if [ -f "/etc/sudoers" ]; then
    print_subsection "sudoers File"
    cat /etc/sudoers | egrep -v "^\ *#|^$"
fi

################################
# packages and modules
print_section "Package Management"

print_subsection "Statistics"

if command -v dpkg &>/dev/null; then
    echo "Number of packages installed (dpkg): $(dpkg --list | tail -n +6 | wc -l)"
fi

if command -v apt &>/dev/null; then
    echo "Number of packages available (apt): $(apt-cache search . | wc -l)"
fi

if command -v yum &>/dev/null; then
    echo "Number of packages installed (yum): $(yum list installed | tail -n +2 | wc -l)"
    echo "Number of packages available (yum): $(yum list all | tail -n +2 | wc -l)"
fi

if command -v dnf &>/dev/null; then
    echo "Number of packages installed (dnf): $(dnf list installed | tail -n +2 | wc -l)"
    echo "Number of packages available (dnf): $(dnf list available | tail -n +3 | wc -l)"
fi

# list of active repositories
if [ -d "/etc/apt" ]; then
    print_subsection "Active Repositories (apt)"
    cat /etc/apt/sources.list | egrep -v "^\ *#|^$"
    find /etc/apt/sources.list.d/ -iname "*.list" -exec cat {} + | egrep -v "^\ *#|^$"
fi

if command -v yum &>/dev/null; then
    print_subsection "Active Repositories (yum)"
    yum repolist
fi

if command -v dnf &>/dev/null; then
    print_subsection "Active Repositories (dnf)"
    dnf repolist
fi

# name of software packages installed
if [ "$VERBOSE" == true ]; then
    if command -v dpkg &>/dev/null; then
        print_subsection "Installed Packages (dpkg)"
        dpkg --list | tail -n +6 # | cut -d " " -f 3 | tr "\n" " "
    fi

    if command -v yum &>/dev/null; then
        print_subsection "Installed Packages (yum)"
        yum list installed | tail -n +2
    fi

    if command -v dnf &>/dev/null; then
        print_subsection "Installed Packages (dnf)"
        dnf list installed | tail -n +2
    fi
fi

print_subsection "Loaded Kernel Mods"
lsmod

print_subsection "Namespaces"
lsns

################################
# hardware
print_section "Hardware Information"

# CPU
print_subsection "CPU Information"
lscpu

# RAM
print_subsection "RAM Information"
free -h

# swap
print_subsection "SWAP Information"
swapon

# use lshw if it's available
# lshw currently manually disabled
if command -v lshw &>/dev/null && false; then
    lshw

# otherwise use individual commands
else
    print_subsection "PCI/PCIe Devices"
    lspci

    print_subsection "Memory"
    lsmem

    print_subsection "USB Devices"
    lsusb

    print_subsection "SCSI Devices"
    lsscsi

    if [ "$VERBOSE" == true ]; then
        print_subsection "SMBIOS/DMI"
        dmidecode
    fi
fi

if command -v nvidia-smi &>/dev/null; then
    nvidia-smi
fi

################################
# services
print_section "Services"

print_subsection "Running Services"
systemctl list-units --no-pager --type=service --state=running

# services installed but not running
if [ "$VERBOSE" == true ]; then
    print_subsection "Stopped Services"
    systemctl list-units --no-pager --type=service --state=inactive
    systemctl list-units --no-pager --type=service --state=failed
fi

################################
# configurations
print_section "Configurations"

print_subsection "sysctl Configurations"
sysctl_config=$(cat /etc/sysctl.conf | egrep -v "^\ *#|^$")
if [ -z "$sysctl_config" ]; then
    echo -e "(Empty)"
else
    echo "$sysctl_config"
fi

if [ -f "/etc/ssh/sshd_config" ]; then
    print_subsection "SSH Server"
    egrep -v "^\ *#|^$" /etc/ssh/sshd_config | egrep --color=always "^|^PermitRootLogin\ +yes|^PermitRootLogin\ +prohibit-password"
fi
