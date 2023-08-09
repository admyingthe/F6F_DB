SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==========================================================
-- Author:		Smita Thorat
-- Create date: 2022-07-19
-- Description: (Run by Job) To check for success TO creation
-- ==========================================================

CREATE PROCEDURE [dbo].[SPP_SAP_INTEGRATION_JOB]
	
AS
BEGIN
	SET NOCOUNT ON;

   	--Added to get Thailand Time along with date
	DECLARE @CurrentDateTime AS DATETIME
	SET @CurrentDateTime=(SELECT DATEADD(hh, -1 ,GETDATE()) )
	--Added to get Thailand Time along with date

	SELECT IDENTITY(INT, 1, 1) AS row_id, running_no 
	INTO #TEMP_NO FROM TBL_TMP_SAP_ORDER WITH(NOLOCK)
	 
	DECLARE @count INT, @i INT = 1, @requirement_no VARCHAR(10)
	SET @count = (SELECT COUNT(*) FROM #TEMP_NO WITH(NOLOCK))

	IF @count <> 0
	BEGIN
		WHILE @i <= @count
		BEGIN
			SET @requirement_no = (SELECT running_no FROM #TEMP_NO WHERE row_id = @i)

			IF (SELECT COUNT(*) FROM VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP WITH(NOLOCK) WHERE requirement_no = @requirement_no AND status = 'R') >= 1
			BEGIN
				DECLARE @running_no VARCHAR(50) = 1, @len INT = 8
				SELECT TOP 1 @running_no = CAST(CAST(RIGHT(running_no, @len) as INT) + 1 AS VARCHAR(50))
											FROM (SELECT running_no FROM TBL_TXN_JOB_EVENT WITH(NOLOCK)) A ORDER BY CAST(RIGHT(running_no, @len) AS INT) DESC
				SET @running_no = 'TH' + REPLICATE('0', @len - LEN(@running_no)) + @running_no

				DECLARE @job_ref_no VARCHAR(50), @start_date DATETIME,@type VARCHAR(5)
				SET @job_ref_no = (SELECT job_ref_no FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE running_no = @requirement_no)
				SET @start_date = (SELECT end_date FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE running_no = @requirement_no)
				SET @type= LEFT(@job_ref_no,1)

				--1. Insert into tbl_txn_job_event -> event_id = 21
				INSERT INTO TBL_TXN_JOB_EVENT
				(running_no, job_ref_no, event_id, start_date, end_date, remarks, parent_running_no, created_date,storage_type,bin_no)
				SELECT TOP 1 @running_no, @job_ref_no, '21', @start_date, @CurrentDateTime, remarks, @requirement_no, @CurrentDateTime,storage_type_destination,	bin_destination
				FROM VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP WITH(NOLOCK) WHERE requirement_no = @requirement_no

				IF @type='S'
					BEGIN
					--2. Update current_event in TBL_TXN_WORK_ORDER
						UPDATE TBL_SUBCON_TXN_WORK_ORDER
						SET current_event = '21'
						WHERE job_ref_no = @job_ref_no
					END
				ELSE
					BEGIN
						--2. Update current_event in TBL_TXN_WORK_ORDER
						UPDATE TBL_TXN_WORK_ORDER_JOB_DET
						SET current_event = '21'
						WHERE job_ref_no = @job_ref_no
					END

				--3. Delete from tbl_tmp_sap_order
				DELETE FROM TBL_TMP_SAP_ORDER WHERE running_no = @requirement_no

				--4. Insert audit trail
				INSERT INTO TBL_ADM_AUDIT_TRAIL
				(module, key_code, action, action_by, action_date)
				SELECT 'JOB-EVENT-NEW', @job_ref_no, 'TO Created', '1', @CurrentDateTime
			END
			
			SET @i = @i + 1
		END
	END

	DROP TABLE #TEMP_NO
END

GO
