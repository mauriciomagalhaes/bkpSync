#!/bin/bash

# yum install rclone
# rclone config

RCLONE=$(which rclone)
SRCDIR="/var/www/backup"
DSTDIR="/Backups/Asterisk/nome_remoto/"
REMOTE="nome_remoto"


$RCLONE --log-file=rclone.log -v sync --max-age 3d  $SRCDIR --exclude="*.php" $REMOTE:$DSTDIR
