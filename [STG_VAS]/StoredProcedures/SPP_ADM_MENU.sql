/****** Object:  StoredProcedure [dbo].[SPP_ADM_MENU]    Script Date: 08-Aug-23 8:39:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPP_ADM_MENU]
	@user_id varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT A.submodule_id, A.submodule_name, A.parent_submodule_id, A.url, A.icon, A.seq
	INTO #TEMP
	FROM TBL_ADM_SUBMODULE A WITH(NOLOCK)
	INNER JOIN TBL_ADM_ACCESSRIGHT_DTL B WITH(NOLOCK) ON A.submodule_id = B.submodule_id
	INNER JOIN TBL_ADM_USER_ACCESSRIGHT C WITH(NOLOCK) ON C.accessright_id = B.accessright_id
	WHERE user_id = @user_id AND 
	A.status = 'A'
	
	SELECT * FROM #TEMP
	UNION
	SELECT DISTINCT A.submodule_id, A.submodule_name, A.parent_submodule_id, A.url, A.icon, A.seq
	FROM TBL_ADM_SUBMODULE A WITH(NOLOCK)
	INNER JOIN #TEMP B WITH(NOLOCK) ON A.submodule_id = B.parent_submodule_id
	ORDER BY seq ASC

	DROP TABLE #TEMP
END

GO
