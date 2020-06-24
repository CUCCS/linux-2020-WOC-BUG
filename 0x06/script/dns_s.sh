#!/bin/bash

apt-get update || echo "apt update failed!"

## 判断目标主机是否已安装bind9 ##
sta=$(command -v bind9 > /dev/null)   # 重定向输出到黑洞文件，可以不显示输出仅判断操作是否正常
if [[ "$sta" -ne 0 ]];then
                # 安装vsftpd
                sta=$(apt install bind9 -y)
                if [[ "$sta" -ne 0 ]];then
                                echo "failed to install bind9!"
                                exit
                fi
else
                echo "bind9 is already installed!"
fi

options_path="/etc/bind/named.conf.options"

if [[ ! -f "${options_path}.bak" ]];then
                cp "$options_path" "$options_path".bak  # 没有已存在的备份，创建备份
else
                echo "${options_path}.bak already exits!"
fi

sed -i '16a recursion yes;\nallow-recursion { trusted; };\nlisten-on { 192.168.56.102; };\nallow-transfer { none; };\nforwarders {\n\t8.8.8.8;\n\t8.8.4.4;\n};\n' ${options_path}

cat>>${options_path}<<EOF
acl "trusted" {
        192.168.56.101;
};
EOF

local_path="/etc/bind/named.conf.local"

if [[ ! -f "${local_path}.bak" ]];then
                cp "$local_path" "$local_path".bak  # 没有已存在的备份，创建备份
else
                echo "${local_path}.bak already exits!"
fi

cat>>${local_path}<<EOF
zone "cuc.edu.cn" {
    type master;
    file "/etc/bind/db.cuc.edu.cn";
};
EOF

cuc_path="/etc/bind/db.cuc.edu.cn"
touch ${cuc_path}

cat>>${cuc_path}<<EOF
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     cuc.edu.cn. root.cuc.edu.cn. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;

        IN      NS      ns.cuc.edu.cn.
ns      IN      A       192.168.56.102
wp.sec.cuc.edu.cn.      IN      A       192.168.56.102
dvwa.sec.cuc.deu.cn.    IN      CNAME   wp.sec.cuc.edu.cn.
EOF

if pgrep -x "bind9" > /dev/null
then
                systemctl restart bind9
else
                systemctl start bind9
fi
