SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ========================================================================
-- Author:		Ying
-- Create date: 2023-04-04
-- Description: Return PPM product
-- Example Query: exec SPP_TXN_PPM_RETURN @job_ref_no_list=N'G2022/09/00036,G2022/09/00036', @system_running_no_list=N'PPM0000067,PPM0000067', @prd_code_list=N'400019075,400019521', @batch_list=N'0122092,0321001', @returned_qty_list=N'1,2', @user_id=N'8032'

-- V2022/08/0001 [VAS]

-- ========================================================================

--exec SPP_TXN_PPM_RETURN @job_ref_no_list=N'G2022/09/00040',@line_no_list=N'1',@system_running_no_list=N'PPM0000079',@prd_code_list=N'400009863',@batch_list=N'C12345',@returned_qty_list=N'1',@user_id=N'8032'

CREATE PROCEDURE SPP_TXN_PPM_RETURN
	@job_ref_no_list NVARCHAR(MAX),
	@line_no_list NVARCHAR(MAX),
	@system_running_no_list NVARCHAR(MAX),
	@prd_code_list NVARCHAR(MAX),
	@batch_list NVARCHAR(MAX),
	@returned_qty_list NVARCHAR(MAX),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT * INTO #JOB_REF_NO FROM SF_SPLIT(@job_ref_no_list, ',','''')
	SELECT * INTO #LINE_NO FROM SF_SPLIT(@line_no_list, ',','''')
	SELECT * INTO #SYSTEM_RUNNING_NO FROM SF_SPLIT(@system_running_no_list, ',','''')
	SELECT * INTO #PRD_CODE FROM SF_SPLIT(@prd_code_list, ',','''')
	SELECT * INTO #BATCH FROM SF_SPLIT(@batch_list, ',','''')
	SELECT * INTO #RETURNED_QTY FROM SF_SPLIT(@returned_qty_list, ',','''')

	DECLARE @wh_code varchar(10)
	SET @wh_code = (SELECT wh_code FROM VAS.dbo.TBL_ADM_USER WITH(NOLOCK) WHERE user_id = @user_id)  

	CREATE TABLE #OUTPUT_TABLE
	(
		ERROR INT,
		MESSAGE VARCHAR(MAX)
	)
	
	SELECT DISTINCT IDENTITY(INT,1,1) as row_num, A.ID, B.DATA as job_ref_no, C.DATA as line_no, 
	D.DATA as returned_from_system_running_no, A.DATA as prd_code, 
	E.DATA as batch, F.DATA as returned_qty
	INTO #TEMP_PPM
	FROM #PRD_CODE A
	INNER JOIN #JOB_REF_NO B ON A.ID = B.ID
	INNER JOIN #LINE_NO C ON A.ID = C.ID
	INNER JOIN #SYSTEM_RUNNING_NO D ON A.ID = D.ID
	INNER JOIN #BATCH E ON A.ID = E.ID
	INNER JOIN #RETURNED_QTY F ON A.ID = F.ID
	WHERE A.DATA <> 'null'
	AND EXISTS (SELECT 1 FROM TBL_TXN_PPM P WITH(NOLOCK) LEFT JOIN VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP S WITH(NOLOCK) ON P.system_running_no = S.requirement_no AND P.prd_code = S.prd_code AND S.country_code = 'TH' AND P.line_no = S.line_no WHERE A.Data = P.prd_code AND B.Data = P.job_ref_no AND C.Data = P.line_no AND D.Data = P.system_running_no AND S.status = 'R')
	--AND NOT EXISTS (SELECT 1 FROM TBL_TXN_PPM P WITH(NOLOCK) WHERE A.Data = P.prd_code AND B.Data = P.job_ref_no AND C.Data = P.line_no AND system_running_no IS NULL) --data come inside here should not have null system running number
	
	DECLARE @job_ref_no VARCHAR(50), @from_vas_event_running_no VARCHAR(50), @from_line_no INT, @returned_from_system_running_no varchar(50), @prd_code VARCHAR(50), @batch varchar(100), @returned_qty INT, @total_issued_qty int, @total_returned_qty int, @new_line_no INT, @remarks NVARCHAR(MAX), @i INT = 1, @ttl_row INT,
		@ppm_by varchar(100), @expirydate datetime, @mfg_date datetime, @plant varchar(10)
	SET @job_ref_no = (SELECT DISTINCT DATA FROM #JOB_REF_NO)
	SET @from_vas_event_running_no = (SELECT MAX(running_no) FROM TBL_TXN_JOB_EVENT WHERE job_ref_no = @job_ref_no AND event_id = 40)

	SET @ttl_row = (SELECT COUNT(1) FROM #TEMP_PPM)
	WHILE @i <= @ttl_row
	BEGIN
		SELECT @from_line_no = line_no, @returned_from_system_running_no = returned_from_system_running_no, @prd_code = prd_code, @batch = batch, @returned_qty = returned_qty FROM #TEMP_PPM WITH(NOLOCK) WHERE row_num = @i

		SELECT @new_line_no = ISNULL((SELECT MAX(line_no) + 1 FROM TBL_TXN_PPM WITH(NOLOCK) WHERE job_ref_no = @job_ref_no), 1)

		SET @total_returned_qty = (SELECT SUM(issued_qty) from TBL_TXN_PPM WHERE job_ref_no = @job_ref_no AND prd_code = @prd_code AND batch_no = @batch AND action_from_reopen in ('Return') group by job_ref_no, prd_code, batch_no)
		SET @total_issued_qty = (SELECT SUM(issued_qty) from TBL_TXN_PPM WHERE job_ref_no = @job_ref_no AND prd_code = @prd_code AND batch_no = @batch AND (action_from_reopen is null OR action_from_reopen in ('Add')) group by job_ref_no, prd_code, batch_no) 
		SET @total_returned_qty = COALESCE(@total_returned_qty, 0) + @returned_qty
		SET @total_issued_qty = COALESCE(@total_issued_qty, 0) 
		
		SELECT @ppm_by = ppm_by, @expirydate = expirydate, @mfg_date = mfg_date, @plant = plant, @remarks = remarks from TBL_TXN_PPM where job_ref_no = @job_ref_no AND prd_code = @prd_code AND batch_no = @batch AND line_no = @from_line_no
		
		IF @total_issued_qty >= @total_returned_qty
		BEGIN

			-- NEVER update the existing PPM line, we will just add a new returning line
			INSERT INTO TBL_TXN_PPM
			(line_no, job_ref_no, prd_code, issued_qty, remarks, manual_ppm, created_date, creator_user_id, expirydate, batch_no, whs_no, ppm_by, plant, mfg_date, action_from_reopen, reopened_from_VAS_event_running_no, returned_from_line_no, returned_from_job_ref_no)
			VALUES (@new_line_no, @job_ref_no, @prd_code, @returned_qty, concat(coalesce(@remarks, ''), 'Returned from line ', @from_line_no), 1, GETDATE(), @user_id, @expirydate, @batch, @wh_code, @ppm_by, @plant, @mfg_date, 'Return', @from_vas_event_running_no, @from_line_no, @job_ref_no)

			INSERT INTO #OUTPUT_TABLE (ERROR, MESSAGE) VALUES (0, 'Returning PPM saved. ')
		END
		ELSE
		BEGIN
			INSERT INTO #OUTPUT_TABLE (ERROR, MESSAGE) VALUES (1, 'Returning PPM cannot be processed. The returned quantity exceeds the remaining quantity. ')
		END
		SET @i = @i + 1
	END

	INSERT INTO TBL_ADM_AUDIT_TRAIL
	(module, key_code, action , action_by, action_date)
	VALUES('PPM-SEARCH', @job_ref_no, 'Manually returned ' + CAST(@ttl_row as varchar(10)) +  ' PPM material(s)', @user_id, GETDATE())

	SELECT * FROM #OUTPUT_TABLE

	DROP TABLE #TEMP_PPM
	DROP TABLE #JOB_REF_NO 
	DROP TABLE #SYSTEM_RUNNING_NO
	DROP TABLE #PRD_CODE 
	DROP TABLE #BATCH 
	DROP TABLE #RETURNED_QTY 
	DROP TABLE #OUTPUT_TABLE

END

GO
