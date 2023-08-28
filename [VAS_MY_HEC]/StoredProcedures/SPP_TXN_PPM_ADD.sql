SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ========================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Add other ppm product
-- Example Query: exec SPP_TXN_PPM_ADD @job_ref_no_list=N'2018/07/0007',@prd_code_list=N'450000010',@balance_qty_list=N'10',@required_qty_list=N'10',@user_id=N'1'
-- Explanation : @balance_qty = required_qty
--				 @required_qty = issued_qty
-- ========================================================================

CREATE PROCEDURE [dbo].[SPP_TXN_PPM_ADD]
	@job_ref_no_list NVARCHAR(MAX),
	@prd_code_list NVARCHAR(MAX),
	@balance_qty_list NVARCHAR(MAX),
	@required_qty_list NVARCHAR(MAX),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT * INTO #JOB_REF_NO FROM SF_SPLIT(@job_ref_no_list, ',','''')
	SELECT * INTO #PRD_CODE FROM SF_SPLIT(@prd_code_list, ',','''')
	SELECT * INTO #BALANCE_QTY FROM SF_SPLIT(@balance_qty_list, ',','''')
	SELECT * INTO #REQUIRED_QTY FROM SF_SPLIT(@required_qty_list, ',','''')

	SELECT DISTINCT IDENTITY(INT,1,1) as row_num, A.ID, D.DATA as job_ref_no, A.DATA as prd_code, B.DATA as balance_qty, C.DATA as required_qty
	INTO #TEMP_PPM
	FROM #PRD_CODE A
	INNER JOIN #BALANCE_QTY B ON A.ID = B.ID
	INNER JOIN #REQUIRED_QTY C ON A.ID = C.ID
	INNER JOIN #JOB_REF_NO D ON A.ID = D.ID
	WHERE A.DATA <> 'null'
	AND A.DATA IN (SELECT prd_code FROM TBL_MST_PRODUCT WITH(NOLOCK) WHERE prd_type = 'ZPK4')
	AND NOT EXISTS(SELECT 1 FROM TBL_TXN_PPM E WITH(NOLOCK) WHERE A.Data = E.prd_code AND manual_ppm = 1 AND D.Data = E.job_ref_no AND system_running_no IS NULL)

	DECLARE @job_ref_no VARCHAR(50), @prd_code VARCHAR(50), @balance_qty INT, @required_qty INT, @line_no INT, @i INT = 1, @ttl_row INT
	SET @job_ref_no = (SELECT DISTINCT DATA FROM #JOB_REF_NO)

	SET @ttl_row = (SELECT COUNT(1) FROM #TEMP_PPM)
	WHILE @i <= @ttl_row
	BEGIN
		SELECT @prd_code = prd_code, @balance_qty = balance_qty, @required_qty = required_qty FROM #TEMP_PPM WITH(NOLOCK) WHERE row_num = @i
		SELECT @line_no = ISNULL((SELECT MAX(line_no) + 1 FROM TBL_TXN_PPM WITH(NOLOCK) WHERE job_ref_no = @job_ref_no),1)

		IF @balance_qty = 0 -- For non-leftover PPM that is maintained in MLL originally
			INSERT INTO TBL_TXN_PPM
			(line_no, job_ref_no, prd_code, required_qty, issued_qty, manual_ppm, created_date, creator_user_id)
			VALUES(@line_no, @job_ref_no, @prd_code, @required_qty, @balance_qty, 1, GETDATE(), @user_id)
		ELSE
			INSERT INTO TBL_TXN_PPM
			(line_no, job_ref_no, prd_code, required_qty, issued_qty, manual_ppm, created_date, creator_user_id)
			VALUES(@line_no, @job_ref_no, @prd_code, @balance_qty, @required_qty, 1, GETDATE(), @user_id)

		SET @i = @i + 1
	END
	
	INSERT INTO TBL_ADM_AUDIT_TRAIL
	(module, key_code, action , action_by, action_date)
	VALUES('PPM-SEARCH', @job_ref_no, 'Manually added ' + CAST(@ttl_row as varchar(10)) +  ' PPM material(s)', @user_id, GETDATE())

	DROP TABLE #TEMP_PPM
	DROP TABLE #JOB_REF_NO
	DROP TABLE #PRD_CODE
	DROP TABLE #BALANCE_QTY
	DROP TABLE #REQUIRED_QTY
END

GO
