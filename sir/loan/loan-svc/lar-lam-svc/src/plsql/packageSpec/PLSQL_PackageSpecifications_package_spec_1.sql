-- Example Package Specification Script
CREATE OR REPLACE PACKAGE my_package_spec_1 AS
  -- Declare public types, variables, and functions/procedures here
  FUNCTION get_data(p_id IN NUMBER) RETURN VARCHAR2;
END my_package_spec_1;
/