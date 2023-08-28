SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[SPP_GET_AUDIT_TRAIL]
@module NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TOP(10) action, B.user_name as action_by, CONVERT(VARCHAR(19), action_date, 121) as action_date
	FROM TBL_ADM_AUDIT_TRAIL A WITH(NOLOCK)
	INNER JOIN VAS.dbo.TBL_ADM_USER B WITH(NOLOCK) ON A.action_by = B.user_id
	WHERE module = @module
	ORDER BY action_date DESC
END

GO
