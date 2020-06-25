#!/bin/bash
sudo apt-get update || echo "apt update failed!"

## 判断目标主机是否已安装resolvconf ##
sta=$(command -v resolvconf > /dev/null)   # 重定向输出到黑洞文件，可以不显示输>出仅判断操作是否正常
if [[ "$sta" -ne 0 ]];then
                # 安装resolvconf
                sta=$(sudo apt install resolvconf -y)
                if [[ "$sta" -ne 0 ]];then
                                echo "failed to install resolvconf!"
                                exit
                fi
else
                echo "resolvconf is already installed!"
fi

resolv_path="/etc/resolvconf/resolv.conf.d/head"
if [[ ! -f "${resolv_path}.bak" ]];then
                sudo cp "$resolv_path" "$resolv_path".bak  # 没有已存在的备份，创建备
份
else
                echo "${resolv_path}.bak already exits!"
fi

sudo cat>>${resolv_path}<<EOF
search cuc.edu.cn
nameserver 192.168.56.102
EOF

resolvconf -u
