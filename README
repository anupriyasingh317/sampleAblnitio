# Complex Project

This repository contains a complex project with PLSQL scripts, Ab Initio graphs, and shell scripts.

## Structure

- **PLSQL/**: Directory for PLSQL scripts.
- **AbInitio/**: Directory for Ab Initio graphs.
- **ShellScripts/**: Directory for shell scripts.

## Project Overview

The project involves the following steps:
1. Extracting data from a source system using an Ab Initio graph.
2. Processing the extracted data using another Ab Initio graph.
3. Storing the processed data into a database using a PLSQL script.
4. Generating a report from the database using another PLSQL script.
5. Managing the entire workflow using shell scripts.

## Usage

### Step 1: Create Necessary Tables

Run the following command to create the necessary tables in the database:

```sql
sqlplus -s username/password@database @PLSQL/create_tables.sql
```

### Step 2: Run the Workflow

To run the entire workflow, execute the following command in your terminal:

```bash
bash ShellScripts/run_workflow.sh
```

### Individual Steps

You can also run individual steps of the workflow using the respective shell scripts:

- **Data Extraction**: `bash ShellScripts/run_extraction.sh`
- **Data Processing**: `bash ShellScripts/run_processing.sh`
- **Data Insertion**: `bash ShellScripts/run_insertion.sh`
- **Report Generation**: `bash ShellScripts/generate_report.sh`

Ensure that you have the necessary permissions and configurations to run Ab Initio graphs and execute PLSQL scripts on your database.
