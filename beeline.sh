#!/bin/bash

# Set the database credentials
db_user="username"
db_password="password"
db_host="hostname:port/service_name"

# Set the DDL for the table
ddl=$(cat <<EOF
CREATE TABLE dev.my_table (
  column1 string,
  column2 int,
  column3 double,
  load_ts timestamp
)
PARTITIONED BY (load_date date)
STORED AS ORC
TBLPROPERTIES ("orc.compress"="SNAPPY");
EOF
)

# Set the name of the input file
input_file="input.csv"

# Set the name of the output file
output_file="output.csv"

# Execute the DDL to create the table
beeline -u "jdbc:oracle:thin:${db_user}/${db_password}@${db_host}" -e "${ddl}"

# Load the data into the table and partition by day
beeline -u "jdbc:oracle:thin:${db_user}/${db_password}@${db_host}" << EOF
LOAD DATA LOCAL INPATH '${input_file}' OVERWRITE INTO TABLE dev.my_table
PARTITION (load_date=FROM_UNIXTIME(UNIX_TIMESTAMP(load_ts,'yyyy-MM-dd HH:mm:ss'),'yyyy-MM-dd'))
EOF

# Execute a query to select the data and store the output as a CSV file
beeline -u "jdbc:oracle:thin:${db_user}/${db_password}@${db_host}" --outputformat=csv2 -e "SELECT * FROM dev.my_table" > "${output_file}"

# Move the output file to the script directory
mv "${output_file}" "$(dirname "$0")/${output_file}"
