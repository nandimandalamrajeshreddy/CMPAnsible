#!/bin/bash
MYSQL_DB_USER="cmpadmin"
MYSQL_DB_PASS="Unisys*12345"
MYSQL_DB_NAME="hybrid"
mysql -u "$MYSQL_DB_USER" --password="$MYSQL_DB_PASS" -e "CREATE DATABASE "$MYSQL_DB_NAME""
mysql -u "$MYSQL_DB_USER" --password="$MYSQL_DB_PASS" --database="$MYSQL_DB_NAME"  -e "CREATE TABLE users (id int(11) NOT NULL,name varchar(255) NOT NULL,email varchar(255) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1"
mysql -u "$MYSQL_DB_USER" --password="$MYSQL_DB_PASS" --database="$MYSQL_DB_NAME"  -e "ALTER TABLE users ADD PRIMARY KEY (id)"
mysql -u "$MYSQL_DB_USER" --password="$MYSQL_DB_PASS" --database="$MYSQL_DB_NAME"  -e "ALTER TABLE users MODIFY id int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=1"
mysql -u "$MYSQL_DB_USER" --password="$MYSQL_DB_PASS" --database="$MYSQL_DB_NAME"  -e "COMMIT"
mysql -u "$MYSQL_DB_USER" --password="$MYSQL_DB_PASS" --database="$MYSQL_DB_NAME"  -e "GRANT ALL ON *.* to 'cmpadmin'@'0.0.0.0'"
mysql -u "$MYSQL_DB_USER" --password="$MYSQL_DB_PASS" --database="$MYSQL_DB_NAME"  -e "INSERT INTO users (id,name,email) VALUES (1,'datamart','datamart@gmail.com'),(2,'hadoop','hadoop@gmail.com')"