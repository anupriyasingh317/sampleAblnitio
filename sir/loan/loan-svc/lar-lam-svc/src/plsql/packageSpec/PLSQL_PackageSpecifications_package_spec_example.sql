CREATE OR REPLACE PACKAGE pkg_example AS
  -- Declare public constants
  gl_lar_96_typ_no  CONSTANT VARCHAR2(2) := '96';
  gl_lar_97_typ_no  CONSTANT VARCHAR2(2) := '97';

  -- Declare public types and variables
  TYPE gt_cnt IS RECORD (
    cnt NUMBER
  );
  gv_nxt_cyl_lar_cnt gt_cnt := gt_cnt(0);

  -- Declare public procedures
  PROCEDURE p_trcy_initialize_cnt;
  
END pkg_example;
/