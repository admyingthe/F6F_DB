SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description:	Retrieve header info of selected MLL and product
-- Example Query: exec SPP_MST_GET_PRD_MLL_DTL @param=N'{"mll_no":"MLL005300RD00001","prd_code":"100790225"}', @user_id = 1
-- ========================================================================================================================

CREATE PROCEDURE [dbo].[SPP_MST_GET_PRD_MLL_DTL]
	@param NVARCHAR(MAX),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @mll_no VARCHAR(50), @prd_code VARCHAR(50)
	SET @mll_no = (SELECT JSON_VALUE(@param, '$.mll_no'))
	SET @prd_code = (SELECT JSON_VALUE(@param, '$.prd_code'))

    SELECT A.mll_no, B.client_code, C.name as storage_cond, ISNULL(D.name,'NA') as medical_device_usage,ISNULL(E.name,'NA')as bm_ifu, remarks, registration_no, CAST(NULL AS NVARCHAR(MAX)) as vas_activities, client_ref_no, revision_no
	INTO #DTL
	FROM TBL_MST_MLL_DTL A WITH(NOLOCK)
	INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no
	LEFT JOIN TBL_MST_DDL C WITH(NOLOCK) ON A.storage_cond = C.code
	LEFT JOIN TBL_MST_DDL D WITH(NOLOCK) ON A.medical_device_usage = D.code
	LEFT JOIN TBL_MST_DDL E WITH(NOLOCK) ON A.bm_ifu = E.code
	WHERE B.mll_no = @mll_no AND prd_code = @prd_code

	DECLARE @json_activities NVARCHAR(MAX)
	SET @json_activities = (SELECT vas_activities FROM TBL_MST_MLL_DTL A WITH(NOLOCK) INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no WHERE B.mll_no = @mll_no AND prd_code = @prd_code) 
	SELECT IDENTITY(INT, 1, 1) AS row_id, CAST(NULL AS NVARCHAR(250)) as display_name, * INTO #VAS_ACTIVITIES FROM OPENJSON ( @json_activities )  
	WITH (
		prd_code	VARCHAR(50)	'$.prd_code',  
		page_dtl_id	INT			'$.page_dtl_id',  
		radio_val	CHAR(1)		'$.radio_val'
	)
	WHERE radio_val = 'Y'

	UPDATE A
	SET display_name = B.display_name
	FROM #VAS_ACTIVITIES A, VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING B WITH(NOLOCK)
	WHERE A.page_dtl_id = B.page_dtl_id

	DECLARE @vas_html NVARCHAR(MAX) = ''
	DECLARE @count INT = (SELECT COUNT(*) FROM #VAS_ACTIVITIES), @i INT = 1
	
	WHILE @i <= @count
	BEGIN
		--SET @vas_html += (SELECT CAST(@i as VARCHAR(100)) + '. ' + prd_code + ' ' + CASE WHEN radio_val = '' THEN '' ELSE + '(' + CASE WHEN radio_val = 'Y' THEN 'Yes' WHEN radio_val = 'N' THEN 'No' WHEN radio_val = 'P' THEN 'Preprinted' ELSE '' END  + ')' END + ' - ' + display_name FROM #VAS_ACTIVITIES WHERE row_id = @i)
		SET @vas_html += (SELECT CAST(@i as VARCHAR(100)) + '. ' + prd_code + ' ' + CASE WHEN radio_val = '' THEN '' ELSE '(' + radio_val + ')' END + ' - ' + display_name FROM #VAS_ACTIVITIES WHERE row_id = @i)

		IF (@i != @count) SET @vas_html = @vas_html + '<br />'
		ELSE SET @vas_html = @vas_html + ' '
		SET @i = @i + 1
	END
	
	UPDATE #DTL SET vas_activities = @vas_html

	SELECT * FROM #DTL
	DROP TABLE #DTL
	DROP TABLE #VAS_ACTIVITIES
END

GO
