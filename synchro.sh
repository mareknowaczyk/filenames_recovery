#!/bin/bash
options=""
if [ "$1" == "delete" ] || [ "$1" == "--delete" ] || [ "$1" == "-d" ] ; then
  options=" --delete "
fi

echo "options: $options" 
  
rsync -av $options ../md5sum --exclude copy --exclude orig root@192.168.0.116:synchro/
