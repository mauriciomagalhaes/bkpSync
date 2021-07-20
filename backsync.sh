#!/bin/bash
#
# yum install rclone
# rclone config
#
RCLONE=$(which rclone)
DEL=$(which find)
PHP=$(which php)
#
SRCDIR="/var/www/backup/"
DSTDIR="/Backups/Asterisk/nome_remoto/"
REMOTE="nome_remoto"
QTDIAS="+3"
#
$PHP /var/www/backup/automatic_backup.php
$DEL $SRCDIR -type f -name '*.tar' -mtime $QTDIAS -exec rm -f {} \;
$RCLONE --log-file=rclone.log -v -P sync $SRCDIR --exclude="*.php" $REMOTE:$DSTDIR
