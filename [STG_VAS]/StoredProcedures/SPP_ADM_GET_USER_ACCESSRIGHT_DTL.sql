/****** Object:  StoredProcedure [dbo].[SPP_ADM_GET_USER_ACCESSRIGHT_DTL]    Script Date: 08-Aug-23 8:46:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_ADM_GET_USER_ACCESSRIGHT_DTL]
	@user_id		INTEGER,
	@submodule_id	INTEGER
AS
BEGIN
	SET NOCOUNT ON;

	IF @submodule_id = 0
	BEGIN
		SELECT A.user_id, A.accessright_id, C.accessright_name, B.module_id, D.module_name, B.submodule_id, E.submodule_name, B.action_id
		FROM TBL_ADM_USER_ACCESSRIGHT A WITH(NOLOCK)
		INNER JOIN TBL_ADM_ACCESSRIGHT_DTL B WITH(NOLOCK) ON B.accessright_id = A.accessright_id
		INNER JOIN TBL_ADM_ACCESSRIGHT C WITH(NOLOCK) ON B.accessright_id = C.accessright_id
		INNER JOIN TBL_ADM_MODULE D WITH(NOLOCK) ON B.module_id = D.module_id
		INNER JOIN TBL_ADM_SUBMODULE E WITH(NOLOCK) ON B.submodule_id = E.submodule_id
		WHERE user_id = @user_id
	END
	ELSE
	BEGIN
		SELECT A.user_id, A.accessright_id, C.accessright_name, B.module_id, D.module_name, B.submodule_id, E.submodule_name, B.action_id
		FROM TBL_ADM_USER_ACCESSRIGHT A WITH(NOLOCK)
		INNER JOIN TBL_ADM_ACCESSRIGHT_DTL B WITH(NOLOCK) ON B.accessright_id = A.accessright_id
		INNER JOIN TBL_ADM_ACCESSRIGHT C WITH(NOLOCK) ON B.accessright_id = C.accessright_id
		INNER JOIN TBL_ADM_MODULE D WITH(NOLOCK) ON B.module_id = D.module_id
		INNER JOIN TBL_ADM_SUBMODULE E WITH(NOLOCK) ON B.submodule_id = E.submodule_id
		WHERE user_id = @user_id AND B.submodule_id = @submodule_id
	END
END

GO
