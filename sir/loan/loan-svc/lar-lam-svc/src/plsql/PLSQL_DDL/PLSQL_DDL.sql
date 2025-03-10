-- **********************************************************************************
-- DDL Script: Create Tables, Sequences, and Constraints
-- **********************************************************************************

-- Create a table for storing file processing details
CREATE TABLE file_processing (
    file_id          NUMBER PRIMARY KEY,
    file_name        VARCHAR2(255) NOT NULL,
    process_date     DATE DEFAULT SYSDATE,
    total_records    NUMBER DEFAULT 0,
    total_amount     NUMBER DEFAULT 0,
    process_status   VARCHAR2(20) DEFAULT 'PENDING',
    error_message    VARCHAR2(4000)
);

-- Create a table for storing processed records
CREATE TABLE processed_records (
    record_id        NUMBER PRIMARY KEY,
    file_id          NUMBER REFERENCES file_processing(file_id),
    record_data      VARCHAR2(1000),
    record_status    VARCHAR2(20) DEFAULT 'SUCCESS',
    error_message    VARCHAR2(4000)
);

-- Create a sequence for file IDs
CREATE SEQUENCE seq_file_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

-- Create a sequence for record IDs
CREATE SEQUENCE seq_record_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

-- temp_table_bank_files

-- Parent Table (Temp Bank Files)

CREATE GLOBAL TEMPORARY TABLE temp_bank_files (
    file_id NUMBER PRIMARY KEY,
    file_name VARCHAR2(255),
    processed_date DATE
) ON COMMIT PRESERVE ROWS;


-- Child Table (Temp Transactions)

CREATE GLOBAL TEMPORARY TABLE temp_transactions (
    transaction_id NUMBER PRIMARY KEY,
    file_id NUMBER,
    transaction_amount NUMBER(10,2),
    transaction_status VARCHAR2(20)
) ON COMMIT PRESERVE ROWS;

--object
CREATE OR REPLACE TYPE bank_transaction_obj AS OBJECT (
    transaction_id NUMBER,
    file_id NUMBER,
    transaction_amount NUMBER(10,2),
    transaction_status VARCHAR2(20)
);

--
CREATE SEQUENCE SEQ_TRANSACTION_ID
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- **********************************************************************************
-- End of DDL Script
-- *****************************



