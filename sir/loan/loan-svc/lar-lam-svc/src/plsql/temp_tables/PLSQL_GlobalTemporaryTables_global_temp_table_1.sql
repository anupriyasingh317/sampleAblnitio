-- Example Global Temporary Table Script
CREATE GLOBAL TEMPORARY TABLE temp_table_1 (
  id NUMBER,
  data_value VARCHAR2(100)
) ON COMMIT DELETE ROWS;
/