FROM ubuntu:latest
RUN apt update && apt install -y wget curl; curl -fsSL https://deb.nodesource.com/setup_current.x | bash -; apt install -y nodejs ; curl https://get.docker.com|bash -
COPY root_copy/ /
RUN cd save_config/ && npm i --no-save -f && echo "nightly" > /etc/bds_docker_version
RUN chmod a+x /bin/prepare,sh ;systemctl enable bdscore