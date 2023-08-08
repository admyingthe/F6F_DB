/****** Object:  StoredProcedure [dbo].[SPP_API_USER_LIST]    Script Date: 08-Aug-23 8:46:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CHOI CHEE KIEN
-- Create date: 21-06-2023
-- Description:	GET USER LIST FOR IGA API
-- =============================================
CREATE PROCEDURE SPP_API_USER_LIST 
	@user_name AS VARCHAR(200) = NULL,
	@page_number AS INT = NULL,
	@page_size AS INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @sql AS VARCHAR(MAX)

    SET @sql = 'SELECT user_id, login, B.country_name, C.principal_name, D.user_type_name, user_name, email, login_date, A.status, A.wh_code
	FROM TBL_ADM_USER A WITH(NOLOCK)
	LEFT JOIN TBL_ADM_COUNTRY B WITH(NOLOCK) ON A.country_id = B.country_id
	LEFT JOIN TBL_ADM_PRINCIPAL C WITH(NOLOCK) ON A.principal_id = C.principal_id
	LEFT JOIN TBL_ADM_USER_TYPE D WITH(NOLOCK) ON A.user_type_id = D.user_type_id
	WHERE 1 = 1' + CASE WHEN @user_name IS NOT NULL AND @user_name <> '' THEN 'AND user_name LIKE ''%' + @user_name + '%''' 
	ELSE '' END 
	+
	'ORDER BY user_id'
	+
	CASE WHEN @page_number IS NULL AND @page_size IS NULL THEN ''
	ELSE ' OFFSET ' + CAST(ISNULL(@page_size, 50) * (ISNULL(@page_number, 1) - 1) AS VARCHAR(200)) + ' ROWS' +
	' FETCH NEXT ' + CAST(ISNULL(@page_size, 50) AS VARCHAR(200)) + ' ROWS ONLY'
	END

	EXEC(@sql)
END

GO
