#!/bin/bash

BACKUP_DIR="/opt/mysql_backup"

BACKUP_NAME="backup_$(date +%Y%m%d_%H%M%S).sql"

mysqldump -u root -p rsshabanov > $BACKUP_DIR/$BACKUP_NAME