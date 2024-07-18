#!/bin/bash

mkdir -p ~/myfolder

cd ~/myfolder

echo "Приветствие" > file1.txt
date >> file1.txt

touch file2.txt
chmod 777 file2.txt

base64 /dev/urandom | head -c 20 > file3.txt

touch file4.txt file5.txt
