#!/bin/bash

output() {
    echo -e '\e[36m'$1'\e[0m'
}

get_ports() {
    read -a ports

    if [[ -z $ports ]]; then
      output "You cannot put in an empty list of ports! Try again:"
      get_ports
    fi
}

output "TCPShield IPWhitelist Script"
output "Copyright © 2021 Thien Tran <contact@tommytran.io>."
output "Support: https://matrix.to/#/#tommytran732:matrix.org"
output ""
output "Adapted to support modern bash safety features by gh/Elsie19"
output ""

output "Enter the list of ports you want opened, separated by a space."
output "For example, if you want to open port 25565-25570, type: "
output "25565 25566 25567 25568 25569 25570"

get_ports

if [[ -r /etc/os-release ]]; then
    lsb_dist="$(. /etc/os-release && echo "$ID")"
fi

if [[ -r /etc/os-release ]]; then
   lsb_dist="$(. /etc/os-release && echo "$ID")"
   dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
else
   output "Unsupported Distribution! Only RHEL, CentOS, Fedora, Ubuntu, and Debian are supported!" 
   exit 1
fi

if [[ "$lsb_dist" == "rhel" ]]; then
   output "OS: Red Hat Enterprise Linux $dist_version detected."
else
   output "OS: $lsb_dist $dist_version detected."
fi

if [[ "$lsb_dist" ==  "ubuntu" ]] || [[ "$lsb_dist" == "debian" ]]; then
     apt -y install ufw wget
     # Opening Port 22 just in case so that we do not lose the internet connection when the rules are applied.
     ufw allow 22
     wget https://tcpshield.com/v4
     
     for ips in $(cat v4); do
        for port in "${ports[@]}"; do
          ufw allow from $ips to any proto tcp port $port comment 'TCPShield'
        done
     done    
     yes | ufw enable
elif [[ "$lsb_dist" == "fedora" ]] || [[ "$lsb_dist" == "rhel" ]] || [[ "$lsb_dist" == "centos" ]] || [[ "$lsb_dist" == "opensuse" ]]; then
     if [[ "$lsb_dist" == "fedora" ]] || [[ "$lsb_dist" == "rhel" ]] || [[ "$lsb_dist" == "centos" ]]; then
        yum -y install firewalld wget
     elif [[ "$lsb_dist" == "opensuse" ]]; then
        zypper in firewalld wget -y
     fi
     wget https://tcpshield.com/v4
     for ips in $(cat v4); do
        for port in "${ports[@]}"; do
          firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address='"$ips"' port port='"$port"' protocol="tcp" accept'
        done
     done
     firewall-cmd --reload
else 
     output "Unsupported distribution. This script only supports Fedora, RHEL, CentOS, Ubuntu, and Debian."
     exit 1
fi 

rm v4

output "Configuration finished!"
