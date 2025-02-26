#!/bin/bash

# Shell Script to manage the entire workflow

# Step 1: Run data extraction
./ShellScripts/run_extraction.sh
if [ $? -ne 0 ]; then
    echo "Workflow failed during data extraction."
    exit 1
fi

# Step 2: Run data processing
./ShellScripts/run_processing.sh
if [ $? -ne 0 ]; then
    echo "Workflow failed during data processing."
    exit 1
fi

# Step 3: Insert processed data into the database
./ShellScripts/run_insertion.sh
if [ $? -ne 0 ]; then
    echo "Workflow failed during data insertion."
    exit 1
fi

# Step 4: Generate report from the database
./ShellScripts/generate_report.sh
if [ $? -ne 0 ]; then
    echo "Workflow failed during report generation."
    exit 1
fi

echo "Workflow completed successfully."