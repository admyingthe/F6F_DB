/****** Object:  StoredProcedure [dbo].[SPP_ADM_ACCESSRIGHT_USER_LIST]    Script Date: 08-Aug-23 8:37:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_ADM_ACCESSRIGHT_USER_LIST] 
	@accessright_id	INTEGER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT login, user_name FROM TBL_ADM_USER A WITH(NOLOCK)
	INNER JOIN TBL_ADM_USER_ACCESSRIGHT B WITH(NOLOCK) ON A.user_id = B.user_id
	WHERE accessright_id = @accessright_id

END


GO
