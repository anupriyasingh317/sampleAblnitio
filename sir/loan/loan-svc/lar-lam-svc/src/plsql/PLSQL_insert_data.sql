-- PLSQL Script to insert data into the processed_data table
BEGIN
  INSERT INTO processed_data (id, processed_value)
  VALUES (1, 'Processed Data Example');
  COMMIT;
END;
/