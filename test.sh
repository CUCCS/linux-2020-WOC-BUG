#!/usr/bin/env bash

printf "===============vsftpd.sh==============\n"
bash 0x06/script/vsftpd.sh

printf "------------------------shellcheck------------------------\n"
shellcheck 0x06/script/vsftpd.sh

printf "==============nfs_s.sh==============\n"
bash 0x06/script/nfs_s.sh

printf "------------------------shellcheck------------------------\n"
shellcheck 0x06/script/nfs_s.sh

printf "==============nfs_c.sh==============\n"
bash 0x06/script/nfs_c.sh

printf "------------------------shellcheck------------------------\n"
shellcheck 0x06/script/nfs_c.sh

printf "==============samba.sh==============\n"
bash 0x06/script/samba.sh

printf "------------------------shellcheck------------------------\n"
shellcheck 0x06/script/samba.sh
