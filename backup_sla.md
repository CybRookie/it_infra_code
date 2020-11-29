# Backup services SLA

Last time modified: 29th November 2020  

> Update:
> - updated the list of the services in the infrastructure

Table of contents:

- [Backup services SLA](#backup-services-sla)
  - [Introduction](#introduction)
    - [Definition of SLA](#definition-of-sla)
    - [Structure of SLA](#structure-of-sla)
  - [Backup coverage](#backup-coverage)
  - [Backup RPO](#backup-rpo)
  - [Versioning and retention](#versioning-and-retention)
  - [Usability](#usability)
  - [Restoration criteria](#restoration-criteria)
  - [Backup RTO](#backup-rto)

## Introduction

### Definition of SLA

This Service Level Agreement (this “SLA”) governs the backup Services. Operations and security teams may update, amend, modify or supplement this SLA from time to time. The terms and conditions of this SLA are applicable to the Managed Backup and Disaster Recovery Services only.  

### Structure of SLA

This SLA describes the backup approach for all services in the infrastructure:  

- Web services - **Nginx**
- App services - **Agama**
- Database services - **MySQL, InfluxDB**
- DNS service - **Bind9**
- Monitoring services - **Prometheus, Grafana, Telegraf, Pinger, Bind9 exporter, MySQL exporter, Nginx exporters, Node exporters, Rsyslog, HAProxy exporter, keepalived exporter**
- Backup services - **Scripts, Duplicity**
- Containerisation services - **Docker**
- Load balancing services - **HAProxy, keepalived**
- Additional services - **Ansible, uWSGI, Cron**
- Ansible repository - <https://github.com/CybRookie/ica0002> (stores configuration, roles, playbooks to configure all the above-mentioned services)

Descriptions of backup approaches contain information on specific backup attributes, such as:

- Backup coverage - what is backed up and what is not
- Backup RPO (recovery point objective) - acceptable data loss (time period)
- Versioning and retention - how many backup versions are stored and for how long
- Usability - how is the backup recovery verified (backup should be usable)
- Restoration criteria - when should backup be restored
- Backup RTO (recovery time objective) - how long will it take to restore the service

## Backup coverage

Backup service covers only the next services:

- Database services - **MySQL, InfluxDB**
- Monitoring services - **Grafana**, **Prometheus**
- Ansible repository

**Explanation:**  
All the services included contain user provided information (MySQL) or log information, reflecting the health of our infrastructure (InfluxDB and Prometheus), or configuration of our infrastructure. User and the log data, and Grafana configuration cannot be restored by any other means, Ansible repository is backed up to make it available in case infrastructure is misconfigured during network outage.

All the services not included under the backup service, such as web, app, DNS and monitoring services do not store any data produced by themselves and our service users. Log data is stored on InfluxDB service, monitoring data on InfluxDB and Prometheus services, and user data in MySQL database. Not covered services can be reliably and swiftly restored using Ansible service.

## Backup RPO

Recovery point objective for:

- **MySQL** equals **4 weeks/28 days**.
- **InfluxDB** equals **4 weeks/28 days**.
- **Prometheus** equals **4 weeks/28 days**.
- **Grafana** equals **1 week/7 days**.
- **Ansible repository** equals **1 week/7 days**.

Two types of backup can be produced: full and incremental.

- **Full backup** contains the whole backed up data and can be solely used to restore require data or service. **Full backups are done for each service covered by our backup strategy according to the backup RPO' schedule.**
- **Incremental backup** stores only the difference in the data relative to the last incremental backup produced. First incremental backup stores difference from the last created full backup. These backups form a chain, if some links disappear, they cannot be used to restore the data or service, but they allow to use less storage. **Incremental backups are not produced done only for any service.**

**Time:** backups should be done automatically at 1:00 (1 AM) with 1 minute steps for each service on Sundays, according to EET (UTC +2) and EEST (UTC +3) time zones.

**Explanation:**  
Considering the nature of our Agama service, users cannot and do not store any important information using our service, this information is also relatively short-lived. Services' logs and connection quality information are important in forensics' evaluation of the (un-)successful breaches.  
In view of the unimportance of our service and that the data produced by services is not analysed, the backup of MySQL, InfluxDB and Prometheus is done every 4 weeks. Meanwhile, our infrastructure evolves every week and the Ansible/Grafana configurations with it.  
1:00 time was chosen as the time with the least activity in the region when our service is provided, some backed up services may be in the read-only mode or shutdown.  
Incremental backups are not produced, main services are backed up rarely and according to the versioning and retention specification, only two versions are stored. These backups do not require a lot of storage in these amounts, as a result only more reliable full backups are created.

## Versioning and retention

- **MySQL**, **InfluxDB** and **Prometheus** backups are retained for **8 weeks/56 days + 4 hours**, only 2 versions can be stored at the same time.
- **Agama** and **Ansible repository** backups are retained for **2 weeks/14 days + 4 hours**, only 2 versions should be stored at the same time.

**Time:** the oldest/3rd backup should be deleted at 5:00 (5 AM), according to EET (UTC +2) and EEST (UTC +3) time zones, on the same day when a new backup is created (Sunday).

**Explanation:**  
Retention period should be longer than the period between creation of backups to not create a window of time, when there is none. To minimize storage used and still provide reliable backup service, 8 weeks was chosen as a backup retention period for MySQL, InfluxDB and Prometheus, and 2 weeks for Agama and Ansible repository to retain only 2 backup versions. If the last backup is not compatible with the newer version of the used software, then there is a higher chance that the older backup will cover this issue.

## Usability

Usability of the last **MySQL**, **InfluxDB**, **Prometheus**, **Grafana** and **Ansible repository** backup is regularly checked every **1 weeks/7 days** before new modifications to Ansible repository and Grafana configuration is done. The test is done on the virtual environment setup, simulating our real infrastructure.

**Explanation:**  
Before Ansible repository and Grafana configuration are modified, new backups are produced. New modifications should be tested in the development environment, this moment could used to to test backups as well.

## Restoration criteria

- Backup restoration of the **MySQL**, **InfluxDB** or **Prometheus** data should be done only if it was detected and confirmed that the stored data was corrupted, modified by the unauthorized 1st/3rd party, stolen or deleted.
- Backup restoration of the **Grafana** configuration should be done only if it was detected and confirmed that the service configuration was corrupted, modified by the unauthorized 1st/3rd party, stolen or deleted.
- **Ansible repository** backup should only be used if the reconfiguration of services is required, and original GitHub based repository is unavailable, or the process of acquiring and using a backup copy is faster than acquiring and using GitHub's copy.

**Explanation:**  
Backup restoration takes time and computing resources, there is no reason to use it, if the data it covers, was not corrupted.

## Backup RTO

- Backup service is expected to take maximum of **2 hours** to fully recover all the data.
- If the whole infrastructures should be restored, excepted maximum required time equals **3 hours**.

**Explanation:**  
Our infrastructure is small and its recovery with Ansible should be swift, meanwhile, to restore the data more time might be required because of the possible bandwidth and storage media limitations.

