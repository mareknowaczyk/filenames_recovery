#!/bin/bash

if [ -d orig ]; then rm -R orig; fi
if [ -d copy ]; then rm -R copy; fi

mkdir orig
cd orig
cat ../files1.txt |
while read file; do
  echo "creating file $file"  
  dirpath="$(echo $file | sed -r -e 's/[^/]+$//g')"    
  if [ ! -z "$dirpath" ] && [ ! -d "$dirpath" ]; then    
    mkdir -p "$dirpath"
  fi
  echo "original file content" > "$file"  
done

cd ..
#cp -R orig copy
mkdir copy
find orig/* -type f |\
xargs -L 1 -I _file_ sh -c 'randomfilename="copy/$(./randomfile.sh 20 1);"; \
  cp _file_ $randomfilename; \
  echo "create random file: $randomfilename"'  
cd copy

# renaming copy files
 
cat ../modifications.txt |
while read fileline; do
  echo -n "parsing $fileline : "
  operation="$(echo $fileline | awk '{print $1}')"
  file="$(echo $fileline | awk '{print $2}')"  
  if [ "$operation" == "m" ]; then
    echo "modify file $file"  
    dirpath="$(echo $file | sed -r -e 's/[^/]+$//g')"    
    if [ ! -z "$dirpath" ] && [ ! -d "$dirpath" ]; then
      echo "$dirpath"
      mkdir -p "$dirpath"
    fi
    echo "modified file content" >> "$file"
  fi  
  if [ "$operation" == "d" ]; then
    echo "delete file $file"
    rm "$file" 
  fi
done

find | grep -v "md5sum.txt" | grep ".txt" |\
sed -e 's/\.\///' | xargs -L 1 -I file mv file file.newname

echo -e "\ndone\n"
