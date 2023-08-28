SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ===============================================================================
-- Author:		Smita Thorat
-- Create date: 2022-04-19
-- Description:	Validate uploaded MLL data
-- Example Query: exec [SPP_MST_MASS_UPLOAD_SUBCON_VALIDATE] '1'
-- Remarks : 1) Need to add in column in select statement if add new vas_activities
-- ===============================================================================

CREATE PROCEDURE [dbo].[SPP_MST_MASS_UPLOAD_SUBCON_VALIDATE]
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

	CREATE TABLE #SUBCON_MASS_UPLOAD
	(
	row_num INT IDENTITY(1,1),
	client_code NVARCHAR(2000) NULL,
	type_of_vas NVARCHAR(2000) NULL,
	sub NVARCHAR(MAX) NULL,
	sub_name NVARCHAR(MAX) NULL,
	[indicator] VARCHAR(5) NULL,	
	prd_code NVARCHAR(2000) NULL,	
	reg_no NVARCHAR(2000) NULL,
	expirydate NVARCHAR(2000) NULL,
	remarks NVARCHAR(MAX) NULL,
	vas_activities_1 NVARCHAR(2000) NULL, 
	vas_activities_1_radio NVARCHAR(50) NULL, 
	vas_activities_2 NVARCHAR(2000) NULL, 
	vas_activities_2_radio NVARCHAR(50) NULL,
	vas_activities_3 NVARCHAR(2000) NULL, 
	vas_activities_3_radio NVARCHAR(50) NULL, 
	vas_activities_4 NVARCHAR(2000) NULL, 
	vas_activities_4_radio NVARCHAR(50) NULL,
	vas_activities_5 NVARCHAR(2000) NULL, 
	vas_activities_5_radio NVARCHAR(50) NULL, 
	vas_activities_6 NVARCHAR(2000) NULL, 
	vas_activities_6_radio NVARCHAR(2000) NULL,
	vas_activities_7 NVARCHAR(2000) NULL, 
	vas_activities_7_radio NVARCHAR(50) NULL, 
	vas_activities_8 NVARCHAR(2000) NULL, 
	vas_activities_8_radio NVARCHAR(50) NULL,
	vas_activities_9 NVARCHAR(2000) NULL, 
	vas_activities_9_radio NVARCHAR(50) NULL,
	
	json_vas NVARCHAR(MAX),
	is_valid_client_code VARCHAR(50) DEFAULT 'Invalid client code.',
	is_valid_type_of_vas VARCHAR(50) DEFAULT 'Invalid VAS type.',
	is_valid_sub VARCHAR(50) DEFAULT 'Invalid sub code.',
	--is_valid_expiry_date VARCHAR(50) DEFAULT 'Invalid expiry date.',
	is_valid_prd_code VARCHAR(50) DEFAULT 'Invalid product code.',
	is_valid_ppm VARCHAR(50) DEFAULT '',
	action VARCHAR(50), 
	error_msg VARCHAR(MAX) DEFAULT ''
	)

	INSERT INTO #SUBCON_MASS_UPLOAD
	(client_code, type_of_vas, sub, sub_name, 
	indicator, prd_code, reg_no, expirydate,remarks, 
	vas_activities_1, vas_activities_1_radio, vas_activities_2, vas_activities_2_radio, vas_activities_3,
	vas_activities_3_radio, vas_activities_4, vas_activities_4_radio, vas_activities_5, vas_activities_5_radio, vas_activities_6, vas_activities_6_radio, vas_activities_7, vas_activities_7_radio,
	vas_activities_8, vas_activities_8_radio, vas_activities_9, vas_activities_9_radio)
	SELECT LTRIM(RTRIM(SUBSTRING(client_code ,0, CHARINDEX('-', client_code)))), B.code,  LTRIM(RTRIM(SUBSTRING(sub,0, CHARINDEX('-',sub)))),  LTRIM(RTRIM(RIGHT(sub, CHARINDEX('-', REVERSE(sub)) - 1))),  
	LTRIM(RTRIM(indicator)),LTRIM(RTRIM(prd_code)), reg_no,expirydate,REPLACE(REPLACE(remarks, CHAR(13), ''), CHAR(10), ''),
	vas_activities_1, ISNULL(LTRIM(LEFT(vas_activities_1_radio,1)),'N'), vas_activities_2, ISNULL(LTRIM(LEFT(vas_activities_2_radio,1)),'N'),
	vas_activities_3, ISNULL(LTRIM(LEFT(vas_activities_3_radio,1)),'N'), vas_activities_4, ISNULL(LTRIM(LEFT(vas_activities_4_radio,1)),'N'), 
	vas_activities_5, ISNULL(LTRIM(LEFT(vas_activities_5_radio,1)),'N'), 
	vas_activities_6, ISNULL(LTRIM(LEFT(vas_activities_6_radio,1)),'N'), vas_activities_7, ISNULL(LTRIM(LEFT(vas_activities_7_radio,1)),'N'),
	vas_activities_8, ISNULL(LTRIM(LEFT(vas_activities_8_radio,1)),'N'), vas_activities_9, ISNULL(LTRIM(LEFT(vas_activities_9_radio,1)),'N')
	FROM TBL_TMP_MASS_UPLOAD_SUBCON A WITH(NOLOCK)
	INNER JOIN TBL_MST_DDL B WITH(NOLOCK) ON A.type_of_vas = B.name
	WHERE user_id = @user_id

	DELETE FROM TBL_TMP_MASS_UPLOAD_SUBCON WHERE user_id = @user_id

	DECLARE @count_row INT, @count_vas_activities INT
	SET @count_row = (SELECT COUNT(1) FROM #SUBCON_MASS_UPLOAD)
	SET @count_vas_activities = (SELECT COUNT(*) FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING A WITH(NOLOCK) INNER JOIN VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) ON A.page_dtl_id = B.page_dtl_id WHERE principal_code = 'MY-HEC' AND page_code = 'SUBCON-SEARCH' AND input_name LIKE 'vas_activities_%')

	/** Validation here **/
	--1. Client -------------------------------------------------------------
	UPDATE A
	SET is_valid_client_code = 'Y'
	FROM #SUBCON_MASS_UPLOAD A
	INNER JOIN TBL_MST_CLIENT B WITH(NOLOCK) ON A.client_code = B.client_code
	-- Client ----------------------------------------------------------------

	--2. Type of VAS ---------------------------------------------------------
	UPDATE A
	SET is_valid_type_of_vas = 'Y'
	FROM #SUBCON_MASS_UPLOAD A
	INNER JOIN TBL_MST_DDL B WITH(NOLOCK) ON A.type_of_vas = B.code
	-- Type of VAS -----------------------------------------------------------

	
	

	--3. Sub --------------------------------------------------------------------------------------------
	UPDATE A
	SET is_valid_sub = 'Y'
	FROM #SUBCON_MASS_UPLOAD A
	INNER JOIN TBL_MST_CLIENT_SUB B WITH(NOLOCK) ON A.client_code = B.client_code AND A.sub = B.sub_code

	INSERT INTO TBL_MST_CLIENT_SUB
	(client_code, sub_code, sub_name)
	SELECT DISTINCT client_code, sub, sub_name FROM #SUBCON_MASS_UPLOAD A WITH(NOLOCK) 
	WHERE is_valid_sub <> 'Y' AND NOT EXISTS(SELECT 1 FROM TBL_MST_CLIENT_SUB B WITH(NOLOCK) WHERE A.client_code = B.client_code AND A.sub = B.sub_code)

	UPDATE A
	SET is_valid_sub = 'Y'
	FROM #SUBCON_MASS_UPLOAD A
	INNER JOIN TBL_MST_CLIENT_SUB B WITH(NOLOCK) ON A.client_code = B.client_code AND A.sub = B.sub_code 
	-- Sub ----------------------------------------------------------------------------------------------

	--4. Validity Period ------------------------------------------------
 --   UPDATE #SUBCON_MASS_UPLOAD
	--SET is_valid_expiry_date = 'Y'
	--WHERE expirydate >= GETDATE()	
	-- Validity Period --------------------------------------------------

	--5. Product code ---------------------------------------------------------------------------------
	UPDATE A
	SET is_valid_prd_code = 'Y'
	FROM #SUBCON_MASS_UPLOAD A
	INNER JOIN TBL_MST_PRODUCT B WITH(NOLOCK) ON A.client_code = B.princode AND A.prd_code = B.prd_code
	-- Product code -----------------------------------------------------------------------------------

	--6. PPM product code ---------------------------------------------------------------------------------
	CREATE TABLE #PPM_PRD(num INT, vas_activity_num INT, prd_list VARCHAR(2000))
	DECLARE @m INT = 1, @n INT = 1, @sql_ppm NVARCHAR(MAX) = ''
	SET @sql_ppm += 'INSERT INTO #PPM_PRD (num, vas_activity_num, prd_list) '
	SET @n = 1
	WHILE @n <= @count_vas_activities
	BEGIN
		SET @sql_ppm += 'SELECT row_num, ' + CAST(@n as VARCHAR(10)) + ', vas_activities_' + CAST(@n as VARCHAR(50)) + ' FROM #SUBCON_MASS_UPLOAD WITH(NOLOCK) '

		IF @n < @count_vas_activities SET @sql_ppm += ' UNION '
		SET @n = @n + 1
	END
	EXEC (@sql_ppm)

	SELECT A.num, A.vas_activity_num, LTRIM(Split.a.value('.', 'VARCHAR(100)')) AS prd_code, CAST('Invalid PPM material.' as VARCHAR(50)) as check_ppm
	INTO #SPLIT_PPM_PRD
	FROM (SELECT num, vas_activity_num, CAST ('<M>' + REPLACE(prd_list, ',', '</M><M>') + '</M>' AS XML) AS prd_code  
    FROM #PPM_PRD) AS A CROSS APPLY prd_code.nodes ('/M') AS Split(a);

	UPDATE A
	SET check_ppm = 'Y'
	FROM #SPLIT_PPM_PRD A
	INNER JOIN TBL_MST_PRODUCT B WITH(NOLOCK) ON A.prd_code = B.prd_code AND B.prd_type = 'ZPK4'

	UPDATE #SPLIT_PPM_PRD
	SET check_ppm = 'Y'
	WHERE prd_code = ''

	UPDATE A
	SET is_valid_ppm = B.check_ppm
	FROM #SUBCON_MASS_UPLOAD A 
	INNER JOIN #SPLIT_PPM_PRD B WITH(NOLOCK) ON A.row_num = B.num

	--DELETE A
	--FROM #PPM_PRD A 
	--WHERE EXISTS(SELECT 1 FROM #ABC B WHERE A.num = B.num AND A.vas_activity_num = B.vas_activity_num)  

	--SELECT * FROM #PPM_PRD
	--UNION ALL
	--SELECT * FROM #ABC
	--ORDER BY num, vas_activity_num
	DROP TABLE #SPLIT_PPM_PRD
	DROP TABLE #PPM_PRD
	-- PPM product code ---------------------------------------------------------------------------------

	/** Validation end **/

	/** Build json string for vas_activities **/
	DECLARE @i INT = 1, @j INT = 1, @sql NVARCHAR(MAX) = '', @page_dtl_id INT
	CREATE TABLE #TEMP_JSON_1(seq INT IDENTITY(1,1), row_num INT, prd_code VARCHAR(2000), radio_val CHAR(1), page_dtl_id INT)
	SET @sql = 'INSERT INTO #TEMP_JSON_1(row_num, prd_code, radio_val, page_dtl_id) '
	SET @j = 1
	WHILE @j <= @count_vas_activities
	BEGIN
		SET @page_dtl_id = (SELECT A.page_dtl_id FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING A WITH(NOLOCK) INNER JOIN VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) ON A.page_dtl_id = B.page_dtl_id
WHERE principal_code = 'MY-HEC' AND page_code = 'SUBCON-SEARCH' AND input_name LIKE 'vas_activities_' + CAST(@j as VARCHAR(50)))
		SET @sql += 'SELECT row_num, ISNULL(vas_activities_' + CAST(@j as VARCHAR(50)) + ', '''') as prd_code, ISNULL(vas_activities_' + CAST(@j as VARCHAR(50)) + '_radio, '''') as radio_val, ' + CAST(@page_dtl_id as VARCHAR(50)) + ' as page_dtl_id FROM #SUBCON_MASS_UPLOAD '

		IF (@j <> @count_vas_activities) SET @sql += ' UNION ALL '
		SET @j = @j + 1
	END
	EXEC (@sql)

	SELECT seq, row_num, (SELECT prd_code, radio_val, page_dtl_id FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) as json_vas 
	INTO #TEMP_JSON_2
	FROM #TEMP_JSON_1 WITH(NOLOCK)
	GROUP BY seq, row_num, prd_code, radio_val, page_dtl_id
	ORDER BY seq

	CREATE NONCLUSTERED INDEX ABC
	ON #TEMP_JSON_2 (row_num)
	include (json_vas)

	SELECT DISTINCT row_num,
    '[' + STUFF((
        SELECT ',' + json_vas
        FROM #TEMP_JSON_2 t1
        WHERE t1.row_num = t2.row_num
		ORDER BY seq
        FOR XML PATH('')
    ), 1, 1, '') + ']' AS json_vas INTO #FINAL_JSON
	FROM #TEMP_JSON_2 t2

	UPDATE A
	SET A.json_vas = B.json_vas
	FROM #SUBCON_MASS_UPLOAD A INNER JOIN #FINAL_JSON B WITH(NOLOCK) ON A.row_num = B.row_num

	DROP TABLE #TEMP_JSON_1
	DROP TABLE #TEMP_JSON_2
	DROP TABLE #FINAL_JSON
	/** Build json string for vas_activities **/

	/** Check if have existing draft **/ -- N : New MLL ; -- I : Update Header + Insert Detail ; -- U : Update Header + Update Detail
	UPDATE A
	SET action = 'N'
	FROM #SUBCON_MASS_UPLOAD A
	WHERE NOT EXISTS(SELECT 1 FROM TBL_MST_MLL_HDR B WITH(NOLOCK) WHERE mll_status = 'Draft' AND A.client_code = B.client_code AND A.type_of_vas = B.type_of_vas AND A.sub = B.sub)

	UPDATE A
	SET action = 'I'
	FROM #SUBCON_MASS_UPLOAD A
	WHERE EXISTS(SELECT 1 FROM TBL_MST_MLL_HDR B WITH(NOLOCK) WHERE mll_status = 'Draft' AND A.client_code = B.client_code AND A.type_of_vas = B.type_of_vas AND A.sub = B.sub)

	UPDATE A
	SET action = 'U'
	FROM #SUBCON_MASS_UPLOAD A
	WHERE EXISTS(SELECT 1 FROM TBL_MST_MLL_HDR B WITH(NOLOCK) INNER JOIN TBL_MST_MLL_DTL C WITH(NOLOCK) ON B.mll_no = C.mll_no WHERE mll_status = 'Draft' AND A.client_code = B.client_code AND A.type_of_vas = B.type_of_vas AND A.sub = B.sub AND A.prd_code = C.prd_code)

	UPDATE #SUBCON_MASS_UPLOAD
	SET error_msg = CASE is_valid_client_code WHEN 'Y' THEN '' ELSE is_valid_client_code END + '' + 
					CASE is_valid_type_of_vas WHEN 'Y' THEN '' ELSE is_valid_type_of_vas END + '' + 
					CASE is_valid_sub WHEN 'Y' THEN '' ELSE is_valid_sub END + '' +
					--CASE is_valid_expiry_date WHEN 'Y' THEN '' ELSE is_valid_expiry_date END + '' +
					CASE is_valid_prd_code WHEN 'Y' THEN '' ELSE is_valid_prd_code END + '' +
					
					CASE is_valid_ppm WHEN 'Y' THEN '' ELSE is_valid_ppm END 
					

	DELETE FROM TBL_TMP_MASS_UPLOAD_SUBCON_VALIDATED WHERE user_id = @user_id


	INSERT INTO TBL_TMP_MASS_UPLOAD_SUBCON_VALIDATED
	(client_code, type_of_vas, sub, indicator,  prd_code, reg_no,expirydate,remarks, vas_activities, 
	vas_activities_1, vas_activities_1_radio, vas_activities_2, vas_activities_2_radio, vas_activities_3,
	vas_activities_3_radio, vas_activities_4, vas_activities_4_radio, vas_activities_5, vas_activities_5_radio, vas_activities_6, vas_activities_6_radio, vas_activities_7, vas_activities_7_radio,
	vas_activities_8, vas_activities_8_radio, vas_activities_9, vas_activities_9_radio, error_msg, action, user_id)

	SELECT distinct client_code, type_of_vas, sub, indicator,  prd_code, reg_no,expirydate, remarks, json_vas,
	vas_activities_1, vas_activities_1_radio, vas_activities_2, vas_activities_2_radio, 
	vas_activities_3, vas_activities_3_radio, vas_activities_4, vas_activities_4_radio, 
	vas_activities_5, vas_activities_5_radio, vas_activities_6, vas_activities_6_radio, 
	vas_activities_7, vas_activities_7_radio, vas_activities_8, vas_activities_8_radio, 
	vas_activities_9, vas_activities_9_radio,
	CASE is_valid_client_code WHEN 'Y' THEN '' ELSE is_valid_client_code END + '' + 
	CASE is_valid_type_of_vas WHEN 'Y' THEN '' ELSE is_valid_type_of_vas END + '' + 
	CASE is_valid_sub WHEN 'Y' THEN '' ELSE is_valid_sub END + '' +
	--CASE is_valid_expiry_date WHEN 'Y' THEN '' ELSE is_valid_expiry_date END + '' +
	CASE is_valid_prd_code WHEN 'Y' THEN '' ELSE is_valid_prd_code END + '' +	
	CASE is_valid_ppm WHEN 'Y' THEN '' ELSE is_valid_ppm END ,
	action, @user_id
	FROM #SUBCON_MASS_UPLOAD WITH(NOLOCK)
	
	DROP TABLE #SUBCON_MASS_UPLOAD

	SELECT 'OK' as result

	END TRY

	BEGIN CATCH
		SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_LINE() as ErrorLine, ERROR_MESSAGE() AS ErrorMessage; 
	END CATCH
END

GO
