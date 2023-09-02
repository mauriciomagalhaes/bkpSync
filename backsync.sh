#!/bin/bash
#
# yum install rclone
# rclone config
#
RCLONE=$(which rclone)
DEL=$(which find)
PHP=$(which php)
IPBXHOSTNAME=$(hostname | cut -d. -f1)
#
SRCDIR="/var/www/backup/"
DSTDIR="/T3telecom/BACKUP/ISSABEL"
REMOTE="Backup"
QTDIAS="+3"
#
#$PHP $SRCDIR/automatic_backup.php
$DEL $SRCDIR -type f -name '*.tar' -mtime $QTDIAS -exec rm -f {} \;
$RCLONE --log-file=rclone.log -v -P sync $SRCDIR --exclude="*.php" $REMOTE:$DSTDIR/${IPBXHOSTNAME^^}
