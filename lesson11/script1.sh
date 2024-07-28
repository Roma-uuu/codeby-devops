#!/bin/bash

# Константы
FOLDER=~/myfolder
FILE1=file1.txt
FILE2=file2.txt
FILE3=file3.txt
FILE4=file4.txt
FILE5=file5.txt

# Создание директории, если она не существует
mkdir -p $FOLDER

# Переход в созданную директорию
cd $FOLDER

# Создание file1.txt и добавление приветствия и текущей даты
echo "Приветствие" > $FILE1
date >> $FILE1

# Создание file2.txt и установка прав 777
touch $FILE2
chmod 777 $FILE2

# Генерация случайной строки и сохранение её в file3.txt
base64 /dev/urandom | head -c 20 > $FILE3

# Создание file4.txt и file5.txt
touch $FILE4 $FILE5

# Код возврата
exit 0
