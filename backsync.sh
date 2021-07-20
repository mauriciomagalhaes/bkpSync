#!/bin/bash

# yum install rclone
# rclone config

RCLONE=$(which rclone)
SRCDIR="/var/www/backup"
DSTDIR="/Backups/Asterisk/nome_remoto/"
REMOTE="nome_remoto"
# suffix ms|s|m|h|d|w|M|y
QTDDIAS="3d"

$RCLONE --log-file=rclone.log -v -P sync --max-age $QTDDIAS  $SRCDIR --exclude="*.php" $REMOTE:$DSTDIR
