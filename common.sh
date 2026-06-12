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

SCRIPT_DIR=$PWD

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

app_setup(){
    id roboshop &>> $LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
        VALIDATE $? "Creating roboshop system user"
    else
        echo -e "$R User Already present with this name $N ... $Y SKIPPING $N"
    fi

    rm -rf /app
    VALIDATE $? "Removing Existing app/code"

    rm -rf /tmp/$app_name.zip
    VALIDATE $? "Removing Exisiting $app_name"

    mkdir -p /app &>> $LOG_FILE
    VALIDATE $? "Creating app folder for code"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip  &>>$LOG_FILE
    cd /app
    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "Unzipping the $app_name code"
}

nodejs_setup(){
    dnf module disable nodejs -y &>> $LOG_FILE
    dnf module enable nodejs:20 -y &>> $LOG_FILE
    dnf  install nodejs -y -y &>> $LOG_FILE
    VALIDATE $? "Installing nodejs:20"
    npm install &>> $LOG_FILE
    VALIDATE $? "Installing npm dependencies"
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "Creating systemctl service"

    systemctl daemon-reload 
    systemctl enable $app_name &>> $LOG_FILE
    VALIDATE $? "Enabling the $app_name"
}

app_restart(){
    systemctl restart $app_name 
    VALIDATE $? "Restarting the $app_name"

}