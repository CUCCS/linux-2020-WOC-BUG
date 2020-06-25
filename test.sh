#!/usr/bin/env bash
printf "bash\n"
printf "===============vsftpd.sh==============\n"
data=$(ssh wocbugnolvm@192.168.56.102)
bash 0x06/script/vsftpd.sh

printf "==============nfs_s.sh==============\n"
bash 0x06/script/nfs_s.sh

printf "==============nfs_c.sh==============\n"
bash 0x06/script/nfs_c.sh

printf "===============dhcpd.sh==============\n"
bash 0x06/script/dhcpd.sh

printf "==============samba.sh==============\n"
bash 0x06/script/samba.sh

printf "===============dns_s.sh==============\n"
bash 0x06/script/dns_s.sh

printf "===============dns_c.sh==============\n"
bash 0x06/script/dns_c.sh

printf "shellcheck\n"
printf "===============vsftpd.sh==============\n"
shellcheck 0x06/script/vsftpd.sh

printf "==============nfs_s.sh==============\n"
shellcheck 0x06/script/nfs_s.sh

printf "==============nfs_c.sh==============\n"
shellcheck 0x06/script/nfs_c.sh

printf "===============dhcpd.sh==============\n"
shellcheck 0x06/script/dhcpd.sh

printf "==============samba.sh==============\n"
shellcheck 0x06/script/samba.sh

printf "===============dns_s.sh==============\n"
shellcheck 0x06/script/dns_s.sh

printf "===============dns_c.sh==============\n"
shellcheck 0x06/script/dns_c.sh

