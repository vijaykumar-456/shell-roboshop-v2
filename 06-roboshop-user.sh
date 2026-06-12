#!bin/bash

app_name=catalogue
source ./common.sh
check_root

app_setup
nodejs_setup
systemd_setup



cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Added mongo repo"

dnf install mongodb-mongosh -y &>> $LOG_FILE
VALIDATE $? "Installing Mongo client"

INDEX=$(mongosh --host mongodb.learndevopskills.shop --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $INDEX -lt 0 ]; then
    mongosh --host mongodb.learndevopskills.shop </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Load Products"
else
    echo -e "Products already provided ... $Y SKIPPING $N" 
fi

app_restart

print_total_time