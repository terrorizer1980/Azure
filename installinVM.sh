#!/bin/bash
set -x
# Install Maneger Depedencies
apt update
export DEBIAN_FRONTEND="noninteractive"
apt install -y curl wget jq git

# Clone and Copy Maneger Files
git clone https://github.com/The-Bds-Maneger/Azure.git /opt/bds_core_vm 
cp -rfv /opt/bds_core_vm/root_copy/* /  
chmod a+x $(command -v prepare.sh)
chmod 600 /etc/cron.d/bdscore

# Install Docker EE
curl https://get.docker.com | bash -

# Install Nodejs
curl -fsSL https://deb.nodesource.com/setup_current.x | bash -
apt install -y nodejs

# Validate the variables
# docker_version
# worldname
# worlddescripition
# totalplayers
# gamemode
# difficulty
# bdsplatfrom

[ -z "$worldname" ] && worldname="bds Maneger"
[ -z "$worlddescripition" ] && worlddescripition="NoDescription"
[ -z "$totalplayers" ] && totalplayers="13"
[ -z "$gamemode" ] && gamemode="survival"
[ -z "$difficulty" ] && difficulty="normal"
[ -z "$bdsplatfrom" ] && bdsplatfrom="bedrock"
[ -z "$docker_version" ] && docker_version="latest"

# Create JSON Config file
echo '{"world": "'${worldname}'","description": "'${worlddescripition}'", "gamemode": "'${gamemode}'", "difficulty": "'${difficulty}'", "players": '${totalplayers}', "platform": "'${bdsplatfrom}'", "dockertag": "'${docker_version}'"''}' | tee "/etc/VMAzureConfig.txt"
cat "/etc/VMAzureConfig.txt" | jq '.' | tee /etc/VMAzureConfig.json

# Restart systemctl
systemctl enable bdscore

# Reboot VM
sleep 15s
reboot