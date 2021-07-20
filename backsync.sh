#!/bin/bash
#
# yum install rclone
# rclone config
#
RCLONE=$(which rclone)
DEL=$(which find)
#
SRCDIR="/var/www/backup/"
DSTDIR="/Backups/Asterisk/nome_remoto/"
REMOTE="nome_remoto"
QTDIAS="+3"
#
$DEL $SRCDIR -type f -name '*.tar' -mtime $QTDIAS -exec rm -f {} \;
$RCLONE --log-file=rclone.log -v -P sync $SRCDIR --exclude="*.php" $REMOTE:$DSTDIR
