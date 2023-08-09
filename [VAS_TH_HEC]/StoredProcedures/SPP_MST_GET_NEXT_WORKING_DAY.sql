SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE SPP_MST_GET_NEXT_WORKING_DAY
	@param VARCHAR(500)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @date as VARCHAR(50), @case VARCHAR(10)
	SET @case = (SELECT JSON_VALUE(@param, '$.case'))
	SET @date = (SELECT JSON_VALUE(@param, '$.date'))

	IF @case = 'urgent'
		SELECT CONVERT(VARCHAR(10), working_day, 121) as next_working_day FROM dbo.[TF_COR_GET_WORKING_DAYS](@date, 0)
	ELSE IF @case = 'normal'
		SELECT TOP 1 CONVERT(VARCHAR(10), working_day, 121) as next_working_day FROM dbo.[TF_COR_GET_WORKING_DAYS](@date, 5) ORDER BY s_no DESC
END

GO
