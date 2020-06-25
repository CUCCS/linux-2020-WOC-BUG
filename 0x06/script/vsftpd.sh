#!/bin/bash

# sudo apt-get update || echo "apt update failed!"

## 判断目标主机是否已安装vsftpd ##
sta=$(command -v vsftpd > /dev/null)   # 重定向输出到黑洞文件，可以不显示输出仅判断操作是否正常
if [[ "$sta" -ne 0 ]];then
                # 安装vsftpd
                sta=$(sudo apt install vsftpd -y)
                if [[ "$sta" -ne 0 ]];then
                                echo "failed to install vsftpd!"
                                exit
                fi
else
                echo "vsftpd is already installed!"
fi

conf=/etc/vsftpd.conf

## 判断文件是否已有备份 ##
if [[ ! -f "${conf}.bak" ]];then
                sudo cp "$conf" "$conf".bak  # 没有已存在的备份，创建备份
else
                echo "${conf}.bak already exits!"
fi


## 匿名用户访问FTP设置 ##
# 创建匿名用户可访问的文件夹
anon_path="/var/ftp/pub"
if [[ ! -d "$anon_path" ]];     # 判断文件夹是否存在
then
                sudo mkdir -p "$anon_path"
fi

sudo chown nobody:nogroup "$anon_path"		# 设置pub文件夹所属用户和组
echo "vsftpd test file" | sudo tee "${anon_path}/test.txt"      # 将输出重定向到文件test.txt

## 修改vsftpd.conf ##
# 开启匿名使用
sudo sed -i -e "/anonymous_enable=/s/^[#]//g;/anonymous_enable=/s/NO/YES/g" "$conf"
# 不允许匿名用户上传
sudo sed -i -e "/anon_upload_enable=/s/^[#]//g;/anon_upload_enable=/s/YES/NO/g" "$conf"
# 禁止匿名用户的写权限
sudo sed -i -e "/anon_mkdir_write_enable=/s/^[#]//g;/anon_mkdir_write_enable=/s/YES/NO/g" "$conf"

## 在/etc/vsftpd.conf文件中搜索关键字，并替换文件中的内容 ##
# anon_root设为/var/ftp，设置无需密码登录
sudo grep -q "anon_root=" "$conf" && sudo sed -i -e "#anon_root=#s#^[#]##g;#anon_root=#s#\=.*#=/var/ftp#g" "$conf" || sudo echo "anon_root=/var/ftp" >> "$conf"
sudo grep -q "no_anon_password=" "$conf" && sudo sed -i -e "/no_anon_password=/s/^[#]//g;/no_anon_password=/s/\=.*/=YES/g" "$conf" || sudo echo "no_anon_password=YES" >> "$conf"

## 设置用户名和密码方式访问的账号 ##
user="wocbug"
# 如果passwd文件中没有user用户，则添加用户
if [[ $(grep -c "^$user:" /etc/passwd) -eq 0 ]];then
                sudo adduser $user
else
                echo "${user} is already exited!"
fi

## 创建用户目录 ##
u_path="/home/${user}/ftp"
if [[ ! -d "$u_path" ]];
then
                sudo mkdir "$u_path"
else
                echo "${u_path} is already exited!"
fi

sudo chown nobody:nogroup "$u_path"	# 设置所有权
sudo chmod a-w "$u_path"	# 删除写权限
ls -la "$u_path"	# 验证权限

## 为用户创建upload目录 ##
u_write_path="${u_path}/files"
if [[ ! -d "$u_write_path" ]];
then
                sudo mkdir "$u_write_path"
else
                echo "${u_write_path} is already exited!"
fi

sudo chown "$user":"$user" "$u_write_path"		# 设置所有权
ls -la "$u_path"	# 验证权限
echo "vsftpd test file" | tee "${u_write_path}/test.txt"

## 更改相关配置 ##
sudo sed -i -e "/local_enable=/s/^[#]//g;/local_enbale=/s/NO/YES/g" "$conf"
sudo sed -i -e "/write_enable=/s/^[#]//g;/^write_enable=/s/NO/YES/g" "$conf"
sudo sed -i -e "/chroot_local_user=/s/^[#]//g;/chroot_local_user=/s/NO/YES/g" "$conf"	# 限制用户使用权限只限于用户目录

## 设置目标主机用于FTP的范围 ##
port_min=40000
port_max=50000
sudo grep -q "pasv_min_port=" "$conf" && sudo sed -i -e "/pasv_min_port=/s/^[#]//g;/pasv_min_port=/s/\=.*/=${port_min}/g" "$conf" || sudo echo "pasv_min_port=${port_min}" >> "$conf"
sudo grep -q "pasv_max_port=" "$conf" && sudo sed -i -e "/pasv_max_port=/s/^[#]//g;/pasv_max_port=/s/\=.*/=${port_max}/g" "$conf" || sudo echo "pasv_max_port=${port_max}" >>  "$conf"


## 限制用户只有添加到userlist才能访问 ##
sudo grep -q "userlist_enable=" "$conf" && sudo sed -i -e "/userlist_enable=/s/^[#]//g;/userlist_enable=/s/\=.*/=YES/g" "$conf" || sudo echo "userlist_enable=YES" >> "$conf"
sudo grep -q "userlist_file=" "$conf" && sudo sed -i -e "#userlist_file=#s#^[#]##g;#userlist_file=#s#\=.*#=/etc/vsftpd.userlist#g" "$conf" || sudo echo "userlist_file=/etc/vsftpd.userlist" >> "$conf"
sudo grep -q "userlist_deny=" "$conf" && sudo sed -i -e "/userlist_deny=/s/^[#]//g;/userlist_deny=/s/\=.*/=NO/g" "$conf" || sudo echo "userlist_deny=NO" >> "$conf"

## 将用户添加到userlist ##
sudo grep -q "$user" /etc/vsftpd.userlist || sudo echo "$user" | sudo tee -a /etc/vsftpd.userlist
sudo grep -q "anonymous" /etc/vsftpd.userlist || sudo echo "anonymous" | sudo tee -a /etc/vsftpd.userlist

## 只允许白名单用户访问ftp ##
sudo grep -q "tcp_wrappers=" "$conf" && sudo sed -i -e "/tcp_wrappers=/s/^[#]//g;/tcp_wrappers=/s/NO/YES/g" "$conf" || sudo echo "tcp_wrappers=YES" >> "$conf"
sudo grep -q "vsftpd:ALL" /etc/hosts.deny || sudo echo "vsftpd:ALL" >> /etc/hosts.deny
sudo grep -q "vsftpd:192.168.56.101" /etc/hosts.allow || sudo echo "vsftpd:192.168.56.101" >> /etc/hosts.allow
sudo grep -q "allow_writeable_chroot=" "$conf" && sudo sed -i -e "/allow_writeable_chroot=/s/^[#]//g;/allow_writeable_chroot=/s/NO/YES/g" "$conf" || sudo echo "allow_writeable_chroot=YES" >> "$conf"

## 判断vsftpd进程状态 ##
if pgrep -x "vsftpd" > /dev/null
then
                sudo systemctl restart vsftpd
else
                sudo systemctl start vsftpd
fi
