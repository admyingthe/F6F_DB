SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_TXN_WORK_ORDER_LISTING]
	@param	nvarchar(max),
	 @user_id INT 
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
	SET @export_ind = (SELECT JSON_VALUE(@param, '$.export_ind')) -- 1 means export
	SET @pending_job = (SELECT JSON_VALUE(@param, '$.pending_job'))


	--IF @start_date = '1900-01-01' SET @start_date = DATEADD(MONTH, -1, GETDATE())

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

	 ------------------------------------------------------------  
  SET @job_ref_no = (SELECT JSON_VALUE(@param, '$.job_ref_no'))
  -- Get user warehouse Code-------  
 DECLARE @wh_code varchar(10)
 SET @wh_code = (SELECT wh_code FROM VAS.dbo.TBL_ADM_USER WITH(NOLOCK) WHERE user_id = @user_id)  --T50
 --select @wh_code
 ------------------------------------------------------------  
	

	CREATE TABLE #WO
	(work_ord_ref	VARCHAR(150),
	job_ref_no	VARCHAR(50),
	current_event INT, post_event_id INT, pending_job VARCHAR(MAX))

    CREATE TABLE #WORK_ORDER_TEMP
	(
	row_num INT IDENTITY(1,1),
	pending_job VARCHAR(MAX),
	post_event_id INT,
	elapsed_time NUMERIC(18,2),
	work_ord_ref	VARCHAR(MAX),
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
	after_deduct_on_hold INT,
	changed_date varchar(50),
	to_time varchar(50),
	created_dt datetime,
	mll_no varchar(50),
	qi_type varchar(100),
	to_no varchar(100)
	)


	  DECLARE @JobFormat VARCHAR(25)=(SELECT  [format_code] FROM [TBL_REDRESSING_JOB_FORMAT])
--select * From  TBL_TXN_WORK_ORDER_JOB_DET

	INSERT INTO #WO (work_ord_ref, job_ref_no, current_event)
	SELECT DISTINCT  CASE WHEN @JobFormat='JobFormat' THEN A.job_ref_no ELSE A.work_ord_ref  END work_ord_ref, A.job_ref_no, current_event
	FROM TBL_TXN_WORK_ORDER A WITH(NOLOCK)
	INNER JOIN TBL_TXN_WORK_ORDER_JOB_DET G   WITH(NOLOCK) ON A.job_ref_no=G.job_ref_no
	INNER JOIN TBL_MST_DDL B WITH(NOLOCK) ON G.work_ord_status = B.code
	INNER JOIN TBL_MST_PRODUCT C WITH(NOLOCK) ON A.prd_code = C.prd_code
	INNER JOIN TBL_MST_CLIENT D WITH(NOLOCK) ON A.client_code = D.client_code
	INNER JOIN VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER E WITH(NOLOCK) ON A.vas_order = E.vas_order AND A.prd_code = E.prd_code AND A.batch_no = E.batch_no
	INNER JOIN TBL_MST_MLL_DTL F WITH(NOLOCK) ON A.mll_no = F.mll_no AND A.prd_code = F.prd_code
	WHERE B.ddl_code = 'ddlWorkOrderStatus' AND CONVERT(VARCHAR(10), A.created_date, 121) BETWEEN CONVERT(VARCHAR(10), @start_date, 121) AND CONVERT(VARCHAR(10), @end_date, 121)
	AND ISNULL(name, '') = COALESCE(@status, ISNULL(name, ''))  AND A.whs_no=@wh_code 
	AND (	A.work_ord_ref LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE A.work_ord_ref END OR
				A.job_ref_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE A.job_ref_no END OR
				E.inbound_doc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE E.inbound_doc END OR
				client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR
				A.prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE A.prd_code END OR
				C.prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE C.prd_desc END)
				AND CASE @cntCurrentEvent WHEN 0 THEN '' ELSE current_event END IN (SELECT event_id FROM #CURRENT_EVENT)

union

select  distinct work_ord_ref ,A.job_ref_no, current_event
FROM		TBL_SUBCON_TXN_WORK_ORDER A WITH(NOLOCK)
			INNER JOIN 
			TBL_MST_DDL B WITH(NOLOCK) 
ON			A.work_ord_status = B.code
			INNER JOIN 
			TBL_MST_PRODUCT C WITH(NOLOCK) 
ON			A.prd_code = C.prd_code
			INNER JOIN 
			TBL_MST_CLIENT D WITH(NOLOCK) 
ON			A.client_code = D.client_code
			left JOIN 
			VAS_INTEGRATION_TH.dbo.VAS_Subcon_TRANSFER_ORDER E WITH(NOLOCK) 
ON			A.job_ref_no = E.Subcon_Job_No and
			A.prd_code = E.prd_code AND 
			A.batch_no = E.batch_no
WHERE		B.ddl_code = 'ddlWorkOrderStatus' AND CONVERT(VARCHAR(10), A.created_date, 121) BETWEEN CONVERT(VARCHAR(10), @start_date, 121) AND CONVERT(VARCHAR(10), @end_date, 121)
	AND ISNULL(name, '') = COALESCE(@status, ISNULL(name, ''))
	AND (	work_ord_ref LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE work_ord_ref END OR
				A.job_ref_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE A.job_ref_no END OR
				E.outbound_doc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE E.outbound_doc END OR
				client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR
				A.prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE A.prd_code END OR
				C.prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE C.prd_desc END)
				AND CASE @cntCurrentEvent WHEN 0 THEN '' ELSE current_event END IN (SELECT event_id FROM #CURRENT_EVENT)


			
  


select		*
into		#JOB_REF_LIST
from		(
SELECT		DISTINCT CASE WHEN @JobFormat='JobFormat' THEN A.job_ref_no ELSE A.work_ord_ref  END work_ord_ref, '<a href=# onclick="ShowDetails(''' + A.job_ref_no + ''',''' + A.prd_code + ''',''' + A.batch_no + ''',''' + A.vas_order + ''',''' + A.inbound_doc + ''',''' + A.to_no + ''')">' + CASE WHEN @JobFormat='JobFormat' THEN A.job_ref_no ELSE A.work_ord_ref  END + '</a>' as work_ord_ref_link, 
A.job_ref_no, CONVERT(VARCHAR(19), to_time, 121) as to_datetime, CONVERT(TIME(0), to_time) as to_time, E.inbound_doc, D.client_name, A.prd_code, C.prd_desc, CASE WHEN G.urgent = '1' THEN 'Yes' ELSE 'No' END as urgent, E.uom, A.ttl_qty_eaches, 0 as completed_qty, 0 as damaged_qty, 0 as balance, B.name, current_event, F.vas_activities, others, CASE G.work_ord_status WHEN 'CCL' THEN cancellation_reason ELSE '' END as remarks, CONVERT(VARCHAR(19), G.changed_date, 121) as chdate, before_deduct_on_hold, G.changed_date, to_time as ttime,A.mll_no,G.qi_type,A.to_no
FROM		TBL_TXN_WORK_ORDER A WITH(NOLOCK)
			INNER JOIN TBL_TXN_WORK_ORDER_JOB_DET G ON A.job_ref_no=G.job_ref_no
			INNER JOIN 
			TBL_MST_DDL B WITH(NOLOCK) 
ON			G.work_ord_status = B.code
			INNER JOIN 
			TBL_MST_PRODUCT C WITH(NOLOCK) 
ON			A.prd_code = C.prd_code
			INNER JOIN 
			TBL_MST_CLIENT D WITH(NOLOCK) 
ON			A.client_code = D.client_code
			INNER JOIN 
			VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER E WITH(NOLOCK) 
ON			A.vas_order = E.vas_order AND 
			A.prd_code = E.prd_code AND 
			A.batch_no = E.batch_no AND 
			A.inbound_doc = E.inbound_doc AND 
			A.to_no = E.to_no
			INNER JOIN 
			TBL_MST_MLL_DTL F WITH(NOLOCK) 
ON			A.mll_no = F.mll_no AND 
			A.prd_code = F.prd_code
WHERE		B.ddl_code = 'ddlWorkOrderStatus'  AND A.whs_no=@wh_code 

union

select		distinct CASE WHEN @JobFormat='JobFormat' THEN A.job_ref_no ELSE A.work_ord_ref  END work_ord_ref,'<a href=# onclick="ShowDetails(''' + A.job_ref_no + ''')">' + work_ord_ref + '</a>' as work_ord_ref_link, A.job_ref_no,cast(CONVERT(VARCHAR(10), A.created_date, 121) as varchar)+' '+cast(CONVERT(TIME(0), A.created_date) as varchar), CONVERT(TIME(0), A.created_date) as to_time, E.outbound_doc, D.client_name, A.prd_code, C.prd_desc, CASE WHEN A.urgent = '1' THEN 'Yes' ELSE 'No' END as urgent, A.uom, A.qty_of_goods, 0 as completed_qty, 0 as damaged_qty, 0 as balance, B.name, A.current_event, A.vas_order[vas_activities], others,  CASE A.work_ord_status WHEN 'CCL' THEN cancellation_reason ELSE '' END as remarks, CONVERT(VARCHAR(19), A.changed_date, 121) as chdate, before_deduct_on_hold, A.changed_date, A.created_date  as ttime ,''mll_no,''qi_type,'' to_no
FROM		TBL_SUBCON_TXN_WORK_ORDER A WITH(NOLOCK)
			INNER JOIN 
			TBL_MST_DDL B WITH(NOLOCK) 
ON			A.work_ord_status = B.code
			INNER JOIN 
			TBL_MST_PRODUCT C WITH(NOLOCK) 
ON			A.prd_code = C.prd_code
			INNER JOIN 
			TBL_MST_CLIENT D WITH(NOLOCK) 
ON			A.client_code = D.client_code
			left JOIN 
			VAS_INTEGRATION_TH.dbo.VAS_Subcon_TRANSFER_ORDER E WITH(NOLOCK) 
ON			A.job_ref_no = E.Subcon_Job_No and
			A.prd_code = E.prd_code AND 
			A.batch_no = E.batch_no
WHERE		B.ddl_code = 'ddlWorkOrderStatus'
) main

	--INSERT INTO #WORK_ORDER_TEMP (work_ord_no, work_ord_ref, job_ref_no, created_date, created_time, inbound_doc, client_name, prd_code, prd_desc, urgent, uom ,ttl_qty_eaches, completed_qty, damaged_qty, balance, work_ord_status, current_event, vas_activities, others, remarks, mpo_closed_date, before_deduct_on_hold, changed_date, to_time,mll_no,qi_type,to_no)
	--select	* 
	--from	#JOB_REF_LIST
	--where	CONVERT(VARCHAR(10), ttime, 121) BETWEEN CONVERT(VARCHAR(10), @start_date, 121) AND 
	--		CONVERT(VARCHAR(10), @end_date, 121) AND 
	--		ISNULL(name, '') = COALESCE(@status, ISNULL(name, '')) AND
	--		(work_ord_ref LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE work_ord_ref END OR job_ref_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE job_ref_no END OR
	--		inbound_doc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE inbound_doc END OR
	--		mll_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE mll_no END OR
	--		client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR
	--		prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END OR
	--		prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_desc END) AND 
	--		CASE @cntCurrentEvent WHEN 0 THEN '' ELSE current_event END IN (SELECT event_id FROM #CURRENT_EVENT)
	--ORDER BY	job_ref_no desc
	--OFFSET		@page_index * @page_size ROWS
	--FETCH NEXT	@page_size ROWS ONLY

	IF(@export_ind <> '1')
	BEGIN
		INSERT INTO #WORK_ORDER_TEMP (work_ord_no, work_ord_ref, job_ref_no, created_date, created_time, inbound_doc, client_name, prd_code, prd_desc, urgent, uom ,ttl_qty_eaches, completed_qty, damaged_qty, balance, work_ord_status, current_event, vas_activities, others, remarks, mpo_closed_date, before_deduct_on_hold, changed_date, to_time,mll_no,qi_type,to_no)
		select	* 
		from	#JOB_REF_LIST
		where	CONVERT(VARCHAR(10), ttime, 121) BETWEEN CONVERT(VARCHAR(10), @start_date, 121) AND 
				CONVERT(VARCHAR(10), @end_date, 121) AND 
				ISNULL(name, '') = COALESCE(@status, ISNULL(name, '')) AND
				(work_ord_ref LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE work_ord_ref END OR job_ref_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE job_ref_no END OR
				inbound_doc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE inbound_doc END OR
				mll_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE mll_no END OR
				client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR
				prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END OR
				prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_desc END) AND 
				CASE @cntCurrentEvent WHEN 0 THEN '' ELSE current_event END IN (SELECT event_id FROM #CURRENT_EVENT)
		ORDER BY	job_ref_no desc
		OFFSET		@page_index * @page_size ROWS
		FETCH NEXT	@page_size ROWS ONLY
	END
	ELSE
	BEGIN
		INSERT INTO #WORK_ORDER_TEMP (work_ord_no, work_ord_ref, job_ref_no, created_date, created_time, inbound_doc, client_name, prd_code, prd_desc, urgent, uom ,ttl_qty_eaches, completed_qty, damaged_qty, balance, work_ord_status, current_event, vas_activities, others, remarks, mpo_closed_date, before_deduct_on_hold, changed_date, to_time,mll_no,qi_type,to_no)
		select	* 
		from	#JOB_REF_LIST
		where	CONVERT(VARCHAR(10), ttime, 121) BETWEEN CONVERT(VARCHAR(10), @start_date, 121) AND 
				CONVERT(VARCHAR(10), @end_date, 121) AND 
				ISNULL(name, '') = COALESCE(@status, ISNULL(name, '')) AND
				(work_ord_ref LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE work_ord_ref END OR job_ref_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE job_ref_no END OR
				inbound_doc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE inbound_doc END OR
				mll_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE mll_no END OR
				client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR
				prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END OR
				prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_desc END) AND 
				CASE @cntCurrentEvent WHEN 0 THEN '' ELSE current_event END IN (SELECT event_id FROM #CURRENT_EVENT)
		ORDER BY	job_ref_no desc
	END

	UPDATE #WORK_ORDER_TEMP
	SET before_deduct_on_hold = dbo.GetTotalWorkingMins(to_time, work_ord_status, changed_date)
	WHERE work_ord_status NOT IN ('C','CCL')

	UPDATE A
	SET post_event_id = B.post_event_id
	FROM #WORK_ORDER_TEMP A
	INNER JOIN TBL_MST_EVENT_CONFIGURATION_HDR B WITH(NOLOCK) ON A.current_event = B.event_id

	UPDATE A
	SET post_event_id = B.post_event_id
	FROM #WO A
	INNER JOIN TBL_MST_EVENT_CONFIGURATION_HDR B WITH(NOLOCK) ON A.current_event = B.event_id

	-----------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------------------------------
	--	Declare @running_no as varchar(50)
	--	SELECT TOP 1 @running_no = running_no FROM TBL_TXN_JOB_EVENT
	--	WHERE job_ref_no = @job_ref_no
	--AND event_id = '80'
	--ORDER BY created_date DESC



	SELECT job_ref_no, prd_code,sum(damaged_qty) AS damaged_qty,batch_no,inbound_doc,to_no
	INTO #Temp_damage_qty
	FROM TBL_TXN_JOB_EVENT_DET
	WHERE event_id IN ('80')--job_ref_no = @job_ref_no
	GROUP BY job_ref_no,prd_code,batch_no,inbound_doc,to_no




	UPDATE A
	SET completed_qty = B.completed_qty,
		damaged_qty = T.damaged_qty,
		balance = ttl_qty_eaches - B.completed_qty - T.damaged_qty
	FROM #WORK_ORDER_TEMP A
	INNER JOIN TBL_TXN_JOB_EVENT_DET B WITH(NOLOCK) ON A.job_ref_no = B.job_ref_no AND A.prd_code=B.prd_code AND A.inbound_doc = B.inbound_doc  AND A.to_no = B.to_no 
	INNER JOIN #TEMP_DAMAGE_QTY T ON T.job_ref_no= B.job_ref_no AND A.prd_code=T.prd_code   AND B.batch_no = T.batch_no AND B.inbound_doc = T.inbound_doc  AND B.to_no = T.to_no 
	WHERE B.event_id IN ('80') AND B.running_no in (	SELECT  running_no FROM TBL_TXN_JOB_EVENT
														WHERE created_date in (	SELECT MAX(created_date) FROM TBL_TXN_JOB_EVENT WHERE event_id = '80' GROUP BY job_ref_no)
														AND event_id = '80')

	UPDATE A
	SET A.pending_job = B.description
	FROM #WORK_ORDER_TEMP A, TBL_MST_EVENT_CONFIGURATION_DTL B WITH(NOLOCK)
	WHERE A.post_event_id = B.post_event_id

	UPDATE A
	SET A.pending_job = B.description
	FROM #WO A, TBL_MST_EVENT_CONFIGURATION_DTL B WITH(NOLOCK)
	WHERE A.post_event_id = B.post_event_id

	SELECT job_ref_no, ISNULL(SUM(on_hold_time),0) as ttl_on_hold
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

	UPDATE A
	SET remarks = ISNULL(B.remarks,'')
	FROM #WORK_ORDER_TEMP A
	LEFT JOIN TBL_TXN_JOB_EVENT B WITH(NOLOCK) ON A.job_ref_no = B.job_ref_no
	WHERE B.event_id IN ('80', '85')

	UPDATE A
	SET mpo_closed_date = ''
	FROM #WORK_ORDER_TEMP A
	WHERE work_ord_status <> 'Closed'

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

	CREATE TABLE #TRACKING_VAS_ACTIVITIES_OTHER
	(
		row_num INT,
		others NVARCHAR(2000),
		max_key_value INT
	)

	INSERT INTO #TRACKING_VAS_ACTIVITIES_OTHER
	SELECT row_num, others, MAX(key_value) AS max_key_value FROM #B
	GROUP BY row_num, others

	UPDATE A
	SET A.others = ''
	FROM #B A
	INNER JOIN #TRACKING_VAS_ACTIVITIES_OTHER B ON A.row_num = B.row_num and A.others = B.others
	WHERE A.key_value <> B.max_key_value

	UPDATE A
	SET html_string = display_name + ' - ' + '(' + RTRIM(LTRIM(radio_val)) + ') ' + prd_code + CASE WHEN others = '' THEN '' ELSE ' , ' + others END
	FROM #B A
	INNER JOIN VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING B WITH(NOLOCK) ON A.page_dtl_id = B.page_dtl_id
	WHERE principal_code = 'TH-HEC'

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
		SELECT COUNT(1) as ttl_rows FROM #WO
		WHERE (	
				pending_job LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE pending_job END)-- OR

	END
	ELSE
	BEGIN
		SELECT COUNT(1) as ttl_rows FROM #WO --1
	END

	IF (@export_ind = '0')
		SELECT * FROM #WORK_ORDER_TEMP --2
		WHERE (	work_ord_ref LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE work_ord_ref END OR
				job_ref_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE job_ref_no END OR
				mll_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE mll_no END OR
				inbound_doc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE inbound_doc END OR
				client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR
				prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END OR
				prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_desc END)
				AND CASE @cntCurrentEvent WHEN 0 THEN '' ELSE current_event END IN (SELECT event_id FROM #CURRENT_EVENT)
		ORDER BY job_ref_no desc
	ELSE IF (@export_ind = '1')
		SELECT * FROM #WORK_ORDER_TEMP --2
		WHERE (	work_ord_ref LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE work_ord_ref END OR
				job_ref_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE job_ref_no END OR
				mll_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE mll_no END OR
				inbound_doc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE inbound_doc END OR
				client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR
				prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END OR
				prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_desc END)
				AND CASE @cntCurrentEvent WHEN 0 THEN '' ELSE current_event END IN (SELECT event_id FROM #CURRENT_EVENT)
		ORDER BY job_ref_no desc

	SELECT @export_ind AS export_ind --3

	SELECT list_dtl_id, list_col_name as input_name, list_default_display_name as display_name  --4
	FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_LISTING_DTL WITH(NOLOCK)
	WHERE list_hdr_id IN (SELECT list_hdr_id FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_LISTING_HDR WITH(NOLOCK)) AND list_col_name in (SELECT name FROM tempdb.sys.columns where object_id = object_id('tempdb..#WORK_ORDER_TEMP'))

	DROP TABLE #CURRENT_EVENT
	DROP TABLE #ON_HOLD
	DROP TABLE #WORK_ORDER_TEMP
	DROP TABLE #WO
	DROP TABLE #A
	DROP TABLE #B
	DROP TABLE #C
	DROP TABLE #TRACKING_VAS_ACTIVITIES_OTHER
	DROP TABLE #JOB_REF_LIST
END
GO
