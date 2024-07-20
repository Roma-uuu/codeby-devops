#!/bin/bash

cd ~/myfolder

file_count=$(ls | wc -l)
echo "Количество файлов в папке myfolder: $file_count"

if [ -f file2.txt ]; then
  chmod 664 file2.txt
fi

for file in *; do
  if [ -s "$file" ]; then
    continue
  else
    rm "$file"
  fi
done

for file in *; do
  if [ -f "$file" ]; then
    sed -i '2,$d' "$file"
  fi
done
