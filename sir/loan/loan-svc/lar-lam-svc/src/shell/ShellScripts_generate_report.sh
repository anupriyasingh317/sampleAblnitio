#!/bin/bash

# Shell Script to run the PLSQL script for report generation

echo "Generating report from the database..."
sqlplus -s username/password@database @PLSQL/generate_report.sql

if [ $? -eq 0 ]; then
    echo "Report generation completed successfully."
else
    echo "Failed to generate report."
    exit 1
fi