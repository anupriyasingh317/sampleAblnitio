CREATE OR REPLACE PACKAGE BODY pkg_customer_service AS

  ------------------------------------------------------------------------
  --Module     p_initialize_customer_count
  --Purpose    Private procedure to initialize the customer count.
  --
  --Parameters: None
  -------------------------------------------------------------------------
  PROCEDURE p_initialize_customer_count IS
    v_total_customer_count NUMBER;
  BEGIN
    -- Initialize the total customer count
    SELECT COUNT(*) total_count
      INTO v_total_customer_count
      FROM customers;
    
    gv_current_customer_count.count := v_total_customer_count;
  END p_initialize_customer_count;

  ------------------------------------------------------------------------
  --Module     c_handle_customer
  --Purpose    Main entry point to handle customers. This procedure will be 
  --           called by the batch process.
  --
  --Parameters: p_batch_id, p_file_id, p_tran_id, p_complete_dt
  ------------------------------------------------------------------------
  PROCEDURE c_handle_customer(
    p_batch_id   IN NUMBER,
    p_file_id    IN NUMBER,
    p_tran_id    IN NUMBER,
    p_complete_dt IN DATE
  ) IS
    v_error_message VARCHAR2(50);
    l_total_customer_count gt_customer_count := gt_customer_count(0);
  BEGIN
    pkg_log.p_set_step_name(i_step_name => 'Customer Handling Process');
    pkg_log.p_info(io_context => gv_log_context, i_message => v_error_message || 'Start processing customer');
    
    v_error_message := TO_CHAR(p_batch_id) || ':' || TO_CHAR(p_file_id) || ':' || TO_CHAR(p_tran_id) || ':' || TO_CHAR(p_complete_dt, 'mm-dd-yyyy');
    
    IF f_has_customer_records() THEN
      -- Load customer source code global variable
      SELECT customer_source_code
      INTO pkg_customer_util.gv_customer_source_code
      FROM customers
      WHERE ROWNUM < 2;
      
      -- Move records to the servicing table
      p_load_customers;
      
      -- Load file name if available
      p_load_file_name(p_batch_id => p_batch_id, p_file_id => p_file_id, p_tran_id => p_tran_id);
      
      -- Call the preprocess for validation and filtering
      pkg_preprocess.p_preprocess_customers(p_processing_date => p_complete_dt, p_batch_id => p_batch_id);
      
      -- Call the customer service API for processing
      pkg_log.p_info(io_context => gv_log_context, i_message => 'Invoke the Customer Service');
      pkg_customer_service.p_process_customers(p_processing_date => p_complete_dt, p_mode => 'BATCH', p_batch_id => p_batch_id);
      
      pkg_reversal_service.p_reverse_customers(p_processing_date => p_complete_dt, p_batch_id => p_batch_id);
      
      -- Load records from temporary table to main table
      pkg_trace_process.p_load_customer_trace(p_batch_id => p_batch_id, p_tran_id => p_tran_id);
    END IF;
  END c_handle_customer;

END pkg_customer_service;
/