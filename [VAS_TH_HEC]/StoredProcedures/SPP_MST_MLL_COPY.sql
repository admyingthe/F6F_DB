SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ===============================================
-- Author:		Smita Thorat
-- Create date: 2022-07-13
-- Description:	Retrieve uploaded validated MLL list
-- Example Query: exec [SPP_MST_MLL_COPY] @mll_no='',@user_id=8032
-- ===============================================


CREATE PROCEDURE [dbo].[SPP_MST_MLL_COPY]
	@mll_no VARCHAR(100),
	@user_id	INT
AS
BEGIN
	SET NOCOUNT ON;

	--Added to get Thailand Time along with date
	DECLARE @CurrentDateTime AS DATETIME
	SET @CurrentDateTime=(SELECT DATEADD(hh, -1 ,GETDATE()) )
	--Added to get Thailand Time along with date

	DECLARE @client_code VARCHAR(50), @type_of_vas VARCHAR(50), @sub VARCHAR(50), @mll_desc NVARCHAR(200)--, @revision_no nvarchar(100), @revision_no_int INT
	SET @client_code = (SELECT TOP 1 client_code FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_no = @mll_no)
	SET @type_of_vas = (SELECT TOP 1 type_of_vas FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_no = @mll_no)
	SET @sub = (SELECT TOP 1 sub FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_no = @mll_no)
	SET @mll_desc = (SELECT TOP 1 mll_desc FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_no = @mll_no)
	
	DECLARE @new_mll_no VARCHAR(50) = 1, @len INT = 5
	SELECT TOP 1 @new_mll_no = CAST(CAST(RIGHT(mll_no, @len) AS INT) + 1 AS VARCHAR(50))
								FROM (SELECT mll_no FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE client_code = @client_code and type_of_vas = @type_of_vas AND sub = @sub) A ORDER BY CAST(RIGHT(mll_no, @len) AS INT) DESC
	SET @new_mll_no = (SELECT TOP 1 LEFT(mll_no, 11) + REPLICATE('0', @len - LEN(@new_mll_no)) + @new_mll_no FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE client_code = @client_code and type_of_vas = @type_of_vas AND sub = @sub)

	INSERT INTO TBL_MST_MLL_HDR
	(client_code, type_of_vas, sub, mll_no, mll_desc, mll_status, start_date, end_date, 
	created_date, creator_user_id)
	SELECT client_code, type_of_vas, sub, @new_mll_no, @mll_desc, 'Draft', DATEADD(day, 7, GETDATE()), CONVERT(DATETIME, DATEADD(DD,-1,DATEADD(YY,DATEDIFF(YY,0,GETDATE())+1,0)), 126), 
	@CurrentDateTime, @user_id
	FROM TBL_MST_MLL_HDR WITH(NOLOCK)
	WHERE mll_no = @mll_no


	DECLARE @count INT = (SELECT COUNT(*) FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING A WITH(NOLOCK)
						INNER JOIN VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) ON A.page_dtl_id = B.page_dtl_id 
						WHERE principal_code = 'TH-HEC' AND input_name LIKE 'vas_activities_%')

		/***** Temp table for vas activities name *****/
	DECLARE @i INT = 0
	DECLARE @sql NVARCHAR(MAX)
	SET @sql = 'DECLARE @json_activities NVARCHAR(MAX) SET @json_activities = (SELECT Top 1 vas_activities FROM TBL_MST_MLL_DTL A WITH(NOLOCK) INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no WHERE  A.mll_no = ''' + @mll_no + ''' ) '
	CREATE TABLE #TEMPNAME (page_dtl_id INT, input_name VARCHAR(50))
	WHILE @i < @count
	BEGIN
		SET @sql +='INSERT INTO #TEMPNAME (page_dtl_id) SELECT JSON_VALUE(@json_activities, + ''$[' + CAST(@i as varchar(50)) + '].page_dtl_id'')'
		SET @i = @i + 1
	END
	SET @sql += ' DELETE FROM #TEMPNAME WHERE page_dtl_id IS NULL'
	EXEC (@sql)
	UPDATE A
	SET A.input_name = B.input_name
	FROM #TEMPNAME A, VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) WHERE A.page_dtl_id = B.page_dtl_id
	/***** Temp table for vas activities name *****/

	DECLARE @sqlCommand NVARCHAR(MAX), @j INT = 0, @count_tempname INT
	SET @count_tempname = (SELECT COUNT(*) FROM #TEMPNAME)
	SET @sqlCommand = 'CREATE TABLE #TEMP_MLL(mll_no VARCHAR(100), mll_desc NVARCHAR(250), vas_activities NVARCHAR(2000), client_ref_no NVARCHAR(100), prd_code VARCHAR(50), prd_desc NVARCHAR(2000), storage_cond VARCHAR(50), reg_no VARCHAR(50),medical_device_usage VARCHAR(50),bm_ifu VARCHAR(50) ,ppm_by VARCHAR(50), gmp_required VARCHAR(5) ,remarks NVARCHAR(4000), qa_required_view VARCHAR(5), has_attachment_files BIT, lst_attachment_files NVARCHAR(MAX), ' SELECT @sqlCommand += input_name + ' NVARCHAR(2000) NULL,' + input_name + '_radio NVARCHAR(2000) NULL, ' FROM #TEMPNAME
	SET @sqlCommand = LEFT(@sqlCommand , len (@sqlCommand) - 1 ) + ') '

	/*****--SET @sqlCommand += 'DECLARE @json_activities NVARCHAR(MAX) SET @json_activities = (SELECT top 1 vas_activities FROM TBL_MST_MLL_DTL A WITH(NOLOCK) INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no WHERE A.mll_no = ''' + @mll_no + ''') '***/
	SET @sqlCommand += 'DECLARE @column_temp NVARCHAR(MAX), @tmp NVARCHAR(MAX) SELECT @tmp = @tmp + name + '', '' from tempdb.sys.columns where object_id = object_id(''tempdb..#TEMP_MLL'') '
	SET @sqlCommand += 'SET @column_temp = (SELECT SUBSTRING(@tmp, 0, LEN(@tmp)))'
	SET @sqlCommand += 'INSERT INTO #TEMP_MLL '
	SET @sqlCommand += 'SELECT A.mll_no, ISNULL(mll_desc,''''),vas_activities, ISNULL(client_ref_no,''''), A.prd_code, C.prd_desc, storage_cond, registration_no,medical_device_usage,bm_ifu,ppm_by,gmp_required, remarks, qa_required, A.has_attachment_files, A.lst_attachment_files, '
	WHILE @j < @count_tempname
	BEGIN
		SET @sqlCommand += ' JSON_VALUE(vas_activities, + ''$[' + CAST(@j as varchar(50)) + '].prd_code''), ' 
		SET @sqlCommand += ' JSON_VALUE(vas_activities, + ''$[' + CAST(@j as varchar(50)) + '].radio_val'') '
		IF @j <> @count_tempname-1 SET @sqlCommand += ','
		SET @j = @j + 1
	END
	SET @sqlCommand += 'FROM TBL_MST_MLL_DTL A WITH(NOLOCK) INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no INNER JOIN TBL_MST_PRODUCT C WITH(NOLOCK) ON A.prd_code = C.prd_code
				WHERE A.mll_no = ''' + @mll_no + ''''
	
	--SET @sqlCommand += ' SELECT * FROM #TEMP_MLL 
	SET @sqlCommand += ' 	UPDATE	#TEMP_MLL  SET	qa_required_View =CASE WHEN (vas_activities_1_radio = ''Y'' or 
						vas_activities_2_radio  = ''Y'' or 
						vas_activities_3_radio  = ''Y'' or 
						vas_activities_4_radio = ''Y'' or 
						vas_activities_5_radio = ''Y'' or 
						vas_activities_6_radio  = ''Y'' or 
						vas_activities_7_radio = ''Y'' or 
						vas_activities_8_radio = ''Y'' or
						vas_activities_9_radio = ''Y'' or
						vas_activities_10_radio  = ''Y'' or 
						vas_activities_11_radio = ''Y'' or 
						vas_activities_12_radio = ''Y'' or
						vas_activities_13_radio = ''Y''
						
						) THEN   1 ELSE 0 END ;


	INSERT INTO TBL_MST_MLL_DTL
	(mll_no, prd_code, storage_cond, registration_no, medical_device_usage,bm_ifu,ppm_by,gmp_required,remarks, vas_activities, qa_required, has_attachment_files, lst_attachment_files )
	SELECT ''' + @new_mll_no + ''' , prd_code, storage_cond, reg_no,medical_device_usage,bm_ifu, ppm_by,gmp_required,remarks, vas_activities, qa_required_view, has_attachment_files, lst_attachment_files  
	FROM #TEMP_MLL WITH(NOLOCK)

	
	DROP TABLE #TEMP_MLL'

	PRINT(@sqlCommand)
	EXEC(@sqlCommand)
	DROP TABLE #TEMPNAME

	

	INSERT INTO TBL_ADM_AUDIT_TRAIL
	(module, key_code, action, action_by, action_date)
	SELECT 'MLL', @new_mll_no, 'Copied from ' + @mll_no, @user_id, @CurrentDateTime

	SELECT @new_mll_no as new_mll_no
END


GO
