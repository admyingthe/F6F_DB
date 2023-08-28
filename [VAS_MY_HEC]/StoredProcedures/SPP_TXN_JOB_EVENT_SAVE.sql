SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                
-- =====================================================================================                
-- Author:  Siow Shen Yee                
-- Create date: 2018-07-13                
-- Description: Save Job events                
-- Example Query: exec SPP_TXN_JOB_EVENT_SAVE @submit_obj=N'{"job_ref_no":"S2021/11/0001","search":"Search","job_ref_wo_no":"S2021/11/0001","work_ord_ref":"BYRON ORIGINS/Meditree/BANANA1/May 20 2024 12:00AM","work_ord_status":"In Process","add":"Add","export":"Export","complete":"Complete","job_event":"20","start_date":"2021-11-14 20:22:26","issued_qty":"","email":"","email_photos":"","remarks":"","completed_qty":"","save":"Save","damaged_qty":"","guid":"5a57623d-da02-4524-8ece-f552af42938b"}',@user_id=N'1'      --exec SPP_TXN_JOB_EVENT_SAVE @submit_obj=N'{"job_ref_no":"2018/07/0018","search":"Search","job_ref_wo_no":"2018/07/0018","work_ord_ref":"NOVARTIS/F/LOOK/TEST3-C/2025-02-03","work_ord_status":"In Process","add":"Add","export":"Export","complete":"Close Job","job_event":"60","start_date":"2021-03-23 09:26:47","original_qty":"500","qa_qty":"500","email":"shen.yee.siow@dksh.com","inbound_damaged_qty":"","save":"Save","issued_qty":"500","remarks":"","completed_qty":"","damaged_qty":"","on_hold_job":"On Hold Job","release_job":"Release Job","cancel_job":"Cancel Job","on_hold_reason":"","on_hold_remarks":"","on_hold_confirm":"Confirm","ques_a":"N","ques_b":"N","ques_c":"N","ques_d":"N","internal_qa_completed_qty":"","internal_qa_required":"1","guid":"36f1e980-b87f-49b8-b201-0e62327fbe63"}',@user_id=N'1'                
-- =====================================================================================                
                
CREATE PROCEDURE [dbo].[SPP_TXN_JOB_EVENT_SAVE]                
 @submit_obj NVARCHAR(MAX),                
 @user_id INT                
AS                
BEGIN                
 SET NOCOUNT ON;                
                
 BEGIN TRY                
                
 DECLARE @event_id INT, @job_ref_no VARCHAR(50), @start_date VARCHAR(50), @issued_qty INT, @remarks NVARCHAR(500),                
 @qa_qty INT, @email NVARCHAR(500), @completed_qty INT, @damaged_qty INT, @guid VARCHAR(500), @internal_qa_completed_qty INT,                
 @original_qty INT, @inbound_damaged_qty INT, @job_type char(1), @su_no varchar(100),@new_su_no varchar(100),@vas_order varchar (100)
                
 SET @event_id = (SELECT JSON_VALUE(@submit_obj, '$.job_event'))                
 SET @job_ref_no = (SELECT JSON_VALUE(@submit_obj, '$.job_ref_no'))                
 SET @job_type = left(@job_ref_no, 1)
 SET @start_date = (SELECT JSON_VALUE(@submit_obj, '$.start_date'))                
 SET @issued_qty = (SELECT JSON_VALUE(@submit_obj, '$.issued_qty'))                
 SET @original_qty = (SELECT JSON_VALUE(@submit_obj, '$.original_qty'))                
 SET @inbound_damaged_qty = (SELECT JSON_VALUE(@submit_obj, '$.inbound_damaged_qty'))                
 SET @remarks = (SELECT JSON_VALUE(@submit_obj, '$.remarks'))                
                
 EXEC REPLACE_SPECIAL_CHARACTER @remarks, @remarks OUTPUT                
                
 SET @qa_qty = (SELECT JSON_VALUE(@submit_obj, '$.qa_qty'))                
 SET @email = (SELECT JSON_VALUE(@submit_obj, '$.email'))                
 SET @completed_qty = (SELECT JSON_VALUE(@submit_obj, '$.completed_qty'))                
 SET @damaged_qty = (SELECT JSON_VALUE(@submit_obj, '$.damaged_qty'))                
 SET @guid = (SELECT JSON_VALUE(@submit_obj, '$.guid'))                
 SET @internal_qa_completed_qty = (SELECT JSON_VALUE(@submit_obj, '$.internal_qa_completed_qty'))                
                  
 -- To get the value of TOTAL QUANTITY from MPO to compare with completed quantity input by user                
 DECLARE @ttl_qty_eaches INT                
 SET @ttl_qty_eaches = (SELECT ttl_qty_eaches FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)                
 -----------------------------------------------------------------------------------------------------------------                
                
 -- Check if same event had been added before (except --                
 -- IF (SELECT COUNT(*) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND event_id = @event_id AND event_id NOT IN ('40','50','60')) >= 1                
 IF (SELECT COUNT(*) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND event_id = @event_id AND event_id NOT IN (SELECT event_id FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK) WHERE to_show_after_event = 'Y' and wo_type_id = @job_type)) >= 1              
 BEGIN                
  SELECT 'Y' as duplicate                
 END                
 ELSE                
 BEGIN                
  -------------------------------------------------------------------------------------------------------------------                
  -- To get previous running no, search in TBL_TXN_WORK_ORDER_ACTION_LOG                
  -- If found, calculate the time between release date and on hold date                
  -- Calculated time will be inserted into on_hold_time in TBL_TXN_JOB_EVENT of the newly created event                
  DECLARE @last_running_no VARCHAR(10), @total_time_taken_in_sec INT                
  SET @last_running_no = (SELECT MAX(running_no) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)                
                
  IF (SELECT COUNT(*) FROM TBL_TXN_WORK_ORDER_ACTION_LOG WITH(NOLOCK) WHERE current_running_no = @last_running_no) > 0                
  BEGIN                
   SET @total_time_taken_in_sec = (SELECT SUM(dbo.TotalOnHold(on_hold_date, released_date)) FROM TBL_TXN_WORK_ORDER_ACTION_LOG WITH(NOLOCK) WHERE current_running_no = @last_running_no)  --(SELECT SUM(DATEDIFF(s, on_hold_date, released_date)) FROM TBL_TXN_WORK_ORDER_ACTION_LOG WITH(NOLOCK) WHERE current_running_no = @last_running_no)                
  END                
  -------------------------------------------------------------------------------------------------------------------                
                
  DECLARE @running_no VARCHAR(50) = 1, @len INT = 8                
  SELECT TOP 1 @running_no = CAST(CAST(RIGHT(running_no, @len) as INT) + 1 AS VARCHAR(50))                
         FROM (SELECT running_no FROM TBL_TXN_JOB_EVENT WITH(NOLOCK)) A ORDER BY CAST(RIGHT(running_no, @len) AS INT) DESC                
  SET @running_no = 'MY' + REPLICATE('0', @len - LEN(@running_no)) + @running_no                
           
  IF @event_id = '20' --Request for stock                
  BEGIN                
   --1. Insert into txn table                
   INSERT INTO TBL_TXN_JOB_EVENT                
   (running_no, job_ref_no, event_id, start_date, end_date, issued_qty, damaged_qty, remarks, on_hold_time, created_date, creator_user_id)                
   SELECT @running_no, @job_ref_no, @event_id, CONVERT(varchar(23), REPLACE(@start_date, 'T', ' '), 121), GETDATE(), @issued_qty, @inbound_damaged_qty, @remarks, @total_time_taken_in_sec, GETDATE(), @user_id                
                
   --2. Insert into sap integration table                
    IF(LEFT(@job_ref_no,1) = 'S')              
   BEGIN              
    --   INSERT INTO VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER_SAP                
    --(country_code, process_ind, vas_order, whs_no, workorder_no, requirement_no, qty,                 
    --prd_code, uom, plant, sloc, batch_no, movement_type, stock_category, created_date, created_by, status, ssto_unit_no,  ssto_section, ssto_stg_bin)                
    --SELECT TOP 1 'MY', 'A', vas_order, whs_no, work_ord_ref, running_no, issued_qty,                
    --prd_code, uom, plant, sloc, batch_no, '999', stock_category, GETDATE(), @user_id, 'P', dsto_unit_no, dsto_section, dsto_stg_bin                
    --FROM TBL_TXN_JOB_EVENT A WITH(NOLOCK)                
    --INNER JOIN TBL_Subcon_TXN_WORK_ORDER B WITH(NOLOCK) ON A.job_ref_no = B.job_ref_no                
    --WHERE running_no = @running_no               
              
    UPDATE TBL_Subcon_TXN_WORK_ORDER                
    SET qty_of_goods = @issued_qty                
    WHERE job_ref_no = @job_ref_no                
          
 UPDATE TBL_Subcon_TXN_WORK_ORDER                
    SET current_event = @event_id                
    WHERE job_ref_no = @job_ref_no           
           
   END              
   ELSE IF(LEFT(@job_ref_no,1) = 'P')              
   BEGIN                  
    UPDATE TBL_SIA_TXN_WORK_ORDER                
    SET qty_of_goods = @issued_qty                
    WHERE job_ref_no = @job_ref_no                
          
	UPDATE TBL_SIA_TXN_WORK_ORDER                
    SET current_event = @event_id                
    WHERE job_ref_no = @job_ref_no           
           
   END
   ELSE IF(LEFT(@job_ref_no,1) = 'C')              
   BEGIN                  
		UPDATE TBL_INVOICE_TXN_WORK_ORDER                
		SET qty_of_goods = @issued_qty                
		WHERE job_ref_no = @job_ref_no                
          
		UPDATE TBL_INVOICE_TXN_WORK_ORDER                
		SET current_event = @event_id                
		WHERE job_ref_no = @job_ref_no                      
   END              
   ELSE              
   BEGIN              
	SET @su_no = (SELECT su_no FROM VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER WHERE workorder_no = (select top 1 job_ref_no from TBL_TXN_JOB_EVENT where running_no = @running_no ))

    INSERT INTO VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER_SAP                
    (country_code, process_ind, vas_order, whs_no, workorder_no, requirement_no, qty,                 
    prd_code, uom, plant, sloc, batch_no, movement_type, stock_category, created_date, created_by, status, ssto_unit_no,  ssto_section, ssto_stg_bin, su_no, su_ind)                
    SELECT TOP 1 'MY', 'A', vas_order, whs_no, work_ord_ref, running_no, issued_qty,                
    prd_code, uom, plant, sloc, batch_no, '999', stock_category, GETDATE(), @user_id, 'P', dsto_unit_no, dsto_section, dsto_stg_bin, @su_no,
	--26/06/2023 Added by CHOI CHEE KIEN: If damage qty > 0 set su_ind as Y else N
	CASE WHEN A.damaged_qty > 0 THEN 'Y' ELSE 'N' END
    FROM TBL_TXN_JOB_EVENT A WITH(NOLOCK)                
    INNER JOIN TBL_TXN_WORK_ORDER B WITH(NOLOCK) ON A.job_ref_no = B.job_ref_no                
    WHERE running_no = @running_no               
                  
    UPDATE TBL_TXN_WORK_ORDER                
    SET qty_of_goods = @issued_qty--, current_event = @event_id
    WHERE job_ref_no = @job_ref_no 

   END              
                
                
   --3. Insert into TBL_TMP_SAP_ORDER table                
   INSERT INTO TBL_TMP_SAP_ORDER                
   (running_no, created_date, creator_user_id)                
   VALUES (@running_no, GETDATE(), @user_id)                
                
                 
  END           
  ELSE IF @event_id = '25' --Confirm Stock
  BEGIN 
	IF(LEFT(@job_ref_no,1) = 'S')
	BEGIN         
		UPDATE TBL_Subcon_TXN_WORK_ORDER          
		SET current_event = @event_id          
		Where job_ref_no = @job_ref_no          
	END
	ELSE IF(LEFT(@job_ref_no,1) = 'P')
	BEGIN         
		UPDATE TBL_SIA_TXN_WORK_ORDER          
		SET current_event = @event_id          
		Where job_ref_no = @job_ref_no          
	END
	ELSE IF(LEFT(@job_ref_no,1) = 'C')
	BEGIN         
		UPDATE TBL_INVOICE_TXN_WORK_ORDER          
		SET current_event = @event_id          
		Where job_ref_no = @job_ref_no          
	END          
    INSERT INTO TBL_TXN_JOB_EVENT                
   (running_no, job_ref_no, event_id, start_date, end_date, issued_qty, remarks, on_hold_time, created_date, creator_user_id)                
   SELECT @running_no, @job_ref_no, @event_id, CONVERT(varchar(23), REPLACE(@start_date, 'T', ' '), 121), GETDATE(), @issued_qty, @remarks, @total_time_taken_in_sec, GETDATE(), @user_id                
             
  END          
          
  ELSE IF @event_id = '30' --Mock sample                
  BEGIN                
   DECLARE @ques_a CHAR(1), @ques_b CHAR(1), @ques_c CHAR(1), @ques_d CHAR(1)                
   SET @ques_a = (SELECT JSON_VALUE(@submit_obj, '$.ques_a'))                
   SET @ques_b = (SELECT JSON_VALUE(@submit_obj, '$.ques_b'))                
   SET @ques_c = (SELECT JSON_VALUE(@submit_obj, '$.ques_c'))                
   SET @ques_d = (SELECT JSON_VALUE(@submit_obj, '$.ques_d'))                
                
   --1. Insert into txn table                
   INSERT INTO TBL_TXN_JOB_EVENT                
   (running_no, job_ref_no, event_id, start_date, end_date, issued_qty, remarks, on_hold_time, created_date, creator_user_id)                
   SELECT @running_no, @job_ref_no, @event_id, CONVERT(varchar(23), REPLACE(@start_date, 'T', ' '), 121), GETDATE(), @issued_qty, @remarks, @total_time_taken_in_sec, GETDATE(), @user_id                
           
   IF(LEFT(@job_ref_no,1) = 'S')            
   BEGIN        
		UPDATE TBL_Subcon_TXN_WORK_ORDER                
		SET ques_a = @ques_a,                 
		ques_b = @ques_b,                
		ques_c = @ques_c,                
		ques_d = @ques_d                
		WHERE job_ref_no = @job_ref_no          
        
		UPDATE TBL_Subcon_TXN_WORK_ORDER          
		SET current_event = @event_id          
		Where job_ref_no = @job_ref_no          
	END        
	ELSE IF(LEFT(@job_ref_no,1) = 'P')            
	BEGIN        
		UPDATE TBL_SIA_TXN_WORK_ORDER                
		SET ques_a = @ques_a,                 
		ques_b = @ques_b,                
		ques_c = @ques_c,                
		ques_d = @ques_d                
		WHERE job_ref_no = @job_ref_no          
        
		UPDATE TBL_SIA_TXN_WORK_ORDER          
		SET current_event = @event_id          
		Where job_ref_no = @job_ref_no          
	END
	ELSE IF(LEFT(@job_ref_no,1) = 'C')            
	BEGIN        
		UPDATE TBL_INVOICE_TXN_WORK_ORDER                
		SET ques_a = @ques_a,                 
		ques_b = @ques_b,                
		ques_c = @ques_c,                
		ques_d = @ques_d                
		WHERE job_ref_no = @job_ref_no          
        
		UPDATE TBL_INVOICE_TXN_WORK_ORDER          
		SET current_event = @event_id          
		Where job_ref_no = @job_ref_no          
	END
	ELSE        
		BEGIN        
			UPDATE TBL_TXN_WORK_ORDER                
			SET ques_a = @ques_a,                 
			ques_b = @ques_b,                
			ques_c = @ques_c,                
			ques_d = @ques_d                
			WHERE job_ref_no = @job_ref_no           
		END                      
	END                
  ELSE IF @event_id = '40' --VAS                
  BEGIN                
   --1. Insert into txn table                
   INSERT INTO TBL_TXN_JOB_EVENT                
   (running_no, job_ref_no, event_id, start_date, end_date, issued_qty, remarks, on_hold_time, created_date, creator_user_id)                
   SELECT @running_no, @job_ref_no, @event_id, CONVERT(varchar(23), REPLACE(@start_date, 'T', ' '), 121), GETDATE(), @issued_qty, @remarks, @total_time_taken_in_sec, GETDATE(), @user_id                
               
    DECLARE @mll_mo VARCHAR(50), @subcon_wi_no VARCHAR(50), @prd_code VARCHAR(50), @qa_required INT             
            
   IF(LEFT(@job_ref_no,1) = 'S')            
   BEGIN            
    UPDATE TBL_Subcon_TXN_WORK_ORDER                
    SET completion_date = GETDATE(),                
  num_of_days_to_complete = (SELECT top 1 CASE WHEN DATEDIFF(day, commencement_date, completion_date) = 0 THEN 1 ELSE DATEDIFF(day, commencement_date, completion_date) END FROM TBL_Subcon_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)              
  
    WHERE job_ref_no = @job_ref_no            
                   
  SELECT @subcon_wi_no = subcon_WI_no, @prd_code = prd_code FROM TBL_Subcon_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no                
  SET @qa_required = (SELECT qa_required FROM TBL_MST_MLL_DTL WITH(NOLOCK) WHERE mll_no = @subcon_wi_no AND prd_code = @prd_code)                
                
  UPDATE TBL_Subcon_TXN_WORK_ORDER                
  SET qa_required = @qa_required                
  WHERE job_ref_no = @job_ref_no            
              
   END            
	ELSE IF(LEFT(@job_ref_no,1) = 'P')            
	BEGIN            
		UPDATE TBL_SIA_TXN_WORK_ORDER                
		SET completion_date = GETDATE(),                
		num_of_days_to_complete = (SELECT CASE WHEN DATEDIFF(day, commencement_date, completion_date) = 0 THEN 1 ELSE DATEDIFF(day, commencement_date, completion_date) END FROM TBL_SIA_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)                
		WHERE job_ref_no = @job_ref_no            
          
		SELECT @mll_mo = mll_no, @prd_code = prd_code FROM TBL_SIA_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no                
		SET @qa_required = (SELECT qa_required FROM TBL_MST_MLL_DTL WITH(NOLOCK) WHERE mll_no = @mll_mo AND prd_code = @prd_code)                
                
		UPDATE TBL_SIA_TXN_WORK_ORDER                
		SET qa_required = @qa_required                
		WHERE job_ref_no = @job_ref_no              
	END            
	ELSE IF(LEFT(@job_ref_no,1) = 'C')            
	BEGIN            
		UPDATE TBL_INVOICE_TXN_WORK_ORDER                
		SET completion_date = GETDATE(),                
		num_of_days_to_complete = (SELECT CASE WHEN DATEDIFF(day, commencement_date, completion_date) = 0 THEN 1 ELSE DATEDIFF(day, commencement_date, completion_date) END FROM TBL_INVOICE_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)                
		WHERE job_ref_no = @job_ref_no            
          
		SELECT @mll_mo = mll_no, @prd_code = prd_code FROM TBL_INVOICE_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no                
		SET @qa_required = (SELECT qa_required FROM TBL_MST_MLL_DTL WITH(NOLOCK) WHERE mll_no = @mll_mo AND prd_code = @prd_code)                
                
		UPDATE TBL_INVOICE_TXN_WORK_ORDER                
		SET qa_required = @qa_required                
		WHERE job_ref_no = @job_ref_no              
	END   
   ELSE            
   BEGIN            
    UPDATE TBL_TXN_WORK_ORDER                
    SET completion_date = GETDATE(),                
  num_of_days_to_complete = (SELECT CASE WHEN DATEDIFF(day, commencement_date, completion_date) = 0 THEN 1 ELSE DATEDIFF(day, commencement_date, completion_date) END FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)                
    WHERE job_ref_no = @job_ref_no            
          
  SELECT @mll_mo = mll_no, @prd_code = prd_code FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no                
  SET @qa_required = (SELECT qa_required FROM TBL_MST_MLL_DTL WITH(NOLOCK) WHERE mll_no = @mll_mo AND prd_code = @prd_code)                
                
  UPDATE TBL_TXN_WORK_ORDER                
  SET qa_required = @qa_required                
  WHERE job_ref_no = @job_ref_no            
            
 END            
                
   /** To check whether QA is required or not **/                
   --SELECT TOP 1 @running_no = CAST(CAST(RIGHT(running_no, @len) as INT) + 1 AS VARCHAR(50))                
   --      FROM (SELECT running_no FROM TBL_TXN_JOB_EVENT WITH(NOLOCK)) A ORDER BY CAST(RIGHT(running_no, @len) AS INT) DESC                
   --SET @running_no = 'MY' + REPLICATE('0', @len - LEN(@running_no)) + @running_no                
                
                  
                   
   --IF @qa_required = 0 -- QA is not required, system to auto insert                
   --BEGIN                
   -- SET @event_id = '50'                
                
   -- INSERT INTO TBL_TXN_JOB_EVENT                
   -- (running_no, job_ref_no, event_id, start_date, end_date, issued_qty, completed_qty, remarks, on_hold_time, created_date, creator_user_id)                
   -- SELECT @running_no, @job_ref_no, @event_id, CONVERT(varchar(23), REPLACE(GETDATE(), 'T', ' '), 121), GETDATE(), @issued_qty, @internal_qa_completed_qty, 'System Auto - QA is set to not required', @total_time_taken_in_sec, GETDATE(), '0'             
  
   
                
   -- DECLARE @com_qty_1 INT                
   -- SET @com_qty_1 = (SELECT ISNULL(SUM(completed_qty),0) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND event_id = '50')                
                
   -- UPDATE TBL_TXN_WORK_ORDER                
   -- SET qty_of_goods = @com_qty_1                
   -- WHERE job_ref_no = @job_ref_no                
   --END                
   /** To check whether QA is required or not **/           
                
  END                
  ELSE IF @event_id = '50' --QA Final Release                
  BEGIN                
   --1. Insert into txn table                
   INSERT INTO TBL_TXN_JOB_EVENT                
   (running_no, job_ref_no, event_id, start_date, end_date, issued_qty, completed_qty, remarks, on_hold_time, created_date, creator_user_id)                
   SELECT @running_no, @job_ref_no, @event_id, CONVERT(varchar(23), REPLACE(@start_date, 'T', ' '), 121), GETDATE(), @issued_qty, @internal_qa_completed_qty, @remarks, @total_time_taken_in_sec, GETDATE(), @user_id                
                
   DECLARE @com_qty INT                
   SET @com_qty = (SELECT ISNULL(SUM(completed_qty),0) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND event_id = '50')                
   IF(LEFT(@job_ref_no,1) = 'S')            
   BEGIN 
		UPDATE TBL_Subcon_TXN_WORK_ORDER                
		SET qty_of_goods = @internal_qa_completed_qty                
		WHERE job_ref_no = @job_ref_no        
   end
   ELSE IF(LEFT(@job_ref_no,1) = 'P')            
   BEGIN 
		UPDATE TBL_SIA_TXN_WORK_ORDER                
		SET qty_of_goods = @internal_qa_completed_qty                
		WHERE job_ref_no = @job_ref_no        
   END
   ELSE IF(LEFT(@job_ref_no,1) = 'C')            
   BEGIN 
		UPDATE TBL_INVOICE_TXN_WORK_ORDER                
		SET qty_of_goods = @internal_qa_completed_qty                
		WHERE job_ref_no = @job_ref_no        
   END
   else 
   begin
		UPDATE TBL_TXN_WORK_ORDER                
		SET qty_of_goods = @com_qty                
		WHERE job_ref_no = @job_ref_no     
   end           
  END        
  ELSE IF @event_id = '60' --Trigger email to client QA                
  BEGIN                
   --1. Insert into txn table                
   INSERT INTO TBL_TXN_JOB_EVENT                
   (running_no, job_ref_no, event_id, start_date, end_date, issued_qty, completed_qty, remarks, on_hold_time, created_date, creator_user_id)                
   SELECT @running_no, @job_ref_no, @event_id, CONVERT(varchar(23), REPLACE(@start_date, 'T', ' '), 121), GETDATE(), @issued_qty, @qa_qty, @remarks, @total_time_taken_in_sec, GETDATE(), @user_id                
                
   UPDATE TBL_TXN_WORK_ORDER                
   SET qty_of_goods = @internal_qa_completed_qty                
   WHERE job_ref_no = @job_ref_no   
   
      IF(LEFT(@job_ref_no,1) = 'S')            
   BEGIN 
		UPDATE TBL_Subcon_TXN_WORK_ORDER                
		SET qty_of_goods = @qa_qty                
		WHERE job_ref_no = @job_ref_no        
   end
   ELSE IF(LEFT(@job_ref_no,1) = 'P')            
   BEGIN 
		UPDATE TBL_SIA_TXN_WORK_ORDER                
		SET qty_of_goods = @internal_qa_completed_qty                
		WHERE job_ref_no = @job_ref_no        
   END
   ELSE IF(LEFT(@job_ref_no,1) = 'C')            
   BEGIN 
		UPDATE TBL_INVOICE_TXN_WORK_ORDER                
		SET qty_of_goods = @internal_qa_completed_qty                
		WHERE job_ref_no = @job_ref_no        
   END
   else 
   begin
		UPDATE TBL_TXN_WORK_ORDER                
		SET qty_of_goods = @com_qty                
		WHERE job_ref_no = @job_ref_no     
   end   
                
   --2. Trigger email to client                
   SET ARITHABORT ON                
   --- Get data into temp table ---                
   DECLARE @file_extension VARCHAR(50), @file_data NVARCHAR(MAX), @file_name NVARCHAR(250)                
                
   CREATE TABLE #TEMP                
   (                
   row_id INT IDENTITY(1,1),                
   job_ref_no VARCHAR(50),                
   guid VARCHAR(250),                
   file_name NVARCHAR(250),                
   file_data VARBINARY(MAX),                
   file_extension VARCHAR(50)                
   )                
                
   INSERT INTO #TEMP                
   (job_ref_no, guid, file_name, file_extension)                
   SELECT job_ref_no, guid, file_name, file_extension FROM TBL_TXN_JOB_EVENT_EMAIL_ATTACHMENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND guid = @guid                
                
   UPDATE A                
   SET A.file_data = CAST(N'' AS xml).value('xs:base64Binary(sql:column("B.file_data"))', 'varbinary(max)')                
   FROM #TEMP A, TBL_TXN_JOB_EVENT_EMAIL_ATTACHMENT B WITH(NOLOCK)                
   WHERE A.job_ref_no = B.job_ref_no AND A.guid = B.guid AND A.file_name = B.file_name                
   --- Get data into temp table ---                
                
   --- Check if folder exists ---                
   CREATE TABLE #ResultSet (Directory varchar(200))                
   INSERT INTO #ResultSet EXEC master.dbo.xp_subdirs N'D:\VAS\MY-HEC\'                
   DECLARE @folder_exists INT                 
   SET @folder_exists = (SELECT COUNT(*) FROM #ResultSet WHERE Directory = @guid)                
    DECLARE @folder_path NVARCHAR(4000)                
    SET @folder_path = N'D:\VAS\MY-HEC\' + @guid + '\'                
   IF (@folder_exists = 0)                
   BEGIN                
    DECLARE @cmdpath VARCHAR(4000)                
    SET @cmdpath = 'MD ' + @folder_path                
    EXEC master..xp_cmdshell @cmdpath, no_output;                
   END                
   DROP TABLE #ResultSet                
   --- Check if folder exists ---                
                
   --- Convert binary file to physical files ---                
   DECLARE @img_path VARBINARY(MAX), @timestamp NVARCHAR(500), @ObjectToken INT, @id INT = 1, @tbl_count INT                
   SET @tbl_count = (SELECT COUNT(1) FROM #TEMP)                
   WHILE @tbl_count >= @id                 
   BEGIN                
    SELECT @img_path = file_data from #TEMP WHERE row_id = @id                
    SELECT @timestamp =  @folder_path + file_name FROM #TEMP  WHERE row_id = @id                
    EXEC sp_OACreate 'ADODB.Stream', @ObjectToken OUTPUT                
    EXEC sp_OASetProperty @ObjectToken, 'Type', 1                
    EXEC sp_OAMethod @ObjectToken, 'Open'                
    EXEC sp_OAMethod @ObjectToken, 'Write', NULL, @img_path                
    EXEC sp_OAMethod @ObjectToken, 'SaveToFile', NULL, @timestamp, 2                
    EXEC sp_OAMethod @ObjectToken, 'Close'                
    EXEC sp_OADestroy @ObjectToken                
    SET @id = @id + 1                
   END                 
   --- Convert binary file to physical files ---                
                
   --Generate pdf--                
   DECLARE @html NVARCHAR(MAX), @barcode_html VARCHAR(MAX), @parameter NVARCHAR(MAX), @html_file_name VARCHAR(100), @html_full_path VARCHAR(1000), @pdf_full_path VARCHAR(1000), @strCMD VARCHAR(1000)                
   SET @parameter = N'{"job_ref_no":"' + @job_ref_no + '"}'                
           
   CREATE TABLE #HTML_STRING                
   (                
   string_a nvarchar(maX),                
   string_b nvarchar(maX),                
   string_c nvarchar(maX),                
   string_d nvarchar(maX)                
   )                
   
   IF(LEFT(@job_ref_no,1) = 'S')            
   BEGIN 
		INSERT INTO #HTML_STRING (string_a, string_b, string_c, string_d)   
		EXEC SPP_TXN_SUBCON_WORK_ORDER_PRINT @parameter     
   end
   ELSE IF(LEFT(@job_ref_no,1) = 'P')            
   BEGIN 
		INSERT INTO #HTML_STRING (string_a, string_b, string_c, string_d)   
		EXEC SPP_TXN_SIA_WORK_ORDER_PRINT @parameter     
   END
   ELSE IF(LEFT(@job_ref_no,1) = 'C')            
   BEGIN 
		INSERT INTO #HTML_STRING (string_a, string_b, string_c, string_d)   
		EXEC SPP_TXN_INVOICE_WORK_ORDER_PRINT @parameter     
   END
   else 
   begin
		INSERT INTO #HTML_STRING (string_a, string_b, string_c, string_d)   
		EXEC SPP_TXN_WORK_ORDER_PRINT @parameter     
   end              
                 
   IF(LEFT(@job_ref_no,1) = 'S')            
   BEGIN 
		SET @barcode_html = (SELECT barcode_html FROM TBL_Subcon_TXN_WORK_ORDER WHERE job_ref_no = @job_ref_no)      
   end
   ELSE IF(LEFT(@job_ref_no,1) = 'P')            
   BEGIN 
		SET @barcode_html = (SELECT barcode_html FROM TBL_SIA_TXN_WORK_ORDER WHERE job_ref_no = @job_ref_no)      
   END
   ELSE IF(LEFT(@job_ref_no,1) = 'C')            
   BEGIN 
		SET @barcode_html = (SELECT barcode_html FROM TBL_INVOICE_TXN_WORK_ORDER WHERE job_ref_no = @job_ref_no)      
   END
   else 
   begin
		SET @barcode_html = (SELECT barcode_html FROM TBL_TXN_WORK_ORDER WHERE job_ref_no = @job_ref_no) 
   end                

   SET @html = (SELECT string_a + string_b + string_c + string_d FROM #HTML_STRING)                
   SET @html = (SELECT replace(@html, '<svg id="barcode"></svg>' , @barcode_html))             
   SET @html_file_name = @running_no + '.html' -- 2018/05/0001.html                
                 
   EXEC SPP_GENERATE_HTML @String = @html, @Path = @folder_path, @Filename = @html_file_name --Generate .html file in @folder_path                
                 
   SET @html_full_path = @folder_path + @html_file_name -- D:\VAS\MY-HEC\@guid\html_file_name.html                
   SET @pdf_full_path = @folder_path + @running_no + '.pdf' -- D:\VAS\MY-HEC\@guid\2018/05/0001.pdf                
   SET @strCMD = 'D:\VAS\wkhtmltopdf.exe --image-dpi -600 --image-dpi 100 -n --print-media-type -q --quiet --header-html "" --header-spacing 30 --footer-html ""   ' + @html_full_path + '  ' + @pdf_full_path +'  '                
                
   EXEC xp_cmdshell @strCMD, no_output;                
   DROP TABLE #HTML_STRING                
                
   INSERT INTO #TEMP                
   (job_ref_no, guid, file_name, file_extension)                
   SELECT @job_ref_no, @guid, @running_no + '.pdf', '.pdf'                
   --Generate pdf--                
                
   --- Trigger email ---                
   DECLARE @subject NVARCHAR(MAX), @body NVARCHAR(MAX), @file_attachments NVARCHAR(MAX) = '', @count INT, @i INT = 1                
   SET @count = (SELECT COUNT(*) FROM #TEMP)                
   WHILE @i <= @count                
   BEGIN                
    SET @file_name = (SELECT file_name FROM #TEMP WHERE row_id = @i)                
    SET @file_attachments += 'D:\VAS\MY-HEC\' + @guid + '\' + @file_name      IF @i <> @count                
    SET @file_attachments += ';'                
    SET @i = @i + 1                
   END                
                 
   DECLARE @email_country_hdr VARCHAR(100), @approve_link NVARCHAR(4000), @approval_email_addr NVARCHAR(4000),@ref_no NVARCHAR(4000), @rejected_link NVARCHAR(4000), @profile_name VARCHAR(50)                
   SET @email_country_hdr = (SELECT TOP 1 email_country_hdr FROM VAS.dbo.TBL_ADM_SETTING A WITH(NOLOCK) INNER JOIN VAS.dbo.TBL_ADM_PRINCIPAL B WITH(NOLOCK) ON A.setting_id = B.setting_id INNER JOIN VAS.dbo.TBL_ADM_USER C WITH(NOLOCK) ON B.principal_id = 
   
   
      
C.principal_id WHERE user_id = @user_id)                
   SET @subject = 'Pending Approval (' + @running_no + ')'                
   SET @ref_no = '[VAS]' + @email_country_hdr                
   SET @approval_email_addr = (SELECT config_value FROM VAS.dbo.TBL_ADM_CONFIGURATION WITH(NOLOCK) WHERE config = 'global_email_address')                
   SET @profile_name = (SELECT config_value FROM VAS.dbo.TBL_ADM_CONFIGURATION WITH(NOLOCK) WHERE config = 'email_profile_name')                
   SET @approve_link = 'mailto:' + @approval_email_addr + '?Subject=Re:' + @ref_no + ':' + @running_no + ':A&body=Comments:%0A%0A[eom]%0A%0A'                
   SET @rejected_link = 'mailto:' + @approval_email_addr + '?Subject=Re:' + @ref_no + ':' + @running_no + ':R&body=Comments:%0A%0A[eom]%0A%0A'                 
                
   SET @body = '<table style="font-family:arial;font-size:10pt;">'                 
   SET @body = '<tr><td colspan=2>This is testing site.</td></tr>'                
   SET @body += '<tr><td colspan=2>Please click on the <b>Approve</b> or <b>Reject</b> link. Thereafter the email will be composed.</td></tr>'                
   SET @body += '<tr><td colspan=2>Do take note that comments is required for rejection.</td></tr>'                
   SET @body += '<tr><td colspan=2>Once done, please select <b>SEND</b> for this request to proceed to the next steps</td></tr>'                
   SET @body += '<tr><td colspan=2>&nbsp;</td></tr>'                
   SET @body += '<tr><td colspan=2><a href='+ @approve_link +'>Approve</a></td></tr>'                
   SET @body += '<tr><td colspan=2>&nbsp;</td></tr>'                
   SET @body += '<tr><td colspan=2><a href='+ @rejected_link +'>Reject</a></td></tr>'                
   SET @body += '<tr><td colspan=2>&nbsp;</td></tr></table>'                 
                
   EXEC msdb.dbo.sp_send_dbmail                
    @profile_name = @profile_name,                
    @recipients = @email,                
    @blind_copy_recipients = 'shen.yee.siow@dksh.com',                    
    @subject = @subject,                
    @body = @body,                
    @attach_query_result_as_file = 0,                
@body_format ='HTML',                
    @importance = 'NORMAL',                
    @file_attachments = @file_attachments;                
   -- Trigger email ---                
                
   INSERT INTO TBL_TXN_JOB_EVENT_EMAIL_LOG                
   (job_ref_no, system_running_no, guid, email_addr, cc_addr, subject, body, sent_by, sent_date)                
   VALUES                
   (@job_ref_no, @running_no, @guid, @email, 'shen.yee.siow@dksh.com', @subject, @body, @user_id, GETDATE())                
                
   ---- Delete ALL files and folder ---                
   DECLARE @remove_files NVARCHAR(MAX), @cmd VARCHAR(8000), @remove_folder NVARCHAR(MAX)                
   SET @remove_files = N'D:\VAS\MY-HEC\' + @guid + '\*.*'                
   SET @cmd = 'DEL /F /Q ' + @remove_files                
   EXEC master..xp_cmdshell @cmd, no_output;                
                
   SET @remove_folder = N'D:\VAS\MY-HEC\' + @guid                
   SET @cmd = 'RMDIR /S /Q ' + @remove_folder                
   EXEC master..xp_cmdshell @cmd, no_output;                
   ---- Delete ALL files and folder ---                
                
   UPDATE TBL_TXN_JOB_EVENT                
   SET email_sent_count = 1                
   WHERE running_no = @running_no                
                
   DROP TABLE #TEMP                
   SET ARITHABORT OFF                
  END                
  ELSE IF ((@event_id = '80' OR @event_id = '85') AND (LEFT(@job_ref_no,1) <> 'P' AND LEFT(@job_ref_no,1) <> 'C')) -- Submit to SAP                
  BEGIN                
   --1. Insert into txn table                
   INSERT INTO TBL_TXN_JOB_EVENT                
   (running_no, job_ref_no, event_id, start_date, end_date, issued_qty, completed_qty, damaged_qty, remarks, on_hold_time, created_date, creator_user_id)                
   SELECT @running_no, @job_ref_no, @event_id, CONVERT(varchar(23), REPLACE(@start_date, 'T', ' '), 121), GETDATE(), @issued_qty, @completed_qty, @damaged_qty, @remarks, @total_time_taken_in_sec, GETDATE(), @user_id                
                
   --2. Insert into sap integration table      
       
   IF(LEFT(@job_ref_no,1) = 'S')            
   BEGIN    
    INSERT INTO VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER_SAP                
    (country_code, process_ind, vas_order, whs_no, workorder_no, requirement_no, qty,                 
    prd_code, uom, plant, sloc, batch_no, movement_type, stock_category, created_date, created_by, status, ssto_unit_no,  ssto_section, ssto_stg_bin, su_ind)                
    SELECT TOP 1 'MY', 'P', vas_order, whs_no, work_ord_ref, running_no, (ISNULL(completed_qty,0) + ISNULL(damaged_qty,0)),                
    prd_code, uom, plant, sloc, batch_no, '999', stock_category, GETDATE(), 1, 'P', dsto_unit_no, dsto_section, dsto_stg_bin ,
	--26/06/2023 BY CHOI CHEE KIEN: set su_ind to Y if event id = 80 and damaged_qty > 0 else N
	CASE WHEN A.damaged_qty > 0 AND @event_id = '80' THEN 'Y' ELSE 'N' END
    from TBL_TXN_JOB_EVENT A                
    INNER JOIN TBL_Subcon_TXN_WORK_ORDER B WITH(NOLOCK) ON A.job_ref_no = B.job_ref_no                
    WHERE running_no = @running_no    
  
 INSERT INTO VAS_INTEGRATION.dbo.[VAS_SUBCON_INBOUND_ORDER]  
( [country_code],[process_ind], [status],[outbound_doc] ,[Subcon_Doc], [Subcon_Item_No], [whs_no], [plant], [supplier_code], [supplier_name],   
[prd_code], [prd_desc], [uom], [batch_no], [qty], [expiry_date], [SWI_No], [created_date], [created_by], [sloc], [po_date], [subcon_po],   
[component], [component_desc], [to_no],  [to_date], [to_time], [delete_flag], [Subcon_Job_No], [running_no], [job_ref_no])  
    --(country_code, process_ind, vas_order, whs_no, workorder_no, requirement_no, qty,                 
    --prd_code, uom, plant, sloc, batch_no, movement_type, stock_category, created_date, created_by, status, ssto_unit_no,  ssto_section, ssto_stg_bin)        
	
select	'MY', 'P','S', C.outbound_doc, C.Subcon_Doc,C.Subcon_Item_No, A.whs_no, A.plant, C.supplier_code, C.supplier_name, c.prd_code, c.prd_desc, A.uom, A.batch_no, A.qty, C.expiry_date,c.SWI_No,GETDATE(),'System', A.sloc, c.po_date,'',C.component,c.component_desc,  
 c.to_no,c.to_date, c.to_time,0, A.workorder_no, A.requirement_no, B.job_ref_no
from	VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER_SAP A
		inner join
		TBL_TXN_JOB_EVENT B
on		A.requirement_no = B.running_no
		inner join
		VAS_INTEGRATION.dbo.VAS_Subcon_TRANSFER_ORDER C
on		B.job_ref_no = C.Subcon_Job_No
		inner join
		TBL_Subcon_TXN_WORK_ORDER D
on		C.Subcon_Job_No = D.job_ref_no
where	A.requirement_no = @running_no 

 --   SELECT TOP 1 'MY', 'P','S',c.outbound_doc,C.Subcon_Doc,C.Subcon_Item_No,B.whs_no,B.plant,C.supplier_code,C.supplier_name,c.prd_code,c.prd_desc,b.uom,  
 --c.batch_no,  
 --(ISNULL(completed_qty,0) + ISNULL(damaged_qty,0)),C.expiry_date,c.SWI_No,GETDATE(),'System',B.sloc,c.po_date,'',C.component,c.component_desc,  
 --c.to_no,c.to_date, c.to_time,0,B.work_ord_ref  
               
 --   from TBL_TXN_JOB_EVENT A                
 --   INNER JOIN TBL_Subcon_TXN_WORK_ORDER B WITH(NOLOCK) ON A.job_ref_no = B.job_ref_no    
 --INNER JOIN VAS_INTEGRATION.dbo.[VAS_Subcon_TRANSFER_ORDER] C ON  B.Subcon_WI_No = C.SWI_No  
 --   WHERE running_no = @running_no   
   END    
   ELSE    
   BEGIN    

   SET @vas_order = (SELECT vas_order FROM VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER WHERE workorder_no = (select top 1 job_ref_no from TBL_TXN_JOB_EVENT where running_no = @running_no )) 
   SET @new_su_no =  (SELECT new_su_no FROM VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER_SAP WHERE vas_order =@vas_order and process_ind ='A' and status='R' and su_ind='Y'  )
   SET @su_no =  (SELECT su_no FROM VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER WHERE workorder_no = (select top 1 job_ref_no from TBL_TXN_JOB_EVENT where running_no = @running_no ))



     INSERT INTO VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER_SAP                
  (country_code, process_ind, vas_order, whs_no, workorder_no, requirement_no, qty,                 
  prd_code, uom, plant, sloc, batch_no, movement_type, stock_category, created_date, created_by, status, ssto_unit_no,  ssto_section, ssto_stg_bin, su_no,su_ind)                
  SELECT TOP 1 'MY', 'P', vas_order, whs_no, work_ord_ref, running_no, (ISNULL(completed_qty,0) + ISNULL(damaged_qty,0)),                
  prd_code, uom, plant, sloc, batch_no, '999', stock_category, GETDATE(), @user_id, 'P', dsto_unit_no, dsto_section, dsto_stg_bin, case when @new_su_no is not null then @new_su_no else @su_no end,    
  	--26/06/2023 BY CHOI CHEE KIEN: set su_ind to Y if event id = 80 and damaged_qty > 0 else N
	CASE WHEN A.damaged_qty > 0 AND @event_id = '80' THEN 'Y' ELSE 'N' END
  from TBL_TXN_JOB_EVENT A                
  INNER JOIN TBL_TXN_WORK_ORDER B WITH(NOLOCK) ON A.job_ref_no = B.job_ref_no                
  WHERE running_no = @running_no      
   END    
  END                
  ELSE -- Other basic events (no special actions required)                
  BEGIN                
   --1. Insert into txn table                
   INSERT INTO TBL_TXN_JOB_EVENT                
   (running_no, job_ref_no, event_id, start_date, end_date, issued_qty, remarks, on_hold_time, created_date, creator_user_id)                
   SELECT @running_no, @job_ref_no, @event_id, CONVERT(varchar(23), REPLACE(@start_date, 'T', ' '), 121), GETDATE(), @issued_qty, @remarks, @total_time_taken_in_sec, GETDATE(), @user_id      
  END                
                
  DECLARE @event_name NVARCHAR(100)                
  SET @event_name = (SELECT event_name FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK) WHERE event_id = @event_id and wo_type_id = @job_type)                
                
  INSERT INTO TBL_ADM_AUDIT_TRAIL                
  (module, key_code, action, action_by, action_date)                
  SELECT 'JOB-EVENT-NEW', @job_ref_no, 'Completed ' + @event_name, @user_id, GETDATE()                
        
  IF(LEFT(@job_ref_no,1) = 'S')      
  BEGIN      
    UPDATE TBL_Subcon_TXN_WORK_ORDER                
    SET current_event = @event_id                
    WHERE job_ref_no = @job_ref_no      
  END
  ELSE IF(LEFT(@job_ref_no,1) = 'P')      
  BEGIN      
    UPDATE TBL_SIA_TXN_WORK_ORDER                
    SET current_event = @event_id                
    WHERE job_ref_no = @job_ref_no      
  END
  ELSE IF(LEFT(@job_ref_no,1) = 'C')      
  BEGIN      
    UPDATE TBL_INVOICE_TXN_WORK_ORDER                
    SET current_event = @event_id                
    WHERE job_ref_no = @job_ref_no      
  END
  ELSE      
  BEGIN      
    UPDATE TBL_TXN_WORK_ORDER                
 SET current_event = @event_id                
 WHERE job_ref_no = @job_ref_no      
  END      
                  
 END                
                
 SELECT 'N' as duplicate                
                
 END TRY                
                
 BEGIN CATCH                
  SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_LINE() as ErrorLine, ERROR_MESSAGE() AS ErrorMessage;                 
 END CATCH                
END 
GO
