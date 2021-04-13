#!/bin/bash
#
{
    git clone https://github.com/The-Bds-Maneger/Azure_VMs.git /opt/bds_core_vm 
    cp -rfv /opt/bds_core_vm/root_copy/* /  
    chmod a+x $(command -v prepare.sh)
    chmod 600 /etc/cron.d/bdscore
    curl https://get.docker.com | bash -
    curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && apt install -y nodejs
    echo "${docker_version}" > /etc/bds_docker_version
    [ -z "$worldname" ] && worldname="bds Maneger"
    [ -z "$worlddescripition" ] && worlddescripition="NoDescription"
    [ -z "$totalplayers" ] && totalplayers="13"
    [ -z "$TelegramBOT" ] && TelegramBOT="null"
    [ -z "$gamemode" ] && gamemode="survival"
    [ -z "$difficulty" ] && difficulty="normal"
    [ -z "$bdsplatfrom" ] && bdsplatfrom="bedrock"
echo -e "{
    \"worldname\": \"${worldname}\",
    \"worlddescripition\": \"${worlddescripition}\",
    \"totalplayers\": \"${totalplayers}\",
    \"TelegramBOT\": \"${TelegramBOT}\",
    \"gamemode\": \"${gamemode}\",
    \"difficulty\": \"${difficulty}\",
    \"bdsplatfrom\": \"${bdsplatfrom}\"
}" > /etc/bdscoreConfig
    systemctl enable bdscore
} && reboot