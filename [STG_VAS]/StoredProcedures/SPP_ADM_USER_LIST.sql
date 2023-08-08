/****** Object:  StoredProcedure [dbo].[SPP_ADM_USER_LIST]    Script Date: 08-Aug-23 8:39:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_ADM_USER_LIST]
	@login	VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ar_id INTEGER, @principal_id INT
	SET @ar_id = (SELECT accessright_id FROM TBL_ADM_USER_ACCESSRIGHT A WITH(NOLOCK)
				  INNER JOIN TBL_ADM_USER B WITH(NOLOCK) ON A.user_id = B.user_id
				  WHERE B.login = @login)
	SET @principal_id = (SELECT principal_id FROM TBL_ADM_USER WITH(NOLOCK) WHERE login = @login)

	IF( @ar_id = '1')
	BEGIN
		SELECT user_id, login, B.country_name, C.principal_name, D.user_type_name, user_name, email, login_date, A.status, A.wh_code
		FROM TBL_ADM_USER A WITH(NOLOCK)
		LEFT JOIN TBL_ADM_COUNTRY B WITH(NOLOCK) ON A.country_id = B.country_id
		LEFT JOIN TBL_ADM_PRINCIPAL C WITH(NOLOCK) ON A.principal_id = C.principal_id
		LEFT JOIN TBL_ADM_USER_TYPE D WITH(NOLOCK) ON A.user_type_id = D.user_type_id 
		WHERE A.principal_id = @principal_id
	END
	ELSE
	BEGIN
		SELECT A.user_id, login, B.country_name, C.principal_name, D.user_type_name, user_name, email, login_date, A.status, A.wh_code
		FROM TBL_ADM_USER A WITH(NOLOCK)
		LEFT JOIN TBL_ADM_COUNTRY B WITH(NOLOCK) ON A.country_id = B.country_id
		LEFT JOIN TBL_ADM_PRINCIPAL C WITH(NOLOCK) ON A.principal_id = C.principal_id
		LEFT JOIN TBL_ADM_USER_TYPE D WITH(NOLOCK) ON A.user_type_id = D.user_type_id 
		INNER JOIN TBL_ADM_USER_ACCESSRIGHT E WITH(NOLOCK) ON A.user_id = E.user_id
		WHERE E.accessright_id <> '1'
		--AND E.accessright_id <> @ar_id
		AND A.status = 'A' AND A.principal_id = @principal_id
	END
	
END
GO
