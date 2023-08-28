SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Retrieve MLL listing
-- Example Query: exec SPP_MST_MLL_LISTING @param=N'{"client":"0128","type_of_vas":"RD","sub":"00","page_index":0,"page_size":10,"search_term":"","selected_mll_no":"","export_ind":0}'
-- Output:
-- 1) dtCount - Total rows
-- 2) dtHdr - Header
-- 3) dtDtl - Details
-- 4) dtExportInd - Export indicator
-- 5) dtAuditTrail - Audit trail
-- 6) dtExportColumnName - Export column display name
-- ======================================================================================================================================

CREATE PROCEDURE [dbo].[SPP_MST_MLL_LISTING]
	@param	nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @client VARCHAR(50), @type_of_vas VARCHAR(50), @sub VARCHAR(50), @page_index INT, @page_size INT, @search_term NVARCHAR(100), @selected_mll_no VARCHAR(100), @export_ind CHAR(1),@wh_code VARCHAR(50)
	SET @client = (SELECT JSON_VALUE(@param, '$.client'))
	SET @type_of_vas = (SELECT JSON_VALUE(@param, '$.type_of_vas'))
	SET @sub = (SELECT JSON_VALUE(@param, '$.sub'))
	SET @page_index = (SELECT JSON_VALUE(@param, '$.page_index'))
	SET @page_size = (SELECT JSON_VALUE(@param, '$.page_size'))
	SET @search_term = (SELECT JSON_VALUE(@param, '$.search_term'))
	SET @selected_mll_no = (SELECT JSON_VALUE(@param, '$.selected_mll_no'))
	SET @export_ind = (SELECT JSON_VALUE(@param, '$.export_ind'))

	IF @selected_mll_no = ''
	BEGIN
		SET @selected_mll_no = (SELECT TOP 1 mll_no FROM TBL_MST_MLL_HDR WHERE client_code = @client AND type_of_vas = @type_of_vas AND sub = @sub ORDER BY mll_no DESC)
	END


		SET @wh_code=(SELECT wh_code FROM TBL_MST_CLIENT_SUB WHERE sub_code=@sub AND client_code=@client)

	/***** Header *****/
	SELECT mll_no, mll_desc, CONVERT(VARCHAR(10), start_date, 121) as start_date, CONVERT(VARCHAR(10), end_date, 121) as end_date, 
	CASE WHEN LTRIM(RTRIM(mll_status)) = 'Submitted' THEN 'Submitted by ' + B.user_name + ' on ' + CONVERT(VARCHAR(10),submitted_date, 121)
	     WHEN LTRIM(RTRIM(mll_status)) = 'Approved' THEN 'Approved by ' + C.user_name + ' on ' + CONVERT(VARCHAR(10),approved_date, 121)
		 WHEN LTRIM(RTRIM(mll_status)) = 'Rejected' THEN 'Rejected by ' + D.user_name + ' on ' + CONVERT(VARCHAR(10),rejected_date, 121) + ' (' + rejection_reason + ')'
	ELSE LTRIM(RTRIM(mll_status)) END as mll_status,
	E.dept_name as department, ISNULL(mll_change_remarks, '') as mll_change_remarks, ISNULL(mll_urgent, '') as mll_urgent,@wh_code wh_code
	INTO #MLL_HDR 
	FROM TBL_MST_MLL_HDR A WITH(NOLOCK)
	LEFT JOIN VAS.dbo.TBL_ADM_USER B WITH(NOLOCK) ON A.submitted_by = B.user_id 
	LEFT JOIN VAS.dbo.TBL_ADM_USER C WITH(NOLOCK) ON A.approved_by = C.user_id
	LEFT JOIN VAS.dbo.TBL_ADM_USER D WITH(NOLOCK) ON A.rejected_by = D.user_id
	LEFT JOIN VAS.dbo.TBL_ADM_USER F WITH(NOLOCK) ON A.creator_user_id = F.user_id
	LEFT JOIN TBL_MST_DEPARTMENT E WITH(NOLOCK) ON F.department = E.dept_code
	WHERE mll_no = @selected_mll_no
	/******************/

	/***** Details *****/
	CREATE TABLE #MLL_DTL
	(
		client_code	VARCHAR(50),
		client_name	NVARCHAR(200),
		mll_no		VARCHAR(100),
		prd_code	VARCHAR(50),
		prd_desc	NVARCHAR(MAX),
		reg_no	VARCHAR(MAX),
		storage_cond_code VARCHAR(10),
		storage_cond	VARCHAR(MAX),
		medical_device_usage_code VARCHAR(10),
		medical_device_usage	VARCHAR(MAX),
		bm_ifu_code VARCHAR(10),
		bm_ifu VARCHAR(MAX),
		remarks		NVARCHAR(MAX),
		vas_activities NVARCHAR(MAX),
		qa_required INT,
		row_different_ind CHAR(1) DEFAULT 0
	)

	IF @search_term <> ''
	BEGIN
		INSERT INTO #MLL_DTL
		(client_code, client_name, mll_no, prd_code, prd_desc, reg_no, storage_cond_code, storage_cond,medical_device_usage_code ,medical_device_usage,bm_ifu_code,bm_ifu,remarks, vas_activities, qa_required)
		SELECT distinct B.client_code, C.client_name, A.mll_no, A.prd_code, D.prd_desc, registration_no, storage_cond, E.name, 
		       medical_device_usage,ISNULL(F.name,'NA'),bm_ifu,ISNULL(G.name,'NA'),remarks, vas_activities, qa_required
		FROM TBL_MST_MLL_DTL A WITH(NOLOCK)
		INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no
		INNER JOIN TBL_MST_CLIENT C WITH(NOLOCK) ON B.client_code = C.client_code
		INNER JOIN TBL_MST_PRODUCT D WITH(NOLOCK) ON A.prd_code = D.prd_code
		INNER JOIN TBL_MST_DDL E WITH(NOLOCK) ON A.storage_cond = E.code
		LEFT JOIN TBL_MST_DDL F WITH(NOLOCK) ON A.medical_device_usage = F.code
		LEFT JOIN TBL_MST_DDL G WITH(NOLOCK) ON A.bm_ifu = G.code
		WHERE B.client_code = @client AND type_of_vas = @type_of_vas AND sub = @sub AND B.mll_no = @selected_mll_no
		AND (	A.prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE A.prd_code END OR
				prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_desc END OR
				storage_cond LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE storage_cond END OR
				medical_device_usage LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE medical_device_usage END OR
				bm_ifu LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE bm_ifu END OR
				registration_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE registration_no END OR
				remarks LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE remarks END)
	END
	ELSE
	BEGIN
		INSERT INTO #MLL_DTL
		(client_code, client_name, mll_no, prd_code, prd_desc, reg_no, storage_cond_code, storage_cond,medical_device_usage_code,medical_device_usage,bm_ifu_code,bm_ifu,remarks, vas_activities, qa_required)
		SELECT distinct B.client_code, C.client_name, A.mll_no, A.prd_code, D.prd_desc, registration_no, storage_cond, E.name, 
		       medical_device_usage,ISNULL(F.name,'NA'),bm_ifu,ISNULL(G.name,'NA'),
		       remarks, vas_activities, qa_required
		FROM TBL_MST_MLL_DTL A WITH(NOLOCK)
		INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no
		INNER JOIN TBL_MST_CLIENT C WITH(NOLOCK) ON B.client_code = C.client_code
		INNER JOIN TBL_MST_PRODUCT D WITH(NOLOCK) ON A.prd_code = D.prd_code
		INNER JOIN TBL_MST_DDL E WITH(NOLOCK) ON A.storage_cond = E.code
		LEFT JOIN TBL_MST_DDL F WITH(NOLOCK) ON A.medical_device_usage = F.code
		LEFT JOIN TBL_MST_DDL G WITH(NOLOCK) ON A.bm_ifu = G.code
		WHERE B.client_code = @client AND type_of_vas = @type_of_vas AND sub = @sub AND B.mll_no = @selected_mll_no
		
	END
	/*******************/

	/*** Find difference between current MLL and last effective MLL ***/
	DECLARE @last_effective_mll_no VARCHAR(50)
	SET @last_effective_mll_no = (SELECT TOP 1 mll_no FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE client_code = @client AND type_of_vas = @type_of_vas AND sub = @sub AND mll_no <> @selected_mll_no AND LTRIM(RTRIM(mll_status)) = 'Approved' ORDER BY mll_no DESC)
	
	IF @last_effective_mll_no <> ''
	BEGIN
		SELECT prd_code, storage_cond, registration_no, remarks, vas_activities INTO #TEMP_DIFF_MLL
		FROM
		(
		SELECT t1.prd_code, t1.storage_cond, isnull(t1.registration_no,'') as registration_no, isnull(t1.remarks,'') as remarks, t1.vas_activities, mll_no
		FROM tbl_mst_mll_dtl t1 where mll_no = @selected_mll_no
		UNION ALL
		SELECT t2.prd_code, t2.storage_cond, isnull(t2.registration_no,'') as registration_no, isnull(t2.remarks,'')as remarks, t2.vas_activities, mll_no
		FROM tbl_mst_mll_dtl t2 where mll_no = @last_effective_mll_no
		) t
		GROUP BY prd_code, storage_cond, registration_no, remarks, vas_activities
		HAVING COUNT(*) = 1

		UPDATE A
		SET row_different_ind = 1
		FROM #MLL_DTL A, #TEMP_DIFF_MLL B
		WHERE isnull(A.prd_code,'') = isnull(B.prd_code,'') AND isnull(A.storage_cond_code,'') = isnull(B.storage_cond,'') AND isnull(A.reg_no,'') = isnull(B.registration_no,'') AND isnull(A.remarks,'') = isnull(B.remarks,'') AND A.vas_activities = B.vas_activities
		AND @selected_mll_no NOT LIKE '%00001'

		DROP TABLE #TEMP_DIFF_MLL
	END
	/*** Find difference between current MLL and last effective MLL ***/

	/***** Temp table for vas activities name *****/
	DECLARE @count INT = (SELECT COUNT(*) FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING A WITH(NOLOCK)
						INNER JOIN VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) ON A.page_dtl_id = B.page_dtl_id 
						WHERE principal_code = 'MY-HEC' AND page_code = 'MLL-SEARCH' AND input_name LIKE 'vas_activities_%')

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
	FROM #MLL_TEMPNAME A, VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) WHERE A.page_dtl_id = B.page_dtl_id

	UPDATE A
	SET A.display_name = B.display_name
	FROM #MLL_TEMPNAME A, VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING B WITH(NOLOCK) WHERE A.page_dtl_id = B.page_dtl_id AND principal_code = 'MY-HEC' AND page_code = 'MLL-SEARCH'
	/***** Temp table for vas activities name *****/

	DECLARE @sqlCommand NVARCHAR(MAX), @j INT = 0, @count_tempname INT
	SET @count_tempname = (SELECT COUNT(*) FROM #MLL_TEMPNAME)
	SET @sqlCommand = 'CREATE TABLE #MLL_DTL_2(client_code VARCHAR(50), client_name NVARCHAR(200), mll_no VARCHAR(100), prd_code VARCHAR(50), prd_desc NVARCHAR(MAX), reg_no VARCHAR(50), storage_cond_code VARCHAR(10), storage_cond VARCHAR(50),medical_device_usage_code VARCHAR(10), medical_device_usage VARCHAR(50),bm_ifu_code VARCHAR(10), bm_ifu VARCHAR(50), remarks	NVARCHAR(MAX), vas_activities NVARCHAR(MAX), qa_required INT,  row_different_ind CHAR(1), ' SELECT @sqlCommand += input_name + ' NVARCHAR(2000) NULL, ' FROM #MLL_TEMPNAME WHERE page_dtl_id IS NOT NULL 
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
	SET @sqlCommand += ' FROM #MLL_DTL '
	IF (@export_ind = '0')
		SET @sqlCommand += 'ORDER BY prd_code OFFSET ' + CAST(@page_index * @page_size as varchar(250)) + ' ROWS FETCH NEXT ' + cast(@page_size as varchar(50)) + ' ROWS ONLY SELECT * FROM #MLL_DTL_2 DROP TABLE #MLL_DTL_2'
	ELSE IF (@export_ind = '1')
		SET @sqlCommand += 'ORDER BY prd_code SELECT * FROM #MLL_DTL_2 DROP TABLE #MLL_DTL_2'


	/*** Output ***/
	SELECT COUNT(1) as ttl_rows FROM #MLL_DTL												--1--
	SELECT * FROM #MLL_HDR																	--2--
	IF (SELECT COUNT(*) FROM #MLL_DTL) > 0 EXEC(@sqlCommand) ELSE SELECT * FROM #MLL_DTL 	--3--
	SELECT @export_ind AS export_ind														--4--

	/***** Audit Trail *****/
	SELECT action, B.user_name as action_by, CONVERT(VARCHAR(20), action_date, 121) as action_date  --5--
	FROM TBL_ADM_AUDIT_TRAIL A WITH(NOLOCK)
	INNER JOIN VAS.dbo.TBL_ADM_USER B WITH(NOLOCK) ON A.action_by = B.user_id
	WHERE module = 'MLL' AND key_code = @selected_mll_no
	ORDER BY action_date DESC
	/***********************/

	IF @export_ind = '1'
		EXEC SPP_GENERATE_MLL @selected_mll_no, 1
	ELSE IF @export_ind = '0'
		SELECT * FROM #MLL_TEMPNAME --6--
		WHERE page_dtl_id IS NOT NULL
		UNION ALL
		SELECT list_dtl_id as page_dtl_id, list_col_name, list_default_display_name as display_name 
		FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_LISTING_DTL WITH(NOLOCK)
		WHERE list_hdr_id IN (SELECT list_hdr_id FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_LISTING_HDR WITH(NOLOCK) WHERE page_code LIKE 'MLL%') AND list_col_name in (SELECT name FROM tempdb.sys.columns where object_id = object_id('tempdb..#MLL_DTL'))

SELECT @wh_code wh_code


	DROP TABLE #MLL_TEMPNAME
	DROP TABLE #MLL_HDR
	DROP TABLE #MLL_DTL
END
GO
