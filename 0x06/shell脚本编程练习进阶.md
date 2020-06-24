# shell脚本编程练习进阶

## 实验环境

Ubuntu 18.04 Server 64bit

工作主机host only：192.168.56.101

目标主机host only：192.168.56.102

## 实验步骤

### 零、配置免密登录

``ssh-keygen -t rsa``

``ssh-copy-id -i ~/.ssh/id_rsa.pub wocbugnolvm@192.168.56.102``

<img src="./img/keygen.png"  align='left'/>



---

### 一、FTP

ftp服务器软件选用vsftpd

远程登录到目的主机，拷贝并运行vsftpd.sh文件，进行vsftpd的安装和配置。

[vstpd.sh](./script/vsftpd.sh)

[vstpd.conf](./config/vsftpd.conf)

<img src="./img/bash_vsftpd.png" />



我这里由于多次调试，所以显示文件已存在。

退回到工作主机进行匿名登录：



<img src="./img/anonymous.png" />



* **配置一个提供匿名访问的FTP服务器，匿名访问者可以访问1个目录且仅拥有该目录及其所有子目录的只读访问权限：**



<img src="./img/authority.png" />

<img src="./img/authority2.png" />



-  **配置一个支持用户名和密码方式访问的账号，该账号继承匿名访问者所有权限，且拥有对另1个独立目录及其子目录完整读写（包括创建目录、修改文件、删除文件等）权限：**
  
  - **该账号仅可用于FTP服务访问，不能用于系统shell登录：**
  
  wocbug账号登录：
  
  <img src="./img/wocbug.png"  />
  
  
  
  成功get和put文件：
  
  <img src="./img/get_and_put.png" />
  
  
  
  test.txt被成功get到工作主机上：
  
  <img src="./img/get_success.png" />
  
  
  
  hello.sh被成功put到目标主机上：
  
  <img src="./img/put_success.png" />
  
  
  
  删除文件和创建文件夹成功：
  
  <img src="./img/delete_mkdir.png" />



* **FTP用户不能越权访问指定目录之外的任意其他目录和文件：**

  <img src="./img/changedir.png" />

  

* **匿名访问权限仅限白名单IP来源用户访问，禁止白名单IP以外的访问：**

  <img src="./img/other_user.png" />

  

----

### 二、NFS

[nfs_c.sh](./script/nfs_c.sh)

[nfs_s.sh](./script/nfs_s.sh)

[exports](./config/exports)



在目标主机上运行nfs_s.sh：

<img src="./img/install.png" align="left"/>

<img src="./img/nfs_server.png" />

工作主机上运行nfs_c.sh：

<img src="./img/install2.png" />



* **在1台Linux上配置NFS服务，另1台电脑上配置NFS客户端挂载2个权限不同的共享目录，分别对应只读访问和读写访问权限**

  <img src="./img/touch.png" />

  

* **实验报告中请记录你在NFS客户端上看到的：**

  - **共享目录中文件、子目录的属主、权限信息**
  
    <img src="./img/info.png" />
  
    
  
  - **你通过NFS客户端在NFS共享目录中新建的目录、创建的文件的属主、权限信息**
  
    <img src="./img/info2.png" />
  
    
  
  - **上述共享目录中文件、子目录的属主、权限信息和在NFS服务器端上查看到的信息一样吗？无论是否一致，请给出你查到的资料是如何讲解NFS目录中的属主和属主组信息应该如何正确解读**
  
    看到的信息一样。
    
    [资料1](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-ubuntu-18-04),[资料2](https://blog.51cto.com/yttitan/2406403)
    
    <img src="./img/reference.png" />
    
    
    
    ---
    

### 三、DHCP

[dhcpd.sh](./script/dhcpd.sh)

[dhcpd.conf](./config/dhcpd.conf)

[isc-dhcp-server](./config/isc-dhcp-server)

* **2台虚拟机使用Internal网络模式连接，其中一台虚拟机上配置DHCP服务，另一台服务器作为DHCP客户端，从该DHCP服务器获取网络地址配置**

  * client

    配置第三块网卡为intnet网卡，更改``/etc/netplan/01-netcfg.yaml``文件

    ![](./img/netplan.png)

    用``netplan apply``使配置生效

    ![](./img/enp0s9.png)

    * server

      配置intnet网卡，设置静态ip配置

      ![](./img/netplan2.png)

      效果：

      ![](./img/serverip.png)

      安装``isc-dhcp-server``后

      更改/etc/dhcp/dhcpd.conf文件：

      ![](./img/dhcpd_conf.png)

      更改/etc/default/isc-dhcp-server文件：

      ![](./img/isc-dhcp-server.png)

      启动服务：``systemctl restart isc-dhcp-server``

      效果：

      ![](./img/status.png)

  

  ---
  
  

### 四、Samba

在192.168.56.102上安装samba并配置：

[samba.sh](./script/samba.sh)

[samba.conf](./config/samba.conf)

![](./img/demo.png)

* 配置windows10连接LInux上的Samba

  ![](./img/add_network_location.png)

  ![](./img/ip.png)

  ![](./img/name.png)

  访问指定用户需要输入用户名密码、可以新建文件夹，访问匿名用户无需密码、不可新建文件夹：

  ![](./img/new_file.png)

- **Linux访问Windows的匿名共享目录**

  ``apt-get install smbclient``

  关闭密码保护共享

  ![](./img/passwd_share.png)

  ![](./img/anonymous_visit.png)

- **Linux访问Windows的用户名密码方式共享目录**

  开启密码保护共享

  ![](./img/user_visit.png)

- 下载整个目录

  ![](./img/mget.png)

  ![](./img/download.png)

---

### 五、DNS

- **基于上述Internal网络模式连接的虚拟机实验环境，在DHCP服务器上配置DNS服务，使得另一台作为DNS客户端的主机可以通过该DNS服务器进行DNS查询**
- **在DNS服务器上添加 `zone "cuc.edu.cn"` 的以下解析记录**

```
ns.cuc.edu.cn NS
ns A <自行填写DNS服务器的IP地址>
wp.sec.cuc.edu.cn A <自行填写第5章实验中配置的WEB服务器的IP地址>
dvwa.sec.cuc.edu.cn CNAME wp.sec.cuc.edu.cn
```

[dns_s.sh](./script/dns_s.sh)

[dns_c.sh](./script/dns_c.sh)

[named.conf.options](./config/named.conf.options)

[named.conf.local](./config/named.conf.local)

[db.cuc.edu.cn](./config/db.cuc.edu.cn)

[head](./config/head)

#### server

- 安装Bind：``apt-get install bind9``

- 修改配置文件``options``

  ```
  # 16行后添加如下配置
  recursion yes;
  allow-recursion { trusted; };
  listen-on { 192.168.56.102; };
  allow-transfer { none; };
  forwarders {
      8.8.8.8;
      8.8.4.4;
  };
  
  # 文件末尾添加如下配置
  acl "trusted" {
          192.168.56.101;
  };
  ```
  

![](./img/options.png)

- 编辑配置文件``named.conf.local``

  ```
  # 添加如下配置
  zone "cuc.edu.cn" {
      type master;
      file "/etc/bind/db.cuc.edu.cn";
  };
  ```
  
  ![](./img/local.png)

- 生成配置文件``db.cuc.edu.cn``，并编辑

  ```
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
  ```

  ![](./img/db.cuc.edu.cn.png)

- 重启bind9：``service bind9 restart``


#### client

- 安装resolvconf并修改配置文件

  ```
  # 增加配置
  search cuc.edu.cn
  nameserver 192.168.56.102
  ```

- ``resolvconf -u``

#### 测试

![](./img/dig_wp.png)

![](./img/dig_dvwa.png)


## 参考文献

3. [鸟哥的Linux 私房菜-- vsFTPd 文件服务器](http://cn.linux.vbird.org/linux_server/0410vsftpd/0410vsftpd-centos4.php)
4. [关于Linux环境下安装配置vsftpd服务全攻略（踩坑）](https://blog.csdn.net/aiynmimi/article/details/77012507)
5. [NFS服务的用户身份映射](https://blog.51cto.com/yttitan/2406403)
6. [Install NFS Server and Client on Ubuntu 18.04 LTS](https://vitux.com/install-nfs-server-and-client-on-ubuntu/)
7. [How To Set Up an NFS Mount on Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-ubuntu-18-04)
8. [How to connect to Linux Samba shares from Windows 10](https://www.techrepublic.com/article/how-to-connect-to-linux-samba-shares-from-windows-10/)
9. [Setting up Samba as a Standalone Server](https://wiki.samba.org/index.php/Setting_up_Samba_as_a_Standalone_Server)
10. [下载整个目录](https://indradjy.wordpress.com/2010/04/14/getting-whole-folder-using-smbclient/)
11. [实验报告1](https://github.com/CUCCS/2015-linux-public-JuliBeacon/blob/exp6/%E5%AE%9E%E9%AA%8C%206/%E5%AE%9E%E9%AA%8C6.md)
12. [实验报告2](https://github.com/CUCCS/2015-linux-public-songyawen/blob/master/exp6/SHELL%E8%84%9A%E6%9C%AC%E7%BC%96%E7%A8%8B%E7%BB%83%E4%B9%A0%E8%BF%9B%E9%98%B6%EF%BC%88%E5%AE%9E%E9%AA%8C%EF%BC%89.md)
13. [实验报告3](https://github.com/CUCCS/linux-2019-luyj/blob/Linux_exp0x06/Linux_exp0x06/Linux_exp0x06.md)
