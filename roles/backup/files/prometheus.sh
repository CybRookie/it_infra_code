#!/bin/bash

rsync -a /var/lib/prometheus/ /home/backup/backup/prometheus/ &> /dev/null
