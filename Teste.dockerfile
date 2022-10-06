FROM ubuntu:22.04

# Install git and curl
RUN apt update && apt install -y wget curl git sudo

# Copy Installer
COPY ./ ./
RUN cat installinVM.sh | sudo bash -