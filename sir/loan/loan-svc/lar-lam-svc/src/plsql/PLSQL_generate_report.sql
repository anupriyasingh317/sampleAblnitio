-- PLSQL Script to generate a report from the processed_data table
BEGIN
  INSERT INTO report (id, report_value)
  SELECT id, processed_value || ' - Report' FROM processed_data;
  COMMIT;
END;
/