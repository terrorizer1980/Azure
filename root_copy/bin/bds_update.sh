#!/bin/bash
set -x
cd /opt/bds_core_vm 
git pull
cp -rfv root_copy/* /
chmod a+x $(command -v prepare.sh)
chmod a+x $(command -v bds_update.sh)
chmod 600 /etc/cron.d/bdscore
systemctl daemon-reload