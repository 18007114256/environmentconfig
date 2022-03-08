#!/bin/sh
DIRECTORY=$1
if [ -d $DIRECTORY ];then
echo "exist"
else
echo "notexist"
fi