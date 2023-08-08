/****** Object:  StoredProcedure [dbo].[CONFIG_PAGE_LIST]    Script Date: 08-Aug-23 8:25:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec XX_PAGE_LIST @param=N'{"country_id":"1","principal_id":"1","type":"input","page_code":"MLL-SEARCH"}'
--exec XX_PAGE_LIST @param=N'{"country_id":"1","principal_id":"1","type":"listing","page_code":"JOB-EVENT-SEARCH"}'
CREATE PROCEDURE [dbo].[CONFIG_PAGE_LIST]
	@param	nvarchar(max) = ''
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @country_id INT, @principal_id INT, @type varchar(50), @page_code varchar(50), @principal_code VARCHAR(50)
	SET @type = (SELECT JSON_VALUE(@param, '$.type'))
	SET @country_id = (SELECT JSON_VALUE(@param, '$.country_id'))
	SET @principal_id = (SELECT JSON_VALUE(@param, '$.principal_id'))
	SET @page_code = (SELECT JSON_VALUE(@param, '$.page_code'))
	SET @principal_code = (SELECT principal_code FROM TBL_ADM_PRINCIPAL WITH(NOLOCK) WHERE principal_id = @principal_id)

	IF @type = 'input'
	BEGIN
		CREATE TABLE #INPUT
		(
		principal_code	varchar(50),
		page_hdr_id		int,
		page_code		varchar(100),
		section_code	varchar(50),
		page_dtl_id		integer,
		input_id		varchar(100),
		input_name		nvarchar(200),
		input_type_name	varchar(50),
		is_checked		int,
		display_name	nvarchar(200),
		mandatory		int,
		readonly		int,
		seq				int,
		input_source	varchar(100),
		additional_input nvarchar(4000),
		additional_input_name	varchar(50),
		validation_message	nvarchar(4000)
		)

		INSERT INTO #INPUT
		(page_code, page_hdr_id, section_code, page_dtl_id, input_id, input_name, input_type_name, is_checked, display_name, mandatory, readonly, seq, input_source, additional_input, additional_input_name, validation_message)
		SELECT @page_code, '0', B.section_code, A.page_dtl_id, input_id, input_name, input_type_name, '0', cast(null as nvarchar(200)), '0', '0', '0', cast(null as varchar(100)), cast(null as nvarchar(4000)), cast(null as varchar(50)), cast(null as nvarchar(4000))
		FROM TBL_ADM_CONFIG_PAGE_INPUT_DTL A WITH(NOLOCK)
		INNER JOIN TBL_ADM_CONFIG_PAGE_INPUT_HDR B WITH(NOLOCK) ON A.page_hdr_id = B.page_hdr_id
		--LEFT JOIN TBL_ADM_CONFIG_PAGE_INPUT_SETTING C ON A.page_dtl_id = C.page_dtl_id
		WHERE B.page_code = @page_code
		AND delete_flag = 0
		ORDER BY B.page_hdr_id
		--AND C.country_code = (SELECT country_code FROM TBL_ADM_COUNTRY WHERE country_id = @country_id)
		--AND C.principal_code = (SELECT principal_code FROM TBL_ADM_PRINCIPAL WHERE principal_id = @principal_id)

		UPDATE A
		SET A.page_hdr_id = B.page_hdr_id
		FROM #INPUT A
		INNER JOIN TBL_ADM_CONFIG_PAGE_INPUT_HDR B WITH(NOLOCK) ON A.page_code = B.page_code AND A.section_code = B.section_code

		UPDATE A
		SET is_checked = 1
		FROM #INPUT A
		WHERE EXISTS(SELECT 1 FROM TBL_ADM_CONFIG_PAGE_INPUT_SETTING B WITH(NOLOCK) 
					 WHERE A.page_dtl_id = B.page_dtl_id 
					 AND B.country_code = (SELECT country_code FROM TBL_ADM_COUNTRY WITH(NOLOCK) WHERE country_id = @country_id) 
					 AND B.principal_code = (SELECT principal_code FROM TBL_ADM_PRINCIPAL WITH(NOLOCK) WHERE principal_id = @principal_id))

		UPDATE A
		SET A.display_name = B.display_name,
			A.mandatory = B.mandatory,
			A.readonly = B.readonly,
			A.seq = B.seq,
			A.additional_input = B.additional_input,
			A.additional_input_name = B.additional_input_name,
			A.validation_message = B.validation_message
		FROM #INPUT A
		INNER JOIN TBL_ADM_CONFIG_PAGE_INPUT_SETTING B WITH(NOLOCK) ON A.page_dtl_id = B.page_dtl_id
		AND B.country_code = (SELECT country_code FROM TBL_ADM_COUNTRY WITH(NOLOCK) WHERE country_id = @country_id) 
		AND B.principal_code = (SELECT principal_code FROM TBL_ADM_PRINCIPAL WITH(NOLOCK) WHERE principal_id = @principal_id)

		UPDATE A
		SET A.input_source = ISNULL(B.input_source,'')
		FROM #INPUT A
		LEFT JOIN TBL_ADM_CONFIG_PAGE_INPUT_SETTING B WITH(NOLOCK) ON A.page_dtl_id = B.page_dtl_id
		AND B.country_code = (SELECT country_code FROM TBL_ADM_COUNTRY WITH(NOLOCK) WHERE country_id = @country_id) 
		AND B.principal_code = (SELECT principal_code FROM TBL_ADM_PRINCIPAL WITH(NOLOCK) WHERE principal_id = @principal_id)

		SELECT * FROM #INPUT
		DROP TABLE #INPUT
	END
	ELSE IF @type = 'listing'
	BEGIN
		CREATE TABLE #LISTING
		(
		list_hdr_id		int,
		page_code		varchar(100),
		section_code	varchar(50),
		list_dtl_id		integer,
		list_col_name	varchar(200),
		is_checked		int,
		list_col_display_name	nvarchar(200),
		list_col_seq	int,
		list_col_type	varchar(100),
		list_col_function nvarchar(200), 
		editable	int,
		editable_data_type nvarchar(200),
		hidden int
		)

		INSERT INTO #LISTING
		(list_hdr_id, page_code, section_code, list_dtl_id, list_col_name, is_checked, list_col_display_name, list_col_seq, list_col_type, list_col_function, editable, editable_data_type, hidden)
		SELECT '0', @page_code, section_code, A.list_dtl_id, list_col_name, '0', cast(null as nvarchar(200)), '0', cast(null as varchar(100)), list_col_function, '0', cast(null as nvarchar(200)), '0'
		FROM TBL_ADM_CONFIG_PAGE_LISTING_DTL A WITH(NOLOCK)
		INNER JOIN TBL_ADM_CONFIG_PAGE_LISTING_HDR B WITH(NOLOCK) ON A.list_hdr_id = B.list_hdr_id
		--LEFT JOIN TBL_ADM_CONFIG_PAGE_LISTING_SETTING C ON A.list_dtl_id = C.list_dtl_id
		WHERE B.page_code = @page_code
		--AND C.country_code = (SELECT country_code FROM TBL_ADM_COUNTRY WHERE country_id = @country_id)
		--AND C.principal_code = (SELECT principal_code FROM TBL_ADM_PRINCIPAL WHERE principal_id = @principal_id)

		UPDATE A
		SET A.list_hdr_id = B.list_hdr_id
		FROM #LISTING A
		INNER JOIN TBL_ADM_CONFIG_PAGE_LISTING_HDR B WITH(NOLOCK) ON A.page_code = B.page_code AND A.section_code = B.section_code

		UPDATE A
		SET is_checked = 1
		FROM #LISTING A
		WHERE EXISTS(SELECT 1 FROM TBL_ADM_CONFIG_PAGE_LISTING_SETTING B WITH(NOLOCK) 
					 WHERE A.list_dtl_id = B.list_dtl_id
					 AND B.country_code = (SELECT country_code FROM TBL_ADM_COUNTRY WITH(NOLOCK) WHERE country_id = @country_id) 
					 AND B.principal_code = (SELECT principal_code FROM TBL_ADM_PRINCIPAL WITH(NOLOCK) WHERE principal_id = @principal_id))
		
		UPDATE A
		SET A.list_col_display_name = B.list_col_display_name,
			A.list_col_seq = B.list_col_seq,
			A.list_col_type = ISNULL(B.list_col_type,''),
			A.editable = B.editable,
			A.editable_data_type = B.editable_data_type, 
			A.hidden = B.hidden
		FROM #LISTING A
		LEFT JOIN TBL_ADM_CONFIG_PAGE_LISTING_SETTING B WITH(NOLOCK) ON A.list_dtl_id = B.list_dtl_id
		AND B.country_code = (SELECT country_code FROM TBL_ADM_COUNTRY WITH(NOLOCK) WHERE country_id = @country_id) 
		AND B.principal_code = (SELECT principal_code FROM TBL_ADM_PRINCIPAL WITH(NOLOCK) WHERE principal_id = @principal_id)

		SELECT * FROM #LISTING
		DROP TABLE #LISTING
	END
END
GO
