SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =====================================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description:	Retrieve sub list and next running sub code
-- Example Query: exec SPP_MST_GET_MLL_SUB @param=N'{"client_code":"0091","action":"GET_SUB_BY_CLIENT"}'
-- =====================================================================================================

CREATE PROCEDURE [dbo].[SPP_MST_GET_MLL_SUB]
	@param NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @client_code VARCHAR(50), @action VARCHAR(50), @wh_code VARCHAR(50)

	SET @client_code = (SELECT JSON_VALUE(@param, '$.client_code'))
	SET @action = (SELECT JSON_VALUE(@param, '$.action'))
	SET @wh_code = (SELECT JSON_VALUE(@param, '$.wh_code'))
	IF @action = 'GET_SUB_BY_CLIENT'
		SELECT client_code, sub_code, sub_name,wh_code FROM TBL_MST_CLIENT_SUB WITH(NOLOCK) WHERE client_code = @client_code ORDER BY sub_code

	ELSE IF @action = 'GET_NEXT_SUB_CODE'
	BEGIN
		DECLARE @sub_code VARCHAR(10) = 0, @len INT = 2
		SELECT TOP 1 @sub_code = CAST(CAST(RIGHT(sub_code, @len) as INT) + 1 AS VARCHAR(50))
									FROM (SELECT sub_code FROM TBL_MST_CLIENT_SUB WITH(NOLOCK) WHERE client_code = @client_code) A ORDER BY CAST(RIGHT(sub_code, @len) AS INT) DESC
		SET @sub_code = REPLICATE('0', @len - LEN(@sub_code)) + @sub_code

		IF @sub_code > 99
		BEGIN
			SELECT '' as client_code, '' as sub_code,'' wh_code
		END
		ELSE
		BEGIN
			INSERT INTO TBL_MST_CLIENT_SUB
			(client_code, sub_code,wh_code)
			SELECT @client_code, @sub_code,@wh_code
		
			SELECT @client_code as client_code, @sub_code as sub_code,@wh_code
		END
	END
END

GO
