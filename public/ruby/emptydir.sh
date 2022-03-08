#!/bin/sh
DIRECTORY=$1
if [ "`ls -A $DIRECTORY`" = "" ]; then
  echo "empty"
else
  echo "notempty"
fi