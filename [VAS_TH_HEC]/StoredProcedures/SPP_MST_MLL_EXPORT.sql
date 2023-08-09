SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ==========================================================================
-- Author:		Smita Thorat
-- Create date: 2022-07-13
-- Description:	Export existing MLL data to upload
-- Example Query: exec SPP_MST_MLL_EXPORT @param=N'{"mll_no":"MLL009300RD00001"}',@user_id=N'1'
-- ===========================================================================

CREATE PROCEDURE [dbo].[SPP_MST_MLL_EXPORT]
	@param	nvarchar(max),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @mll_no VARCHAR(100),@NoRowSelect Integer =0
	SET @mll_no = (SELECT JSON_VALUE(@param, '$.mll_no'))

	IF @mll_no=''
	BEGIN
		SET @mll_no=(select top 1 mll_no from TBL_MST_MLL_HDR)
		SET @NoRowSelect=1
	END
	-- Modified table to include 10-11 VAS activities
	CREATE TABLE #UPLOADED_TEMP(
		client_code VARCHAR(300),
		type_of_vas VARCHAR(200),		
		sub VARCHAR(200),
		validity_period VARCHAR(200),
		prd_code VARCHAR(50),
		storage_cond VARCHAR(100),
		reg_no VARCHAR(200), 
	    medical_device_usage VARCHAR(100),
		bm_ifu VARCHAR(100),
		ppm_by  VARCHAR(100),
		gmp_required VARCHAR(100),
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
		vas_activities_10 VARCHAR(200), 
		vas_activities_10_radio VARCHAR(20), 
		vas_activities_11 VARCHAR(200), 
		vas_activities_11_radio VARCHAR(20), 
		vas_activities_12 VARCHAR(200), 
		vas_activities_12_radio VARCHAR(20), 
		vas_activities_13 VARCHAR(200), 
		vas_activities_13_radio VARCHAR(20), 
		mll_desc NVARCHAR(200),
		vas_activities NVARCHAR(MAX)
	)
	-- Modified Insert query to include 9-12 VAS activities
	INSERT INTO #UPLOADED_TEMP
	SELECT distinct A.client_code + ' - ' + B.client_name, C.name, A.sub + ' - ' + D.sub_name, CONVERT(VARCHAR(10), start_date, 111) + ' - ' + CONVERT(VARCHAR(10), end_date, 111), E.prd_code, F.name, registration_no,ISNULL(G.name,'NA'),
	ISNULL(H.name,'NA'),ISNULL(I.name,'NA') ,CASE WHEN E.gmp_required =1 THEN 'YES' ELSE 'NO' END , remarks,
	json_value(vas_activities, '$[0].prd_code'), json_value(vas_activities, '$[0].radio_val'),
	json_value(vas_activities, '$[1].prd_code'), json_value(vas_activities, '$[1].radio_val'),
	json_value(vas_activities, '$[2].prd_code'), json_value(vas_activities, '$[2].radio_val'),
	json_value(vas_activities, '$[3].prd_code'), json_value(vas_activities, '$[3].radio_val'),
	json_value(vas_activities, '$[4].prd_code'), json_value(vas_activities, '$[4].radio_val'),
	json_value(vas_activities, '$[5].prd_code'), json_value(vas_activities, '$[5].radio_val'),
	json_value(vas_activities, '$[6].prd_code'), json_value(vas_activities, '$[6].radio_val'),
	json_value(vas_activities, '$[7].prd_code'), json_value(vas_activities, '$[7].radio_val'),
	json_value(vas_activities, '$[8].prd_code'), json_value(vas_activities, '$[8].radio_val'),

	json_value(vas_activities, '$[9].prd_code'), json_value(vas_activities, '$[9].radio_val'),
	json_value(vas_activities, '$[10].prd_code'), json_value(vas_activities, '$[10].radio_val'),
	json_value(vas_activities, '$[11].prd_code'), json_value(vas_activities, '$[11].radio_val'),
	json_value(vas_activities, '$[12].prd_code'), json_value(vas_activities, '$[12].radio_val'),

	mll_desc, vas_activities
	FROM TBL_MST_MLL_HDR A WITH(NOLOCK)
	INNER JOIN TBL_MST_CLIENT B WITH(NOLOCK) ON A.client_code = B.client_code
	INNER JOIN TBL_MST_DDL C WITH(NOLOCK) ON A.type_of_vas = C.code
	INNER JOIN TBL_MST_CLIENT_SUB D WITH(NOLOCK) ON A.client_code = D.client_code AND A.sub = D.sub_code
	INNER JOIN TBL_MST_MLL_DTL E WITH(NOLOCK) ON A.mll_no = E.mll_no
	INNER JOIN TBL_MST_DDL F WITH(NOLOCK) ON E.storage_cond = F.code
	LEFT JOIN TBL_MST_DDL G WITH(NOLOCK) ON E.medical_device_usage = G.code
	LEFT JOIN TBL_MST_DDL H WITH(NOLOCK) ON E.bm_ifu = H.code
	LEFT JOIN TBL_MST_DDL I WITH(NOLOCK) ON E.ppm_by = I.code
	WHERE A.mll_no = @mll_no

	IF @NoRowSelect = 1
		SELECT * FROM #UPLOADED_TEMP WHERE 1=2
	ELSE
		SELECT * FROM #UPLOADED_TEMP

	/***** Temp table for vas activities name *****/
	DECLARE @count INT = (SELECT COUNT(*) FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING A WITH(NOLOCK)
							INNER JOIN VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) ON A.page_dtl_id = B.page_dtl_id 
							WHERE principal_code = 'TH-HEC' AND input_name LIKE 'vas_activities_%')

	DECLARE @i INT = 0, @sql NVARCHAR(MAX) = ''
	CREATE TABLE #MLL_TEMPNAME (page_dtl_id INT, input_name VARCHAR(50), display_name NVARCHAR(250))
	WHILE @i < @count
	BEGIN
		SET @sql +=' INSERT INTO #MLL_TEMPNAME (page_dtl_id) SELECT DISTINCT JSON_VALUE(vas_activities, + ''$[' + CAST(@i as varchar(50)) + '].page_dtl_id'') FROM #UPLOADED_TEMP'
		SET @i = @i + 1
	END
	SET @sql += ' DELETE FROM #MLL_TEMPNAME WHERE page_dtl_id IS NULL'
	EXEC (@sql)

	UPDATE A
	SET A.input_name = B.input_name
	FROM #MLL_TEMPNAME A, VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) WHERE A.page_dtl_id = B.page_dtl_id

	UPDATE A
	SET A.display_name = B.display_name
	FROM #MLL_TEMPNAME A, VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING B WITH(NOLOCK) WHERE A.page_dtl_id = B.page_dtl_id AND principal_code = 'TH-HEC'
	/***** Temp table for vas activities name *****/

	SELECT * FROM #MLL_TEMPNAME --6--
	WHERE page_dtl_id IS NOT NULL
	UNION ALL
	SELECT list_dtl_id as page_dtl_id, list_col_name, list_default_display_name as display_name 
	FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_LISTING_DTL WITH(NOLOCK)
	WHERE list_hdr_id IN (SELECT list_hdr_id FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_LISTING_HDR WITH(NOLOCK) WHERE page_code LIKE 'MLL%') AND list_col_name in (SELECT name FROM tempdb.sys.columns where object_id = object_id('tempdb..#UPLOADED_TEMP'))
	AND list_col_name NOT IN (SELECT input_name FROM #MLL_TEMPNAME)
	UNION ALL
	SELECT '', 'mll_desc', 'MLL Description'
	UNION ALL
	SELECT '', 'validity_period', 'Validity Period'

	DROP TABLE #UPLOADED_TEMP
	DROP TABLE #MLL_TEMPNAME
END

GO
