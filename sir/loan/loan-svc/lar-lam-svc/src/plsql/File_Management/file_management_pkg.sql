

CREATE OR REPLACE PACKAGE file_management_pkg AS

    -- **********************************************************************************
    -- Package Specification: file_management_pkg
    -- **********************************************************************************


    -- Function to get configuration values
    FUNCTION get_config_value(p_key IN VARCHAR2) RETURN VARCHAR2;

    -- Procedures
    PROCEDURE load_configuration;
    PROCEDURE initialize_file_processing(p_file_name IN VARCHAR2);
    PROCEDURE process_record(p_file_id IN NUMBER, p_record_data IN VARCHAR2);
    PROCEDURE finalize_file_processing(p_file_id IN NUMBER);
    PROCEDURE log_error(p_file_id IN NUMBER, p_error_message IN VARCHAR2);
    PROCEDURE archive_file(p_file_name IN VARCHAR2);
    PROCEDURE generate_report(p_file_id IN NUMBER);
    PROCEDURE process_file(p_file_name IN VARCHAR2);
    PROCEDURE process_bank_file(p_file_name IN VARCHAR2);
END file_management_pkg;
/

CREATE OR REPLACE PACKAGE BODY file_management_pkg AS
    -- **********************************************************************************
    -- Package Body: file_management_pkg
    -- **********************************************************************************

    -- Global Variables
    g_total_records NUMBER := 0;
    g_total_amount  NUMBER := 0;

    -- Configuration Table
    TYPE config_table IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(50);
    g_config config_table;

    -- **********************************************************************************
    -- PROCEDURE: load_configuration
    -- Description: Loads configuration values into a global table.
    -- **********************************************************************************
    PROCEDURE load_configuration IS
    BEGIN
        g_config('FILE_DIRECTORY') := '/u01/app/files';
        g_config('ARCHIVE_DIRECTORY') := '/u01/app/archive';
        g_config('LOG_DIRECTORY') := '/u01/app/logs';
        g_config('MAX_RECORDS') := '1000';

        DBMS_OUTPUT.PUT_LINE('Configuration loaded successfully.');
    END load_configuration;

    -- **********************************************************************************
    -- FUNCTION: get_config_value
    -- Description: Retrieves a configuration value by key.
    -- **********************************************************************************
    FUNCTION get_config_value(p_key IN VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        RETURN g_config(p_key);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'Configuration key not found: ' || p_key);
    END get_config_value;

    -- **********************************************************************************
    -- PROCEDURE: initialize_file_processing
    -- Description: Initializes file processing by inserting metadata into the database.
    -- **********************************************************************************
    PROCEDURE initialize_file_processing(p_file_name IN VARCHAR2) IS
        v_file_id NUMBER;
    BEGIN
        v_file_id := seq_file_id.NEXTVAL;

        INSERT INTO file_processing (file_id, file_name, process_status)
        VALUES (v_file_id, p_file_name, 'IN_PROGRESS');

        DBMS_OUTPUT.PUT_LINE('File processing initialized for file: ' || p_file_name || ' (File ID: ' || v_file_id || ')');
    END initialize_file_processing;

    -- **********************************************************************************
    -- PROCEDURE: process_record
    -- Description: Processes a single record and updates the database.
    -- **********************************************************************************
    PROCEDURE process_record(p_file_id IN NUMBER, p_record_data IN VARCHAR2) IS
    v_record_id NUMBER;
    v_amount NUMBER;
    v_error_message VARCHAR2(4000); -- Ensure it's declared properly
BEGIN
    v_record_id := seq_record_id.NEXTVAL;

    -- Simulate record processing
    v_amount := LENGTH(p_record_data) * 10;

    -- Update global counters
    g_total_records := g_total_records + 1;
    g_total_amount := g_total_amount + v_amount;

    DBMS_OUTPUT.PUT_LINE('Processed record ID: ' || v_record_id || ', Amount: ' || v_amount);

EXCEPTION
    WHEN OTHERS THEN
        v_error_message := SQLERRM;
        INSERT INTO processed_records (record_id, file_id, record_data, record_status, error_message)
        VALUES (v_record_id, p_file_id, p_record_data, 'FAILED', v_error_message);

        log_error(p_file_id, 'Error processing record: ' || v_error_message);
END process_record;

    -- **********************************************************************************
    -- PROCEDURE: finalize_file_processing
    -- Description: Finalizes file processing by updating metadata in the database.
    -- **********************************************************************************
    PROCEDURE finalize_file_processing(p_file_id IN NUMBER) IS
    BEGIN
        UPDATE file_processing
        SET total_records = g_total_records,
            total_amount = g_total_amount,
            process_status = 'COMPLETED'
        WHERE file_id = p_file_id;

        DBMS_OUTPUT.PUT_LINE('Error logged for File ID: ' || p_file_id || ': ' || SQLERRM);

    EXCEPTION
    WHEN OTHERS THEN
        log_error(p_file_id, 'Error finalizing file processing: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Error logged for File ID: ' || p_file_id || ': ' || SQLERRM);

    END finalize_file_processing;

    -- **********************************************************************************
    -- PROCEDURE: log_error
    -- Description: Logs an error message into the database.
    -- **********************************************************************************
    PROCEDURE log_error(p_file_id IN NUMBER, p_error_message IN VARCHAR2) IS
    BEGIN
        UPDATE file_processing
        SET error_message = p_error_message,
            process_status = 'FAILED'
        WHERE file_id = p_file_id;

        DBMS_OUTPUT.PUT_LINE('Error logged for File ID: ' || p_file_id || ': ' || p_error_message);
    END log_error;

    -- **********************************************************************************
    -- PROCEDURE: archive_file
    -- Description: Archives a file after successful processing.
    -- **********************************************************************************
    PROCEDURE archive_file(p_file_name IN VARCHAR2) IS
        v_source_path VARCHAR2(255);
        v_target_path VARCHAR2(255);
    BEGIN
        v_source_path := get_config_value('FILE_DIRECTORY') || '/' || p_file_name;
        v_target_path := get_config_value('ARCHIVE_DIRECTORY') || '/' || p_file_name;
       
        -- Simulate file archiving
        DBMS_OUTPUT.PUT_LINE('Archiving file from ' || v_source_path || ' to ' || v_target_path);

    END archive_file;

    -- **********************************************************************************
    -- PROCEDURE: generate_report
    -- Description: Generates a report for a processed file.
    -- **********************************************************************************
    PROCEDURE generate_report(p_file_id IN NUMBER) IS
        v_total_records NUMBER;
        v_total_amount  NUMBER;
    BEGIN
        SELECT total_records, total_amount INTO v_total_records, v_total_amount
        FROM file_processing
        WHERE file_id = p_file_id;

        DBMS_OUTPUT.PUT_LINE('Report for File ID: ' || p_file_id);
        DBMS_OUTPUT.PUT_LINE('Total Records: ' || v_total_records);
        DBMS_OUTPUT.PUT_LINE('Total Amount: ' || v_total_amount);
    END generate_report;

    -- **********************************************************************************
    -- PROCEDURE: process_file
    -- Description: Main procedure to process a file.
    -- **********************************************************************************
    PROCEDURE process_file(p_file_name IN VARCHAR2) IS
        v_file_id NUMBER;
        v_record_data VARCHAR2(1000);
        v_record_count NUMBER := 0;
    BEGIN
        -- Initialize file processing
        initialize_file_processing(p_file_name);

        -- Get the file ID
        SELECT file_id INTO v_file_id
        FROM file_processing
        WHERE file_name = p_file_name;

        -- Simulate reading records from a file
        FOR i IN 1 .. TO_NUMBER(get_config_value('MAX_RECORDS')) LOOP
            v_record_data := 'Record_' || i;

            -- Process each record
            process_record(v_file_id, v_record_data);

            v_record_count := v_record_count + 1;

            -- Exit loop if maximum records are processed
            IF v_record_count >= TO_NUMBER(get_config_value('MAX_RECORDS')) THEN
                EXIT;
            END IF;
        END LOOP;

        -- Finalize file processing
        finalize_file_processing(v_file_id);

        -- Archive the file
        archive_file(p_file_name);

        -- Generate a report
        generate_report(v_file_id);
    EXCEPTION
        WHEN OTHERS THEN
            log_error(v_file_id, 'Error processing file: ' || SQLERRM);
    END process_file;

-- ********************************************************************************** 
    -- PRIVATE PROCEDURE: clean_up_temp_data 
    -- Description: Cleans up temporary data used during file processing. 
    -- ********************************************************************************** 
    PROCEDURE clean_up_temp_data IS 
    BEGIN 
        -- Simulate cleaning up temporary data 
        DBMS_OUTPUT.PUT_LINE('Cleaning up temporary data...'); 
        END clean_up_temp_data; 

    -- ********************************************************************************** 
    -- PRIVATE FUNCTION: calculate_average_amount 
    -- Description: Calculates the average amount per record. 
    -- ********************************************************************************** 
    FUNCTION calculate_average_amount RETURN NUMBER IS 
        v_average_amount NUMBER; 
    BEGIN 
        IF g_total_records > 0 THEN 
            v_average_amount := g_total_amount / g_total_records; 
        ELSE 
            v_average_amount := 0; 
        END IF; 

        RETURN v_average_amount; 
    END calculate_average_amount; 

    -- ********************************************************************************** 
CREATE OR REPLACE PROCEDURE process_bank_file(p_file_name IN VARCHAR2) IS
    v_file_id NUMBER;
    v_transaction bank_transaction_obj;
BEGIN
    -- Insert into temp_bank_files table
    INSERT INTO temp_bank_files9 (file_id, file_name, processed_date)
    VALUES (seq_file_id.NEXTVAL, p_file_name, SYSDATE)
    RETURNING file_id INTO v_file_id;

    -- Insert dummy transactions into temp_transactions table
    v_transaction := bank_transaction_obj(SEQ_TRANSACTION_ID.NEXTVAL, v_file_id, 500.75, 'PENDING');

    INSERT INTO temp_transactions (transaction_id, file_id, transaction_amount, transaction_status)
    VALUES (v_transaction.transaction_id, v_transaction.file_id, v_transaction.transaction_amount, v_transaction.transaction_status);

    -- Print confirmation
    DBMS_OUTPUT.PUT_LINE('File Processed: ' || p_file_name || ' | File ID: ' || v_file_id);
    DBMS_OUTPUT.PUT_LINE('Transaction Added: ' || v_transaction.transaction_id || ' | Amount: ' || v_transaction.transaction_amount);

END process_bank_file;
END file_management_pkg;
/


