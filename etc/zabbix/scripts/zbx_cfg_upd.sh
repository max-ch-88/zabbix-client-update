#!/bin/sh
# Author:      Chudinov M.B.
# Description: Update zabbix-agent configuration
#              $1 The hostname as it created in Zabbix server
#              $2 The full path to dir with zabbix_agentd.conf
#              $3 The URL of the repository site
#

host=$1
path=$2
url=$3

#access to web-server
user=zabbix
password=zabbix

if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then
    echo "Usage: $0 <HOSTNAME> <Zabbix config dir> <Repo URL>"
    echo "Example: $0 'Zabbix server' /etc/zabbix https://192.168.0.1"
    exit 1
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
    echo "sudo systemctl restart zabbix-agent" | SHELL=/bin/sh at -m now +1min 2>/dev/null
    echo 2
    exit 2
else
    echo 0
    exit 0
fi

