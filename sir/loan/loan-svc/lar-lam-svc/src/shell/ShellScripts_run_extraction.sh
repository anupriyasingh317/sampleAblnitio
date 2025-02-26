#!/bin/bash

# Shell Script to run the data extraction Ab Initio graph

echo "Running Ab Initio data extraction graph..."
abinitio_run AbInitio/extract_data.mp

if [ $? -eq 0 ]; then
    echo "Data extraction completed successfully."
else
    echo "Data extraction failed."
    exit 1
fi