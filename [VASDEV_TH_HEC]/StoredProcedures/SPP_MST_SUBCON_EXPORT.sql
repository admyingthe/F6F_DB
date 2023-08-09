SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_MST_SUBCON_EXPORT]
	@param	nvarchar(max),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @subcon_no VARCHAR(100)
	SET @subcon_no = (SELECT JSON_VALUE(@param, '$.subcon_no'))
	
	If @subcon_no='NA'
	BEGIN
		SET @subcon_no =(SELECT top 1 subcon_no FROM TBL_MST_subcon_HDR WHERE subcon_status='Active')
	END

	print(@subcon_no)

	CREATE TABLE #UPLOADED_TEMP(
		client_code VARCHAR(300),
		type_of_vas VARCHAR(200),		
		sub VARCHAR(200),
		indicator VARCHAR(200),
		
		prd_code VARCHAR(50),
		
		reg_no VARCHAR(200), 
	    expiry_date VARCHAR(100),
		
		remarks NVARCHAR(300),
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
		--subcon_desc NVARCHAR(200),
		vas_activities NVARCHAR(MAX)
	)

	INSERT INTO #UPLOADED_TEMP
	SELECT distinct A.client_code + ' - ' + B.client_name, C.name, A.sub + ' - ' + D.sub_name,'' indicator, E.prd_code,  registration_no,CONVERT(VARCHAR(10), expiry_date, 111) , remarks,
	json_value(vas_activities, '$[0].prd_code'), json_value(vas_activities, '$[0].radio_val'),
	json_value(vas_activities, '$[1].prd_code'), json_value(vas_activities, '$[1].radio_val'),
	json_value(vas_activities, '$[2].prd_code'), json_value(vas_activities, '$[2].radio_val'),
	json_value(vas_activities, '$[3].prd_code'), json_value(vas_activities, '$[3].radio_val'),
	json_value(vas_activities, '$[4].prd_code'), json_value(vas_activities, '$[4].radio_val'),
	json_value(vas_activities, '$[5].prd_code'), json_value(vas_activities, '$[5].radio_val'),
	json_value(vas_activities, '$[6].prd_code'), json_value(vas_activities, '$[6].radio_val'),
	json_value(vas_activities, '$[7].prd_code'), json_value(vas_activities, '$[7].radio_val'),
	json_value(vas_activities, '$[8].prd_code'), json_value(vas_activities, '$[8].radio_val'),
	--subcon_desc, 
	vas_activities
	FROM TBL_MST_subcon_HDR A WITH(NOLOCK)
	INNER JOIN TBL_MST_CLIENT B WITH(NOLOCK) ON A.client_code = B.client_code
	INNER JOIN TBL_MST_DDL C WITH(NOLOCK) ON A.type_of_vas = C.code
	INNER JOIN TBL_MST_CLIENT_SUB D WITH(NOLOCK) ON A.client_code = D.client_code AND A.sub = D.sub_code
	INNER JOIN TBL_MST_subcon_DTL E WITH(NOLOCK) ON A.subcon_no = E.subcon_no
	WHERE A.subcon_no = @subcon_no

	SELECT * FROM #UPLOADED_TEMP

	/***** Temp table for vas activities name *****/
	DECLARE @count INT = (SELECT COUNT(*) FROM VASDEV.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING A WITH(NOLOCK)
							INNER JOIN VASDEV.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) ON A.page_dtl_id = B.page_dtl_id 
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
	FROM #SUBCON_TEMPNAME A, VASDEV.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) WHERE A.page_dtl_id = B.page_dtl_id

	UPDATE A
	SET A.display_name = B.display_name
	FROM #SUBCON_TEMPNAME A, VASDEV.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING B WITH(NOLOCK) WHERE A.page_dtl_id = B.page_dtl_id AND principal_code = 'TH
-HEC'
	/***** Temp table for vas activities name *****/

	SELECT * FROM #SUBCON_TEMPNAME --6--
	WHERE page_dtl_id IS NOT NULL
	UNION ALL
	SELECT list_dtl_id as page_dtl_id, list_col_name, list_default_display_name as display_name 
	FROM VASDEV.dbo.TBL_ADM_CONFIG_PAGE_LISTING_DTL WITH(NOLOCK)
	WHERE list_hdr_id IN (SELECT list_hdr_id FROM VASDEV.dbo.TBL_ADM_CONFIG_PAGE_LISTING_HDR WITH(NOLOCK) WHERE page_code LIKE 'SUBCON%') AND list_col_name in (SELECT name FROM tempdb.sys.columns where object_id = object_id('tempdb..#UPLOADED_TEMP'))
	AND list_col_name NOT IN (SELECT input_name FROM #SUBCON_TEMPNAME)
	UNION ALL
	SELECT '', 'subcon_desc', 'SUBCON Description'
	UNION ALL
	SELECT '', 'validity_period', 'Validity Period'

	DROP TABLE #UPLOADED_TEMP
	DROP TABLE #SUBCON_TEMPNAME
END

GO
