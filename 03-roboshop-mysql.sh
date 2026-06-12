#!bin/bash

source ./common.sh

check_root

dnf install mysql-server -y &>> $LOG_FILE
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>> $LOG_FILE
systemctl start mysqld &>> $LOG_FILE
systemctl status mysqld &>> $LOG_FILE
VALIDATE $? "Enabling and Starting MySQL Server"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Setting up root password"

print_total_time