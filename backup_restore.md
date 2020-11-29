# Backup restoration procedures for every service and configuration

Last time modified: 29th November 2020  

> Update:
> - added restoration procedure for the Docker
> - added restoration procedure for the HAProxy
> - added restoration procedure for the keepalived
> - added restoration procedure for the containerised HAProxy exporter
> - added restoration procedure for the keepalived exporter

Table of contents:

- [Backup restoration procedures for every service and configuration](#backup-restoration-procedures-for-every-service-and-configuration)
  - [Preamble](#preamble)
  - [Application related services](#application-related-services)
    - [AGAMA -  application](#agama----application)
    - [MySQL - app database](#mysql---app-database)
    - [uWSGI - app server](#uwsgi---app-server)
  - [General services](#general-services)
    - [Ansible - configuration management tool](#ansible---configuration-management-tool)
    - [Hosts' users configuration](#hosts-users-configuration)
    - [Bind9 - DNS](#bind9---dns)
      - [Hosts' DNS resolvers configuration](#hosts-dns-resolvers-configuration)
    - [Duplicity - backup facility](#duplicity---backup-facility)
    - [Cron - time scheduler](#cron---time-scheduler)
    - [Nginx - web server](#nginx---web-server)
    - [Docker - containerisation service](#docker---containerisation-service)
  - [Monitoring related services](#monitoring-related-services)
    - [InfluxDB - metrics/logs database](#influxdb---metricslogs-database)
    - [Grafana - monitoring visualization](#grafana---monitoring-visualization)
    - [Pinger - connectivity/latency checker](#pinger---connectivitylatency-checker)
    - [Prometheus - metrics collector](#prometheus---metrics-collector)
      - [Bind9 exporter](#bind9-exporter)
      - [MySQL exporter](#mysql-exporter)
      - [Nginx exporters](#nginx-exporters)
      - [Node exporters](#node-exporters)
      - [HAProxy exporters](#haproxy-exporters)
      - [keepalived exporters](#keepalived-exporters)
    - [Rsyslog - syslog facility](#rsyslog---syslog-facility)
    - [Telegraf - metrics collector](#telegraf---metrics-collector)
  - [Load balancing related services](#load-balancing-related-services)
    - [HAProxy - TCP/HTTP load balancer](#haproxy---tcphttp-load-balancer)
    - [keepalived - Layer 4 load balancer](#keepalived---layer-4-load-balancer)

## Preamble

All services and their configurations can be restored with Ansible playbooks (except for Ansible itself), but if restoration of data or Ansible configuration/playbooks is required then custom solutions are shown.

If restoration of a service is needed to be done through Ansible and it is corrupted or absent then firstly refer to the [Ansible - configuration management](#ansible---configuration-management) section to set it up.

Restorations through Ansible playbook should be done in the directory that contains them. All commands are run through console/terminal/command line; from a user "backup" for the restoration of data and configuration without Ansible on the hosts where the service and/or its data should be restored.

If you are starting as a user "ubuntu" you can become user "backup" after running next commands:

```bash
sudo su
su backup
/bin/bash
cd ~
```

**NOTE:** words/phrases enclosed in angle brackets/chevrons (e.g. <backup_username>) should be replaced with the value referenced by the enclosed word/phrase.

## Application related services

### AGAMA -  application

To restore **AGAMA application that uses MySQL database** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab04_web_app.yaml
```

To restore **containerised AGAMA application that uses MySQL database** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab12_docker.yaml
```

### MySQL - app database

To restore **MySQL and its configuration** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab04_web_app.yaml
ansible-playbook ansible-playbook lab07_grafana.yaml
ansible-playbook ansible-playbook lab10_backups.yaml
```

To restore **MySQL databases and their data** run the following commands on the host with MySQL installed:

```bash
duplicity --no-encryption --force restore rsync://<backup_user>@<our_domain>//home/<backup_user> /home/backup/restore/
mysql agama < /home/backup/restore/agama.sql

# To check the results run the next command to show AGAMA database contents
mysql -e 'SELECT * FROM agama.item'
```

### uWSGI - app server

To restore **uWSGI** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab04_web_app.yaml
```

## General services

### Ansible - configuration management tool

To restore **Ansible and playbooks** go through the following options on the management host (or temporary, if management one is unavailable):

1. Install Ansible if if it does not exist, otherwise this step can be skipped. There are two options:

   1. Install from the repository (escalated privileges required, for that run commands as user "ubuntu"):

      ```bash
      sudo apt -y install ansible
      ```

      Afterwards `PATH="$HOME/ansible-venv/bin:$PATH"` string should be added to the **.profile** file in the /home/<ansible_user>/. The file can be open with a simple console text editor:

      ```bash
      nano .profile
      ```

   2. **RECOMMENDED:** Install from the repository into the Python virtual environment, run in /home/<ansible_user>/ directory (escalated privileges and Python3 are required, for that run commands as user "ubuntu"):

      ```bash
      sudo apt install python3.9
      sudo apt install python3-venv
      python3 -m venv ~/ansible-venv
      ~/ansible-venv/bin/pip install ansible==2.9
      ~/ansible-venv/bin/ansible --version
      ```

      Afterwards `PATH="$HOME/ansible-venv/bin:$PATH"` string should be added to the **.profile** file in the /home/<ansible_user>/. The file can be open with a simple console text editor:

      ```bash
      nano .profile
      ```

2. Download Ansible repository into its new location if it does not exist. There are two options:

   1. Download from GitHub

      ```bash
      curl -L -o /home/<ansible_user>/ansible --header 'Authorization: token <github_token>' --header "Accept: application/vnd.github.v3+json" https://api.github.com/repos/<username>/<repository_name>/tarball/master
      tar -zxf ansible

      # Enter the unarchived directory until you see files with .yaml extension, run playbook commands in that directory
      ```

   2. Download from backup server (escalated privileges required, for that run commands as user "ubuntu")

      ```bash
      # If Duplicity is not available on the host - install it
      sudo apt -y install duplicity

      duplicity --no-encryption --force restore rsync://<backup_user>@<our_domain>//home/<backup_user> /home/<ansible_user>/backup/

      cp -a /home/<ansible_user>/backup/ansible /home/<ansible_user>/
      tar -zxf ansible

      # Enter the unarchived directory until you see files with .yaml extension, run playbook commands in that directory
      ```

### Hosts' users configuration

To restore **juri and roman users** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab02_web_server.yaml
```

### Bind9 - DNS

To restore **Bind9** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab05_dns.yaml
```

#### Hosts' DNS resolvers configuration

To restore **hosts' DNS resolvers configuration** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab05_dns.yaml
```

### Duplicity - backup facility

To restore **Duplicity** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab10_backups.yaml
```

### Cron - time scheduler

To restore **Cron** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab10_backups.yaml
```

### Nginx - web server

To restore **Nginx** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab02_web_server.yaml
```

### Docker - containerisation service

To restore **Docker** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab12_docker.yaml
```

## Monitoring related services

### InfluxDB - metrics/logs database

To restore **InfluxDB** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab08_logging.yaml
```

To restore **InfluxDB databases and their data**, **do no start with user "backup", start with user "ubuntu"** run the following commands on the host with InfluxDB installed (escalated privileges are required to stop/start InlfuxDB and transfer the files to the final destination with `rsync`).

```bash
duplicity --no-encryption --force restore rsync://<backup_user>@<our_domain>//home/<backup_user> /home/backup/restore/
sudo systemctl stop influxdb
influxd restore -metadir /var/lib/influxdb/meta /home/backup/restore/influxdb
influxd restore -datadir /var/lib/influxdb/data /home/backup/restore/influxdb
sudo systemctl start influxdb

# To check the results run the next command to show databases
influx -execute 'show databases'
```

### Grafana - monitoring visualization

To restore **Grafana** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab07_grafana.yaml
```

To restore **containerised Grafana** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab12_docker.yaml
```

To restore **Grafana's configuration**, **do no start with user "backup", start with user "ubuntu"** run the following commands on the host with Grafana installed (escalated privileges are required to stop/start Grafana and transfer the files to the final destination with `rsync`).

```bash
duplicity --no-encryption --force restore rsync://<backup_user>@<our_domain>//home/<backup_user> /home/backup/restore/
sudo systemctl stop grafana-server
rsync -a --delete /home/backup/backup/grafana.etc/ /etc/grafana/
rsync -a --delete home/backup/backup/grafana.lib/ /var/lib/grafana/
sudo systemctl start grafana-server
```

Run the following commands if the configuration should be restored for the **Grafana Docker container**, **do no start with user "backup", start with user "ubuntu"** (escalated privileges are required to change file permissions and transfer the files to the final destination with `rsync`):

```bash
duplicity --no-encryption --force restore rsync://<backup_user>@<our_domain>//home/<backup_user> /home/backup/restore/
docker stop grafana
rsync -a --delete /home/backup/backup/grafana.docker.etc/grafana-etc/ /opt/docker/grafana-etc/
rsync -a --delete home/backup/backup/grafana.docker.lib/grafana/ /opt/docker/grafana/
chown -R 472:472 /opt/docker/grafana-etc
chown -R 472:472 /opt/docker/grafana
docker start grafana
```

### Pinger - connectivity/latency checker

To restore **Pinger** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab08_logging.yaml
```

### Prometheus - metrics collector

To restore **Prometheus** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab06_prometheus.yaml
```

To restore **Prometheus databases and their data**, **do no start with user "backup", start with user "ubuntu"** run the following commands on the host with Prometheus installed (escalated privileges are required to stop/start Prometheus and transfer the files to the final destination with `rsync`).

```bash
duplicity --no-encryption --force restore rsync://<backup_user>@<our_domain>//home/<backup_user> /home/backup/restore/
sudo systemctl stop prometheus
rsync -a --delete /home/backup/backup/prometheus/ /var/lib/prometheus/
sudo systemctl start prometheus
```

#### Bind9 exporter

To restore **Bind9 exporter** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab07_grafana.yaml
```

#### MySQL exporter

To restore **MySQL exporter** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab07_grafana.yaml
```

#### Nginx exporters

To restore **Nginx exporters** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab07_grafana.yaml
```

#### Node exporters

To restore **Node exporters** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab06_prometheus.yaml
```

#### HAProxy exporters

To restore **HAProxy exporters** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab13_haproxy.yaml
```

#### keepalived exporters

To restore **keepalived exporters** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab13_haproxy.yaml
```

### Rsyslog - syslog facility

To restore **Rsyslog** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab08_logging.yaml
```

### Telegraf - metrics collector

To restore **Telegraf** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab08_logging.yaml
```

## Load balancing related services

### HAProxy - TCP/HTTP load balancer

To restore **HAProxy** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab13_haproxy.yaml
```

### keepalived - Layer 4 load balancer

To restore **keepalived** run the following commands in the Ansible directory containing playbooks on the management host/system (or the system where playbooks were restored):

```bash
ansible-playbook ansible-playbook lab13_haproxy.yaml
```

