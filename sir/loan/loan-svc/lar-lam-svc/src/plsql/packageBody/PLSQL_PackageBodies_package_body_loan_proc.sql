CREATE OR REPLACE PACKAGE BODY pkg_loan_proc AS

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
                    JOIN (SELECT pkg_loan_proc.gl_lar_96_typ_no lon_tp_nm FROM DUAL
                          UNION ALL
                          SELECT pkg_loan_proc.gl_lar_97_typ_no FROM DUAL) v
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

  ------------------------------------------------------------------------
  --Module     c_process_loan
  --Purpose    Main entry point to the batch. This procedure will be 
  --           called by the pkg_loan_proc_btch
  --
  --Parameters: n_batch_id, n_run_file_id, i_tran_id, i_cpl_dt
  ------------------------------------------------------------------------
  PROCEDURE c_process_loan(
    n_batch_id   IN NUMBER,
    n_run_file_id IN NUMBER,
    i_tran_id    IN NUMBER,
    i_cpl_dt     IN DATE
  ) IS
    v_err_tag_string VARCHAR2(50);
    l_tot_dist_lar_cnt gt_cnt := gt_cnt(0);
  BEGIN
    pkg_sir_log.p_set_tx_stepnme(i_tx_step_nme => 'Payment Sub-Process of Payment LAR Batch');
    pkg_sir_log.p_fine(io_ctx => gv_log_ctx, i_msg => v_err_tag_string || 'Start pkg_pmt_process_proxy.p_process_pmt');
    
    v_err_tag_string := TO_CHAR(n_batch_id) || ':' || TO_CHAR(n_run_file_id) || ':' || TO_CHAR(i_tran_id) || ':' || TO_CHAR(i_cpl_dt, 'mm-dd-yyyy');
    
    IF f_has_input_records() THEN
      -- Load SMSS SRC CD Global variable for traceability
      SELECT tran_smss_src_cd
      INTO pkg_pmt_lar_util.gv_tran_smss_src_cd
      FROM tmp_ln_pmt_lar
      WHERE ROWNUM < 2;
      
      -- Move records in a specific partition with specific transaction_id to servicing API table
      p_load_lar;
      
      -- Find the batch file name if there is one
      p_load_file_nme(i_batch_id => n_batch_id, i_run_file_id => n_run_file_id, i_tx_id => i_tran_id);
      
      -- Call the batch preprocess, for screening filter out and validation of LARs
      pkg_pmt_preprocess.p_pmt_preprocess(i_pcsg_dt => i_cpl_dt, i_batch_id => n_batch_id);
      
      -- Call the payment service API for performing the payment process
      pkg_sir_log.p_fine(io_ctx => gv_log_ctx, i_msg => 'Invoke the Payment Service');
      pkg_lar_pmt_srvc.p_process_payment(i_lpc_tran_pcsg_dt => i_cpl_dt, i_mode => pkg_lar_constant.C_PMT_BCH, i_batch_id => n_batch_id);
      
      pkg_rvsl_srvc.p_process_payment_rvsl(i_pcsg_dt => i_cpl_dt, i_batch_id => n_batch_id);
      
      -- Call API p_load_srvr_lar_trcy_dtl to load all the records from tmp_srvr_lar_trcy_dtl to srvr_lar_trcy
      pkg_srvr_lar_trcy_process.p_load_srvr_lar_trcy_dtl(i_bch_id => n_batch_id, i_tran_id => i_tran_id);
    END IF;
  END c_process_loan;

END pkg_loan_proc;
/