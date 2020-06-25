#!/usr/bin/env bash
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

