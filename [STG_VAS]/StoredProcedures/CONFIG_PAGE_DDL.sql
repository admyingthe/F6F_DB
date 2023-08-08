/****** Object:  StoredProcedure [dbo].[CONFIG_PAGE_DDL]    Script Date: 08-Aug-23 8:25:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CONFIG_PAGE_DDL]
	@param	nvarchar(max) = ''
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @type VARCHAR(50)
	SET @type = (SELECT JSON_VALUE(@param, '$.type'))

	IF @type = 'input'
		SELECT DISTINCT page_code, page_name FROM TBL_ADM_CONFIG_PAGE_INPUT_HDR WITH(NOLOCK)
	ELSE IF @type = 'listing'
		SELECT DISTINCT page_code FROM TBL_ADM_CONFIG_PAGE_LISTING_HDR WITH(NOLOCK)
END

GO
