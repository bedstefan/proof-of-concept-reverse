#!/bin/sh
apk add openssh
apk add fail2ban
ssh-keygen -A
chmod 700 /root/.ssh/
chmod 600 /root/.ssh/*
/usr/sbin/sshd -f /etc/ssh/sshd_config