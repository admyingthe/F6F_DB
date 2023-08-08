/****** Object:  StoredProcedure [dbo].[CONFIG_PAGE_ENQ]    Script Date: 08-Aug-23 8:39:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC [CONFIG_PAGE_ENQ] @param=N'{"user_id":"13128","language_id":"0","page_code":"MLL-SEARCH"}'


CREATE PROCEDURE [dbo].[CONFIG_PAGE_ENQ] 
	@param nvarchar(max) = ''
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @page_code VARCHAR(50), @user_id INT, @principal_code VARCHAR(50)
	SET @page_code = (SELECT JSON_VALUE(@param, '$.page_code'))
    SET @user_id = (SELECT JSON_VALUE(@param, '$.user_id'))
	SET @principal_code = (SELECT principal_code FROM TBL_ADM_PRINCIPAL A WITH(NOLOCK) INNER JOIN TBL_ADM_USER B WITH(NOLOCK) ON A.principal_id = B.principal_id WHERE B.user_id = @user_id)

	--INPUT--
	SELECT B.page_dtl_id, D.section_code, input_id, input_name, display_name, default_display_name, B.input_type_name, seq, mandatory, readonly, input_source, C.input_type_syntax, style_name, onclick_function, onkeyup, onchange, additional_input, additional_input_name, validation_message, accessright_ind
	INTO #INPUT
	FROM TBL_ADM_CONFIG_PAGE_INPUT_SETTING A WITH(NOLOCK)
	INNER JOIN TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) ON A.page_dtl_id = B.page_dtl_id
	INNER JOIN TBL_ADM_CONFIG_INPUT_TYPE C WITH(NOLOCK) ON B.input_type_id = C.input_type_id
	INNER JOIN TBL_ADM_CONFIG_PAGE_INPUT_HDR D WITH(NOLOCK) ON B.page_hdr_id = D.page_hdr_id
	WHERE principal_code = @principal_code AND A.page_code = @page_code AND delete_flag = 0

	UPDATE #INPUT
	SET display_name = default_display_name
	WHERE display_name = ''

	UPDATE #INPUT
	SET input_type_syntax = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(input_type_syntax, '@onchange', ISNULL(onchange,'')), '@onkeyup', ISNULL(onkeyup,'')), '@input_name', ISNULL(input_name,'')), '@onclick_function', ISNULL(onclick_function,'')), '@style_name', ISNULL(style_name,'')), '@display_name', display_name), '@display_id', input_id) --REPLACE(REPLACE(REPLACE(REPLACE(input_type_syntax, '@onclick_function', ISNULL(onclick_function,'')), '@style_name', ISNULL(style_name,'')), '@display_name', display_name), '@display_id', input_id)

	UPDATE #INPUT
	SET input_type_syntax = REPLACE(input_type_syntax, '@display_name', ISNULL(display_name,''))
	WHERE input_type_name = 'button-dropdown'

	UPDATE #INPUT
	SET input_type_syntax = REPLACE(input_type_syntax, 'required', '')
	WHERE mandatory = 0

	UPDATE #INPUT
	SET input_type_syntax = REPLACE(input_type_syntax, 'readonly', '')
	WHERE readonly = 0

	UPDATE #INPUT
	SET display_name = (SELECT display_name + '<i onclick="AddSub()" class="fa fa-tag" style="margin-left:10px; cursor:pointer; font-size:18px;" data-toggle="tooltip" title="Edit Sub"></i>' FROM #INPUT WHERE input_id = 'ddlSub')
	WHERE input_id = 'ddlSub'

	UPDATE #INPUT
	SET display_name = (SELECT display_name + '<i onclick="ViewHeaderAttachment()" id="hdr_attachment_ind" class="fa fa-folder-o badge1" style="margin-left:10px; cursor:pointer; font-size:22px" data-toggle="tooltip" title="View Attachments" data-badge="0"></i>' FROM #INPUT WHERE input_name = 'attachment_with_view_button')
	WHERE input_name = 'attachment_with_view_button'

	UPDATE #INPUT
	SET display_name = (SELECT display_name + '<i onclick="ViewMLLChangesSummary()" class="fa fa-sticky-note" style="margin-left:10px; cursor:pointer; font-size:18px; color:#ab1032" data-toggle="tooltip" title="View Changes Summary"></i>' FROM #INPUT WHERE input_name = 'mll_change_remarks')
	WHERE input_name = 'mll_change_remarks'

	DECLARE @accessright_id INT
	SET @accessright_id = (SELECT TOP 1 accessright_id FROM TBL_ADM_USER_ACCESSRIGHT WITH(NOLOCK) WHERE user_id = @user_id)
	
	DECLARE @var1 VARCHAR(5000)
	DECLARE @var2 VARCHAR(5000)
	SET @var1 = (SELECT accessright_button_id FROM TBL_ADM_ACCESSRIGHT WITH(NOLOCK) WHERE accessright_id = @accessright_id)
	SET @var2 = ',' + @var1 + ','
	DELETE FROM #INPUT WHERE accessright_ind = 1 AND CHARINDEX(',' + CAST(page_dtl_id as VARCHAR) + ',', @var2) = 0
	--INPUT--

	--LISTING--
	SELECT section_code, list_col_name, list_col_seq, list_col_type, list_col_display_name, list_default_display_name, B.list_col_function,
	ISNULL(editable,0) as editable, ISNULL(editable_data_type, '') as editable_data_type, ISNULL(hidden,0) as hidden, 0 as qa_access, A.thousand_separator
	INTO #LISTING
	FROM TBL_ADM_CONFIG_PAGE_LISTING_SETTING A WITH(NOLOCK)
	INNER JOIN TBL_ADM_CONFIG_PAGE_LISTING_DTL B WITH(NOLOCK) ON A.list_dtl_id = B.list_dtl_id
	INNER JOIN TBL_ADM_CONFIG_PAGE_LISTING_HDR C WITH(NOLOCK) ON B.list_hdr_id = C.list_hdr_id
	WHERE principal_code = @principal_code AND C.page_code = @page_code AND delete_flag = 0

	UPDATE #LISTING
	SET list_col_display_name = list_default_display_name
	WHERE list_col_display_name = ''

	UPDATE #LISTING
	SET qa_access = 1
	WHERE list_col_name = 'qa_required' AND EXISTS (SELECT 1 FROM TBL_ADM_ACCESSRIGHT A WITH(NOLOCK) WHERE accessright_id = @accessright_id AND (accessright_name LIKE '%QA%' OR accessright_id = '1'))
	--LISTING--


	DECLARE @access_right varchar(100)
		SET @access_right=( SELECT     G.accessright_name  
	  FROM TBL_ADM_USER A WITH(NOLOCK) 
	  INNER JOIN TBL_ADM_USER_ACCESSRIGHT F WITH(NOLOCK) ON A.user_id = F.user_id    
	  INNER JOIN TBL_ADM_ACCESSRIGHT G WITH(NOLOCK) ON F.accessright_id = G.accessright_id  
	  WHERE   A.user_id=@user_id)
  



	IF @page_code ='MLL-SEARCH' AND @principal_code='TH-HEC' AND @access_right='Master Data'
	BEGIN
		DELETE FROM #INPUT WHERE input_id='lblDepartment'
	END
	ELSE IF @page_code ='MLL-SEARCH' AND @principal_code='TH-HEC'
	BEGIN
		DELETE FROM #INPUT WHERE input_id='ddlDepartment'
	END
	   	 


	SELECT * FROM #INPUT ORDER BY seq
	SELECT * FROM #LISTING ORDER BY list_col_seq
	DROP TABLE #INPUT
	DROP TABLE #LISTING
END
GO
