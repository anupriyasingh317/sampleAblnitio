#!/bin/bash

# Shell Script to run the data processing Ab Initio graph

echo "Running Ab Initio data processing graph..."
abinitio_run AbInitio/process_data.mp

if [ $? -eq 0 ]; then
    echo "Data processing completed successfully."
else
    echo "Data processing failed."
    exit 1
fi