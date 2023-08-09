SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec SPP_MST_VALIDATE_PRODUCT @param=N'{"client_code":"0091","prd_list":["abcd","asdjalsdj"]}'
CREATE PROCEDURE [dbo].[SPP_MST_VALIDATE_PRODUCT]
	@param NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @mll_no VARCHAR(50), @client_code VARCHAR(50)
	SET @mll_no = (SELECT JSON_VALUE(@param, '$.mll_no'))
	SET @client_code = (SELECT JSON_VALUE(@param, '$.client_code'))
	
	SELECT value as prd_code, CAST(0 AS INT) as valid INTO #TEMP_PRD FROM OPENJSON(@param,'$.prd_list')

	UPDATE A
	SET valid = 1
	FROM #TEMP_PRD A 
	INNER JOIN TBL_MST_MLL_DTL B WITH(NOLOCK) ON A.prd_code = B.prd_code AND B.mll_no = @mll_no

	SELECT * FROM #TEMP_PRD WHERE valid = 0
    DROP TABLE #TEMP_PRD
END

GO
