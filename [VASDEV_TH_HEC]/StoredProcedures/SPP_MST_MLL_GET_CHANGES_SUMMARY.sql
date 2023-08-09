SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec SPP_MST_MLL_GET_CHANGES_SUMMARY @param=N'{"mll_no":"MLL043000RD00002"}',@user_id=N'1'
CREATE PROCEDURE [dbo].[SPP_MST_MLL_GET_CHANGES_SUMMARY]
	@param NVARCHAR(MAX),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @mll_no VARCHAR(50), @client_code VARCHAR(50), @sub VARCHAR(50)
	SET @mll_no = (SELECT JSON_VALUE(@param, '$.mll_no'))
	SET @client_code = (SELECT client_code FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_no = @mll_no)
	SET @sub = (SELECT sub FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_no = @mll_no)


	CREATE TABLE #MLL_DTL
	(
		row_different_ind VARCHAR(20),
		client_code	VARCHAR(50),
		client_name	NVARCHAR(200),
		mll_no		VARCHAR(100),
		prd_code	VARCHAR(50),
		prd_desc	NVARCHAR(MAX),
		reg_no	VARCHAR(MAX),
		storage_cond_code VARCHAR(10),
		storage_cond	VARCHAR(MAX),
		remarks		NVARCHAR(MAX),
		vas_activities NVARCHAR(MAX)
	)

	INSERT INTO #MLL_DTL
	(client_code, client_name, mll_no, prd_code, prd_desc, reg_no, storage_cond_code, storage_cond, remarks, vas_activities)
	SELECT B.client_code, C.client_name, A.mll_no, A.prd_code, D.prd_desc, registration_no, storage_cond, E.name, remarks, vas_activities
	FROM TBL_MST_MLL_DTL A WITH(NOLOCK)
	INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no
	INNER JOIN TBL_MST_CLIENT C WITH(NOLOCK) ON B.client_code = C.client_code
	INNER JOIN TBL_MST_PRODUCT D WITH(NOLOCK) ON A.prd_code = D.prd_code
	INNER JOIN TBL_MST_DDL E WITH(NOLOCK) ON A.storage_cond = E.code
	WHERE B.client_code = @client_code AND type_of_vas = 'RD' AND sub = @sub AND B.mll_no = @mll_no

	/*** Find difference between current MLL and last effective MLL ***/
	DECLARE @last_effective_mll_no VARCHAR(50)
	SET @last_effective_mll_no = (SELECT TOP 1 mll_no FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE client_code = @client_code AND type_of_vas = 'RD' AND sub = @sub AND mll_no <> @mll_no AND LTRIM(RTRIM(mll_status)) = 'Approved' AND RIGHT(mll_no, 5) < RIGHT(@mll_no, 5) ORDER BY mll_no DESC)
	
	IF @last_effective_mll_no <> ''
	BEGIN
		SELECT prd_code, storage_cond, registration_no, ISNULL(remarks,'') as remarks, vas_activities INTO #TEMP_DIFF_MLL
		FROM
		(
		SELECT t1.prd_code, t1.storage_cond, isnull(t1.registration_no,'') as registration_no, t1.remarks, t1.vas_activities
		FROM tbl_mst_mll_dtl t1 where mll_no = @mll_no
		UNION ALL
		SELECT t2.prd_code, t2.storage_cond, isnull(t2.registration_no,'') as registration_no, t2.remarks, t2.vas_activities
		FROM tbl_mst_mll_dtl t2 where mll_no = @last_effective_mll_no
		) t
		GROUP BY prd_code, storage_cond, registration_no, remarks, vas_activities
		HAVING COUNT(*) = 1

		UPDATE A
		SET row_different_ind = 'Updated'
		FROM #MLL_DTL A, #TEMP_DIFF_MLL B
		WHERE A.prd_code = B.prd_code --AND A.storage_cond_code = B.storage_cond AND A.reg_no = B.registration_no AND A.remarks = B.remarks AND A.vas_activities = B.vas_activities
		AND @mll_no NOT LIKE '%00001'

		--select @mll_no
		--select * from #MLL_DTL
		--select * from #TEMP_DIFF_MLL
		DROP TABLE #TEMP_DIFF_MLL

		--2 : Newly added
		UPDATE #MLL_DTL
		SET row_different_ind = 'New'
		WHERE prd_code NOT IN (SELECT prd_code FROM TBL_MST_MLL_DTL WHERE mll_no = @last_effective_mll_no)

		--3 : Deleted
		INSERT INTO #MLL_DTL
		(client_code, client_name, mll_no, prd_code, prd_desc, reg_no, storage_cond_code, storage_cond, remarks, vas_activities, row_different_ind)
		SELECT B.client_code, C.client_name, A.mll_no, A.prd_code, D.prd_desc, registration_no, storage_cond, E.name, remarks, vas_activities, 'Deleted'
		FROM TBL_MST_MLL_DTL A WITH(NOLOCK)
		INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no
		INNER JOIN TBL_MST_CLIENT C WITH(NOLOCK) ON B.client_code = C.client_code
		INNER JOIN TBL_MST_PRODUCT D WITH(NOLOCK) ON A.prd_code = D.prd_code
		INNER JOIN TBL_MST_DDL E WITH(NOLOCK) ON A.storage_cond = E.code
		WHERE B.mll_no = @last_effective_mll_no  AND A.prd_code NOT IN (SELECT prd_code FROM TBL_MST_MLL_DTL WITH(NOLOCK) WHERE mll_no = @mll_no )
	END
	/*** Find difference between current MLL and last effective MLL ***/

	/***** Temp table for vas activities name *****/
	DECLARE @count INT = (SELECT COUNT(*) FROM VASDEV.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING A WITH(NOLOCK)
						INNER JOIN VASDEV.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) ON A.page_dtl_id = B.page_dtl_id 
						WHERE principal_code = 'TH-HEC' AND input_name LIKE 'vas_activities_%')

	DECLARE @i INT = 0, @sql NVARCHAR(MAX) = ''
	CREATE TABLE #MLL_TEMPNAME (page_dtl_id INT, input_name VARCHAR(50), display_name NVARCHAR(250))
	WHILE @i < @count
	BEGIN
		SET @sql +=' INSERT INTO #MLL_TEMPNAME (page_dtl_id) SELECT DISTINCT JSON_VALUE(vas_activities, + ''$[' + CAST(@i as varchar(50)) + '].page_dtl_id'') FROM #MLL_DTL'
		SET @i = @i + 1
	END
	SET @sql += ' DELETE FROM #MLL_TEMPNAME WHERE page_dtl_id IS NULL'
	EXEC (@sql)

	UPDATE A
	SET A.input_name = B.input_name
	FROM #MLL_TEMPNAME A, VASDEV.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) WHERE A.page_dtl_id = B.page_dtl_id

	UPDATE A
	SET A.display_name = B.display_name
	FROM #MLL_TEMPNAME A, VASDEV.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING B WITH(NOLOCK) WHERE A.page_dtl_id = B.page_dtl_id AND principal_code = 'TH-HEC'
	/***** Temp table for vas activities name *****/

	DECLARE @sqlCommand NVARCHAR(MAX), @j INT = 0, @count_tempname INT
	SET @count_tempname = (SELECT COUNT(*) FROM #MLL_TEMPNAME)
	SET @sqlCommand = 'CREATE TABLE #MLL_DTL_2(row_different_ind VARCHAR(20), client_code VARCHAR(50), client_name NVARCHAR(200), mll_no VARCHAR(100), prd_code VARCHAR(50), prd_desc NVARCHAR(MAX), reg_no VARCHAR(50), storage_cond_code VARCHAR(10), storage_cond VARCHAR(50), remarks	NVARCHAR(MAX), vas_activities NVARCHAR(MAX),  ' SELECT @sqlCommand += input_name + ' NVARCHAR(2000) NULL, ' FROM #MLL_TEMPNAME WHERE page_dtl_id IS NOT NULL 
	SET @sqlCommand = LEFT(@sqlCommand , len (@sqlCommand) - 1 ) + ') '

	SET @sqlCommand += 'DECLARE @column_temp NVARCHAR(MAX), @tmp NVARCHAR(MAX) SELECT @tmp = @tmp + name + '', '' from tempdb.sys.columns where object_id = object_id(''tempdb..#MLL_DTL_2'') '
	SET @sqlCommand += 'SET @column_temp = (SELECT SUBSTRING(@tmp, 0, LEN(@tmp)))'
	SET @sqlCommand += 'INSERT INTO #MLL_DTL_2 '
	SET @sqlCommand += 'SELECT *, '
	WHILE @j < @count_tempname
	BEGIN
		SET @sqlCommand += ' JSON_VALUE(vas_activities, + ''$[' + CAST(@j as varchar(50)) + '].prd_code'') ' 
		SET @sqlCommand += ' + CASE WHEN JSON_VALUE(vas_activities, + ''$[' + CAST(@j as varchar(50)) + '].radio_val'') = '''' THEN '''' ELSE '' ('' + JSON_VALUE(vas_activities, + ''$[' + CAST(@j as varchar(50)) + '].radio_val'') + '')'' END '
		IF @j <> @count_tempname-1 SET @sqlCommand += ','
		SET @j = @j + 1
	END
	SET @sqlCommand += ' FROM #MLL_DTL WHERE row_different_ind IS NOT NULL SELECT * FROM #MLL_DTL_2 ORDER BY row_different_ind DROP TABLE #MLL_DTL_2'

	IF (SELECT COUNT(*) FROM #MLL_DTL) > 0 EXEC(@sqlCommand) ELSE SELECT * FROM #MLL_DTL


	SELECT * FROM #MLL_TEMPNAME 
	WHERE page_dtl_id IS NOT NULL
	UNION ALL
	SELECT list_dtl_id as page_dtl_id, list_col_name, list_default_display_name as display_name 
	FROM VASDEV.dbo.TBL_ADM_CONFIG_PAGE_LISTING_DTL WITH(NOLOCK)
	WHERE list_hdr_id IN (SELECT list_hdr_id FROM VASDEV.dbo.TBL_ADM_CONFIG_PAGE_LISTING_HDR WITH(NOLOCK) WHERE page_code LIKE 'MLL%') AND list_col_name in (SELECT name FROM tempdb.sys.columns where object_id = object_id('tempdb..#MLL_DTL'))
	UNION ALL
	SELECT '', 'row_different_ind', 'Changes'

	DROP TABLE #MLL_TEMPNAME
	DROP TABLE #MLL_DTL
END

GO
