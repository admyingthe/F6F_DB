SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =================================================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description:	Retrieve Audit Trail List
-- Example Query: exec SPP_ADM_AUDIT_TRAIL @param=N'{"module":"WORK_ORDER","key_code":"2018/07/0009"}',@user_id=N'1'
-- =================================================================================================================

CREATE PROCEDURE [dbo].[SPP_ADM_AUDIT_TRAIL]
	@param NVARCHAR(MAX),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @module VARCHAR(50), @key_code VARCHAR(50)
	SET @module = (SELECT JSON_VALUE(@param, '$.module'))
    SET @key_code = (SELECT JSON_VALUE(@param, '$.key_code'))

	SELECT action, B.user_name as action_by, CONVERT(VARCHAR(19), action_date, 121) as action_date
	FROM TBL_ADM_AUDIT_TRAIL A WITH(NOLOCK)
	INNER JOIN VAS.dbo.TBL_ADM_USER B WITH(NOLOCK) ON A.action_by = B.user_id
	WHERE key_code LIKE @key_code + '%'
	ORDER BY action_date DESC
END
GO
