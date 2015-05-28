#!/bin/bash

# utworzenie sum plików md5 w każdym z katalogów począwszy od $1
dir="$1"
if [ -z "$dir" ]; then
  dir="$PWD"
fi;

echo "Working directory: $dir"

if [ -f $dir/md5sum.txt ]; then rm $dir/md5sum.txt; fi
echo "creating md5sum.txt in '$dir'"
md5sum $dir/* 2> /dev/null > $dir/md5sum.txt  
 
#cd $dir
 
find * -type d | grep -E '.+' |
while read subdir; do
  tdir="$subdir"
  echo "creating md5sum.txt in '$tdir' (subdir $tdir)"
  if [ -f $tdir/md5sum.txt ]; then rm $tdir/md5sum.txt; fi
  md5sum $tdir/* 2> /dev/null > $tdir/md5sum.txt  
done;