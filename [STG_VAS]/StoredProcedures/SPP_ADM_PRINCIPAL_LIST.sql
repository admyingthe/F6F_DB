/****** Object:  StoredProcedure [dbo].[SPP_ADM_PRINCIPAL_LIST]    Script Date: 08-Aug-23 8:46:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SPP_ADM_PRINCIPAL_LIST]
	@country_id INT,
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @country_id INT
	--SET @country_id = (SELECT country_id FROM TBL_ADM_USER WHERE user_id = @user_id)

    SELECT principal_id, principal_name, A.country_id, B.country_name
	FROM TBL_ADM_PRINCIPAL A WITH(NOLOCK)
	LEFT JOIN TBL_ADM_COUNTRY B WITH(NOLOCK) ON A.country_id = B.country_id
	WHERE A.status = 'A' and A.country_id = @country_id
END


GO
