SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ========================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Work order actions
-- Example Query: exec SPP_TXN_WORK_ORDER_ACTION @submit_obj=N'{"job_ref_no":"","search":"Search","job_ref_wo_no":"S2021/12/0001","work_ord_ref":"NOVARTIS/TASIGNA/20211223/9999-12-31","work_ord_status":"In Process","add":"Add","export":"Export","complete":"Close Job","job_event":"","Update WI":"UpdateWI","start_date":"","original_qty":"","qa_qty":"","email":"","inbound_damaged_qty":"","save":"Save","issued_qty":"","remarks":"","email_photos":"","completed_qty":"","damaged_qty":"","on_hold_job":"On Hold Job","release_job":"Release Job","cancel_job":"Cancel Job","on_hold_reason":"Pending PPM","on_hold_remarks":"Test","on_hold_confirm":"Confirm","ques_a":"on","ques_b":"on","ques_c":"on","ques_d":"on","internal_qa_completed_qty":"","internal_qa_required":"","job_action":"on-hold-job"}',@user_id=N'1'
-- Remarks : List of actions
-- 1) on-hold-job
-- 2) release-job
-- 3) cancel-job-with-stock
-- 4) cancel-job-without-stock
-- 5) complete-job
-- ========================================================================

CREATE PROCEDURE [dbo].[SPP_TXN_WORK_ORDER_ACTION]
	@submit_obj NVARCHAR(MAX),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @job_ref_no VARCHAR(50), @job_action VARCHAR(50), @on_hold_reason VARCHAR(50), @on_hold_remarks NVARCHAR(250), 
	@latest_running_no VARCHAR(10), @log_id INT = 0

	SET @job_ref_no = (SELECT JSON_VALUE(@submit_obj, '$.job_ref_wo_no'))
	SET @job_action = (SELECT JSON_VALUE(@submit_obj, '$.job_action'))
	SET @on_hold_reason = (SELECT JSON_VALUE(@submit_obj, '$.on_hold_reason'))
	SET @on_hold_remarks = (SELECT JSON_VALUE(@submit_obj, '$.on_hold_remarks'))
	SET @latest_running_no = (SELECT MAX(running_no) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)

	IF @job_action = 'on-hold-job'
	BEGIN
	PRINT '1'
		INSERT INTO TBL_TXN_WORK_ORDER_ACTION_LOG
		(job_no, current_running_no, on_hold_date, on_hold_reason, on_hold_remarks, on_hold_by)
		SELECT @job_ref_no, @latest_running_no, GETDATE(), @on_hold_reason, @on_hold_remarks, @user_id
PRINT '2'
		SET @log_id = (SELECT TOP 1 log_id FROM TBL_TXN_WORK_ORDER_ACTION_LOG WITH(NOLOCK) WHERE job_no = @job_ref_no AND current_running_no = @latest_running_no ORDER BY log_id DESC)
		IF(LEFT(@job_ref_no,1) = 'S')    
		BEGIN
		PRINT '3'
		 UPDATE TBL_Subcon_TXN_WORK_ORDER          
		 SET work_ord_status = 'OH',
		 log_id = @log_id      
		 WHERE job_ref_no = @job_ref_no         
		END
	ELSE
	BEGIN
		UPDATE TBL_TXN_WORK_ORDER
		SET work_ord_status = 'OH',
			log_id = @log_id
		WHERE job_ref_no = @job_ref_no
	END
	END
	ELSE IF @job_action = 'release-job'
	BEGIN
		SET @log_id = (SELECT log_id FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)

		UPDATE TBL_TXN_WORK_ORDER_ACTION_LOG
		SET released_date = GETDATE(),
			released_by = @user_id
		WHERE log_id = @log_id

		IF(LEFT(@job_ref_no,1) = 'S')    
		BEGIN
		 UPDATE TBL_Subcon_TXN_WORK_ORDER          
		 SET work_ord_status = 'IP'
		 WHERE job_ref_no = @job_ref_no         
		END
	ELSE
	BEGIN
		UPDATE TBL_TXN_WORK_ORDER
		SET work_ord_status = 'IP'
		WHERE job_ref_no = @job_ref_no
	END
	END
	ELSE IF @job_action = 'cancel-job-with-stock'
	BEGIN
		DECLARE @cancel_reason_with_stock NVARCHAR(250)
		SET @cancel_reason_with_stock = (SELECT JSON_VALUE(@submit_obj, '$.cancel_reason'))

		DECLARE @running_no VARCHAR(50) = 1, @len INT = 8
		SELECT TOP 1 @running_no = CAST(CAST(RIGHT(running_no, 8) as INT) + 1 AS VARCHAR(50))
									FROM (SELECT running_no FROM TBL_TXN_JOB_EVENT) A ORDER BY CAST(RIGHT(running_no, 8) AS INT) DESC
		SET @running_no = 'MY' + REPLICATE('0', @len - LEN(@running_no)) + @running_no
		
		DECLARE @qty INT
		SET @qty = (SELECT issued_qty FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND event_id = '25')
		
		IF(LEFT(@job_ref_no,1) <> 'S')
		begin

		--1. Insert into txn table
		INSERT INTO TBL_TXN_JOB_EVENT
		(running_no, job_ref_no, event_id, start_date, end_date, issued_qty, completed_qty, damaged_qty, remarks, created_date, creator_user_id)
		SELECT @running_no, @job_ref_no, '80', GETDATE(), GETDATE(), @qty, @qty, 0, 'Cancelled with Submission to SAP', GETDATE(), @user_id

		--2. Insert into sap integration table
		INSERT INTO VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER_SAP
		(country_code, process_ind, vas_order, whs_no, workorder_no, requirement_no, qty, 
		prd_code, uom, plant, sloc, batch_no, movement_type, stock_category, created_date, created_by, status, ssto_unit_no,  ssto_section, ssto_stg_bin)
		SELECT TOP 1 'MY', 'P', vas_order, whs_no, work_ord_ref, running_no, (ISNULL(completed_qty,0) + ISNULL(damaged_qty,0)),
		prd_code, uom, plant, sloc, batch_no, '999', stock_category, GETDATE(), @user_id, 'P', dsto_unit_no, dsto_section, dsto_stg_bin
		from TBL_TXN_JOB_EVENT A
		INNER JOIN TBL_TXN_WORK_ORDER B ON A.job_ref_no = B.job_ref_no
		WHERE running_no = @running_no

		end

		IF(LEFT(@job_ref_no,1) = 'S')    
		BEGIN
		 UPDATE TBL_Subcon_TXN_WORK_ORDER          
		 SET work_ord_status = 'CCL', 
			--current_event = '80',
			cancellation_reason = @cancel_reason_with_stock,
			changed_user_id = @user_id,
			changed_date = GETDATE()
		 WHERE job_ref_no = @job_ref_no        
		END
	ELSE
	BEGIN
		UPDATE TBL_TXN_WORK_ORDER
		SET work_ord_status = 'CCL', 
			current_event = '80',
			cancellation_reason = @cancel_reason_with_stock,
			changed_user_id = @user_id,
			changed_date = GETDATE()
		WHERE job_ref_no = @job_ref_no
	END
	END
	ELSE IF @job_action = 'cancel-job-without-stock'
	BEGIN
		DECLARE @cancel_reason_without_stock NVARCHAR(250)
		SET @cancel_reason_without_stock = (SELECT JSON_VALUE(@submit_obj, '$.cancel_reason'))

		IF(LEFT(@job_ref_no,1) = 'S')    
		BEGIN
		 UPDATE TBL_Subcon_TXN_WORK_ORDER          
		 SET work_ord_status = 'CCL',
			current_event = NULL,
			cancellation_reason = @cancel_reason_without_stock,
			changed_user_id = @user_id,
			changed_date = GETDATE()
		 WHERE job_ref_no = @job_ref_no         
		END
	ELSE
	BEGIN
		UPDATE TBL_TXN_WORK_ORDER
		SET work_ord_status = 'CCL',
			current_event = NULL,
			cancellation_reason = @cancel_reason_without_stock,
			changed_user_id = @user_id,
			changed_date = GETDATE()
		WHERE job_ref_no = @job_ref_no
		END
	END

	DECLARE @audit_action VARCHAR(200)
	SELECT @audit_action = CASE @job_action WHEN 'on-hold-job' THEN 'On Hold Job'
											WHEN 'release-job' THEN 'Release Job'
											WHEN 'cancel-job-with-stock' THEN 'Cancel job with Stock'
											WHEN 'cancel-job-without-stock' THEN 'Cancel job without Stock' END

	INSERT INTO TBL_ADM_AUDIT_TRAIL
	(module, key_code, action, action_by, action_date)
	SELECT 'WORK-ORDER', @job_ref_no, 
	'[' + CAST(CASE @log_id WHEN 0 THEN '' ELSE @log_id END as varchar(50)) + '] ' + @audit_action
	+ CASE @job_action WHEN 'on-hold-job' THEN ' : ' + @on_hold_reason + ' (' + @on_hold_remarks + ')' 
					   WHEN 'cancel-job-with-stock' THEN ' : ' + @cancel_reason_with_stock
					   WHEN 'cancel-job-without-stock' THEN ' : ' + @cancel_reason_without_stock
					   ELSE '' END,
	@user_id, GETDATE()

	SELECT @job_ref_no as job_ref_no
END

GO
