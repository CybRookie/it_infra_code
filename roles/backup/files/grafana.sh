#!/bin/bash

rsync -a /etc/grafana/ /home/backup/backup/grafana.etc/ &> /dev/null
rsync -a /var/lib/grafana/ /home/backup/backup/grafana.lib/ &> /dev/null

# Added backup procedures for the containerised Grafana directories, since Lab 12 - Docker

rsync -a /opt/docker/grafana-etc /home/backup/backup/grafana.docker.etc/ &> /dev/null
rsync -a /opt/docker/grafana /home/backup/backup/grafana.docker.lib/ &> /dev/null
