#!/bin/bash

dosearch="1"
if [ -z "$1" ]; then echo "nie podano katalogu zródłowego"; exit; fi;
if [ -z "$2" ]; then echo "nie podano katalogu docelowego"; exit; fi;
if [ ! -z "$3" ]; then
  dosearch=""
fi

dirsource="$1"
dirtarget="$2"

if [ "$dosearch" == "1" ]; then
  echo "Generowanie sum md5 w katalogu żródłowym"
  ./md5cat.sh $dirsource
  
  echo "Znajdowanie sum md5 dla plików żródłowych"
  find $dirsource/* | \
  grep 'md5sum.txt' | xargs -L1 -I {} cat {} | \
  #awk -F "/" '{last=$NF; sub(FS $NF,x); print $0}' |\
  #xargs -L 1 -I _dir_  sh -c "cat _dir_/md5sum.txt |\
  #sed  -r -e 's| +\**(.*)| _dir_/\1|g'" |\
  sort > md5source.txt 
  
  eval "sed -i -e 's/ $dirsource\// /g' md5source.txt"
  
  echo "Generowanie sum md5 w katalogu docelowym"
  ./md5cat.sh $dirtarget
  
  echo "Znajdowanie sum md5 dla plików docelowych"
  find $dirtarget/* -type f | grep "md5sum.txt" | \
  xargs -L1 -I {} cat {} | \
  #awk -F "/" '{last=$NF; sub(FS $NF,x); print $0}' |\
  #xargs -L 1 -I _dir_  sh -c "cat _dir_/md5sum.txt |\
  #sed  -r -e 's| +\**(.*)| _dir_/\1|g'" |\
  sort > md5target.txt 
  
  eval "sed -i -e 's/ $dirtarget\// /g' md5target.txt"
fi

echo " -- md5source.txt --"
cat md5source.txt
echo " -- md5target.txt --"
cat md5target.txt

#set -x
# $1 input line
# $2 output var
function gethash() {
  lasthash="$(echo $1 | awk '{print $1}')"
  eval "$2=\"$lasthash\""
}

function getpathfile(){
  lastpathfile="$(echo $1 | awk '{print $2}')"
  eval "$2=\"$lastpathfile\""
}

function getpath(){
  lastpath="$(echo $1 | awk -F '/' '{sub(FS $NF,x); print $0}' )"
  eval "$2=\"$lastpath\""
}

function getfile(){
  lastfile="$(echo $1 | awk -F '/' '{if ($NF != "") {print $NF} else {print $0} }' )"
  eval "$2=\"$lastfile\""
}

# dla każdej pary plików A, B gdzie:
# - A i B mają takie same sumy md5
# - A pochodzi z source
# - B pochodzi z target
# - A i B zawierają ścieżki do plików
# należy wykonać polecenia
#   mkdir -p  target/path(A) 2> /dev/null
#   mv target/path(B) target/path(A)

echo "Wyszukiwanie tych samych plików"
cat md5source.txt |
while read line; do
  gethash "$line" sourcehash
  getpathfile "$line" pathfile
  targetline=$(grep "$sourcehash" md5target.txt | head -1)
  if [ ! -z "$targetline" ]; then    
    getpath "$pathfile" sourcepath
    #getfile "$pathfile" sourcefile
    gethash "$targetline" targethash
    getpathfile "$targetline" targetpathfile
    getpath "$targetpathfile" targetpath 
    #getfile "$targetpathfile" targetfile
    #echo "znaleziono te same pliki $sourcehash == $targethash"
    if [ ! -f "$dirtarget/$pathfile" ]; then    
      echo "renaming $dirtarget/$targetpathfile" "$dirtarget/$pathfile"
      mmkdir -p "$dirtarget/$sourcepath" 2> /dev/null
      mv "$dirtarget/$targetpathfile" "$dirtarget/$pathfile" 2> /dev/null
    fi
    eval "sed -i -e '0,/$sourcehash/{s//file_already_restored/}' md5target.txt"        
  else
    if [ ! -f "$dirtarget/$pathfile" ]; then
      # jeżeli plik źródłowy nie istnieje w odpowiednim miejscu
      # katalogu docelowego to należy utworzyć (przywrócić plik)
      echo "restoring file $dirsource/$pathfile"
      mkdir -p "$dirtarget/$sourcepath" 2> /dev/null
      cp "$dirsource/$pathfile" "$dirtarget/$pathfile"
    fi 
  fi      
done

# następnie dla każdego pliku source/A, który
# nie ma odpowiednika B, należy wykonać
#   mkdir -p target/path(A) 2> /dev/null
#   cp source/A target/A 