#!bin/bash

source ./common.sh

check_root

dnf module disable redis -y &>> $LOG_FILE
dnf module enable redis:7 -y &>> $LOG_FILE
dnf install redis -y
VALIDATE $? "Installing Redis:7"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing Remote Connections"

systemctl enable redis
systemctl start redis
VALIDATE $? "Enabling and Starting Redis"

print_total_time