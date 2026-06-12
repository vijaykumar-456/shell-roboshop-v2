#!/bin/bash

LOG_FOLDER="/var/log/roboshop"

#1. Create log folder to send all roboshop logs into this folder
sudo mkdir -p $LOG_FOLDER

#2. Give the necessary ownership / permissions to this folder
sudo chown -R ec2-user:ec2-user $LOG_FOLDER

#3. Give owner-Full Control, Group and others - readandexecute
sudo chmod -R 755 $LOG_FOLDER

#4. specify the log path with folder/file name
LOG_FILE="$LOG_FOLDER/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo -e " $TIMESTAMP [INFO] Script started"

#5. Now Check the user is a sudo user or not with the condition statement
USERID=$(id -u)

check_root(){
    if [ $USERID -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $R Please run with the sudo access $N" | tee -a $LOG_FILE
        exit 1
    fi
}

#7. Validation function
VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $2 ... $R FAILURE $N" | tee -a $LOG_FILE
    else
        echo -e "$TIMESTAMP [INFO] $2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

print_total_time(){
    echo -e " $TIMESTAMP [INFO] Script executed in $G $SECONDS seconds $N"
}