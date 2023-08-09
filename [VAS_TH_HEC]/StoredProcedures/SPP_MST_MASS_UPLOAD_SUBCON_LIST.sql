SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_MST_MASS_UPLOAD_SUBCON_LIST]
	@param NVARCHAR(MAX),
	@user_id	INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @page_index INT, @page_size INT, @export_ind CHAR(1)
	SET @page_index = (SELECT JSON_VALUE(@param, '$.page_index'))
	SET @page_size = (SELECT JSON_VALUE(@param, '$.page_size'))
	SET @export_ind = (SELECT JSON_VALUE(@param, '$.export_ind'))

	CREATE TABLE #UPLOADED_TEMP_ORIGINAL(
		client_code VARCHAR(300),
		type_of_vas VARCHAR(200),
		sub VARCHAR(200),
		prd_code VARCHAR(50),
		reg_no VARCHAR(MAX), 
		expirydate VARCHAR(50) NULL,
		remarks NVARCHAR(MAX),
		vas_activities_1 VARCHAR(200), 
		vas_activities_1_radio VARCHAR(20), 
		vas_activities_2 VARCHAR(200), 
		vas_activities_2_radio VARCHAR(20), 
		vas_activities_3 VARCHAR(200),
		vas_activities_3_radio VARCHAR(20), 
		vas_activities_4 VARCHAR(200), 
		vas_activities_4_radio VARCHAR(20), 
		vas_activities_5 VARCHAR(200), 
		vas_activities_5_radio VARCHAR(20), 
		vas_activities_6 VARCHAR(200), 
		vas_activities_6_radio VARCHAR(20), 
		vas_activities_7 VARCHAR(200), 
		vas_activities_7_radio VARCHAR(20),
		vas_activities_8 VARCHAR(200), 
		vas_activities_8_radio VARCHAR(20), 
		vas_activities_9 VARCHAR(200), 
		vas_activities_9_radio VARCHAR(20),
		
		error_msg VARCHAR(MAX),
		vas_activities VARCHAR(MAX)
	)

	CREATE TABLE #UPLOADED_TEMP(
		client_code VARCHAR(300),
		type_of_vas VARCHAR(200),
		sub VARCHAR(200),
		prd_code VARCHAR(50),
		reg_no VARCHAR(MAX), 
		expirydate VARCHAR(50) NULL,
		remarks NVARCHAR(MAX),
		vas_activities_1 VARCHAR(200), 
		vas_activities_1_radio VARCHAR(20), 
		vas_activities_2 VARCHAR(200), 
		vas_activities_2_radio VARCHAR(20), 
		vas_activities_3 VARCHAR(200),
		vas_activities_3_radio VARCHAR(20), 
		vas_activities_4 VARCHAR(200), 
		vas_activities_4_radio VARCHAR(20), 
		vas_activities_5 VARCHAR(200), 
		vas_activities_5_radio VARCHAR(20), 
		vas_activities_6 VARCHAR(200), 
		vas_activities_6_radio VARCHAR(20), 
		vas_activities_7 VARCHAR(200), 
		vas_activities_7_radio VARCHAR(20),
		vas_activities_8 VARCHAR(200), 
		vas_activities_8_radio VARCHAR(20), 
		vas_activities_9 VARCHAR(200), 
		vas_activities_9_radio VARCHAR(20),
		
		error_msg VARCHAR(MAX),
		vas_activities VARCHAR(MAX)
	)

    SELECT COUNT(1) as ttl_rows FROM TBL_TMP_MASS_UPLOAD_SUBCON_VALIDATED WITH(NOLOCK) WHERE user_id = @user_id -- 1. Total rows
	SELECT COUNT(1) as total_success_rows FROM TBL_TMP_MASS_UPLOAD_SUBCON_VALIDATED WITH(NOLOCK) WHERE user_id = @user_id AND error_msg = '' -- 2. Total success rows
	SELECT COUNT(1) as total_error_rows FROM TBL_TMP_MASS_UPLOAD_SUBCON_VALIDATED WITH(NOLOCK) WHERE user_id = @user_id AND error_msg <> '' -- 3. Total error rows

	IF (@export_ind = '0')
	begin
		--SELECT client_code, type_of_vas, sub, start_date, end_date, subcon_desc, prd_code, storage_cond, reg_no, remarks,  -- 4. Data
		--vas_activities_1, vas_activities_1_radio, vas_activities_2, vas_activities_2_radio, vas_activities_3,
		--vas_activities_3_radio, vas_activities_4, vas_activities_4_radio, vas_activities_5, vas_activities_5_radio, vas_activities_6, vas_activities_6_radio, vas_activities_7, vas_activities_7_radio,
		--vas_activities_8, vas_activities_8_radio, vas_activities_9, vas_activities_9_radio, error_msg 
		--FROM TBL_TMP_MASS_UPLOAD_SUBCON_VALIDATED WITH(NOLOCK)
		--WHERE user_id = @user_id
		--ORDER BY client_code, type_of_vas, sub
		--OFFSET @page_index * @page_size ROWS
		--FETCH NEXT @page_size ROWS ONLY
		INSERT INTO #UPLOADED_TEMP_ORIGINAL
		SELECT  distinct A.client_code + ' - ' + B.client_name as client_code, C.name AS type_of_vas,
		A.sub + ' - ' + D.sub_name as sub,  prd_code,reg_no,expirydate,remarks,
		vas_activities_1, vas_activities_1_radio, vas_activities_2, vas_activities_2_radio, vas_activities_3,vas_activities_3_radio, 
		vas_activities_4, vas_activities_4_radio, vas_activities_5, vas_activities_5_radio, vas_activities_6, vas_activities_6_radio, 
		vas_activities_7, vas_activities_7_radio, vas_activities_8, vas_activities_8_radio, vas_activities_9, vas_activities_9_radio,
		 error_msg, vas_activities
		FROM TBL_TMP_MASS_UPLOAD_SUBCON_VALIDATED A 
		INNER JOIN TBL_MST_CLIENT B WITH(NOLOCK) ON A.client_code = B.client_code
		INNER JOIN TBL_MST_DDL C WITH(NOLOCK) ON A.type_of_vas = C.code
		INNER JOIN TBL_MST_CLIENT_SUB D WITH(NOLOCK) ON A.client_code = D.client_code AND A.sub = D.sub_code
		WHERE user_id = @user_id

		insert into #UPLOADED_TEMP
		select	* 
		from	#UPLOADED_TEMP_ORIGINAL
		ORDER BY LEN(error_msg) DESC
		OFFSET @page_index * @page_size ROWS
		FETCH NEXT @page_size ROWS ONLY

		end
	ELSE IF (@export_ind = '1')
		--SELECT client_code, type_of_vas, sub, start_date + ' - ' + end_date, subcon_desc, prd_code, storage_cond, reg_no, remarks,  -- 4. Data
		--vas_activities_1, vas_activities_1_radio, vas_activities_2, vas_activities_2_radio, vas_activities_3,
		--vas_activities_3_radio, vas_activities_4, vas_activities_4_radio, vas_activities_5, vas_activities_5_radio, vas_activities_6, vas_activities_6_radio, vas_activities_7, vas_activities_7_radio,
		--vas_activities_8, vas_activities_8_radio, vas_activities_9, vas_activities_9_radio, error_msg 
		--FROM TBL_TMP_MASS_UPLOAD_SUBCON_VALIDATED WITH(NOLOCK)
		--WHERE user_id = @user_id
		--ORDER BY client_code, type_of_vas, sub
		INSERT INTO #UPLOADED_TEMP
		SELECT  A.client_code + ' - ' + B.client_name as client_code, C.name AS type_of_vas,
		A.sub + ' - ' + D.sub_name as sub,  prd_code, reg_no,expirydate, remarks,
		vas_activities_1, vas_activities_1_radio, vas_activities_2, vas_activities_2_radio, vas_activities_3,vas_activities_3_radio, 
		vas_activities_4, vas_activities_4_radio, vas_activities_5, vas_activities_5_radio, vas_activities_6, vas_activities_6_radio, 
		vas_activities_7, vas_activities_7_radio, vas_activities_8, vas_activities_8_radio, vas_activities_9, vas_activities_9_radio,
		 error_msg, vas_activities
		FROM TBL_TMP_MASS_UPLOAD_SUBCON_VALIDATED A 
		INNER JOIN TBL_MST_CLIENT B WITH(NOLOCK) ON A.client_code = B.client_code
		INNER JOIN TBL_MST_DDL C WITH(NOLOCK) ON A.type_of_vas = C.code
		INNER JOIN TBL_MST_CLIENT_SUB D WITH(NOLOCK) ON A.client_code = D.client_code AND A.sub = D.sub_code
		WHERE user_id = @user_id
		ORDER BY LEN(error_msg) DESC

		SELECT  distinct client_code, type_of_vas,
		sub,  prd_code,
		 reg_no,expirydate,remarks,
		vas_activities_1, vas_activities_1_radio, vas_activities_2, vas_activities_2_radio, vas_activities_3,
		vas_activities_3_radio, vas_activities_4, vas_activities_4_radio, vas_activities_5, vas_activities_5_radio, vas_activities_6, vas_activities_6_radio, vas_activities_7, vas_activities_7_radio,
		vas_activities_8, vas_activities_8_radio, vas_activities_9, vas_activities_9_radio,
		 error_msg FROM #UPLOADED_TEMP 

		SELECT @export_ind AS export_ind -- 5. Export ind

		/***** Temp table for vas activities name *****/
		DECLARE @count INT = (SELECT COUNT(*) FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING A WITH(NOLOCK)
							INNER JOIN VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) ON A.page_dtl_id = B.page_dtl_id 
							WHERE principal_code = 'TH-HEC' AND input_name LIKE 'vas_activities_%')

		DECLARE @i INT = 0, @sql NVARCHAR(MAX) = ''
		CREATE TABLE #SUBCON_TEMPNAME (page_dtl_id INT, input_name VARCHAR(50), display_name NVARCHAR(250))
		WHILE @i < @count
		BEGIN
			SET @sql +=' INSERT INTO #SUBCON_TEMPNAME (page_dtl_id) SELECT DISTINCT JSON_VALUE(vas_activities, + ''$[' + CAST(@i as varchar(50)) + '].page_dtl_id'') FROM #UPLOADED_TEMP'
			SET @i = @i + 1
		END
		SET @sql += ' DELETE FROM #SUBCON_TEMPNAME WHERE page_dtl_id IS NULL'
		EXEC (@sql)

		UPDATE A
		SET A.input_name = B.input_name
		FROM #SUBCON_TEMPNAME A, VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) WHERE A.page_dtl_id = B.page_dtl_id

		UPDATE A
		SET A.display_name = B.display_name
		FROM #SUBCON_TEMPNAME A, VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING B WITH(NOLOCK) WHERE A.page_dtl_id = B.page_dtl_id AND principal_code = 'TH-HEC'
		/***** Temp table for vas activities name *****/

		SELECT * FROM #SUBCON_TEMPNAME --6--
		WHERE page_dtl_id IS NOT NULL
		UNION ALL
		SELECT list_dtl_id as page_dtl_id, list_col_name, list_default_display_name as display_name 
		FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_LISTING_DTL WITH(NOLOCK)
		WHERE list_hdr_id IN (SELECT list_hdr_id FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_LISTING_HDR WITH(NOLOCK) WHERE page_code LIKE 'SUBCON%') AND list_col_name in (SELECT name FROM tempdb.sys.columns where object_id = object_id('tempdb..#UPLOADED_TEMP'))
		AND list_col_name NOT IN (SELECT input_name FROM #SUBCON_TEMPNAME)
		UNION ALL
		SELECT '', 'subcon_desc', 'Subcon Description'
		UNION ALL
		SELECT '', 'validity_period', 'Validity Period'

		DROP TABLE #UPLOADED_TEMP
		DROP TABLE #SUBCON_TEMPNAME
END
GO
