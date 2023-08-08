/****** Object:  StoredProcedure [dbo].[SPP_ADM_COUNTRY_LIST]    Script Date: 08-Aug-23 8:37:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPP_ADM_COUNTRY_LIST]
	@user_id	int
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @country_id INT
	SET @country_id = (SELECT country_id FROM TBL_ADM_USER WITH(NOLOCK) WHERE user_id = @user_id)

	SELECT country_id, country_name FROM TBL_ADM_COUNTRY WITH(NOLOCK) WHERE status = 'A' AND country_id = @country_id
END

GO
