SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ========================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Add other ppm product
-- Example Query: exec SPP_TXN_PPM_ADD @job_ref_no_list=N'V2022/08/0002',@prd_code_list=N'400019150',@balance_qty_list=N'0',@required_qty_list=N'0'  ,@ppm_by_list=N'Batch',@batch_list=N'220207',@expiry_date_list=N'2025-07-31' ,@mfg_date_list=N'2022-08-01'       ,@user_id=N'8032'
-- Explanation : @balance_qty = required_qty
--				 @required_qty = issued_qty
-- ========================================================================

--SELECT * FROM TBL_TXN_PPM


CREATE PROCEDURE [dbo].[SPP_TXN_PPM_ADD]
	@job_ref_no_list NVARCHAR(MAX),
	@prd_code_list NVARCHAR(MAX),
	@balance_qty_list NVARCHAR(MAX),
	@required_qty_list NVARCHAR(MAX),
	@ppm_by_list NVARCHAR(MAX),
	@batch_list NVARCHAR(MAX),
	@expiry_date_list NVARCHAR(MAX),
	@mfg_date_list NVARCHAR(MAX),
	@plant_list NVARCHAR(MAX),
	@src_prd_code_list NVARCHAR(MAX),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT * INTO #JOB_REF_NO FROM SF_SPLIT(@job_ref_no_list, ',','''')
	SELECT * INTO #PRD_CODE FROM SF_SPLIT(@prd_code_list, ',','''')
	SELECT * INTO #BALANCE_QTY FROM SF_SPLIT(@balance_qty_list, ',','''')
	SELECT * INTO #REQUIRED_QTY FROM SF_SPLIT(@required_qty_list, ',','''')
	-------------------------------------------------------------------
	SELECT * INTO #PPM_BY FROM SF_SPLIT(@ppm_by_list, ',','''')
	SELECT * INTO #BATCH FROM SF_SPLIT(@batch_list, ',','''')
	SELECT * INTO #EXPIRYDATE FROM SF_SPLIT(@expiry_date_list, ',','''')
	SELECT * INTO #MFG_DATE FROM SF_SPLIT(@mfg_date_list, ',','''')
	SELECT * INTO #PLANT FROM SF_SPLIT(@plant_list, ',','''')
	SELECT * INTO #SRC_PRD_CODE FROM SF_SPLIT(@src_prd_code_list, ',','''')
	  ------------------------------------------------------------  

	  UPDATE #MFG_DATE SET DATA=NULL WHERE DATA =' '
  
	  -- Get user warehouse Code-------  
	 DECLARE @wh_code varchar(10)
	 SET @wh_code = (SELECT wh_code FROM VAS.dbo.TBL_ADM_USER WITH(NOLOCK) WHERE user_id = @user_id)  --T50
	 --select @wh_code
	 ------------------------------------------------------------ 
	 

	SELECT DISTINCT IDENTITY(INT,1,1) as row_num, A.ID, D.DATA as job_ref_no, A.DATA as prd_code, B.DATA as balance_qty, C.DATA as required_qty,
	CASE WHEN E.Data='Batch' THEN 'BATCH' ELSE  CASE WHEN E.Data='ExpiryDate' THEN 'EXPIRY DATE' ELSE  CASE WHEN E.Data='MFG_Date' THEN 'MANUFACTURING DATE' ELSE  'NA' END END END as ppm_by,

	CASE WHEN E.Data='Batch' THEN F.DATA ELSE NULL END batch,
	CASE WHEN E.Data='ExpiryDate' THEN G.DATA ELSE NULL END expirydate ,
	CASE WHEN E.Data='MFG_Date' THEN H.DATA ELSE NULL END mfg_date ,
	I.DATA plant ,
	CASE WHEN (J.Data = 'ALL' OR J.Data = '') THEN '' ELSE J.Data END src_prd_code
	INTO #TEMP_PPM
	FROM #PRD_CODE A
	INNER JOIN #BALANCE_QTY B ON A.ID = B.ID
	INNER JOIN #REQUIRED_QTY C ON A.ID = C.ID
	INNER JOIN #JOB_REF_NO D ON A.ID = D.ID
	-----
	INNER JOIN #PPM_BY E ON A.ID = E.ID
	INNER JOIN #BATCH F ON A.ID = F.ID
	INNER JOIN #EXPIRYDATE G ON A.ID = G.ID
	INNER JOIN #MFG_DATE H ON A.ID = H.ID
	INNER JOIN #PLANT I ON A.ID = I.ID
	INNER JOIN #SRC_PRD_CODE J ON A.ID = J.ID
	----
	WHERE A.DATA <> 'null'
	AND A.DATA IN (SELECT prd_code FROM TBL_MST_PRODUCT WITH(NOLOCK) WHERE prd_type like 'ZPK%')
	AND NOT EXISTS(SELECT 1 FROM TBL_TXN_PPM K WITH(NOLOCK) WHERE A.Data = K.prd_code AND manual_ppm = 1 AND D.Data = K.job_ref_no AND system_running_no IS NULL AND K.ppm_by = E.Data AND K.src_prd_code = J.Data)

	DECLARE @job_ref_no VARCHAR(50), @prd_code VARCHAR(50), @balance_qty INT, @required_qty INT, @line_no INT, @i INT = 1, @ttl_row INT, 
	@ppm_by VARCHAR(100), @batch VARCHAR(100), @expiry_date VARCHAR(100), @mfg_date VARCHAR(100), @plant VARCHAR(100), @src_prd_code VARCHAR(50), 
	@from_vas_event_running_no VARCHAR(50), @currently_reopened_PPM VARCHAR(50)
	SET @job_ref_no = (SELECT DISTINCT DATA FROM #JOB_REF_NO)

	SET @from_vas_event_running_no = (SELECT TOP 1 running_no FROM TBL_TXN_JOB_EVENT WHERE job_ref_no = @job_ref_no ORDER BY running_no desc)
	SELECT @currently_reopened_PPM = currently_reopened_PPM FROM TBL_TXN_JOB_EVENT WHERE job_ref_no = @job_ref_no AND running_no = @from_vas_event_running_no AND event_id = 40

	SET @ttl_row = (SELECT COUNT(1) FROM #TEMP_PPM)
	WHILE @i <= @ttl_row
	BEGIN
		SELECT @prd_code = prd_code, @balance_qty = balance_qty, @required_qty = required_qty,
		@ppm_by = ppm_by, @batch = batch, @expiry_date = expirydate, @mfg_date = mfg_date, @plant = plant, @src_prd_code = src_prd_code FROM #TEMP_PPM WITH(NOLOCK) WHERE row_num = @i

		SELECT @line_no = ISNULL((SELECT MAX(line_no) + 1 FROM TBL_TXN_PPM WITH(NOLOCK) WHERE job_ref_no = @job_ref_no), 1)

		IF @balance_qty = 0 -- For non-leftover PPM that is maintained in MLL originally
			INSERT INTO TBL_TXN_PPM
			(line_no, job_ref_no, prd_code, required_qty, issued_qty, manual_ppm, created_date, creator_user_id, whs_no, ppm_by, batch_no, expirydate, mfg_date, plant, action_from_reopen, reopened_from_VAS_event_running_no, src_prd_code)
			VALUES(@line_no, @job_ref_no, @prd_code, @required_qty, @balance_qty, 1, GETDATE(), @user_id, @wh_code, @ppm_by, @batch, @expiry_date, @mfg_date, @plant, CASE WHEN @currently_reopened_PPM = 1 THEN 'Add' ELSE NULL END, @from_vas_event_running_no, @src_prd_code)
		ELSE
			INSERT INTO TBL_TXN_PPM
			(line_no, job_ref_no, prd_code, required_qty, issued_qty, manual_ppm, created_date, creator_user_id, whs_no, ppm_by, batch_no, expirydate, mfg_date, plant, action_from_reopen, reopened_from_VAS_event_running_no, src_prd_code)
			VALUES(@line_no, @job_ref_no, @prd_code, @balance_qty, @required_qty, 1, GETDATE(), @user_id, @wh_code, @ppm_by, @batch, @expiry_date, @mfg_date, @plant, CASE WHEN @currently_reopened_PPM = 1 THEN 'Add' ELSE NULL END, @from_vas_event_running_no, @src_prd_code)

		SET @i = @i + 1
	END
	
	INSERT INTO TBL_ADM_AUDIT_TRAIL	(module, key_code, action, action_by, action_date)
	VALUES ('PPM-SEARCH', @job_ref_no, 'Manually added ' + CAST(@ttl_row as varchar(10)) + ' PPM material(s)', @user_id, GETDATE())

	DROP TABLE #TEMP_PPM
	DROP TABLE #JOB_REF_NO
	DROP TABLE #PRD_CODE
	DROP TABLE #BALANCE_QTY
	DROP TABLE #REQUIRED_QTY
	DROP TABLE #SRC_PRD_CODE
END

GO
