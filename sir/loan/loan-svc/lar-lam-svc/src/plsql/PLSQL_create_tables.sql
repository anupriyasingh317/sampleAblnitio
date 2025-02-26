-- PLSQL Script to create necessary tables
BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE raw_data (id NUMBER, data_value VARCHAR2(100))';
  EXECUTE IMMEDIATE 'CREATE TABLE processed_data (id NUMBER, processed_value VARCHAR2(100))';
  EXECUTE IMMEDIATE 'CREATE TABLE report (id NUMBER, report_value VARCHAR2(100))';
END;
/