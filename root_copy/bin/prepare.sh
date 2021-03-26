#!/bin/bash
#
#
if ! command -v docker &> /dev/null ;then curl https://get.docker.com|bash -;fi
if ! command -v node &> /dev/null   ;then curl -fsSL https://deb.nodesource.com/setup_current.x | bash -;apt install -y nodejs;fi
if ! command -v jq &> /dev/null     ;then apt install -y jq;fi
if ! [ -e "/etc/bds_docker_version" ];then echo "nightly" > /etc/bds_docker_version ;fi
if ! lsblk |grep -q "docker_data";then
    set -ex
    disk=`ls -tr /dev/sd*|grep -v -e [0-9]|grep -v "$(ls -tr /dev/sd*[1-9]|sed -e "s|[0-9]||g"|uniq)"| head -1`
    (echo g; echo n; echo 1; echo ""; echo ""; echo w) | fdisk ${disk}
    mkfs.ext4 -L docker_data ${disk}1
    disk_uuid="$(blkid ${disk}1|awk '{print $3}'|sed 's|"||g'|sed 's|UUID=||g')"
    mkdir -p /docker_data/
    echo "UUID=${disk_uuid}  /docker_data/       ext4    defaults,discard        0 $(($(cat /etc/fstab |tail -1|awk '{print $6}') + 1))" >> /etc/fstab
    cat /etc/fstab|tail -1
    mount -a
fi
docker_image="bdsmaneger/maneger:$(cat /etc/bds_docker_version)"
start_image(){
    docker run --rm -d --name bdsCore -v /docker_data/:/home/bds \
    -p 19132:19132/udp \
    -p 19133:19133/udp \
    -p 1932:1932/tcp \
    -p 6658:6658/tcp \
    -e TELEGRAM_TOKEN="$(cat /docker_data/AzureConfig.json|jq -r '.telegram')" \
    -e WORLD_NAME="$(cat /docker_data/AzureConfig.json|jq -r '.world')" \
    -e DESCRIPTION="$(cat /docker_data/AzureConfig.json|jq -r '.description')" \
    -e GAMEMODE="$(cat /docker_data/AzureConfig.json|jq -r '.gamemode')" \
    -e DIFFICULTY="$(cat /docker_data/AzureConfig.json|jq -r '.difficulty')" \
    -e PLAYERS="$(cat /docker_data/AzureConfig.json|jq -r '.players')" \
    -e SERVER="$(cat /docker_data/AzureConfig.json|jq -r '.platform')" \
    -e BDS_REINSTALL="true" \
    -e BDS_VERSION="$(cat /docker_data/AzureConfig.json|jq -r '.version')" \
    ${docker_image}
}
if [ -e "/docker_data/AzureConfig.json" ];then
    set -e
    while true
    do
        # -------------------
        if ! docker pull ${docker_image} | grep -q 'up to date';then
            docker stop bdsCore
            start_image
        fi
        # -------------------
        if [ "$(docker ps -q -f name=bdsCore)" == "" ];then start_image; else sleep 2m;fi
        # -------------------
    done
else
    (cd /save_config && npm i --no-save && node index.js)
    exit 1
fi
