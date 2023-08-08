/****** Object:  StoredProcedure [dbo].[CONFIG_CREATE_PAGE_INPUT_SETTING]    Script Date: 08-Aug-23 8:39:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CONFIG_CREATE_PAGE_INPUT_SETTING]
	@country_code_list nvarchar(max),
	@principal_code_list nvarchar(max),
	@page_code_list nvarchar(max),
	@page_dtl_id_list nvarchar(max),
	@display_name_list nvarchar(max),
	@mandatory_list nvarchar(max),
	@readonly_list nvarchar(max),
	@seq_list nvarchar(max),
	@input_source_list nvarchar(max),
	@additional_input_list nvarchar(max),
	@additional_input_name_list nvarchar(max),
	@validation_message_list nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT * INTO #COUNTRY FROM SF_SPLIT(@country_code_list, ',','''')
	SELECT * INTO #PRINCIPAL FROM SF_SPLIT(@principal_code_list, ',','''')
	SELECT * INTO #PAGE FROM SF_SPLIT(@page_code_list, ',','''')
	SELECT * INTO #PAGEDTL FROM SF_SPLIT(@page_dtl_id_list, ',','''')
	SELECT * INTO #DISPLAYNAME FROM SF_SPLIT(@display_name_list, '|;|','''')
	SELECT * INTO #MANDATORY FROM SF_SPLIT(@mandatory_list, ',','''')
	SELECT * INTO #READONLY FROM SF_SPLIT(@readonly_list, ',','''')
	SELECT * INTO #SEQ FROM SF_SPLIT(@seq_list, ',','''')
	SELECT * INTO #INPUTSOURCE FROM SF_SPLIT(@input_source_list, ',','''')
	SELECT * INTO #ADDITIONALINPUT FROM SF_SPLIT(@additional_input_list, ',','''')
	SELECT * INTO #ADDITIONALINPUTNAME FROM SF_SPLIT(@additional_input_name_list, ',','''')
	SELECT * INTO #VALIDATIONMESSAGE FROM SF_SPLIT(@validation_message_list, ',','''')

	DECLARE @country varchar(50), @principal varchar(50), @page varchar(50)
	SET @country = (SELECT country_code FROM TBL_ADM_COUNTRY WITH(NOLOCK) WHERE country_id = (SELECT Distinct Data FROM #COUNTRY))
	SET @principal = (SELECT principal_code FROM TBL_ADM_PRINCIPAL WITH(NOLOCK) WHERE principal_id = (SELECT Distinct Data FROM #PRINCIPAL))
	SET @page = (SELECT TOP 1 Data FROM #PAGE)

	IF (SELECT COUNT(*) FROM TBL_ADM_CONFIG_PAGE_INPUT_SETTING WITH(NOLOCK) WHERE country_code = @country AND principal_code = @principal AND page_code = @page) > 0
	DELETE FROM TBL_ADM_CONFIG_PAGE_INPUT_SETTING WHERE country_code = @country AND principal_code = @principal AND page_code = @page

	INSERT INTO TBL_ADM_CONFIG_PAGE_INPUT_SETTING
	(country_code, principal_code, page_code, page_dtl_id, display_name, mandatory, readonly, seq, input_source, additional_input, additional_input_name, validation_message)
	SELECT @country, @principal, T1.Data, T3.Data, T4.Data, T5.Data, T11.Data, T6.Data, T7.Data, T8.Data, T10.Data, T9.Data
	FROM #PAGE T1
	INNER JOIN #PAGEDTL T3 ON T1.Id = T3.Id
	INNER JOIN #DISPLAYNAME T4 ON T1.Id = T4.Id
	LEFT JOIN #MANDATORY T5 ON T1.Id = T5.Id
	LEFT JOIN #READONLY T11 ON T1.Id = T11.Id
	INNER JOIN #SEQ T6 ON T1.Id = T6.Id
	LEFT JOIN #INPUTSOURCE T7 ON T1.Id = T7.Id
	LEFT JOIN #ADDITIONALINPUT T8 ON T1.Id = T8.Id
	LEFT JOIN #ADDITIONALINPUTNAME T10 ON T1.Id = T10.Id
	LEFT JOIN #VALIDATIONMESSAGE T9 ON T1.Id = T9.Id

	DROP TABLE #COUNTRY
	DROP TABLE #PRINCIPAL
	DROP TABLE #PAGE
	DROP TABLE #PAGEDTL
	DROP TABLE #DISPLAYNAME
	DROP TABLE #MANDATORY
	DROP TABLE #READONLY
	DROP TABLE #SEQ
	DROP TABLE #INPUTSOURCE
	DROP TABLE #ADDITIONALINPUT
	DROP TABLE #ADDITIONALINPUTNAME
	DROP TABLE #VALIDATIONMESSAGE
END

GO
