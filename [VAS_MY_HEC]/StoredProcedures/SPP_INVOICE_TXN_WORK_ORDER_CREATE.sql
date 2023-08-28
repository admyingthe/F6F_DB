SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPP_INVOICE_TXN_WORK_ORDER_CREATE] 
	@submit_obj	nvarchar(max),
	@user_id	VARCHAR(10)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @work_ord_ref VARCHAR(50), @vas_order VARCHAR(50), @client_code VARCHAR(50), @prd_code VARCHAR(50), @batch_no VARCHAR(50), 
	@item_no VARCHAR(50), @ttl_qty_eaches INT, @arrival_date VARCHAR(50), @mll_no VARCHAR(50), 
	@urgent VARCHAR(10), @commencement_date VARCHAR(50), @completion_date VARCHAR(50), @qty_of_goods INT, @num_of_days_to_complete INT, 
	@others NVARCHAR(250), @mode VARCHAR(50), @job_ref_no VARCHAR(50)

	SET @work_ord_ref = (SELECT JSON_VALUE(@submit_obj, '$.work_ord_ref'))
	SET @client_code = (SELECT JSON_VALUE(@submit_obj, '$.client_code'))
	SET @vas_order = (SELECT JSON_VALUE(@submit_obj, '$.vas_order'))
	SET @prd_code = (SELECT JSON_VALUE(@submit_obj, '$.prd_code'))
	SET @batch_no = (SELECT JSON_VALUE(@submit_obj, '$.batch_no'))
	SET @item_no = (SELECT JSON_VALUE(@submit_obj, '$.item_no'))
	SET @arrival_date = (SELECT JSON_VALUE(@submit_obj, '$.arrival_date'))
	SET @ttl_qty_eaches = (SELECT JSON_VALUE(@submit_obj, '$.ttl_qty_eaches'))
	SET @mll_no = (SELECT JSON_VALUE(@submit_obj, '$.mll_no'))
	SET @urgent = (SELECT JSON_VALUE(@submit_obj, '$.urgent'))
	SET @commencement_date = (SELECT JSON_VALUE(@submit_obj, '$.commencement_date'))
	SET @completion_date = (SELECT JSON_VALUE(@submit_obj, '$.completion_date'))
	SET @qty_of_goods = (SELECT JSON_VALUE(@submit_obj, '$.qty_of_goods'))
	SET @num_of_days_to_complete = (SELECT JSON_VALUE(@submit_obj, '$.num_of_days_to_complete'))
	SET @others = (SELECT JSON_VALUE(@submit_obj, '$.others'))
	SET @mode = (SELECT JSON_VALUE(@submit_obj, '$.mode'))
	SET @job_ref_no = (SELECT JSON_VALUE(@submit_obj, '$.job_ref_no'))

	IF @commencement_date = '' SET @commencement_date = NULL
	IF @completion_date = '' SET @completion_date = NULL

	EXEC REPLACE_SPECIAL_CHARACTER @others, @others OUTPUT

	DECLARE @qty_to_use INT
	IF (@qty_of_goods <> 0) SET @qty_to_use = @qty_of_goods
	ELSE SET @qty_to_use = @ttl_qty_eaches

	IF (@mode = 'New')
	BEGIN
		DECLARE @new_job_ref_no VARCHAR(50) = 1, @len INT = 4, @to_no VARCHAR(50), @inbound_doc VARCHAR(50)
		SELECT TOP 1 @new_job_ref_no = CAST(CAST(RIGHT(job_ref_no, @len) as INT) + 1 AS VARCHAR(50))
									FROM (SELECT job_ref_no FROM TBL_INVOICE_TXN_WORK_ORDER WHERE SUBSTRING(job_ref_no, 2, @len) = CAST(YEAR(GETDATE()) as VARCHAR(50)) AND SUBSTRING(job_ref_no, 7, 2) = CAST(FORMAT(GETDATE(),'MM') as VARCHAR(50))) A ORDER BY CAST(RIGHT(job_ref_no, @len) AS INT) DESC
		SET @new_job_ref_no = (SELECT 'V' + CAST(YEAR(GETDATE()) as VARCHAR(50)) + '/' + CAST(FORMAT(GETDATE(),'MM') as VARCHAR(50)) + '/' + REPLICATE('0', @len - LEN(@new_job_ref_no)) + @new_job_ref_no)
		SET @to_no = (SELECT TOP 1 to_no FROM VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER WITH(NOLOCK) WHERE vas_order = @vas_order AND prd_code = @prd_code AND batch_no = @batch_no ) -- AND item_no = @item_no)
		SET @inbound_doc = (SELECT TOP 1 inbound_doc FROM VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER WITH(NOLOCK) WHERE vas_order = @vas_order AND prd_code = @prd_code AND batch_no = @batch_no ) --AND item_no = @item_no)

		IF (SELECT COUNT(*) FROM TBL_INVOICE_TXN_WORK_ORDER WITH(NOLOCK) WHERE work_ord_ref = @work_ord_ref AND prd_code = @prd_code AND vas_order = @vas_order AND inbound_doc = @inbound_doc AND to_no = @to_no ) = 0 -- AND item_no = @item_no) = 0
		BEGIN
			INSERT INTO TBL_INVOICE_TXN_WORK_ORDER
			(work_ord_ref, work_ord_status, job_ref_no, mll_no, client_code, prd_code, inbound_doc, 
			requirement_no, vas_order, batch_no, to_no, whs_no, picking_area, upl_point, plant, 
			--ssto_unit_no, dsto_unit_no, dsto_section, dsto_stg_bin, item_no, sloc, uom, 
			ssto_unit_no, dsto_unit_no, dsto_section, dsto_stg_bin, sloc, uom, 
			expiry_date, stock_category, ttl_qty_eaches, arrival_date, urgent, commencement_date, completion_date, qty_of_goods, num_of_days_to_complete, creator_user_id, created_date, others, current_event)
			SELECT DISTINCT @work_ord_ref, 'IP', @new_job_ref_no, @mll_no, @client_code, @prd_code, inbound_doc,
			requirement_no, @vas_order, @batch_no, to_no, whs_no, picking_area, upl_point, plant,
			--ssto_unit_no, dsto_unit_no, dsto_section, dsto_stg_bin, @item_no, sloc, uom,
			ssto_unit_no, dsto_unit_no, dsto_section, dsto_stg_bin, sloc, uom,
			expiry_date, stock_category, @ttl_qty_eaches, @arrival_date, @urgent, @commencement_date, @completion_date, @qty_of_goods, @num_of_days_to_complete, @user_id, GETDATE(), @others, '00'
			FROM VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER WITH(NOLOCK) WHERE vas_order = @vas_order AND prd_code = @prd_code AND batch_no = @batch_no --AND item_no = @item_no

			UPDATE VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER
			SET workorder_no = @new_job_ref_no
			WHERE vas_order = @vas_order AND prd_code = @prd_code AND batch_no = @batch_no --AND item_no = @item_no

			DECLARE @running_no VARCHAR(50) = 1, @length INT = 8
			SELECT TOP 1 @running_no = CAST(CAST(RIGHT(running_no, @length) as INT) + 1 AS VARCHAR(50))
										FROM (SELECT running_no FROM TBL_TXN_JOB_EVENT) A ORDER BY CAST(RIGHT(running_no, @length) AS INT) DESC
			SET @running_no = 'MY' + REPLICATE('0', @length - LEN(@running_no)) + @running_no
			
			INSERT INTO TBL_TXN_JOB_EVENT
			(running_no, job_ref_no, event_id, start_date, issued_qty, created_date, creator_user_id)
			VALUES
			(@running_no, @new_job_ref_no, '00', GETDATE(), @qty_to_use, GETDATE(), @user_id)

			SELECT @new_job_ref_no as job_ref_no
		END
		ELSE
		SELECT '' as job_ref_no
	END
	ELSE IF (@mode = 'Edit')
	BEGIN
		UPDATE TBL_INVOICE_TXN_WORK_ORDER
		SET others = @others,
			urgent = @urgent,
			commencement_date = @commencement_date,
			completion_date = @completion_date,
			qty_of_goods = @qty_of_goods,
			num_of_days_to_complete = @num_of_days_to_complete,
			changed_date = GETDATE(),
			changed_user_id = @user_id
		WHERE job_ref_no = @job_ref_no

		INSERT INTO TBL_ADM_AUDIT_TRAIL
		(module, key_code, action, action_by, action_date)
		SELECT 'INVOICE_WORK_ORDER', @job_ref_no, 'Updated', @user_id, GETDATE()

		SELECT job_ref_no FROM TBL_INVOICE_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no
	END
END

GO
