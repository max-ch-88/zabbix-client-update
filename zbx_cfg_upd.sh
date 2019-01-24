#!/bin/sh +x

sudo /usr/bin/rm -fr /etc/zabbix/*

sudo /usr/bin/wget -q -r --no-parent -nH --cut-dirs=2  http://10.4.128.25/configs/$(hostname)/ --reject index.html -P /etc/zabbix

sudo /usr/bin/systemctl restart zabbix-agent


