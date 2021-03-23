FROM ubuntu:latest
RUN apt update && apt install -y wget curl; curl -fsSL https://deb.nodesource.com/setup_current.x | bash -; apt install -y nodejs ; curl https://get.docker.com|bash -
COPY etc/ /etc
COPY save_config/ /save_config
RUN cd save_config/ && npm i --no-save -f
COPY bin/ /bin/
RUN chmod a+x /bin/* ; systemctl enable bdscore