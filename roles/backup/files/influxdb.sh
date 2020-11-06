#!/bin/bash

# Backup each database separately (meta data included)
influxd backup -database telegraf /home/backup/backup/influxdb  &> /dev/null
influxd backup -database latency /home/backup/backup/influxdb  &> /dev/null
