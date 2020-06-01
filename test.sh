#!/usr/bin/env bash

printf "==============nfs_s.sh==============\n"
shellcheck 0x06/script/nfs_s.sh

printf "==============nfs_c.sh==============\n"
shellcheck 0x06/script/nfs_c.sh

printf "==============samba.sh==============\n"
shellcheck 0x06/script/samba.sh

printf "===============vsftpd.sh==============\n"
shellcheck 0x06/script/vsftpd.sh
