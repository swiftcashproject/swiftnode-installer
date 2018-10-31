#!/bin/bash
# install.sh
# Installs swiftnode on Ubuntu 16.04 LTS x64
# ATTENTION: The anti-ddos part will disable http, https and dns ports.

if [ "$(whoami)" != "root" ]; then
  echo "Script must be run as user: root"
  exit -1
fi

while true; do
 if [ -d ~/.swiftcash ]; then
   printf "~/.swiftcash/ already exists! The installer will delete this folder. Continue anyway?(Y/n)"
   read REPLY
   if [ ${REPLY} == "Y" ]; then
      pID=$(ps -ef | grep swiftcashd | awk '{print $2}')
      kill ${pID}
      rm -rf ~/.swiftcash/
      break
   else
      if [ ${REPLY} == "n" ]; then
        exit
      fi
   fi
 else
   break
 fi
done

# Warning that the script will reboot the server
# echo "WARNING: This script will reboot the server when it's finished."
# printf "Press Ctrl+C to cancel or Enter to continue: "
# read IGNORE

cd
# Changing the SSH Port to a custom number is a good security measure against DDOS attacks
printf "Custom SSH Port(Enter to ignore): "
read VARIABLE
_sshPortNumber=${VARIABLE:-22}

# Get a new privatekey by going to console >> debug and typing swiftnode genkey
printf "SwiftNode GenKey: "
read _nodePrivateKey

# The RPC node will only accept connections from your localhost
_rpcUserName=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12 ; echo '')

# Choose a random and secure password for the RPC
_rpcPassword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32 ; echo '')

# Get the IP address of your vps which will be hosting the swiftnode
_nodeIpAddress=$(curl -s 4.icanhazip.com)
if [[ ${_nodeIpAddress} =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  external_ip_line="swiftnodeaddr=${_nodeIpAddress}:8544"
else
  external_ip_line="#swiftnodeaddr=external_IP_goes_here:8544"
fi

# Make a new directory for swiftcash daemon
mkdir ~/.swiftcash/
touch ~/.swiftcash/swiftcash.conf

# Change the directory to ~/.swiftcash
cd ~/.swiftcash/

# Create the initial swiftcash.conf file
echo "rpcuser=${_rpcUserName}
rpcpassword=${_rpcPassword}
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
txindex=1
maxconnections=64
swiftnode=1
$external_ip_line
swiftnodeprivkey=${_nodePrivateKey}
" > swiftcash.conf
cd

# Install swiftcashd using apt-get
apt-get update -y
apt-get install software-properties-common -y
add-apt-repository ppa:swiftcash/ppa -y && apt update -y && apt install swiftcashd -y && swiftcashd

# Create a directory for swiftnode's cronjobs and the anti-ddos script
rm -r swiftnode
mkdir swiftnode

# Change the directory to ~/swiftnode/
cd ~/swiftnode/

# Download the appropriate scripts
wget https://raw.githubusercontent.com/swiftcashproject/swiftnode-installer/master/makerun.sh
wget https://raw.githubusercontent.com/swiftcashproject/swiftnode-installer/master/checkdaemon.sh
wget https://raw.githubusercontent.com/swiftcashproject/swiftnode-installer/master/upgrade.sh
wget https://raw.githubusercontent.com/swiftcashproject/swiftnode-installer/master/clearlog.sh

#install cpulimit
apt install cpulimit -y

# Create a cronjob for making sure swiftcashd runs after reboot
if ! crontab -l | grep "@reboot swiftcashd"; then
  (crontab -l ; echo "@reboot swiftcashd") | crontab -
fi

# Create a cronjob for making sure cpulimit runs after reboot
if ! crontab -l | grep "@reboot cpulimit"; then
  (crontab -l ; echo "@reboot cpulimit -P /usr/bin/swiftcashd -l 50") | crontab -
fi

# Create a cronjob for making sure swiftcashd is always running
if ! crontab -l | grep "~/swiftnode/makerun.sh"; then
  (crontab -l ; echo "*/5 * * * * ~/swiftnode/makerun.sh") | crontab -
fi

# Create a cronjob for making sure the daemon is never stuck
if ! crontab -l | grep "~/swiftnode/checkdaemon.sh"; then
  (crontab -l ; echo "*/30 * * * * ~/swiftnode/checkdaemon.sh") | crontab -
fi

# Create a cronjob for making sure swiftcashd is always up-to-date
# if ! crontab -l | grep "~/swiftnode/upgrade.sh"; then
#  (crontab -l ; echo "0 0 */1 * * ~/swiftnode/upgrade.sh") | crontab -
# fi

# Create a cronjob for clearing the log file
if ! crontab -l | grep "~/swiftnode/clearlog.sh"; then
  (crontab -l ; echo "0 0 */2 * * ~/swiftnode/clearlog.sh") | crontab -
fi

# Give execute permission to the cron scripts
chmod 0700 ./makerun.sh
chmod 0700 ./checkdaemon.sh
chmod 0700 ./upgrade.sh
chmod 0700 ./clearlog.sh

# Change the SSH port
sed -i "s/[#]\{0,1\}[ ]\{0,1\}Port [0-9]\{2,\}/Port ${_sshPortNumber}/g" /etc/ssh/sshd_config

# Firewall security measures
apt install ufw -y
ufw disable
ufw allow 8544
ufw allow "$_sshPortNumber"/tcp
ufw limit "$_sshPortNumber"/tcp
ufw logging on
ufw default deny incoming
ufw default allow outgoing
ufw --force enable

# Run cpulimit to keep the cpu usage below 50%
cpulimit -P /usr/bin/swiftcashd -l 50 &

# Reload the SSH config to activivate the custom port if selected
systemctl reload sshd
