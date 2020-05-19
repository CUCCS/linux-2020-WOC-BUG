[TOC]

# 实验环境

ubuntu 18.04.4

Host-Only IP：192.168.56.101

---

# 实验完成度

## Part 1 基本要求

* √ 安装Nginx
* √ 安装VeryNginx
* √ 安装配置Wordpress
* √ DVWA
* √ 启用https

## Part 2 安全加固要求
* √ 使用IP地址方式均无法访问上述任意站点，并向访客展示自定义的友好错误提示信息页面-1
* √ Damn Vulnerable Web Application (DVWA)只允许白名单上的访客来源IP，其他来源的IP访问均向访客展示自定义的友好错误提示信息页面-2
* √ 在不升级Wordpress版本的情况下，通过定制VeryNginx的访问控制策略规则，热修复WordPress < 4.7.1 - Username Enumeration
* √ 通过配置VeryNginx的Filter规则实现对Damn Vulnerable Web Application (DVWA)的SQL注入实验在低安全等级条件下进行防护

## Part 3 VeryNginx配置要求
* √ VeryNginx的Web管理页面仅允许白名单上的访客来源IP，其他来源的IP访问均向访客展示自定义的友好错误提示信息页面-3
* × 通过定制VeryNginx的访问控制策略规则实现：
  * 限制DVWA站点的单IP访问速率为每秒请求数 < 50
  *  限制Wordpress站点的单IP访问速率为每秒请求数 < 20
  *  超过访问频率限制的请求直接返回自定义错误提示信息页面-4
  * 禁止curl访问

---



# 实验步骤
（以下步骤均在root权限下操作）

<details>

**<summary>Part 0 初始操作</summary>**

配置本地host文件，路径在C:\Windows\System32\drivers\etc
![](./img/host.png)

</details>

<details>

**<summary>Part 1 基本要求</summary>**

## 一、基本要求

### 在一台主机（虚拟机）上同时配置[Nginx](http://nginx.org/)和[VeryNginx](https://github.com/alexazhou/VeryNginx)

- VeryNginx作为本次实验的Web App的反向代理服务器和WAF
- PHP-FPM进程的反向代理配置在nginx服务器上，VeryNginx服务器不直接配置Web站点服务

```bash
## 安装nginx
apt-get update
apt-get install nginx -y

## 安装verynginx
nginx -s stop
apt install -y libpcre3-dev libssl1.0-dev zlib1g-dev python3 unzip gcc make
wget https://github.com/alexazhou/VeryNginx/archive/master.zip
unzip master.zip		# 解压
cd VeryNginx-master/
sed -i "2s/nginx/www-data/" nginx.conf
python3 install.py install		# 安装
ln -s /opt/verynginx/openresty/nginx/sbin/nginx /usr/sbin/verynginx		# 创建软链接便于启动
verynginx -t	# 检查配置文件是否正确
verynginx		# 启动verynginx
```

安装成功

![](./img/enjoy.png)

![](./img/welcome.png)

![](./img/login.png)

![](./img/index2.png)

---

### 安装Wordpress

```bash
# WordPress需要用到数据库，所以我们要用mysql创建WordPress所需要的库
# 下载安装mysql和php7.2相关软件
apt install -y mysql-server php7.2-fpm php7.2-mysql php7.2-gd
# 安装完成后进入root用户
# mysql root 用户默认没有密码
mysql -u root -p
```

进入mysql后之后，创建WordPress使用的数据库
```sql
mysql> CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'wordpress';
mysql> CREATE DATABASE wordpress_db;
mysql> GRANT ALL ON wordpress_db.* TO 'wordpress'@'localhost';
```
![](./img/database.png)

```bash
# 指定WordPress目录
WP_PATH=/var/www/wordpress
# 创建该目录下的public文件夹
mkdir -p ${WP_PATH}/public/
# 修改该文件下的所有者为www-data
chown -R www-data:www-data ${WP_PATH}/public
# 下载并解压WorePress
wget https://wordpress.org/wordpress-4.7.zip
unzip wordpress-4.7.zip
# 将wordpress文件全部拷贝刚才的public中
cp -r wordpress/* ${WP_PATH}/public/
cd ${WP_PATH}/public/
# 拷贝配置文件
cp wp-config-sample.php wp-config.php
# 修改wp-config.php文件中的`database_name_here`,`username_here`和`password_here`字段为我们的数据库名称，用户名和密码。使wordpress能够访问mysql。

```
![](./img/copy.png)

```
sed -i s/database_name_here/wordpress_db/ wp-config.php
sed -i s/username_here/wordpress/ wp-config.php
sed -i s/password_here/wordpress/ wp-config.php
```
![](./img/set_name.png)

---

### 连接WordPress与Nginx

```bash
# 新建配置文件，设置端口8080和文件名wp.sec.cuc.edu.cn
WP_DOMAIN=wp.sec.cuc.edu.cn
WP_PORT=8080
tee /etc/nginx/sites-available/${WP_DOMAIN} << EOF
server {
    listen localhost:${WP_PORT};
    server_name ${WP_DOMAIN};

    root ${WP_PATH}/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.2-fpm.sock;
    }
}
EOF
# 在sites-enabled中创建sites-available的软链接，并删除default
ln -s /etc/nginx/sites-available/${WP_DOMAIN} /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default
# 启动nginx
nginx
```

---

### 配置VeryNginx访问wp.sec.cuc.edu.cn

添加Request Matcher

![](./img/add_rule1.png)

![](./img/add_rule2.png)

**添加Up Stream和Proxy Pass**：

![](./img/Up_Stream.png)

**页面加载成功**：

![](./img/WelcomePage.png)

初始化信息：

<img src="./img/SetInfo.png" style="zoom:67%;" />

基础网页：

![](./img/MyFirstSite.png)

![](./img/index.png)



---



### 安装Dvwa并配置VeryNginx

与WordPress步骤类似

```bash
# 指定目录，更改所有者
DVWA_PATH=/var/www/dvwa
mkdir -p ${DVWA_PATH}/public/
chown -R www-data:www-data ${DVWA_PATH}/public

# 下载解压
wget https://github.com/ethicalhack3r/DVWA/archive/master.zip
unzip master.zip
# 拷贝文件到/var/www/dvwa下
cp -r DVWA-master/* ${DVWA_PATH}/public/
cd ${DVWA_PATH}/public/
cp config/config.inc.php.dist config/config.inc.php
# 配置文件,8000端口
DVWA_DOMAIN=dvwa.sec.cuc.edu.cn
DVWA_PORT=8000
tee /etc/nginx/sites-available/${DVWA_DOMAIN} << EOF
server {
    listen localhost:${DVWA_PORT};
    server_name ${DVWA_DOMAIN};

    root ${DVWA_PATH}/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.2-fpm.sock;
    }
}
EOF
# 设置软链接
ln -s /etc/nginx/sites-available/${DVWA_DOMAIN} /etc/nginx/sites-enabled/
# 重新载入配置
nginx -s reload
```

和之前的步骤类似：

![](./img/dvwa_matcher.png)

![](./img/dvwa_Up_Stream.png)

页面加载成功：

![](./img/dvwa_WelcomePage.png)



---



### WordPress启用HTTPS

使用OpenSSL生成自签名证书
```bash
openssl req -x509 -newkey rsa:4096 -nodes -subj "/C=CN/ST=Beijing/L=Beijing/O=CUC/OU=SEC/CN=wp.sec.cuc.edu.cn" -keyout key.pem -out cert.pem -days 365
```
得到key.pem与cert.pem. 将其放在/etc/nginx/目录下
```bash
mv cert.pem /etc/nginx/cert.pem
mv key.pem /etc/nginx/key.pem
```
修改VeryNginx目录下的配置文件nginx.conf, 将server块如下修改使其同时监听80端口与443端口且只在443端口开启HTTPS验证
```bash
server {
    listen 80;
    listen 443 ssl;
    ssl_certificate      /etc/nginx/cert.pem;
    ssl_certificate_key  /etc/nginx/key.pem;

    #this line shoud be include in every server block
    include /opt/verynginx/verynginx/nginx_conf/in_server_block.conf;

    location = / {
        root   html;
        index  index.html index.htm;
    }
}
```
使用verynginx -t确认配置文件正确
来到管理页面, 添加一条Scheme Lock，并保存。
![](./img/scheme_lock.png)

此时便能访问https://wp.sec.cuc.edu.cn了

![](./img/not_safe.png)
坚持访问网站：
![](./img/https.png)

</details>

<details>

**<summary>Part 2 安全加固要求</summary>**



## 二、安全加固

### 使用IP地址方式均无法访问上述任意站点，并向访客展示自定义的友好错误提示信息页面-1

添加`Matcher`规则

![](./img/ip.png)

添加`Response`相应

![](./img/no_ip.png)

添加`Filter`

![](./img/ip_filter.png)

此时以ip形式访问，会出现对应的提示并拒绝

![](./img/no_ip_page.png)

---



### Damn Vulnerable Web Application (DVWA)只允许白名单上的访客来源IP，其他来源的IP访问均向访客展示自定义的友好错误提示信息页面-2

上一步操作【我杀我自己】，把自己给踢出去了。

将/opt/verynginx/verynginx/configs/config.json的这里改成false即可：

![](./img/enable.png)

添加`Matcher`

![](./img/white_matcher.png)

添加`Response`

![](./img/white_reponse.png)

添加`Filter`

![](./img/white_filter.png)

在白名单的客户端访问

![](./img/white_list.png)

不在白名单的客户端访问

![](./img/not_white_list.png)

（特殊字符似乎显示有点问题）

---



### 在不升级Wordpress版本的情况下，通过定制VeryNginx的访问控制策略规则，热修复WordPress < 4.7.1 - Username Enumeration

添加`Matcher`

![](C:\Users\HP\Desktop\img\username_enumeration.png)

添加`Filter`,报错信息为404，无需添加response

![](C:\Users\HP\Desktop\img\404.png)

效果：

![](C:\Users\HP\Desktop\img\404_not_found.png)



---



### 通过配置VeryNginx的Filter规则实现对Damn Vulnerable Web Application (DVWA)的SQL注入实验在低安全等级条件下进行防护

我们可以只简单过滤一下提交参数（毕竟低等级）

![](./img/sql.png)

![](./img/sql_filter.png)

</details>

<details>

**<summary>Part 3 VeryNginx配置要求</summary>**


## 三、VERYNGINX配置要求

### VeryNginx的Web管理页面仅允许白名单上的访客来源IP，其他来源的IP访问均向访客展示自定义的友好错误提示信息页面-3

与其他两个类似

添加`Matcher`

![](./img/vn_match.png)

![](./img/white_vn_match.png)

添加`Response`

![](./img/vn_response.png)

添加`Filter`

![](./img/vn_filter.png)

白名单访问

![](./img/vn_white_list.png)

非白名单访问

![](./img/vn_not_white_list.png)



---



### 限制DVWA站点的单IP访问速率为每秒请求数 < 50, 限制Wordpress站点的单IP访问速率为每秒请求数 < 20, 超过访问频率限制的请求直接返回自定义错误提示信息页面-4

添加`Response`

![](./img/fre_response.png)

添加`Frequency Limit`

![](./img/frequency_limit.png)

进行压测，然而不知道是什么原因，并没有被限制，依旧跑通了，尚未解决。

![wrong_answer](./img/wrong_answer.png)

</details>

# 遇到问题及解决方案
1. **无法访问 wp.sec.cuc.edu.cn**
   忘记启动nginx
2. **VeryNginx配置保存不成功**：
    用 chmod -R 777 /opt/verynginx/verynginx/configs改变权限
3. **配置使用ip地址的形式无法访问网站，结果把自己也阻挡在外**
   将/opt/verynginx/verynginx/configs/config.json的这里改成false即可：
    ![](./img/enable.png)
4. **配置成功后无法使用https访问网站**
   是浏览器的防护措施，坚持访问即可跳转
   但奇怪的是，我配置的是only https访问，输入网址后默认进入的仍然是http访问，得手动输入https才能跳转过去，而且https访问的网站页面格式有些错乱。

# 参考文献

1. [linux-2019-DcmTruman/0x05/实验报告.md](https://github.com/CUCCS/linux-2019-DcmTruman/blob/0x05/0x05/实验报告.md)
2. [linux-2019-TheMasterOfMagic/chap0x05/](https://github.com/CUCCS/linux-2019-TheMasterOfMagic/tree/master/chap0x05)