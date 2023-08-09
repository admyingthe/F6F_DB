SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CONFIG_CREATE_PAGE_LISTING_SETTING]
	@country_code_list nvarchar(max),
	@principal_code_list nvarchar(max),
	@page_code_list nvarchar(max),
	@list_dtl_id_list nvarchar(max),
	@list_col_seq_list nvarchar(max),
	@list_col_type_list nvarchar(max),
	@list_col_display_name_list nvarchar(max),
	@list_editable_list nvarchar(max),
	@list_editable_data_type_list nvarchar(max),
	@list_hidden_list nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT * INTO #COUNTRY FROM SF_SPLIT(@country_code_list, ',','''')
	SELECT * INTO #PRINCIPAL FROM SF_SPLIT(@principal_code_list, ',','''')
	SELECT * INTO #PAGE FROM SF_SPLIT(@page_code_list, ',','''')

	DECLARE @country varchar(50), @principal varchar(50), @page varchar(50)
	SET @country = (SELECT country_code FROM TBL_ADM_COUNTRY WITH(NOLOCK) WHERE country_id = (SELECT Distinct Data FROM #COUNTRY))
	SET @principal = (SELECT principal_code FROM TBL_ADM_PRINCIPAL WITH(NOLOCK) WHERE principal_id = (SELECT Distinct Data FROM #PRINCIPAL))
	SET @page = (SELECT Distinct Data FROM #PAGE)

	DELETE FROM TBL_ADM_CONFIG_PAGE_LISTING_SETTING WHERE country_code = @country AND principal_code = @principal AND page_code = @page

	INSERT INTO TBL_ADM_CONFIG_PAGE_LISTING_SETTING
	(country_code, principal_code, page_code, list_dtl_id, list_col_seq, list_col_type, list_col_display_name, editable, editable_data_type, hidden)
	SELECT @country, @principal, @page, T1.Data, T2.Data, T3.Data, T4.Data, T6.Data, T7.Data, T8.Data
	FROM SF_SPLIT(@list_dtl_id_list, ',','''') T1
	INNER JOIN SF_SPLIT(@list_col_seq_list, ',','''') T2 ON T1.Id = T2.Id
	LEFT JOIN SF_SPLIT(@list_col_type_list, ',','''') T3 ON T1.Id = T3.Id
	INNER JOIN SF_SPLIT(@list_col_display_name_list, ',','''') T4 ON T1.Id = T4.Id
	LEFT JOIN SF_SPLIT(@list_editable_list, ',','''') T6 ON T1.Id = T6.Id
	LEFT JOIN SF_SPLIT(@list_editable_data_type_list, ',','''') T7 ON T1.Id = T7.Id
	LEFT JOIN SF_SPLIT(@list_hidden_list, ',','''') T8 ON T1.Id = T8.Id

	DROP TABLE #COUNTRY
	DROP TABLE #PRINCIPAL
END
GO
