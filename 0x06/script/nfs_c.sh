#!/bin/bash


sudo apt-get update || echo "apt update failed!"

## 安装nfs客户端
sudo apt install nfs-common || echo "install nfs-common failed!"

srv_ip="192.168.56.102"

sudo mkdir -p "/nfs/gen_rw" "/nfs/gen_r" "/nfs/no_rsquash" "/nfs/rsquash"

sudo mount "$srv_ip":"/var/nfs/gen_rw" "/nfs/gen_rw"
sudo mount "$srv_ip":"/var/nfs/gen_r" "/nfs/gen_r"
sudo mount "$srv_ip":"/home/no_rsquash" "/nfs/no_rsquash"
sudo mount "$srv_ip":"/home/rsquash" "/nfs/rsquash"