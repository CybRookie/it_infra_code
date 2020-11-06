#!/bin/bash

rsync -a /etc/grafana/ /home/backup/backup/grafana.etc/ &> /dev/null
rsync -a /var/lib/grafana/ /home/backup/backup/grafana.lib/ &> /dev/null
