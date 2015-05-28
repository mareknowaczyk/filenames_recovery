#!/bin/bash
echo "--- synchronizacja katalogów"
synchro.sh
echo "--- wykonanie testu"
ssh root@192.168.0.116 'cd /root/synchro/md5sum/; \
  ./md5cat.sh copy;\
  echo "---- ls copy/ ----"; \
  ls copy/; \
  echo "---- copy/md5sum.txt ----"; \
  cat copy/md5sum.txt;\
  echo "---- ls copy/cat1/ ----"; \
  ls copy/cat1/;\
  echo "---- copy/cat1/md5sum.txt ----"; \
  cat copy/cat1/md5sum.txt;\
  echo "---- md5 files content ----"; \
  find * -type f | grep md5sum.txt | xargs -L 1 -I {} sh -c "echo \"---- {} ----\"; cat {}; echo \"\""; \
  echo -e "\n---- full recovery test ----"; \
  ./createtestfiles.sh; ./restoreFilenames.sh orig copy; \
  echo "---file in copy ---"; \
  find copy/* -type f'
   
