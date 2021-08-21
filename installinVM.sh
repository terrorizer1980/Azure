#!/bin/bash
#
apt update
export DEBIAN_FRONTEND="noninteractive"
apt install -y curl wget jq git
git clone https://github.com/The-Bds-Maneger/Azure.git /opt/bds_core_vm 
cp -rfv /opt/bds_core_vm/root_copy/* /  
chmod a+x $(command -v prepare.sh)
chmod 600 /etc/cron.d/bdscore
curl https://get.docker.com | bash -
curl -fsSL https://deb.nodesource.com/setup_current.x | bash -
apt install -y nodejs
[ -z "$worldname" ] && worldname="bds Maneger"
[ -z "$worlddescripition" ] && worlddescripition="NoDescription"
[ -z "$totalplayers" ] && totalplayers="13"
[ -z "$gamemode" ] && gamemode="survival"
[ -z "$difficulty" ] && difficulty="normal"
[ -z "$bdsplatfrom" ] && bdsplatfrom="bedrock"

# Create JSON Config file
(
    echo '{'
    echo '"world": "'${worldname}'",'
    echo '"description": "'${worlddescripition}'",'
    echo '"gamemode": "'${gamemode}'",'
    echo '"difficulty": "'${difficulty}'",'
    echo '"players": '${totalplayers}','
    echo '"platform": "'${bdsplatfrom}'",'
    echo '"dockertag": "'${docker_version}'"'
    echo '}'
) | jq -r > /etc/VMAzureConfig.json
systemctl enable bdscore
sleep 15s
reboot