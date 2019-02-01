#!/bin/sh

#access to web-server
url=https://10.4.128.25:444/configs
user=zabbix
password=zabbix

if [ -z $1 ]; then
    path="/etc/zabbix"
else
    path=$1
fi

host=$(grep -P 'Hostname[\s]*=' /etc/zabbix/zabbix_agentd.conf | sed s/'\s'//g | grep '^[^#]' | cut -d'=' -f2)
if [ -z $host ]; then
    host=$(hostname)
fi

md5repo=$(curl -s -u $user:$password $url/.zbx-cfg-md5.php -F hostname=$host -X POST -k)

files=$(find -L $path -type f -exec md5sum {} \; 2> /dev/null)

if [ $? == 0 ]; then
    md5local=$(echo "$files" | sed 's!'$path'!!g' | sort |  md5sum | cut -f1 -d" ")
else
    exit $?
fi

if [ $md5local != $md5repo ]; then
    sudo /usr/bin/rm -fr $path/*
    sudo /usr/bin/wget -q -r --user=$user --password=$password --no-parent -nH --cut-dirs=2 $url/$host/ --reject index.html -P $path --no-check-certificate
    sudo /usr/bin/systemctl restart zabbix-agent
fi

