SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Check if there is any existing draft before allowing to create another new draft
-- Example Query: exec SPP_MST_MLL_COPY_CHECK @param=N'{"client_code":"0093","type_of_vas":"RD","sub":"00"}',@user_id=N'1'
-- =======================================================================================================================

CREATE PROCEDURE [dbo].[SPP_MST_MLL_COPY_CHECK]
	@param	NVARCHAR(MAX),
	@user_id	INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @client_code VARCHAR(50), @type_of_vas VARCHAR(50), @sub VARCHAR(50)
	SET @client_code = (SELECT JSON_VALUE(@param, '$.client_code'))
	SET @type_of_vas = (SELECT JSON_VALUE(@param, '$.type_of_vas'))
	SET @sub = (SELECT JSON_VALUE(@param, '$.sub'))

	SELECT COUNT(*) as num FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE client_code = @client_code AND type_of_vas = @type_of_vas AND sub = @sub AND mll_status = 'Draft'
END

GO
