SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SPP_GET_AUDIT_TRAIL_MODULE_KEY_CODE
	@param NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @module VARCHAR(50), @key_code VARCHAR(50)
	SET @module = (SELECT JSON_VALUE(@param, '$.module'))
    SET @key_code = (SELECT JSON_VALUE(@param, '$.key_code'))

	SELECT action, B.user_name as action_by, CONVERT(VARCHAR(19), action_date, 121) as action_date
	FROM TBL_ADM_AUDIT_TRAIL A WITH(NOLOCK)
	INNER JOIN VAS.dbo.TBL_ADM_USER B WITH(NOLOCK) ON A.action_by = B.user_id
	WHERE key_code = @key_code AND module = @module
	ORDER BY action_date DESC
END

GO
