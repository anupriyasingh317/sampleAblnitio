-- Example Package Body Script
CREATE OR REPLACE PACKAGE BODY my_package_spec_1 AS
  -- Implement the functions/procedures declared in the package specification
  FUNCTION get_data(p_id IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN 'Data for ID: ' || p_id;
  END get_data;
END my_package_spec_1;
/