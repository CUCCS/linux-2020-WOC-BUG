#!/bin/bash


apt-get update || echo "apt update failed!"

## 安装nfs客户端
apt install nfs-common || echo "install nfs-common failed!"

srv_ip="192.168.56.102"

mkdir -p "/nfs/gen_rw" "/nfs/gen_r" "/nfs/no_rsquash" "/nfs/rsquash"

mount "$srv_ip":"/var/nfs/gen_rw" "/nfs/gen_rw"
mount "$srv_ip":"/var/nfs/gen_r" "/nfs/gen_r"
mount "$srv_ip":"/home/no_rsquash" "/nfs/no_rsquash"
mount "$srv_ip":"/home/rsquash" "/nfs/rsquash"