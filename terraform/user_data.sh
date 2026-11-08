#!/bin/bash
set -euo pipefail

# 2 GB de swap: a t3.micro tem só 1 GB de RAM para Postgres + API + Nginx
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

apt-get update -y
apt-get install -y docker.io docker-compose-v2
systemctl enable --now docker

# Permite usar o docker sem sudo
usermod -aG docker ubuntu
