/****** Object:  StoredProcedure [dbo].[SPP_ADM_ACCESSRIGHTDTL_UPDATE]    Script Date: 08-Aug-23 8:39:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_ADM_ACCESSRIGHTDTL_UPDATE]
	@accessright_id_list	VARCHAR(MAX),
	@module_id_list			VARCHAR(MAX),
	@submodule_id_list		VARCHAR(MAX),
	@view_list				VARCHAR(MAX),
	@selected_button_string VARCHAR(MAX)
	--@crud_list				VARCHAR(MAX)
	--@create_list			VARCHAR(MAX),
	--@edit_list				VARCHAR(MAX),
	--@del_list				VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT * INTO #ACCESSRIGHT FROM SF_SPLIT(@accessright_id_list,',','''')
	SELECT * INTO #MODULE FROM SF_SPLIT(@module_id_list,',','''')
	SELECT * INTO #SUBMODULE FROM SF_SPLIT(@submodule_id_list,',','''')
	SELECT *, 1 as A_ID INTO #VIEW FROM SF_SPLIT(@view_list,',','''')
	--SELECT *, 2 as A_ID INTO #CRUD FROM SF_SPLIT(@crud_list,',','''')

	DECLARE @ar	VARCHAR(10)
	SET @ar = (SELECT DISTINCT Data FROM #ACCESSRIGHT)

	DECLARE @mod	VARCHAR(10)
	SET @mod = (SELECT DISTINCT Data FROM #MODULE)

	UPDATE TBL_ADM_ACCESSRIGHT
	SET accessright_button_id = @selected_button_string
	WHERE accessright_id = @ar
	AND @mod <> '1'

	DELETE FROM TBL_ADM_ACCESSRIGHT_DTL WHERE accessright_id = @ar AND module_id = @mod AND submodule_id IN (SELECT Data FROM #SUBMODULE)

	INSERT INTO TBL_ADM_ACCESSRIGHT_DTL
	(accessright_id, module_id, submodule_id, action_id)
	SELECT T1.Data as accessright_id, T2.Data as module_id, T3.Data as submodule_id, T4.A_ID as action_id
	FROM #ACCESSRIGHT T1
	INNER JOIN #MODULE T2 ON T1.Id = T2.Id
	INNER JOIN #SUBMODULE T3 ON T1.Id = T3.Id
	INNER JOIN #VIEW T4 ON T1.Id = T4.Id AND T4.Data = 1

	--UNION ALL

	--SELECT T1.Data as accessright_id, T2.Data as module_id, T3.Data as submodule_id, T4.A_ID as action_id
	--FROM #ACCESSRIGHT T1
	--INNER JOIN #MODULE T2 ON T1.Id = T2.Id
	--INNER JOIN #SUBMODULE T3 ON T1.Id = T3.Id
	--INNER JOIN #CRUD T4 ON T1.Id = T4.Id AND T4.Data = 1

	DROP TABLE #ACCESSRIGHT
	DROP TABLE #MODULE
	DROP TABLE #SUBMODULE
	DROP TABLE #VIEW
	--DROP TABLE #CRUD
END

GO
