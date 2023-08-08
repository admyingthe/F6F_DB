/****** Object:  StoredProcedure [dbo].[SPP_ADM_USER_DTL]    Script Date: 08-Aug-23 8:39:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_ADM_USER_DTL]
	@user_id	INTEGER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT user_id, login, password, A.country_id, B.country_name, A.principal_id, C.principal_name, 
	A.user_type_id, D.user_type_name, user_name, email, pwd_expiry, pwd_expiry_rmd, max_retry, A.status, department as department_code, A.wh_code
	FROM TBL_ADM_USER A WITH(NOLOCK)
	LEFT JOIN TBL_ADM_COUNTRY B WITH(NOLOCK) ON B.country_id = A.country_id
	LEFT JOIN TBL_ADM_PRINCIPAL C WITH(NOLOCK) ON C.principal_id = A.principal_id
	LEFT JOIN TBL_ADM_USER_TYPE D WITH(NOLOCK) ON D.user_type_id = A.user_type_id
	WHERE user_id = @user_id
END
GO
