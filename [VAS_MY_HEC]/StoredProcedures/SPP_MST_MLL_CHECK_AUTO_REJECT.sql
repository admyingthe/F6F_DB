SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPP_MST_MLL_CHECK_AUTO_REJECT]
AS
BEGIN
	SET NOCOUNT ON;

	/** Urgent MLL **/
	DECLARE @urgent_new_date DATETIME
	SET @urgent_new_date = GETDATE()

	--SELECT *, CAST(NULL as VARCHAR(10)) as is_not_wd INTO #CHECK_WD_URGENT
	--FROM dbo.DateRange_To_Table (GETDATE(),@urgent_new_date)

	--UPDATE #CHECK_WD_URGENT
	--SET is_not_wd = 'Y'
	--WHERE DateString IN (SELECT CONVERT(VARCHAR(10), date, 121) FROM TBL_MST_WEEKEND)
	--OR DateString IN(SELECT CONVERT(VARCHAR(10), date, 121) FROM TBL_MST_PUBLIC_HOLIDAY)

	--DECLARE @urgent_days_to_add INT
	--SET @urgent_days_to_add = (SELECT COUNT(1) FROM #CHECK_WD_URGENT WHERE is_not_wd = 'Y')

	--DECLARE @urgent_cut_off_date DATETIME
	--SET @urgent_cut_off_date = @urgent_new_date + @urgent_days_to_add

	SELECT * INTO #CHECK_WD_URGENT FROM dbo.[TF_COR_GET_WORKING_DAYS](@urgent_new_date, 1)

	DECLARE @urgent_cut_off_date DATETIME
	SET @urgent_cut_off_date = (SELECT TOP 1 working_day FROM #CHECK_WD_URGENT ORDER BY s_no DESC)

	SELECT mll_no, submitted_by, email INTO #TO_BE_REJECTED_URGENT
	FROM TBL_MST_MLL_HDR A WITH(NOLOCK)
	INNER JOIN VAS.dbo.TBL_ADM_USER B WITH(NOLOCK) ON A.submitted_by = B.user_id
	WHERE mll_urgent = 'Y' AND LTRIM(RTRIM(mll_status)) = 'Submitted' AND CONVERT(VARCHAR(10), start_date, 121) <= CONVERT(VARCHAR(10), @urgent_cut_off_date, 121)

	UPDATE TBL_MST_MLL_HDR
	SET mll_status = 'Rejected',
		rejected_date = GETDATE(),
		rejected_by = '1',
		rejection_reason = '[System Auto Reject] Pass cut of date of 1 WD'
	WHERE mll_no IN (SELECT mll_no FROM #TO_BE_REJECTED_URGENT)

	DROP TABLE #CHECK_WD_URGENT
	/** Urgent MLL **/

	/** Normal MLL **/
	DECLARE @normal_new_date DATETIME
	SET @normal_new_date = GETDATE()

	--SELECT *, CAST(NULL as VARCHAR(10)) as is_not_wd INTO #CHECK_WD_NORMAL
	--FROM dbo.DateRange_To_Table (GETDATE(),@normal_new_date)

	--UPDATE #CHECK_WD_NORMAL
	--SET is_not_wd = 'Y'
	--WHERE DateString IN (SELECT CONVERT(VARCHAR(10), date, 121) FROM TBL_MST_WEEKEND)
	--OR DateString IN(SELECT CONVERT(VARCHAR(10), date, 121) FROM TBL_MST_PUBLIC_HOLIDAY)

	--DECLARE @normal_days_to_add INT
	--SET @normal_days_to_add = (SELECT COUNT(1) FROM #CHECK_WD_NORMAL WHERE is_not_wd = 'Y')

	--DECLARE @normal_cut_off_date DATETIME
	--SET @normal_cut_off_date = @normal_new_date + @normal_days_to_add

	SELECT * INTO #CHECK_WD_NORMAL FROM dbo.[TF_COR_GET_WORKING_DAYS](@normal_new_date, 3)

	DECLARE @normal_cut_off_date DATETIME
	SET @normal_cut_off_date = (SELECT TOP 1 working_day FROM #CHECK_WD_NORMAL ORDER BY s_no DESC)

	SELECT mll_no, submitted_by, email INTO #TO_BE_REJECTED_NORMAL
	FROM TBL_MST_MLL_HDR A WITH(NOLOCK)
	INNER JOIN VAS.dbo.TBL_ADM_USER B WITH(NOLOCK) ON A.submitted_by = B.user_id
	WHERE mll_urgent <> 'Y' AND LTRIM(RTRIM(mll_status)) = 'Submitted' AND CONVERT(VARCHAR(10), start_date, 121) <= CONVERT(VARCHAR(10), @normal_cut_off_date, 121)

	UPDATE TBL_MST_MLL_HDR
	SET mll_status = 'Rejected',
		rejected_date = GETDATE(),
		rejected_by = '1',
		rejection_reason = '[System Auto Reject] Pass cut of date of 3 WD'
	WHERE mll_no IN (SELECT mll_no FROM #TO_BE_REJECTED_NORMAL)

	DROP TABLE #CHECK_WD_NORMAL
	/** Normal MLL **/

	CREATE TABLE #ALL_MLL
	(
		row_num INT IDENTITY(1,1),
		mll_no VARCHAR(50),
		email VARCHAR(200)
	)
	INSERT INTO #ALL_MLL(mll_no, email)
	SELECT mll_no, email FROM #TO_BE_REJECTED_NORMAL
	UNION ALL
	SELECT mll_no, email FROM #TO_BE_REJECTED_URGENT

	DECLARE @profile_name VARCHAR(50)
	SET @profile_name = (SELECT config_value FROM VAS.dbo.TBL_ADM_CONFIGURATION WITH(NOLOCK) WHERE config = 'email_profile_name')

	DECLARE @i INT, @mll_no VARCHAR(50), @email VARCHAR(100), @subject NVARCHAR(400) 
	SET @i = 1
	WHILE @i <= (SELECT COUNT(1) FROM #ALL_MLL) 
    BEGIN
        SET @mll_no = (SELECT mll_no FROM #ALL_MLL WHERE row_num = @i) 
        SET @email = (SELECT email FROM #ALL_MLL WHERE row_num = @i) 
        SET @subject = '[VAS Testing] ' + @mll_no + ' is Auto Rejected by System due to Overdue' 

        EXEC msdb.dbo.sp_send_dbmail 
        @profile_name = @profile_name, 
        @recipients = @email,
        --@copy_recipients = @copy_recipients_email, 
        @blind_copy_recipients = 'shen.yee.siow@dksh.com',  
        @subject = @subject, 
        @body = 'This is a testing site. Please copy and review the validity period', 
        @attach_query_result_as_file = 0, 
        @body_format ='HTML',
        @importance = 'NORMAL' 
        SET @i = @i + 1 
    END 

	DROP TABLE #TO_BE_REJECTED_NORMAL
	DROP TABLE #TO_BE_REJECTED_URGENT
	DROP TABLE #ALL_MLL
END
GO
