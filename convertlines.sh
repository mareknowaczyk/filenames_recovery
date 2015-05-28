#!/bin/bash

osname="$(uname)"
#if [ "$osname" == "Linux" ]; then
  sed -i -e "s/\r//g" *.sh
#else
#  awk
#fi 