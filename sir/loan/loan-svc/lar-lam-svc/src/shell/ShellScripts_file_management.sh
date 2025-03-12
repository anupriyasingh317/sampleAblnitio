#!/bin/bash

# Shell Script to run the PLSQL package for file processing


FILE_NAME="sample_file.txt" 

echo "Starting file processing for: $FILE_NAME"

sqlplus -s username/password@database <<EOF
SET SERVEROUTPUT ON
BEGIN
    -- Call the process_file procedure from the file_management_pkg package
    file_management_pkg.process_file('$FILE_NAME');
END;
/
EXIT;

if [ $? -eq 0 ]; then
    echo "File processing completed successfully for: $FILE_NAME"
else
    echo "Failed to process the file: $FILE_NAME"
    exit 1
fi
