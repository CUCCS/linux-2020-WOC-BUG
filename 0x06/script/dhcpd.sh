#!/bin/bash
# sudo apt-get update || echo "apt update failed!"

## 判断目标主机是否已安装isc-dhcp-server ##
sta=$(command -v isc-dhcp-server > /dev/null)   # 重定向输出到黑洞文件，可以不显示输出仅判断操作是否正常
if [[ "$sta" -ne 0 ]];then
                # 安装isc-dhcp-server
                sta=$(sudo apt install isc-dhcp-server -y)
                if [[ "$sta" -ne 0 ]];then
                                echo "failed to install isc-dhcp-server!"
                                exit
                fi
else
                echo "isc-dhcp-server is already installed!"
fi

conf_path=/etc/dhcp/dhcpd.conf

if [[ ! -f "${conf_path}.bak" ]];then
                sudo cp "$conf_path" "$conf_path".bak  # 没有已存在的备份，创建备份
else
                echo "${conf_path}.bak already exits!"
fi

sudo cat>>${conf_path}<<EOF
subnet 192.168.57.0 netmask 255.255.255.0 {
        # client's ip address range
        range 192.168.57.150 192.168.57.200;
        default-lease-time 600;
        max-lease-time 7200;
}
EOF
server_path=/etc/default/isc-dhcp-server

if [[ ! -f "${server_path}.bak" ]];then
                sudo cp "$server_path" "$server_path".bak  # 没有已存在的备份，创建备份
else
                echo "${server_path}.bak already exits!"
fi

sudo cat>>${server_path}<<EOF
INTERFACESv4="enp0s9"
INTERFACESv6=""
EOF

if pgrep -x "isc-dhcp-server" > /dev/null
then
                sudo systemctl restart isc-dhcp-server
else
                sudo systemctl start isc-dhcp-server
fi

