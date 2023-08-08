/****** Object:  StoredProcedure [dbo].[SPP_ADM_ACCESSRIGHT_ACTION]    Script Date: 08-Aug-23 8:37:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_ADM_ACCESSRIGHT_ACTION]
	@param NVARCHAR(MAX),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @type VARCHAR(50)
	SET @type = (SELECT JSON_VALUE(@param, '$.type'))
	
	IF @type = 'SUBMODULE_LIST'
	BEGIN
		DECLARE @module_id INT
		SET @module_id = (SELECT JSON_VALUE(@param, '$.module_id'))

		SELECT DISTINCT A.submodule_id, submodule_name 
		FROM TBL_ADM_SUBMODULE A WITH(NOLOCK)
		INNER JOIN TBL_ADM_CONFIG_PAGE_INPUT_HDR B WITH(NOLOCK) ON A.submodule_id = B.submodule_id
		INNER JOIN TBL_ADM_CONFIG_PAGE_INPUT_DTL C WITH(NOLOCK) ON B.page_hdr_id = C.page_hdr_id
		WHERE module_id = @module_id AND C.accessright_ind = 1 AND A.status = 'A'
	END
	ELSE IF @type = 'SUBMODULE_BUTTONS'
	BEGIN
		DECLARE @submodule_id INT
		SET @submodule_id = (SELECT JSON_VALUE(@param, '$.submodule_id'))

		SELECT page_dtl_id, input_id, ISNULL(default_display_name,'') as default_display_name, submodule_id
		FROM TBL_ADM_CONFIG_PAGE_INPUT_DTL A WITH(NOLOCK)
		INNER JOIN TBL_ADM_CONFIG_PAGE_INPUT_HDR B WITH(NOLOCK) ON A.page_hdr_id = B.page_hdr_id
		WHERE A.accessright_ind = 1 AND B.submodule_id = @submodule_id
	END
	ELSE IF @type = 'GET_SUBMODULE_ACTION_BUTTON_VALUE'
	BEGIN
		DECLARE @accessright_id INT
		SET @accessright_id = (SELECT JSON_VALUE(@param, '$.accessright_id'))
		SELECT accessright_button_id FROM TBL_ADM_ACCESSRIGHT WITH(NOLOCK) WHERE accessright_id = @accessright_id
	END
END

GO
