SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==========================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Retrieve Work Order Listing
-- Example Query: exec SPP_TXN_WORK_ORDER_LISTING @param=N'{"start_date":"1900-01-01","end_date":"2018-10-01","status":"C","pending_job":"All","page_index":2,"page_size":10,"search_term":"","export_ind":0}'
-- Output:
-- 1) dtCount - Total rows
-- 2) dt - Data
-- 3) dtExportInd - Export indicator
-- 4) dtExportColumnName - Export column display name
-- ==========================================================================================

CREATE PROCEDURE [dbo].[SPP_TXN_WORK_ORDER_LISTING_OLD]
	@param	nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @start_date	VARCHAR(20), @end_date VARCHAR(20), @status VARCHAR(20), @pending_job VARCHAR(50), @job_ref_no VARCHAR(50), 
	@page_index INT, @page_size INT, @search_term NVARCHAR(100), @export_ind CHAR(1)
	SET @start_date = (SELECT JSON_VALUE(@param, '$.start_date'))
	SET @end_date = (SELECT JSON_VALUE(@param, '$.end_date'))
	SET @status = (SELECT JSON_VALUE(@param, '$.status'))
	SET @job_ref_no = (SELECT JSON_VALUE(@param, '$.job_ref_no'))
	SET @page_index = (SELECT JSON_VALUE(@param, '$.page_index'))
	SET @page_size = (SELECT JSON_VALUE(@param, '$.page_size'))
	SET @search_term = (SELECT JSON_VALUE(@param, '$.search_term'))
	SET @export_ind = (SELECT JSON_VALUE(@param, '$.export_ind'))
	SET @pending_job = (SELECT JSON_VALUE(@param, '$.pending_job'))

	IF @status = 'ALL' SET @status = NULL
	ELSE IF @status = 'IP' SET @status = 'In Process'
	ELSE IF @status = 'OH' SET @status = 'On Hold'
	ELSE IF @status = 'C' SET @status = 'Closed'
	ELSE IF @status = 'CCL' SET @status = 'Cancelled'

	CREATE TABLE #CURRENT_EVENT (event_id VARCHAR(50)) 
	DECLARE @cntCurrentEvent INTEGER
	IF @pending_job = 'All'
	BEGIN
		SET @cntCurrentEvent = 0
		INSERT INTO #CURRENT_EVENT(event_id) SELECT '' 
	END
	ELSE
	BEGIN
		INSERT INTO #CURRENT_EVENT (event_id)
		SELECT event_id FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK) WHERE CAST(post_event_id as VARCHAR(10))= @pending_job
		SET @cntCurrentEvent = (SELECT COUNT(*) FROM #CURRENT_EVENT)
	END

    CREATE TABLE #WORK_ORDER_TEMP
	(
	row_num INT IDENTITY(1,1),
	pending_job VARCHAR(MAX),
	post_event_id INT,
	elapsed_time NUMERIC(18,2),
	work_ord_ref	VARCHAR(150),
	job_ref_no	VARCHAR(50),
	created_date	VARCHAR(50),
	created_time	VARCHAR(50),
	inbound_doc	VARCHAR(50),
	client_name	NVARCHAR(100),
	prd_code	VARCHAR(50),
	prd_desc	NVARCHAR(200),
	urgent		VARCHAR(50),
	uom			VARCHAR(50),
	ttl_qty_eaches	VARCHAR(50),
	completed_qty VARCHAR(50),
	damaged_qty VARCHAR(50),
	balance VARCHAR(50),
	work_ord_status	VARCHAR(50),
	work_ord_no NVARCHAR(100),
	current_event INT, 
	vas_activities NVARCHAR(MAX),
	others NVARCHAR(2000),
	remarks NVARCHAR(250),
	--to_be_deducted_seconds INT,
	total_on_hold_time INT,
	--total_final_seconds INT,
	mpo_closed_date VARCHAR(50),
	before_deduct_on_hold INT,
	after_deduct_on_hold INT
	)

	INSERT INTO #WORK_ORDER_TEMP (work_ord_no, work_ord_ref, job_ref_no, created_date, created_time, inbound_doc, client_name, prd_code, prd_desc, urgent, uom ,ttl_qty_eaches, completed_qty, damaged_qty, balance, work_ord_status, current_event, vas_activities, others, remarks, mpo_closed_date, before_deduct_on_hold)
	SELECT DISTINCT work_ord_ref, '<a href=# onclick="ShowDetails(''' + job_ref_no + ''')">' + work_ord_ref + '</a>' as work_ord_ref, job_ref_no, CONVERT(VARCHAR(19), to_time, 121), CONVERT(TIME(0), to_time), E.inbound_doc, D.client_name, A.prd_code, C.prd_desc, 
	CASE WHEN urgent = '1' THEN 'Yes' ELSE 'No' END as urgent, E.uom, qty_of_goods, 0, 0, 0, B.name, current_event, vas_activities, others, CASE work_ord_status WHEN 'CCL' THEN cancellation_reason ELSE '' END, CONVERT(VARCHAR(19), A.changed_date, 121), CASE WHEN work_ord_status IN ('C','CCL') THEN before_deduct_on_hold ELSE dbo.GetTotalWorkingMins(to_time, work_ord_status, A.changed_date) END
	FROM TBL_TXN_WORK_ORDER A WITH(NOLOCK)
	INNER JOIN TBL_MST_DDL B WITH(NOLOCK) ON A.work_ord_status = B.code
	INNER JOIN TBL_MST_PRODUCT C WITH(NOLOCK) ON A.prd_code = C.prd_code
	INNER JOIN TBL_MST_CLIENT D WITH(NOLOCK) ON A.client_code = D.client_code
	INNER JOIN VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER E WITH(NOLOCK) ON A.vas_order = E.vas_order AND A.prd_code = E.prd_code AND A.batch_no = E.batch_no
	INNER JOIN TBL_MST_MLL_DTL F WITH(NOLOCK) ON A.mll_no = F.mll_no AND A.prd_code = F.prd_code
	WHERE B.ddl_code = 'ddlWorkOrderStatus' AND CONVERT(VARCHAR(10), A.created_date, 121) BETWEEN CONVERT(VARCHAR(10), @start_date, 121) AND CONVERT(VARCHAR(10), @end_date, 121)
	AND ISNULL(name, '') = COALESCE(@status, ISNULL(name, ''))


	UPDATE A
	SET post_event_id = B.post_event_id
	FROM #WORK_ORDER_TEMP A
	INNER JOIN TBL_MST_EVENT_CONFIGURATION_HDR B WITH(NOLOCK) ON A.current_event = B.event_id

	UPDATE A
	SET completed_qty = B.completed_qty,
		damaged_qty = B.damaged_qty,
		balance = ttl_qty_eaches - B.completed_qty - B.damaged_qty
	FROM #WORK_ORDER_TEMP A
	INNER JOIN TBL_TXN_JOB_EVENT B WITH(NOLOCK) ON A.job_ref_no = B.job_ref_no
	WHERE B.event_id IN ('80','85')

	UPDATE A
	SET A.pending_job = B.description
	FROM #WORK_ORDER_TEMP A, TBL_MST_EVENT_CONFIGURATION_DTL B WITH(NOLOCK)
	WHERE A.post_event_id = B.post_event_id

	SELECT job_ref_no, ISNULL(SUM(on_hold_time),0) / 60 as ttl_on_hold
	INTO #ON_HOLD
	FROM TBL_TXN_JOB_EVENT WITH(NOLOCK)
	GROUP BY job_ref_no

	UPDATE A
	SET total_on_hold_time = B.ttl_on_hold
	FROM #WORK_ORDER_TEMP A
	INNER JOIN #ON_HOLD B ON A.job_ref_no = B.job_ref_no

	UPDATE A
	SET after_deduct_on_hold = CAST(before_deduct_on_hold as FLOAT) - (CAST(total_on_hold_time as FLOAT) / CAST(60 as FLOAT)) --before_deduct_on_hold - total_on_hold_time
	FROM #WORK_ORDER_TEMP A

	UPDATE #WORK_ORDER_TEMP
	SET elapsed_time = (CAST(after_deduct_on_hold as FLOAT) / CAST(60 as FLOAT)) / CAST(12 as FLOAT)

	--UPDATE A
	--SET to_be_deducted_seconds = ISNULL(( (SELECT COUNT(*) FROM TBL_MST_WEEKEND WITH(NOLOCK) WHERE date BETWEEN created_date AND GETDATE()) + (SELECT COUNT(*) FROM TBL_MST_PUBLIC_HOLIDAY WITH(NOLOCK) WHERE date BETWEEN created_date AND GETDATE()) ),0) * 24 * 60 * 60
	--FROM #WORK_ORDER_TEMP A
	--WHERE work_ord_status <> 'Closed'

	--UPDATE A
	--SET to_be_deducted_seconds = ISNULL(( (SELECT COUNT(*) FROM TBL_MST_WEEKEND WITH(NOLOCK) WHERE date BETWEEN created_date AND mpo_closed_date) + (SELECT COUNT(*) FROM TBL_MST_PUBLIC_HOLIDAY WITH(NOLOCK) WHERE date BETWEEN created_date AND mpo_closed_date) ),0) * 24 * 60 * 60
	--FROM #WORK_ORDER_TEMP A
	--WHERE work_ord_status = 'Closed'

	--UPDATE A
	--SET total_final_seconds = ISNULL((SELECT DATEDIFF(s, created_date, GETDATE())) - (to_be_deducted_seconds + total_on_hold_time),0)
	--FROM #WORK_ORDER_TEMP A
	--WHERE work_ord_status <> 'Closed'

	--UPDATE A
	--SET total_final_seconds = ISNULL((SELECT DATEDIFF(s, created_date, mpo_closed_date)) - (to_be_deducted_seconds + total_on_hold_time),0)
	--FROM #WORK_ORDER_TEMP A
	--WHERE work_ord_status = 'Closed'

	--UPDATE A
	--SET elapsed_time = CONVERT(VARCHAR(12), total_final_seconds /60 / 60 / 24) + ' D '
	--						+ CONVERT(VARCHAR(12), total_final_seconds / 60 / 60 % 24) + ' hr '
	--						+ CONVERT(VARCHAR(2), total_final_seconds / 60 % 60) + ' min '
	--						--+ CONVERT(VARCHAR(2), total_final_seconds % 60) + ' Second(s)' --CONVERT(VARCHAR(19), ( DATEDIFF(s, created_date, GETDATE()) / 86400 )) + ' Days '+ CONVERT(VARCHAR(19), ( ( DATEDIFF(s, created_date, GETDATE()) % 86400 ) / 3600 )) + ' Hours '+ CONVERT(VARCHAR(19), ( ( ( DATEDIFF(s, created_date, GETDATE()) % 86400 ) % 3600 ) / 60 )) + ' Minutes '
	--FROM #WORK_ORDER_TEMP A
	--WHERE work_ord_status <> 'Closed'

	UPDATE A
	SET remarks = ISNULL(B.remarks,'')
	FROM #WORK_ORDER_TEMP A
	LEFT JOIN TBL_TXN_JOB_EVENT B WITH(NOLOCK) ON A.job_ref_no = B.job_ref_no
	WHERE B.event_id IN ('80', '85')

	UPDATE A
	SET mpo_closed_date = ''
	FROM #WORK_ORDER_TEMP A
	WHERE work_ord_status <> 'Closed'

	-- Generate VAS Activities string for Closed MPO ---------------------------------------------------------------------------------------------------------------
	CREATE TABLE #A
	(
	row_num INT,
	json_string NVARCHAR(MAX),
	html_string NVARCHAR(MAX),
	others NVARCHAR(2000)
	)

	CREATE TABLE #B
	(
	row_num INT,
	key_value INT,
	page_dtl_id VARCHAR(50),
	prd_code VARCHAR(50),
	radio_val CHAR(10),
	html_string NVARCHAR(MAX),
	others NVARCHAR(2000)
	)

	INSERT INTO #A
	SELECT row_num, vas_activities, NULL, others FROM #WORK_ORDER_TEMP

	INSERT INTO #B
	SELECT P.row_num, AttsData.[key] as key_value, JSON_VALUE(AttsData.[value], '$.page_dtl_id') page_dtl_id, JSON_VALUE(AttsData.[value], '$.prd_code') prd_code, RTRIM(LTRIM(JSON_VALUE(AttsData.[value], '$.radio_val'))) radio_val, cast(null as varchar(max)) as html_string, others
	FROM #A P CROSS APPLY OPENJSON (P.json_string) AS AttsData
	WHERE RTRIM(LTRIM(JSON_VALUE(AttsData.[value], '$.radio_val'))) = 'Y'

	UPDATE A
	SET html_string = display_name + ' - ' + '(' + RTRIM(LTRIM(radio_val)) + ') ' + prd_code + CASE WHEN others = '' THEN '' ELSE ' , ' + others END
	FROM #B A
	INNER JOIN VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING B WITH(NOLOCK) ON A.page_dtl_id = B.page_dtl_id

	CREATE NONCLUSTERED INDEX ABC
	ON #B (row_num)
	INCLUDE (html_string)

	SELECT DISTINCT row_num,
     STUFF((
        SELECT ' ' + html_string
        FROM #B t1
        WHERE t1.row_num = t2.row_num
		ORDER BY key_value
        FOR XML PATH('')
    ), 1, 1, '') AS final_string INTO #C
	FROM #B t2

	UPDATE A
	SET vas_activities = REPLACE(REPLACE(C.final_string, '&lt;', '<'), '&gt;' ,'>')
	FROM #WORK_ORDER_TEMP A INNER JOIN #C C ON A.row_num = C.row_num

	UPDATE #WORK_ORDER_TEMP
	SET vas_activities = '' WHERE vas_activities LIKE '%page_dtl_id%'
	
	---------------------------------------------------------------------------

	IF @search_term <> '' OR (@status <> NULL OR @status <> '') OR (@pending_job <> NULL OR @pending_job <> '')
	BEGIN
		SELECT COUNT(1) as ttl_rows FROM #WORK_ORDER_TEMP --1
		WHERE (	work_ord_ref LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE work_ord_ref END OR
				job_ref_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE job_ref_no END OR
				pending_job LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE pending_job END OR
				inbound_doc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE inbound_doc END OR
				client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR
				prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END OR
				prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_desc END OR
				urgent LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE urgent END OR
				ttl_qty_eaches LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE ttl_qty_eaches END OR
				completed_qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE completed_qty END OR
				damaged_qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE damaged_qty END OR
				balance LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE balance END)
				--AND ISNULL(work_ord_status, '') = COALESCE(@status, ISNULL(work_ord_status, ''))
				AND CASE @cntCurrentEvent WHEN 0 THEN '' ELSE current_event END IN (SELECT event_id FROM #CURRENT_EVENT)
	END
	ELSE
	BEGIN
		SELECT COUNT(1) as ttl_rows FROM #WORK_ORDER_TEMP --1
		--WHERE ISNULL(work_ord_status, '') = COALESCE(@status, ISNULL(work_ord_status, ''))
	END

	IF (@export_ind = '0')
		SELECT * FROM #WORK_ORDER_TEMP --2
		WHERE (	work_ord_ref LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE work_ord_ref END OR
				job_ref_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE job_ref_no END OR
				inbound_doc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE inbound_doc END OR
				client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR
				prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END OR
				prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_desc END OR
				urgent LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE urgent END OR
				ttl_qty_eaches LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE ttl_qty_eaches END OR
				completed_qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE completed_qty END OR
				damaged_qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE damaged_qty END OR
				balance LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE balance END)
				--AND ISNULL(work_ord_status, '') = COALESCE(@status, ISNULL(work_ord_status, ''))
				AND CASE @cntCurrentEvent WHEN 0 THEN '' ELSE current_event END IN (SELECT event_id FROM #CURRENT_EVENT)
		ORDER BY job_ref_no desc
		OFFSET @page_index * @page_size ROWS
		FETCH NEXT @page_size ROWS ONLY
	ELSE IF (@export_ind = '1')
		SELECT * FROM #WORK_ORDER_TEMP --2
		WHERE (	work_ord_ref LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE work_ord_ref END OR
				job_ref_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE job_ref_no END OR
				inbound_doc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE inbound_doc END OR
				client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR
				prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END OR
				prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_desc END OR
				urgent LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE urgent END OR
				ttl_qty_eaches LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE ttl_qty_eaches END OR
				completed_qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE completed_qty END OR
				damaged_qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE damaged_qty END OR
				balance LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE balance END)
				--AND ISNULL(work_ord_status, '') = COALESCE(@status, ISNULL(work_ord_status, ''))
				AND CASE @cntCurrentEvent WHEN 0 THEN '' ELSE current_event END IN (SELECT event_id FROM #CURRENT_EVENT)
		ORDER BY job_ref_no desc

	SELECT @export_ind AS export_ind --3

	SELECT list_dtl_id, list_col_name as input_name, list_default_display_name as display_name  --4
	FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_LISTING_DTL WITH(NOLOCK)
	WHERE list_hdr_id IN (SELECT list_hdr_id FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_LISTING_HDR WITH(NOLOCK)) AND list_col_name in (SELECT name FROM tempdb.sys.columns where object_id = object_id('tempdb..#WORK_ORDER_TEMP'))

	DROP TABLE #CURRENT_EVENT
	DROP TABLE #ON_HOLD
	DROP TABLE #WORK_ORDER_TEMP
END
GO
