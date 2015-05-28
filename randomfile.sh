#!/bin/bash
#seed=$( date +%s%N )
seed=$(sh -c "echo $RANDOM")
#echo "seed=$seed" 

PASS_LEN=10
PASS_COUNT=50
if [ ! -z "$1" ]; then
  PASS_LEN="$1"
fi
if [ ! -z "$2" ]; then
  PASS_COUNT="$2"
fi          

#echo "$seed"    

awk -v myseed="$seed" -v pass_count="$PASS_COUNT" -v pass_len="$PASS_LEN" '
BEGIN{
  srand(myseed);  
  passc=pass_count;
  while (passc > 0){
    NUM=pass_len;  
    idx=0;  
    while (idx < NUM){                         
      # typ : 0 - liczba, 1 - duza litera, 2-mala litera
      typ = int(rand() * 3)
      dec =0
      if (typ == 0){
        dec=int( (rand()*10) + 48 )
      }
      if (typ == 1){
        dec=int( (rand()*(90-65+1) ) + 65 )
      }
      if (typ == 2){
        dec=int( (rand()*(122-97+1) ) + 97 )
      }
      
      if (typ == 3){
        dec=int( (rand()*(47-33+1) ) + 33 ) 
      }
      printf("%c",dec)
      idx+=1
    }
    printf "\n"
    passc=passc-1;
  }  
}  
'  
