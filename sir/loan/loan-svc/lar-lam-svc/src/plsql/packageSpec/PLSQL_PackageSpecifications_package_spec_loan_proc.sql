CREATE OR REPLACE PACKAGE pkg_loan_proc AS
  -- Declare public constants
  gl_lar_96_typ_no CONSTANT VARCHAR2(2) := '96';
  gl_lar_97_typ_no CONSTANT VARCHAR2(2) := '97';

  -- Declare public types and variables
  TYPE gt_cnt IS RECORD (
    cnt NUMBER
  );
  gv_nxt_cyl_lar_cnt gt_cnt := gt_cnt(0);

  -- Declare public procedures
  PROCEDURE c_process_loan(
    n_batch_id   IN NUMBER,
    n_run_file_id IN NUMBER,
    i_tran_id    IN NUMBER,
    i_cpl_dt     IN DATE
  );

  PROCEDURE p_trcy_initialize_cnt;

END pkg_loan_proc;
/