/****** Object:  StoredProcedure [dbo].[CONFIG_PAGE_DEFAULT_CONFIGURATION]    Script Date: 08-Aug-23 8:25:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec CONFIG_PAGE_DEFAULT_CONFIGURATION @param=N'{"country_id":"1","principal_id":"2","type":"listing"}'
CREATE PROCEDURE [dbo].[CONFIG_PAGE_DEFAULT_CONFIGURATION]
	@param nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @country_id INT, @principal_id INT, @type varchar(50), @principal_code VARCHAR(50), @country_code VARCHAR(50)
	SET @type = (SELECT JSON_VALUE(@param, '$.type'))
	SET @country_id = (SELECT JSON_VALUE(@param, '$.country_id'))
	SET @principal_id = (SELECT JSON_VALUE(@param, '$.principal_id'))
	SET @country_code = (SELECT country_code FROM TBL_ADM_COUNTRY WITH(NOLOCK) WHERE country_id = @country_id)
	SET @principal_code = (SELECT principal_code FROM TBL_ADM_PRINCIPAL WITH(NOLOCK) WHERE principal_id = @principal_id)
	
	IF @type = 'listing'
	BEGIN
		DELETE FROM TBL_ADM_CONFIG_PAGE_LISTING_SETTING WHERE principal_code = @principal_code
		INSERT INTO TBL_ADM_CONFIG_PAGE_LISTING_SETTING
		(country_code, principal_code, page_code, list_dtl_id, list_col_seq, list_col_display_name, editable, editable_data_type)
		SELECT @country_code, @principal_code, page_code, list_dtl_id, list_col_seq, list_col_display_name, editable, editable_data_type
		FROM TBL_ADM_CONFIG_PAGE_LISTING_SETTING WITH(NOLOCK) WHERE country_code = @country_code AND principal_code = @principal_code--country_code = 'MY' AND principal_code = 'MY-HEC'
	END
	ELSE IF @type = 'input'
	BEGIN
		DELETE FROM TBL_ADM_CONFIG_PAGE_INPUT_SETTING WHERE principal_code = @principal_code
		INSERT INTO TBL_ADM_CONFIG_PAGE_INPUT_SETTING
		(country_code, principal_code, page_code, page_dtl_id, display_name, mandatory, readonly, seq, input_source, additional_input, additional_input_name, validation_message)
		SELECT @country_code, @principal_code, page_code, page_dtl_id, display_name, mandatory, readonly, seq, input_source, additional_input, additional_input_name, validation_message
		FROM TBL_ADM_CONFIG_PAGE_INPUT_SETTING WITH(NOLOCK) WHERE country_code = @country_code AND principal_code = @principal_code--country_code = 'MY' AND principal_code = 'MY-HEC'
	END
END

GO
