SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ========================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Trigger event to SAP
-- Example Query: 
-- ========================================================================

CREATE PROCEDURE [dbo].[SPP_TXN_SUBMIT_SAP]
	@submit_obj NVARCHAR(MAX),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	   	--Added to get Thailand Time along with date
	DECLARE @CurrentDateTime AS DATETIME
	SET @CurrentDateTime=(SELECT DATEADD(hh, -1 ,GETDATE()) )
	--Added to get Thailand Time along with date


	DECLARE @running_no VARCHAR(10), @selected_event VARCHAR(50), @return_message INT
	SET @running_no = (SELECT JSON_VALUE(@submit_obj, '$.running_no'))
	SET @selected_event = (SELECT JSON_VALUE(@submit_obj, '$.selected_event'))

	DECLARE @event_id VARCHAR(50), @job_ref_no VARCHAR(50), @parent_running_no VARCHAR(50)
	SET @event_id = (SELECT event_id FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE running_no = @running_no)
	SET @job_ref_no = (SELECT job_ref_no FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE running_no = @running_no)
	SET @parent_running_no = (SELECT parent_running_no FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE running_no = @running_no)
	
	-- For re-triggger SAP Integration use --
	DECLARE @resendcounter INT, @re_qty INT
		SET @resendcounter = (SELECT top 1 ISNULL(resendcounter,0) FROM VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP WHERE requirement_no = @running_no)
		SET @re_qty = (SELECT issued_qty FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE running_no = @running_no)
	-- For re-triggger SAP Integration use --
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Re-trigger SAP to request stock +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	IF @selected_event = 'req_stock_ind' -- Re-trigger SAP to request stock --
	BEGIN
		UPDATE VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP
		SET status = 'P',
			--qty = @re_qty,
			resendcounter = @resendcounter + 1
		WHERE requirement_no = @running_no
		AND status = 'E'

		SELECT @return_message = '1'
	END
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ confirm_stock_ind +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	ELSE IF @selected_event = 'confirm_stock_ind'
	BEGIN
		DECLARE @new_running_no varchar(50), @len INT = 8, @qty INT, @to_no VARCHAR(50), @start_date DATETIME, @storage_type VARCHAR(50), @bin_no VARCHAR(50)
		SELECT TOP 1 @new_running_no = CAST(CAST(RIGHT(running_no, @len) as INT) + 1 AS VARCHAR(50)) FROM (SELECT running_no FROM TBL_TXN_JOB_EVENT) A ORDER BY CAST(RIGHT(running_no, @len) AS INT) DESC
		SET @new_running_no = 'TH' + REPLICATE('0', @len - LEN(@new_running_no)) + @new_running_no

		IF(LEFT(@job_ref_no,1) = 'G') 
		SET @qty = (SELECT sum(ttl_qty_eaches) FROM TBL_TXN_WORK_ORDER WHERE job_ref_no = @job_ref_no)
		ELSE
		SET @qty = (SELECT issued_qty FROM TBL_TXN_JOB_EVENT WHERE running_no = @parent_running_no)

		SET @to_no = (SELECT top 1 to_no FROM VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP WITH(NOLOCK) WHERE requirement_no = @parent_running_no)

		SET @start_date = (SELECT end_date FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE running_no = @running_no)

		SET @storage_type = (SELECT storage_type FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE running_no = @running_no)
		SET @bin_no = (SELECT bin_no FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE running_no = @running_no)

		-- First time confirm stock --
		IF (SELECT COUNT(*) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND remarks = 'Auto generated [' + @running_no + ']') = 0
		BEGIN
			INSERT INTO TBL_TXN_JOB_EVENT (running_no, job_ref_no, event_id, start_date, end_date, issued_qty, remarks, parent_running_no, created_date,storage_type,bin_no)
			VALUES(@new_running_no, @job_ref_no, '25', @start_date, @CurrentDateTime, @qty, 'Auto generated [' + @running_no + ']', @running_no, @CurrentDateTime,@storage_type,@bin_no)


			     DECLARE @JobFormat VARCHAR(25)=(SELECT  [format_code] FROM [TBL_REDRESSING_JOB_FORMAT])


			IF(LEFT(@job_ref_no,1) = 'G') 
			BEGIN
				INSERT INTO VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP
				(country_code, process_ind, vas_order, whs_no, workorder_no, requirement_no, qty, 
				prd_code, uom, plant, sloc, batch_no, movement_type, stock_category, created_date, created_by, to_no, status, ssto_unit_no,  ssto_section, ssto_stg_bin,storage_type_destination,bin_destination,special_stock_indicator,special_stock)
				SELECT  'TH', 'B', vas_order, whs_no, CASE WHEN @JobFormat='JobFormat' THEN B.job_ref_no ELSE B.work_ord_ref  END  work_ord_ref, running_no, sum(ttl_qty_eaches) qty,
				prd_code, uom, plant, sloc, batch_no, '889', stock_category, @CurrentDateTime, @user_id, @to_no, 'P', dsto_unit_no, dsto_section, dsto_stg_bin,storage_type,bin_no,special_stock_indicator,special_stock
				FROM TBL_TXN_JOB_EVENT A WITH(NOLOCK)
				INNER JOIN TBL_TXN_WORK_ORDER B WITH(NOLOCK) ON A.job_ref_no = B.job_ref_no
				WHERE running_no = @new_running_no
				GROUP BY vas_order, whs_no, work_ord_ref,B.job_ref_no, running_no,prd_code, uom, plant, sloc, batch_no,stock_category,dsto_unit_no, dsto_section, dsto_stg_bin,storage_type,bin_no,special_stock_indicator,special_stock
			END
			ELSE
			BEGIN
				INSERT INTO VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP
				(country_code, process_ind, vas_order, whs_no, workorder_no, requirement_no, qty, 
				prd_code, uom, plant, sloc, batch_no, movement_type, stock_category, created_date, created_by, to_no, status, ssto_unit_no,  ssto_section, ssto_stg_bin,storage_type_destination,bin_destination,special_stock_indicator,special_stock)
				SELECT TOP 1 'TH', 'B', vas_order, whs_no, CASE WHEN @JobFormat='JobFormat' THEN B.job_ref_no ELSE B.work_ord_ref  END  work_ord_ref, running_no, @qty,
				prd_code, uom, plant, sloc, batch_no, '889', stock_category, @CurrentDateTime, @user_id, @to_no, 'P', dsto_unit_no, dsto_section, dsto_stg_bin,storage_type,bin_no,special_stock_indicator,special_stock
				FROM TBL_TXN_JOB_EVENT A WITH(NOLOCK)
				INNER JOIN TBL_TXN_WORK_ORDER B WITH(NOLOCK) ON A.job_ref_no = B.job_ref_no
				WHERE running_no = @new_running_no
			END

			UPDATE TBL_TXN_WORK_ORDER_JOB_DET
			SET current_event = '25'
			WHERE job_ref_no = @job_ref_no

			SELECT @return_message = '1'
		END
		ELSE
		BEGIN
			UPDATE VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP
			SET status = 'P',
				--qty = @re_qty,
				resendcounter = @resendcounter + 1
			WHERE requirement_no = @running_no
			AND status = 'E'

			SELECT @return_message = '1'
		END
	END
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  sap_ind +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	ELSE IF @selected_event = 'sap_ind'
	BEGIN
		UPDATE VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP
		SET status = 'P',
			resendcounter = @resendcounter + 1
		WHERE requirement_no = @running_no
		AND status = 'E'

		update	B
		set		B.status = 'P',
				B.Recounter = @resendcounter + 1
		from	VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP A
				inner join  
				VASDEV_INTEGRATION_TH.dbo.VAS_SUBCON_INBOUND_ORDER B
		on		A.workorder_no = B.Subcon_Job_No
		where	A.requirement_no = @running_no and 
				B.status = 'E'

		SELECT @return_message = '1'
	END

	SELECT @return_message as return_message

	IF @return_message = '1'
		INSERT INTO TBL_ADM_AUDIT_TRAIL
		(module, key_code, action , action_by, action_date)
		VALUES ('JOB-EVENT-NEW', @job_ref_no, '[' + @parent_running_no + '] Trigger SAP [' + CASE WHEN @selected_event = 'req_stock_ind' THEN 'Request stock' WHEN @selected_event = 'sap_ind' THEN 'Submit to SAP' WHEN @selected_event = 'confirm_stock_ind' THEN 'Confirm stock' END + ']', @user_id, @CurrentDateTime)
END
GO
