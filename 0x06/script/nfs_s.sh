#!/bin/bash

#sudo apt-get update || echo "apt update failed!"

# 安装nfs服务
sudo apt install -y nfs-kernel-server || echo "install nfs-kernel server failed"

client_ip="192.168.56.101"
srv_pr="/var/nfs/gen_r"
srv_prw="/var/nfs/gen_rw"
srv_no_rsquash="/home/no_rsquash"
srv_rsquash="/home/rsquash"

sudo mkdir -p "$srv_pr" "$srv_prw" "$srv_no_rsquash" "$srv_rsquash"

sudo chown nobody:nogroup "$srv_pr"
sudo chown nobody:nogroup "$srv_prw"

cl_prw_op="rw,sync,no_subtree_check"
cl_pr_op="ro,sync,no_subtree_check"
cl_prw_nors="rw,sync,no_subtree_check,no_root_squash"
cl_prw_rs="rw,sync,no_subtree_check"

conf="/etc/exports"

{echo "${srv_pr} ${client_ip}($cl_pr_op)"
echo "${srv_prw} ${client_ip}($cl_prw_op)"
echo "${srv_no_rsquash} ${client_ip}($cl_prw_nors)"
echo "${srv_rsquash} ${client_ip}($cl_prw_rs)" 
}>> "$conf"

sudo systemctl restart nfs-kernel-server

