#!/bin/bash

BACKUP_DIR="/opt/mysql_backup"

STORE_DIR="user@store:/opt/store/mysql"

rsync -avz $BACKUP_DIR $STORE_DIR