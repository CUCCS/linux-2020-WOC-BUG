#!/bin/bash

sudo apt-get install -y samba

smbuser="demoUser"
smbgroup="demoGroup"

# useradd -M -s /sbin/nologin "$smbuser"
sudo useradd -M -s "$(command -v nologin)" "$smbuser"
echo "$smbuser:password" | chpasswd
# sed -i.bak 's#^\(smbuser:\)[^:]*\(:.*\)$#\$6$0Nf0oKzZw7$LWRXlj45pDhV/KHEISQhmOLr8hux2tB1DmzPvee0UrbvaOsjbcf3pBAd4RNdzJqdMnsmvC2/FCf7hECsDLhwU/#' /etc/shadow
(echo password; echo password) | smbpasswd -a "$smbuser"

sudo cat<<EOT >>/etc/samba/smb.conf
[guest]
path = /home/samba/guest/
read only = yes
guest ok = yes
[demo]
path = /home/samba/demo/
read only = no
guest ok = no
force create mode = 0660
force directory mode = 2770
force user = "$smbuser"
force group = "$smbgroup"
EOT

sudo smbpasswd -e "$smbuser"
sudo groupadd "$smbgroup"
sudo usermod -G "$smbgroup" "$smbuser"
sduo mkdir -p /home/samba/guest/
sudo mkdir -p /home/samba/demo/
sudo chgrp -R "$smbgroup" /home/samba/guest/
sudo chgrp -R "$smbgroup" /home/samba/demo/
sudo chmod 2775 /home/samba/guest/
sudo chmod 2770 /home/samba/demo/

sudo service smbd restart
