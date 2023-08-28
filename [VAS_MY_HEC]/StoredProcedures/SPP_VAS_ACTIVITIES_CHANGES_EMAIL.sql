SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_VAS_ACTIVITIES_CHANGES_EMAIL]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT A.mll_no, A.prd_code, start_date, end_date,
	json_value(vas_activities, '$[0].radio_val') as radio_val_1, 
	json_value(vas_activities, '$[1].radio_val') as radio_val_2, 
	json_value(vas_activities, '$[2].radio_val') as radio_val_3,
	json_value(vas_activities, '$[3].radio_val') as radio_val_4, 
	json_value(vas_activities, '$[4].radio_val') as radio_val_5, 
	json_value(vas_activities, '$[5].radio_val') as radio_val_6, 
	json_value(vas_activities, '$[6].radio_val') as radio_val_7, 
	json_value(vas_activities, '$[7].radio_val') as radio_val_8, 
	json_value(vas_activities, '$[8].radio_val') as radio_val_9, CAST(NULL as VARCHAR(10)) as radio_val
	INTO #temp_vas_activities
	FROM TBL_MST_MLL_DTL A WITH(NOLOCK)
	INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no
	WHERE A.mll_no IN 
	(SELECT mll_no FROM TBL_MST_MLL_HDR where RTRIM(LTRIM(mll_status)) = 'Approved' 
	AND getdate() between start_date and end_date
	--AND CONVERT(VARCHAR(10), approved_date, 121) = CONVERT(VARCHAR(10), GETDATE()-1, 121) 
	AND (sent_email_flag = 0 OR sent_email_flag IS NULL)) --CONVERT(VARCHAR(10), GETDATE()-1, 121)

	UPDATE #temp_vas_activities
	SET radio_val = CASE WHEN (radio_val_1 IN ('Y','P')
						   OR radio_val_2 IN ('Y','P')
						   OR radio_val_3 IN ('Y','P')
						   OR radio_val_4 IN ('Y','P')
						   OR radio_val_5 IN ('Y','P')
						   OR radio_val_6 IN ('Y','P')
						   OR radio_val_7 IN ('Y','P')
						   OR radio_val_8 IN ('Y','P')
						   OR radio_val_9 IN ('Y','P')) THEN 'Y' ELSE 'N' END

	CREATE TABLE #temp_vas 
	(row INT IDENTITY(1,1), 
	mll_no VARCHAR(50), 
	prd_code VARCHAR(50), 
	effective_start_date VARCHAR(10), 
	effective_end_date VARCHAR(10), 
	current_val VARCHAR(10), 
	supercedes_mll_no VARCHAR(50), 
	old_val VARCHAR(10), 
	to_trigger INT)

	INSERT INTO #temp_vas(mll_no, prd_code, effective_start_date, effective_end_date, current_val)
	SELECT mll_no, prd_code, CONVERT(VARCHAR(10), start_date, 121), CONVERT(VARCHAR(10), end_date, 121), radio_val FROM #temp_vas_activities

	DROP TABLE #temp_vas_activities

	SELECT DISTINCT IDENTITY (INT, 1, 1) AS row_num, mll_no, CAST(NULL as VARCHAR(50)) as supercedes_mll_no INTO #GET_SUPERCEDES_MLL FROM #temp_vas

	DECLARE @i INT = 1, @selected_mll_no VARCHAR(50), @supercedes_mll_no VARCHAR(50)
	WHILE @i <= (SELECT COUNT(1) FROM #GET_SUPERCEDES_MLL)
	BEGIN
		SET @selected_mll_no = (SELECT mll_no FROM #GET_SUPERCEDES_MLL WHERE row_num = @i)
		SET @supercedes_mll_no = ISNULL((SELECT TOP 1 mll_no FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE client_code = ( SELECT substring(@selected_mll_no, 4, 4) ) AND type_of_vas = 'RD' AND sub = (select substring(@selected_mll_no, 8, 2)) AND mll_no < @selected_mll_no AND mll_status = 'Approved' ORDER BY mll_no DESC),'')
	
		UPDATE #GET_SUPERCEDES_MLL
		SET supercedes_mll_no = @supercedes_mll_no
		WHERE row_num = @i

		SET @i = @i + 1
	END

	UPDATE A
	SET supercedes_mll_no = B.supercedes_mll_no
	FROM #temp_vas A
	INNER JOIN #GET_SUPERCEDES_MLL B ON A.mll_no = B.mll_no

	UPDATE A
	SET old_val = 'Y'
	FROM #temp_vas A
	WHERE EXISTS (SELECT * FROM TBL_TMP_MLL_VAS_ACTIVITIES B WHERE A.supercedes_mll_no = B.mll_no AND A.prd_code = B.prd_code)

	UPDATE #temp_vas
	SET old_val = 'N'
	WHERE old_val IS NULL

	UPDATE #temp_vas
	SET to_trigger = 1
	WHERE current_val <> old_val

	INSERT INTO TBL_TMP_MLL_VAS_ACTIVITIES
	SELECT mll_no, prd_code, current_val FROM #temp_vas WHERE current_val = 'Y'

	--IF (SELECT COUNT(1) FROM #temp_vas WHERE to_trigger = 1) > 0
	--BEGIN

	--	SELECT  mll_no, prd_code, effective_start_date, effective_end_date, ISNULL(old_val,'') as old_val, current_val
	--	INTO ##temp_vas_2
	--	FROM #temp_vas
	--	WHERE to_trigger = 1

	--	-- write into excel where to_trigger = 1 and send out the email
	--	DECLARE @file_name NVARCHAR(200), @sql NVARCHAR(4000)
	--	SET @file_name = 'D:\VAS\MY-HEC\VASTrigger_' + CONVERT(VARCHAR(10), GETDATE(), 121) + '.xls'
	--	SET @sql = 'bcp "SELECT ''MLL No'', ''Product Code'', ''Effective Start Date'', ''Effective End Date'', ''Previous Value'', ''New Value'' union all SELECT * FROM tempdb..##temp_vas_2" queryout ' + @file_name + ' -S 10.208.7.129 -U EPAdmin -P Dkshcssc00 -w -r \n'
	--	EXEC master..xp_cmdshell @sql

	--	EXEC msdb.dbo.sp_send_dbmail
	--		@profile_name = 'VASMail',
	--		@recipients = 'shen.yee.siow@dksh.com',
	--		--@copy_recipients = @copy_recipients_email,
	--		--@blind_copy_recipients = 'shen.yee.siow@dksh.com', 
	--		@subject = '[VAS Testing] GMP / NON-GMP',
	--		@body = 'Testing',
	--		@attach_query_result_as_file = 0,
	--		@body_format ='HTML',
	--		@importance = 'NORMAL',
	--		@file_attachments = @file_name;

	--	DROP TABLE ##temp_vas_2
	--END

	UPDATE TBL_MST_MLL_HDR
	SET sent_email_flag = 1
	WHERE mll_no IN (SELECT mll_no FROM #GET_SUPERCEDES_MLL)

	DELETE FROM TBL_TMP_MLL_VAS_ACTIVITIES WHERE mll_no IN (SELECT supercedes_mll_no FROM #GET_SUPERCEDES_MLL)

	--SELECT * FROM TBL_TMP_MLL_VAS_ACTIVITIES
	--select * from #GET_SUPERCEDES_MLL
	--select * from #temp_vas

	DROP TABLE #GET_SUPERCEDES_MLL
	DROP TABLE #temp_vas
END

GO
