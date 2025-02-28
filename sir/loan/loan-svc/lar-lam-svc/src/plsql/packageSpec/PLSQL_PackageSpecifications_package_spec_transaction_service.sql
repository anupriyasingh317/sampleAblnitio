CREATE OR REPLACE PACKAGE pkg_transaction_service AS
  -- Declare public constants
  gl_transaction_type_A CONSTANT VARCHAR2(2) := 'A';
  gl_transaction_type_B CONSTANT VARCHAR2(2) := 'B';

  -- Declare public types and variables
  TYPE gt_transaction_count IS RECORD (
    count NUMBER
  );
  gv_current_transaction_count gt_transaction_count := gt_transaction_count(0);

  -- Declare public procedures
  PROCEDURE p_initialize_transaction_count;

  PROCEDURE c_handle_transaction(
    p_batch_id   IN NUMBER,
    p_file_id    IN NUMBER,
    p_tran_id    IN NUMBER,
    p_complete_dt IN DATE
  );

END pkg_transaction_service;
/