#!/bin/bash

# Set the database credentials
db_user="username"
db_password="password"
db_host="hostname:port/service_name"

# Set the query to execute
query=$(cat <<EOF
SELECT
  column1,
  column2,
  column3
FROM
  table_name
WHERE
  column4 = 'value'
  AND column5 > 100;
EOF
)

# Set the name of the output file
output_file="output.csv"

# Execute the query and store the output as a CSV file
sqlplus -S "${db_user}/${db_password}@${db_host}" << EOF
set pagesize 0
set feedback off
set echo off
set heading off
set colsep ','
set trimout on
set termout off
spool "${output_file}"
${query}
spool off
EOF

# Move the output file to the script directory
mv "${output_file}" "$(dirname "$0")/${output_file}"
