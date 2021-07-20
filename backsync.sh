#!/bin/bash

# yum install rclone
# rclone config

RCLONE=$(which rclone)
SRCDIR="/var/www/backup"
DSTDIR="/Backups/Asterisk/PIERRE/ITAIGARA"
REMOTE="pierre-itaigara"


$RCLONE -v sync $SRCDIR --exclude="*.php_original" $REMOTE:$DSTDIR
