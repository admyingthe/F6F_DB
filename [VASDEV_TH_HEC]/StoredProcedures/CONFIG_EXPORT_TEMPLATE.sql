SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description:	Retrieve Export Column Template
-- Example Query: exec CONFIG_EXPORT_TEMPLATE  '8032'
-- =============================================

CREATE PROCEDURE [dbo].[CONFIG_EXPORT_TEMPLATE]
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @principal_id INT, @principal_code VARCHAR(50)
	SET @principal_id = (SELECT principal_id FROM VAS.dbo.TBL_ADM_USER WITH(NOLOCK) WHERE user_id = @user_id)
	SET @principal_code = (SELECT principal_code FROM VAS.dbo.TBL_ADM_PRINCIPAL WITH(NOLOCK) WHERE principal_id = @principal_id)

	CREATE TABLE #TEMPLATE_COL
	(
	 row_num INT IDENTITY(1,1),
	 seq NUMERIC(18,1),
	 input_id VARCHAR(50),
	 input_name VARCHAR(50),
	 input_type_name VARCHAR(50),
	 display_name NVARCHAR(200)
	)
	
	INSERT INTO #TEMPLATE_COL (seq, input_id, input_name, input_type_name, display_name)
	SELECT seq, input_id, input_name, input_type_name, CASE WHEN B.display_name <> '' THEN B.display_name ELSE A.default_display_name END
	FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL A WITH(NOLOCK)
	LEFT JOIN VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING B WITH(NOLOCK) ON A.page_dtl_id = B.page_dtl_id
	WHERE principal_code = 'TH-HEC' AND mass_upload_ind = 1 AND delete_flag = 0 AND page_code = 'MLL-SEARCH'
	
	DECLARE @count INT, @i INT = 1, @sql NVARCHAR(MAX), @page_dtl_seq NUMERIC(18,1)
	SET @count = (SELECT COUNT(1) FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING WITH(NOLOCK) WHERE principal_code = 'TH-HEC' AND additional_input_name LIKE 'vas_activities_%')
	SET @sql = 'INSERT INTO #TEMPLATE_COL '

	WHILE @i <= @count
	BEGIN
		SET @page_dtl_seq = (SELECT CAST(seq as VARCHAR(20)) + '.5' FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING A WITH(NOLOCK) INNER JOIN VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) ON A.page_dtl_id = B.page_dtl_id WHERE principal_code = 'TH-HEC' AND page_code = 'MLL-SEARCH' AND input_name = 'vas_activities_' + CAST(@i as VARCHAR(20)))
		SET @sql += 'SELECT ' + CAST(@page_dtl_seq as VARCHAR(20)) + ', ''txtVASActivities_' + CAST(@i as VARCHAR(20)) + ''', ''vas_activities_' + CAST(@i as VARCHAR(20)) + '_radio'', ''text'', ''vas_activities_' + CAST(@i as VARCHAR(20)) + '_radio'''
		IF (@i <> @count) SET @sql += ' UNION ALL '
		SET @i = @i + 1
	END
	EXEC (@sql)

	SELECT * FROM #TEMPLATE_COL ORDER BY seq

	CREATE TABLE #DROPDOWN_DATA
	(
	code VARCHAR(50),
	name NVARCHAR(500),
	type VARCHAR(50)
	)

	DECLARE @count_template_col INT, @j INT = 1, @input_id VARCHAR(50), @ddl_obj NVARCHAR(MAX), @input_type_name VARCHAR(50)
	SET @count_template_col = (SELECT COUNT(1) FROM #TEMPLATE_COL)
	WHILE @j <= @count_template_col
	BEGIN
		SET @input_type_name = (SELECT input_type_name FROM #TEMPLATE_COL WHERE row_num = @j)
		SET @input_id = (SELECT input_id FROM #TEMPLATE_COL WHERE row_num = @j)
		
		IF (@input_type_name = 'dropdown')
		BEGIN
			SET @ddl_obj = N'{"user_id":"' + CAST(@user_id as VARCHAR(20)) + '","language_id":"0","ddl_code":"' + @input_id + '"}'
			INSERT INTO #DROPDOWN_DATA (code, name)
			EXEC SPP_MST_DDL @ddl_obj

			UPDATE #DROPDOWN_DATA
			SET type = @input_id
			WHERE type IS NULL
		END
		SET @j = @j + 1
	END
	SELECT * FROM #DROPDOWN_DATA

	DROP TABLE #DROPDOWN_DATA
	DROP TABLE #TEMPLATE_COL
END

GO
