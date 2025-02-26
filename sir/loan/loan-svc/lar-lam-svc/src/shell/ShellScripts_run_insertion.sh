#!/bin/bash

# Shell Script to run the PLSQL script for data insertion

echo "Inserting processed data into the database..."
sqlplus -s username/password@database @PLSQL/insert_data.sql

if [ $? -eq 0 ]; then
    echo "Data insertion completed successfully."
else
    echo "Failed to insert data into the database."
    exit 1
fi