#!/bin/bash

# Константы
FOLDER=~/myfolder
FILE2=file2.txt

# Переход в директорию
cd $FOLDER

# Подсчет и вывод количества файлов в директории
file_count=$(ls | wc -l)
echo "Количество файлов в папке myfolder: $file_count"

# Проверка существования file2.txt и изменение его прав на 664
if [ -f $FILE2 ]; then
  chmod 664 $FILE2
fi

# Удаление пустых файлов в директории
for file in *; do
  if [ -s "$file" ]; then
    continue
  else
    rm "$file"
  fi
done

# Удаление содержимого с 2-й строки и далее в каждом файле
for file in *; do
  if [ -f "$file" ]; then
    sed -i '2,$d' "$file"
  fi
done

# Код возврата
exit 0
