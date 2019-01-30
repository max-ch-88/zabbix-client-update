#!/bin/sh

if [ -z $1 ]; then
    path=$(pwd)
else
    path=$1
fi

s=$(find -L $path -type f -exec md5sum {} \; 2> /dev/null)

if [ $? == 0 ]; then
    echo "$s" | sed 's!'$path'!!g' | sort |  md5sum | cut -f1 -d" "
else
    echo $?
fi
