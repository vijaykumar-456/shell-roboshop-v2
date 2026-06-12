#!bin/bash

source ./common.sh

check_root

#6. add the repo to the system
cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo Repo"

#8. Install the packages
dnf install mongodb-org -y &>> $LOG_FILE
VALIDATE $? " Installing Mongodb "

#9. start and enable the mongodb
systemctl enable --now mongod
VALIDATE $? "Enabling and Starting Mongodb "

#10. using sed(streamline editor) update the /etc/mongod.conf
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing Remote connection to MongoDB"

systemctl restart mongod
VALIDATE $? "Restarting MongoDB"

print_total_time