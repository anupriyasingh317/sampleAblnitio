CREATE OR REPLACE PACKAGE pkg_account_service AS
  -- Declare public constants
  gl_account_type_X CONSTANT VARCHAR2(2) := 'X';
  gl_account_type_Y CONSTANT VARCHAR2(2) := 'Y';

  -- Declare public types and variables
  TYPE gt_account_count IS RECORD (
    count NUMBER
  );
  gv_current_account_count gt_account_count := gt_account_count(0);

  -- Declare public procedures
  PROCEDURE p_initialize_account_count;

  PROCEDURE c_handle_account(
    p_batch_id   IN NUMBER,
    p_file_id    IN NUMBER,
    p_tran_id    IN NUMBER,
    p_complete_dt IN DATE
  );

END pkg_account_service;
/