CREATE OR REPLACE PACKAGE BODY pkg_account_service AS

  ------------------------------------------------------------------------
  --Module     p_initialize_account_count
  --Purpose    Private procedure to initialize the account count.
  --
  --Parameters: None
  -------------------------------------------------------------------------
  PROCEDURE p_initialize_account_count IS
    v_total_account_count NUMBER;
  BEGIN
    -- Initialize the total account count
    SELECT COUNT(*) total_count
      INTO v_total_account_count
      FROM accounts;
    
    gv_current_account_count.count := v_total_account_count;
  END p_initialize_account_count;

  ------------------------------------------------------------------------
  --Module     c_handle_account
  --Purpose    Main entry point to handle accounts. This procedure will be 
  --           called by the batch process.
  --
  --Parameters: p_batch_id, p_file_id, p_tran_id, p_complete_dt
  ------------------------------------------------------------------------
  PROCEDURE c_handle_account(
    p_batch_id   IN NUMBER,
    p_file_id    IN NUMBER,
    p_tran_id    IN NUMBER,
    p_complete_dt IN DATE
  ) IS
    v_error_message VARCHAR2(50);
    l_total_account_count gt_account_count := gt_account_count(0);
  BEGIN
    pkg_log.p_set_step_name(i_step_name => 'Account Handling Process');
    pkg_log.p_info(io_context => gv_log_context, i_message => v_error_message || 'Start processing account');
    
    v_error_message := TO_CHAR(p_batch_id) || ':' || TO_CHAR(p_file_id) || ':' || TO_CHAR(p_tran_id) || ':' || TO_CHAR(p_complete_dt, 'mm-dd-yyyy');
    
    IF f_has_account_records() THEN
      -- Load account source code global variable
      SELECT account_source_code
      INTO pkg_account_util.gv_account_source_code
      FROM accounts
      WHERE ROWNUM < 2;
      
      -- Move records to the servicing table
      p_load_accounts;
      
      -- Load file name if available
      p_load_file_name(p_batch_id => p_batch_id, p_file_id => p_file_id, p_tran_id => p_tran_id);
      
      -- Call the preprocess for validation and filtering
      pkg_preprocess.p_preprocess_accounts(p_processing_date => p_complete_dt, p_batch_id => p_batch_id);
      
      -- Call the account service API for processing
      pkg_log.p_info(io_context => gv_log_context, i_message => 'Invoke the Account Service');
      pkg_account_service.p_process_accounts(p_processing_date => p_complete_dt, p_mode => 'BATCH', p_batch_id => p_batch_id);
      
      pkg_reversal_service.p_reverse_accounts(p_processing_date => p_complete_dt, p_batch_id => p_batch_id);
      
      -- Load records from temporary table to main table
      pkg_trace_process.p_load_account_trace(p_batch_id => p_batch_id, p_tran_id => p_tran_id);
    END IF;
  END c_handle_account;

END pkg_account_service;
/