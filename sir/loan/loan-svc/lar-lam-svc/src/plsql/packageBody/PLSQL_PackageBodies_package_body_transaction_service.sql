CREATE OR REPLACE PACKAGE BODY pkg_transaction_service AS

  ------------------------------------------------------------------------
  --Module     p_initialize_transaction_count
  --Purpose    Private procedure to initialize the transaction count.
  --
  --Parameters: None
  -------------------------------------------------------------------------
  PROCEDURE p_initialize_transaction_count IS
    v_total_transaction_count NUMBER;
  BEGIN
    -- Initialize the total transaction count
    SELECT COUNT(*) total_count
      INTO v_total_transaction_count
      FROM transactions;
    
    gv_current_transaction_count.count := v_total_transaction_count;
  END p_initialize_transaction_count;

  ------------------------------------------------------------------------
  --Module     c_handle_transaction
  --Purpose    Main entry point to handle transactions. This procedure will be 
  --           called by the batch process.
  --
  --Parameters: p_batch_id, p_file_id, p_tran_id, p_complete_dt
  ------------------------------------------------------------------------
  PROCEDURE c_handle_transaction(
    p_batch_id   IN NUMBER,
    p_file_id    IN NUMBER,
    p_tran_id    IN NUMBER,
    p_complete_dt IN DATE
  ) IS
    v_error_message VARCHAR2(50);
    l_total_transaction_count gt_transaction_count := gt_transaction_count(0);
  BEGIN
    pkg_log.p_set_step_name(i_step_name => 'Transaction Handling Process');
    pkg_log.p_info(io_context => gv_log_context, i_message => v_error_message || 'Start processing transaction');
    
    v_error_message := TO_CHAR(p_batch_id) || ':' || TO_CHAR(p_file_id) || ':' || TO_CHAR(p_tran_id) || ':' || TO_CHAR(p_complete_dt, 'mm-dd-yyyy');
    
    IF f_has_transaction_records() THEN
      -- Load transaction source code global variable
      SELECT transaction_source_code
      INTO pkg_transaction_util.gv_transaction_source_code
      FROM transactions
      WHERE ROWNUM < 2;
      
      -- Move records to the servicing table
      p_load_transactions;
      
      -- Load file name if available
      p_load_file_name(p_batch_id => p_batch_id, p_file_id => p_file_id, p_tran_id => p_tran_id);
      
      -- Call the preprocess for validation and filtering
      pkg_preprocess.p_preprocess_transactions(p_processing_date => p_complete_dt, p_batch_id => p_batch_id);
      
      -- Call the transaction service API for processing
      pkg_log.p_info(io_context => gv_log_context, i_message => 'Invoke the Transaction Service');
      pkg_transaction_service.p_process_transactions(p_processing_date => p_complete_dt, p_mode => 'BATCH', p_batch_id => p_batch_id);
      
      pkg_reversal_service.p_reverse_transactions(p_processing_date => p_complete_dt, p_batch_id => p_batch_id);
      
      -- Load records from temporary table to main table
      pkg_trace_process.p_load_transaction_trace(p_batch_id => p_batch_id, p_tran_id => p_tran_id);
    END IF;
  END c_handle_transaction;

END pkg_transaction_service;
/