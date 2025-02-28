CREATE OR REPLACE PACKAGE pkg_customer_service AS
  -- Declare public constants
  gl_customer_type_A CONSTANT VARCHAR2(2) := 'A';
  gl_customer_type_B CONSTANT VARCHAR2(2) := 'B';

  -- Declare public types and variables
  TYPE gt_customer_count IS RECORD (
    count NUMBER
  );
  gv_current_customer_count gt_customer_count := gt_customer_count(0);

  -- Declare public procedures
  PROCEDURE p_initialize_customer_count;

  PROCEDURE c_handle_customer(
    p_batch_id   IN NUMBER,
    p_file_id    IN NUMBER,
    p_tran_id    IN NUMBER,
    p_complete_dt IN DATE
  );

END pkg_customer_service;
/