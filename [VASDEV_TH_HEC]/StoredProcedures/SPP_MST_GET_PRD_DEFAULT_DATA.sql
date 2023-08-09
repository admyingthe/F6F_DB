SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ============================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description:	Retrieve registration number of selected product
-- Example Query: exec SPP_MST_GET_PRD_DEFAULT_DATA @param=N'{"prd_code":"120300310"}'
-- ============================================================================

CREATE PROCEDURE [dbo].[SPP_MST_GET_PRD_DEFAULT_DATA]
	@param NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @prd_code VARCHAR(50)
	SET @prd_code = (SELECT JSON_VALUE(@param, '$.prd_code'))

	SELECT ISNULL(RTRIM(LTRIM(temp)), '') as storage_cond, ISNULL(RTRIM(LTRIM(reg_no)), '') as reg_no 
	FROM TBL_MST_PRODUCT WITH(NOLOCK) 
	WHERE prd_code = @prd_code

END

GO
