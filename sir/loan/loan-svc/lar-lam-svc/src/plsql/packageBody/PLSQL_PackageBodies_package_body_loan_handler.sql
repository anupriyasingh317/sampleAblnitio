CREATE OR REPLACE PACKAGE BODY pkg_loan_handler AS

  ------------------------------------------------------------------------
  --Module     p_initialize_loan_count
  --Purpose    Private procedure to initialize the loan count.
  --
  --Parameters: None
  -------------------------------------------------------------------------
  PROCEDURE p_initialize_loan_count IS
    v_total_loan_count NUMBER;
  BEGIN
    -- Initialize the total loan count
    SELECT COUNT(*) total_count
      INTO v_total_loan_count
      FROM loans;
    
    gv_current_loan_count.count := v_total_loan_count;
  END p_initialize_loan_count;

  ------------------------------------------------------------------------
  --Module     c_handle_loan
  --Purpose    Main entry point to handle loans. This procedure will be 
  --           called by the batch process.
  --
  --Parameters: p_batch_id, p_file_id, p_tran_id, p_complete_dt
  ------------------------------------------------------------------------
  PROCEDURE c_handle_loan(
    p_batch_id   IN NUMBER,
    p_file_id    IN NUMBER,
    p_tran_id    IN NUMBER,
    p_complete_dt IN DATE
  ) IS
    v_error_message VARCHAR2(50);
    l_total_loan_count gt_count := gt_count(0);
  BEGIN
    pkg_log.p_set_step_name(i_step_name => 'Loan Handling Process');
    pkg_log.p_info(io_context => gv_log_context, i_message => v_error_message || 'Start processing loan');
    
    v_error_message := TO_CHAR(p_batch_id) || ':' || TO_CHAR(p_file_id) || ':' || TO_CHAR(p_tran_id) || ':' || TO_CHAR(p_complete_dt, 'mm-dd-yyyy');
    
    IF f_has_loan_records() THEN
      -- Load loan source code global variable
      SELECT loan_source_code
      INTO pkg_loan_util.gv_loan_source_code
      FROM loans
      WHERE ROWNUM < 2;
      
      -- Move records to the servicing table
      p_load_loans;
      
      -- Load file name if available
      p_load_file_name(p_batch_id => p_batch_id, p_file_id => p_file_id, p_tran_id => p_tran_id);
      
      -- Call the preprocess for validation and filtering
      pkg_preprocess.p_preprocess_loans(p_processing_date => p_complete_dt, p_batch_id => p_batch_id);
      
      -- Call the loan service API for processing
      pkg_log.p_info(io_context => gv_log_context, i_message => 'Invoke the Loan Service');
      pkg_loan_service.p_process_loans(p_processing_date => p_complete_dt, p_mode => 'BATCH', p_batch_id => p_batch_id);
      
      pkg_reversal_service.p_reverse_loans(p_processing_date => p_complete_dt, p_batch_id => p_batch_id);
      
      -- Load records from temporary table to main table
      pkg_trace_process.p_load_loan_trace(p_batch_id => p_batch_id, p_tran_id => p_tran_id);
    END IF;
  END c_handle_loan;

END pkg_loan_handler;
/