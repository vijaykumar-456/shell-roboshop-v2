#!bin/bash

app_name=shipping
source ./common.sh
check_root

MYSQL_HOST=mysql.learndevopskills.shop
app_setup
java_setup
systemd_setup

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL client"

mysql -h $MYSQL_HOST -u root -pRoboShop@1 -e "use cities" &>>$LOG_FILE
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql
    VALIDATE $? "Data loaded"
else
    echo -e "Data already loaded ... $Y SKIPPING $N"
fi

app_restart
print_total_time
