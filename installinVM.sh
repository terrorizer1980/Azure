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
    systemctl enable bdscore
} && reboot