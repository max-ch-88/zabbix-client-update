#!/bin/sh

host=$1
path=$2
url=$3

#access to web-server
user=zabbix
password=zabbix

if [ -z $2 ]; then
    path="/etc/zabbix"
else
    path=$2
fi

# Get MD5 of config files from server
md5repo=$(curl -s -u $user:$password $url/.zbx-cfg-md5.php -F hostname=$host -X POST -k)
if [ "$md5repo" == "1" ]; then
    echo 1
    exit 1
fi

# Get MD5 of config files from local path
files=$(find -L $path -type f -exec md5sum {} \; 2> /dev/null)
if [ $? == 0 ]; then
    md5local=$(echo "$files" | sed 's!'$path'!!g' | sort |  md5sum | cut -f1 -d" ")
else
    err=$?
    echo $err
    exit $err
fi

# If MD5 on server and local are different, remove local files and download all from server
if [ "$md5local" != "$md5repo" ]; then
    sudo /usr/bin/rm -fr $path/*
    sudo /usr/bin/wget -q -r --user=$user --password=$password --no-parent -nH --cut-dirs=2 $url/$host/ --reject index.html -P $path --no-check-certificate
    sudo /usr/bin/systemctl restart zabbix-agent
    echo 2
    exit 2
#    if [ $? == 0 ]; then
#        zabbix_sender -c $path/zabbix_agentd.conf -k agent.config.status[{HOSTNAME},{$PATH},{$URL}] -o 2
#        exit 2
#    else
#        exit 1
#    fi
else
    echo 0
    exit 0
fi

