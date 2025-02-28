CREATE OR REPLACE PACKAGE pkg_loan_handler AS
  -- Declare public constants
  gl_loan_type_01 CONSTANT VARCHAR2(2) := '01';
  gl_loan_type_02 CONSTANT VARCHAR2(2) := '02';

  -- Declare public types and variables
  TYPE gt_count IS RECORD (
    count NUMBER
  );
  gv_current_loan_count gt_count := gt_count(0);

  -- Declare public procedures
  PROCEDURE p_initialize_loan_count;

  PROCEDURE c_handle_loan(
    p_batch_id   IN NUMBER,
    p_file_id    IN NUMBER,
    p_tran_id    IN NUMBER,
    p_complete_dt IN DATE
  );

END pkg_loan_handler;
/