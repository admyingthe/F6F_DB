SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==================================================================================================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Retrieve MLL Details
-- Example Query: exec SPP_MST_MLL_DTL @param=N'{"client_code":"0091","type_of_vas":"RD","mll_no":"MLL009101RD00001","prd_code":"100161158","sub":"01"}',@user_id=8032
-- ===================================================================================================================================================================

CREATE PROCEDURE [dbo].[SPP_MST_MLL_DTL] 
	@param NVARCHAR(MAX),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @client_code VARCHAR(50), @type_of_vas VARCHAR(50), @sub VARCHAR(50), @mll_no VARCHAR(100), @prd_code VARCHAR(50)
	SET @client_code = (SELECT JSON_VALUE(@param, '$.client_code'))
    SET @type_of_vas = (SELECT JSON_VALUE(@param, '$.type_of_vas'))
	SET @sub = (SELECT JSON_VALUE(@param, '$.sub'))
	SET @mll_no = (SELECT JSON_VALUE(@param, '$.mll_no'))
	SET @prd_code = (SELECT JSON_VALUE(@param, '$.prd_code'))

	DECLARE @count INT = (SELECT COUNT(*) FROM VASDEV.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING A WITH(NOLOCK)
						INNER JOIN VASDEV.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) ON A.page_dtl_id = B.page_dtl_id 
						WHERE principal_code = 'TH-HEC' AND input_name LIKE 'vas_activities_%')

	/***** Temp table for vas activities name *****/
	DECLARE @i INT = 0
	DECLARE @sql NVARCHAR(MAX)
	SET @sql = 'DECLARE @json_activities NVARCHAR(MAX) SET @json_activities = (SELECT vas_activities FROM TBL_MST_MLL_DTL A WITH(NOLOCK) INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no WHERE client_code = ''' + @client_code + ''' AND type_of_vas = ''' + @type_of_vas + ''' AND sub = ''' + @sub + ''' AND A.mll_no = ''' + @mll_no + ''' AND prd_code = ''' + @prd_code + ''') '
	CREATE TABLE #TEMPNAME (page_dtl_id INT, input_name VARCHAR(50))
	WHILE @i < @count
	BEGIN
		SET @sql +='INSERT INTO #TEMPNAME (page_dtl_id) SELECT JSON_VALUE(@json_activities, + ''$[' + CAST(@i as varchar(50)) + '].page_dtl_id'')'
		SET @i = @i + 1
	END
	SET @sql += ' DELETE FROM #TEMPNAME WHERE page_dtl_id IS NULL'
	EXEC (@sql)

	print (@sql)


	UPDATE A
	SET A.input_name = B.input_name
	FROM #TEMPNAME A, VASDEV.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) WHERE A.page_dtl_id = B.page_dtl_id
	/***** Temp table for vas activities name *****/

	DECLARE @sqlCommand NVARCHAR(MAX), @j INT = 0, @count_tempname INT
	SET @count_tempname = (SELECT COUNT(*) FROM #TEMPNAME)
	SET @sqlCommand = 'CREATE TABLE #TEMP_MLL(mll_no VARCHAR(100), mll_desc NVARCHAR(250), client_ref_no NVARCHAR(100), revision_no NVARCHAR(100), prd_code VARCHAR(50), prd_desc NVARCHAR(2000), storage_cond VARCHAR(50), reg_no  NVARCHAR(4000),medical_device_usage VARCHAR(50),bm_ifu VARCHAR(50) ,ppm_by VARCHAR(50) ,gmp_required VARCHAR(5),remarks NVARCHAR(4000), qa_required_view VARCHAR(5), ' SELECT @sqlCommand += input_name + ' NVARCHAR(2000) NULL,' + input_name + '_radio NVARCHAR(2000) NULL, ' FROM #TEMPNAME
	SET @sqlCommand = LEFT(@sqlCommand , len (@sqlCommand) - 1 ) + ') '

	SET @sqlCommand += 'DECLARE @json_activities NVARCHAR(MAX) SET @json_activities = (SELECT vas_activities FROM TBL_MST_MLL_DTL A WITH(NOLOCK) INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no WHERE client_code = ''' + @client_code + ''' AND type_of_vas = ''' + @type_of_vas + ''' AND A.mll_no = ''' + @mll_no + ''' AND prd_code = ''' + @prd_code + ''') '
	SET @sqlCommand += 'DECLARE @column_temp NVARCHAR(MAX), @tmp NVARCHAR(MAX) SELECT @tmp = @tmp + name + '', '' from tempdb.sys.columns where object_id = object_id(''tempdb..#TEMP_MLL'') '
	SET @sqlCommand += 'SET @column_temp = (SELECT SUBSTRING(@tmp, 0, LEN(@tmp)))'
	SET @sqlCommand += 'INSERT INTO #TEMP_MLL '
	SET @sqlCommand += 'SELECT A.mll_no, ISNULL(mll_desc,''''), ISNULL(client_ref_no,''''), ISNULL(revision_no, ''''), A.prd_code, C.prd_desc, storage_cond, registration_no,medical_device_usage,bm_ifu,ppm_by,gmp_required, remarks, qa_required, '
	WHILE @j < @count_tempname
	BEGIN
		SET @sqlCommand += ' JSON_VALUE(@json_activities, + ''$[' + CAST(@j as varchar(50)) + '].prd_code''), ' 
		SET @sqlCommand += ' JSON_VALUE(@json_activities, + ''$[' + CAST(@j as varchar(50)) + '].radio_val'') '
		IF @j <> @count_tempname-1 SET @sqlCommand += ','
		SET @j = @j + 1
	END
	SET @sqlCommand += 'FROM TBL_MST_MLL_DTL A WITH(NOLOCK) INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no INNER JOIN TBL_MST_PRODUCT C WITH(NOLOCK) ON A.prd_code = C.prd_code
				WHERE client_code = ''' + @client_code + ''' AND type_of_vas = ''' + @type_of_vas + ''' AND B.mll_no = ''' + @mll_no + ''' AND A.prd_code = ''' + @prd_code + ''''
	
	SET @sqlCommand += ' SELECT * FROM #TEMP_MLL DROP TABLE #TEMP_MLL'
	PRINT(@sqlCommand)
	EXEC(@sqlCommand)
	DROP TABLE #TEMPNAME
END

GO
