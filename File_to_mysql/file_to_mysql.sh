### This script reads data from a file and load into mysql table. Table name is today's date e.g. 2020-05-28. But you can change it as you need. 
### If the table doesn't exist then it creates the table and inserts data. If table exists then it updates the table. 

#!/bin/bash

# Mysql Credentials
USERNAME=training    
PASSWORD=training
DATABASE=testsql


# Prepare variables
FILENAME=/home/training/training_materials/analyst/data/airports.csv
TABLE=`date +%Y-%m-%d`
SQL_EXISTS=$(printf 'SHOW TABLES LIKE "%s"' "$TABLE")

# SQL_CT carries the table schema. Modify this to suit the schema of your table. 
SQL_CT=$(printf 'CREATE TABLE `%s`(faa varchar(3), name varchar(100), lat varchar(20), lon varchar(20), alt varchar(5), tz varchar(3))' "$TABLE")

# SQL_LOAD loads the file data into table. Here it is assumed that file is comma separated. 
SQL_LOAD=$(printf 'LOAD DATA INFILE '"'"'%s'"'"' INTO TABLE `%s` FIELDS TERMINATED BY '"'"','"'"' ' "$FILENAME" "$TABLE")

# SQL_INS is created in the case when table is already there. 
SQL_INS=$(printf 'INSERT INTO `%s` select * from `tmp_%s`' "$TABLE" "$TABLE")

#create temp table in case table already exists
SQL_CT_TMP=$(printf 'CREATE TABLE `tmp_%s`(faa varchar(3), name varchar(100), lat varchar(20), lon varchar(20), alt varchar(5), tz varchar(3))' "$TABLE")
SQL_LOAD_TMP=$(printf 'LOAD DATA INFILE '"'"'%s'"'"' INTO TABLE `tmp_%s` FIELDS TERMINATED BY '"'"','"'"' ' "$FILENAME" "$TABLE")
SQL_DROP_TMP=$(printf 'DROP TABLE `tmp_%s` ' "$TABLE")

echo "Checking if table <$TABLE> exists ..."

# Check if table exists
if [[ $(mysql -u $USERNAME -p$PASSWORD -e "$SQL_EXISTS" $DATABASE) ]]
then
    echo "Table exists ..."
	#create temporary table and insert data into that. 
	mysql -u $USERNAME -p$PASSWORD -e "$SQL_CT_TMP" $DATABASE
	mysql -u $USERNAME -p$PASSWORD -e "$SQL_LOAD_TMP" $DATABASE
		
	#insert data in original table from tmp table
	mysql -u $USERNAME -p$PASSWORD -e "$SQL_INS" $DATABASE
	echo "Data updated in existing table"
	
	#drop temporary table
	mysql -u $USERNAME -p$PASSWORD -e "$SQL_DROP_TMP" $DATABASE

else
    echo "Table doesn't exist ..."
	
	#Creating new table here
    mysql -u $USERNAME -p$PASSWORD -e "$SQL_CT" $DATABASE	
	echo "Table created"
	
	#Loading data from file 
	mysql -u $USERNAME -p$PASSWORD -e "$SQL_LOAD" $DATABASE
	echo "Data has been successfully loaded"
	
fi
