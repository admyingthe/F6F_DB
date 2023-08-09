SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Retrieve MLL Sumarry Listing
-- Example Query: exec SPP_MST_MLL_SUMMARY_LISTING @param=N'{"page_index":0,"page_size":20,"search_term":"","export_ind":0}',@user_id=N'13148'
-- Output : 
-- 1) dtCount - Total rows
-- 2) dt - Data
-- 3) dtExportInd - Export indicator
-- 4) dtExportColumnName - Export column display name
-- =======================================================================================================================================

CREATE PROCEDURE [dbo].[SPP_MST_MLL_SUMMARY_LISTING]
	@param	nvarchar(max),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @page_index INT, @page_size INT, @search_term NVARCHAR(100), @export_ind CHAR(1)
	SET @page_index = (SELECT JSON_VALUE(@param, '$.page_index'))
	SET @page_size = (SELECT JSON_VALUE(@param, '$.page_size'))
	SET @search_term = (SELECT JSON_VALUE(@param, '$.search_term'))
	SET @export_ind = (SELECT JSON_VALUE(@param, '$.export_ind'))

	DECLARE @dept_code VARCHAR(10)
	SET @dept_code = (SELECT department FROM VASDEV.dbo.TBL_ADM_USER WHERE user_id = @user_id)


	  --Start/13 Dec 2022/ Smita Thorat//Added for Showing all records to Admin login
	DECLARE @Count_user INTEGER

	SET @Count_user=(SELECT count(1) from  VASDEV.dbo.[TBL_ADM_USER_ACCESSRIGHT] UA
					INNER JOIN VASDEV.dbo.TBL_ADM_ACCESSRIGHT A ON UA.accessright_id =A.accessright_id
					INNER JOIN VASDEV.dbo.TBL_ADM_USER U ON UA.user_id =U.user_id
					where A.accessright_name='bsadmin' AND U.user_id=@user_id)

	IF @Count_user=1
	BEGIN
		SET @dept_code=''
	END
	--End/13 Dec 2022/ Smita Thorat//Added for Showing all records to Admin login


	CREATE TABLE #TEMP_MLL_SUMMARY
	(
		mll_no VARCHAR(50),
		qas_no VARCHAR(MAX),
		revision_no VARCHAR(10),
		client_code VARCHAR(50),
		client_name NVARCHAR(500),
		type_of_vas VARCHAR(50),
		sub VARCHAR(10),
		sub_name NVARCHAR(250),
		mll_status NVARCHAR(MAX),
		urgent VARCHAR(10)
	)

	IF @dept_code = ''
	BEGIN
		INSERT INTO #TEMP_MLL_SUMMARY
		SELECT mll_no, A.mll_desc, A.revision_no, A.client_code, B.client_name, type_of_vas, A.sub, C.sub_name, 
		CASE WHEN mll_status = 'Submitted' THEN 'Submitted by ' + D.user_name + ' on ' + CONVERT(VARCHAR(10),submitted_date, 121)
		ELSE mll_status END,
		CASE WHEN mll_urgent = 'Y' THEN 'YES'
		ELSE 'NO' END
		FROM TBL_MST_MLL_HDR A WITH(NOLOCK) 
		INNER JOIN TBL_MST_CLIENT B WITH(NOLOCK) ON A.client_code = B.client_code
		INNER JOIN TBL_MST_CLIENT_SUB C WITH(NOLOCK) ON A.client_code = C.client_code AND A.sub = C.sub_code
		LEFT JOIN VASDEV.dbo.TBL_ADM_USER D WITH(NOLOCK) ON A.submitted_by = D.user_id
		WHERE mll_status IN ('Draft', 'Submitted')
	END
	ELSE
	BEGIN
		INSERT INTO #TEMP_MLL_SUMMARY
		SELECT mll_no, A.mll_desc, A.revision_no, A.client_code, B.client_name, type_of_vas, A.sub, C.sub_name, 
		CASE WHEN mll_status = 'Submitted' THEN 'Submitted by ' + E.user_name + ' on ' + CONVERT(VARCHAR(10),submitted_date, 121)
		ELSE mll_status END,
		CASE WHEN mll_urgent = 'Y' THEN 'YES'
		ELSE 'NO' END
		FROM TBL_MST_MLL_HDR A WITH(NOLOCK) 
		INNER JOIN TBL_MST_CLIENT B WITH(NOLOCK) ON A.client_code = B.client_code
		INNER JOIN TBL_MST_CLIENT_SUB C WITH(NOLOCK) ON A.client_code = C.client_code AND A.sub = C.sub_code
		LEFT JOIN VASDEV.dbo.TBL_ADM_USER D WITH(NOLOCK) ON A.creator_user_id = D.user_id
		LEFT JOIN VASDEV.dbo.TBL_ADM_USER E WITH(NOLOCK) ON A.submitted_by = E.user_id
		WHERE mll_status IN ('Draft', 'Submitted')  AND (D.department = @dept_code or  ISNULL(A.dept_code,'') =@dept_code )
	END

	

	IF @search_term <> ''
	BEGIN
		SELECT COUNT(1) as ttl_rows FROM #TEMP_MLL_SUMMARY  --1
		WHERE (	mll_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE mll_no END OR
				qas_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE qas_no END OR
				revision_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE revision_no END OR
				client_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_code END OR
				client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR
				type_of_vas LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE type_of_vas END OR
				sub LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE sub END OR
				sub_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE sub_name END OR
				mll_status LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE mll_status END OR
				urgent LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE urgent END)
	END
	ELSE
	BEGIN
		SELECT COUNT(1) as ttl_rows FROM #TEMP_MLL_SUMMARY  --1
	END

	IF (@export_ind = '0')
		SELECT * FROM #TEMP_MLL_SUMMARY --2
		WHERE (	mll_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE mll_no END OR
				qas_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE qas_no END OR
				revision_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE revision_no END OR
				client_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_code END OR
				client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR
				type_of_vas LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE type_of_vas END OR
				sub LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE sub END OR
				sub_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE sub_name END OR
				mll_status LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE mll_status END OR
				urgent LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE urgent END)
		ORDER BY mll_no ASC
		OFFSET @page_index * @page_size ROWS
		FETCH NEXT @page_size ROWS ONLY
	ELSE IF (@export_ind = '1')
		SELECT * FROM #TEMP_MLL_SUMMARY --2
		WHERE (	mll_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE mll_no END OR
				qas_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE qas_no END OR
				revision_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE revision_no END OR
				client_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_code END OR
				client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR
				type_of_vas LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE type_of_vas END OR
				sub LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE sub END OR
				sub_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE sub_name END OR
				mll_status LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE mll_status END OR
				urgent LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE urgent END)
		ORDER BY mll_no ASC

	SELECT @export_ind AS export_ind --3

	SELECT list_dtl_id, list_col_name as input_name, list_default_display_name as display_name  --4
	FROM VASDEV.dbo.TBL_ADM_CONFIG_PAGE_LISTING_DTL WITH(NOLOCK)
	WHERE list_hdr_id IN (SELECT list_hdr_id FROM VASDEV.dbo.TBL_ADM_CONFIG_PAGE_LISTING_HDR WITH(NOLOCK) WHERE page_code = 'MLL-SUMMARY-SEARCH') AND list_col_name in (SELECT name FROM tempdb.sys.columns where object_id = object_id('tempdb..#TEMP_MLL_SUMMARY'))

	DROP TABLE #TEMP_MLL_SUMMARY
END
GO
