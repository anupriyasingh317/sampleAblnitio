CREATE OR REPLACE PACKAGE BODY pkg_example AS

  ------------------------------------------------------------------------
  --Module     p_trcy_initialize_cnt
  --Purpose    Private procedure to perform the trace count initialization.
  --
  --Parameters: None
  -------------------------------------------------------------------------
  PROCEDURE p_trcy_initialize_cnt IS
    v_tot_rec_cnt NUMBER;
  BEGIN
    -- Initialize the total record count
    SELECT SUM(CASE
                 WHEN tpl.ln_rptg_mthd_cd = 2 AND
                      pkg_pmt_lar_util.gv_tran_smss_src_cd <> 'UI' THEN
                   2
                 ELSE
                   1
               END) tot_rec
      INTO v_tot_rec_cnt
      FROM tmp_ln_pmt_lar tlpl,
           tmp_pmt_ln tpl
     WHERE tlpl.fncl_ast_id = tpl.fncl_ast_id;

    -- Start: Total count
    MERGE INTO tmp_srvr_lar_trcy_dtl tgt
      USING (SELECT v.lon_tp_nm       lon_tp_nm,
                    tlpl.selr_srvr_no selr_srvr_no,
                    COUNT(*)          rec_tot_cnt,
                    0                 rec_prcs_succ_cnt,
                    0                 rec_prcs_ign_cnt,
                    0                 rec_not_prcs_rej_cnt,
                    0                 rec_prcs_lqdn_cnt,
                    0                 rec_prcs_prpd_cnt,
                    0                 rec_prcs_dlqy_cnt,
                    0                 rec_prcs_curr_cnt
               FROM tmp_pmt_ln tpl
                    JOIN (SELECT pkg_example.gl_lar_96_typ_no lon_tp_nm FROM DUAL
                          UNION ALL
                          SELECT pkg_example.gl_lar_97_typ_no FROM DUAL) v
                      ON (tpl.ln_rptg_mthd_cd = 2)
              GROUP BY v.lon_tp_nm, tlpl.selr_srvr_no) src
         ON (tgt.lon_tp_nm = src.lon_tp_nm AND tgt.selr_srvr_no = src.selr_srvr_no)
     WHEN MATCHED THEN
       UPDATE SET tgt.rec_tot_cnt = src.rec_tot_cnt
     WHEN NOT MATCHED THEN
       INSERT (tgt.lon_tp_nm, tgt.selr_srvr_no, tgt.rec_tot_cnt, tgt.rec_prcs_succ_cnt,
               tgt.rec_prcs_ign_cnt, tgt.rec_not_prcs_rej_cnt, tgt.rec_prcs_lqdn_cnt,
               tgt.rec_prcs_prpd_cnt, tgt.rec_prcs_dlqy_cnt, tgt.rec_prcs_curr_cnt)
       VALUES (src.lon_tp_nm, src.selr_srvr_no, src.rec_tot_cnt, src.rec_prcs_succ_cnt,
               src.rec_prcs_ign_cnt, src.rec_not_prcs_rej_cnt, src.rec_prcs_lqdn_cnt,
               src.rec_prcs_prpd_cnt, src.rec_prcs_dlqy_cnt, src.rec_prcs_curr_cnt);

  END p_trcy_initialize_cnt;

END pkg_example;
/