/****** Object:  StoredProcedure [dbo].[SPP_ADM_USER_TYPE_LIST]    Script Date: 08-Aug-23 8:39:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_ADM_USER_TYPE_LIST]

AS
BEGIN
	SET NOCOUNT ON;

	SELECT user_type_id, user_type_name FROM TBL_ADM_USER_TYPE WITH(NOLOCK) WHERE status = 'A'
END

GO
