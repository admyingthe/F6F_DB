SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_ADM_DASHBOARD]    
 @param NVARCHAR(MAX),    
 @user_id INT    
AS    
BEGIN    
 SET NOCOUNT ON;    
    
 DECLARE @section VARCHAR(50), @type VARCHAR(50)    
 SET @section = (SELECT JSON_VALUE(@param, '$.section'))    
 SET @type = (SELECT JSON_VALUE(@param, '$.type'))    
    
 DECLARE @dept_code VARCHAR(10)    
 SET @dept_code = (SELECT department FROM VASDEV.dbo.TBL_ADM_USER WHERE user_id = @user_id)    


   	--Start/13 Dec 2022/ Smita Thorat//Added for Showing all records to Admin login
	DECLARE @Count_user INTEGER

	SET @Count_user=(SELECT count(1) from  VASDEV.dbo.[TBL_ADM_USER_ACCESSRIGHT] UA
					INNER JOIN VASDEV.dbo.TBL_ADM_ACCESSRIGHT A ON UA.accessright_id =A.accessright_id
					INNER JOIN VASDEV.dbo.TBL_ADM_USER U ON UA.user_id =U.user_id
					where A.accessright_name='bsadmin' AND U.user_id=@user_id)

	IF @Count_user=1
	BEGIN
		SET @dept_code=''
	END
	--End/13 Dec 2022/ Smita Thorat//Added for Showing all records to Admin login
 
 IF (@type <> 'COUNT')
 BEGIN

	 ---------------------------------------------------------------
	CREATE TABLE #JOB_REF_TABLE(category varchar(10), job_ref_no varchar(50), current_event int, temporary_current_event int, count int, quantity int, work_order_status varchar(5), work_order_ref varchar(500), qa_required int, prd_code INT, post_event_id INT)

	INSERT INTO #JOB_REF_TABLE (category, job_ref_no, current_event, temporary_current_event, count, quantity, work_order_status, work_order_ref, qa_required, prd_code, post_event_id)
	SELECT		'MLL'[category], A.job_ref_no, current_event, current_event, count(A.job_ref_no)[count], ttl_qty_eaches, work_ord_status, A.work_ord_ref, qa_required, A.prd_code, D.post_event_id
	FROM		TBL_TXN_WORK_ORDER A
	INNER JOIN  TBL_TXN_WORK_ORDER_JOB_DET B ON A.work_ord_ref = B.work_ord_ref AND A.job_ref_no = B.job_ref_no
	INNER JOIN [VAS].[dbo].[TBL_ADM_USER] C ON C.wh_code = A.whs_no
	INNER JOIN TBL_MST_EVENT_CONFIGURATION_HDR D ON D.event_id = B.current_event
	WHERE		work_ord_status NOT IN ('CCL', 'C')
	AND			C.user_id = @user_id
	GROUP BY	A.job_ref_no, current_event, ttl_qty_eaches, work_ord_status, A.work_ord_ref, qa_required, A.prd_code, D.post_event_id
	UNION
	SELECT		'SUBCON'[category], job_ref_no, current_event, current_event, count(job_ref_no)[count], ttl_qty_eaches, work_ord_status, work_ord_ref, B.qa_required ,A.prd_code, D.post_event_id
	FROM		TBL_SUBCON_TXN_WORK_ORDER A WITH(NOLOCK)   
				INNER JOIN 
				TBL_MST_SUBCON_DTL B WITH(NOLOCK) 
	ON			A.subcon_wi_no = B.subcon_no AND 
				A.prd_code = B.prd_code 
	INNER JOIN [VAS].[dbo].[TBL_ADM_USER] C ON C.wh_code = A.whs_no
	INNER JOIN TBL_MST_EVENT_CONFIGURATION_HDR D ON D.event_id = A.current_event
	WHERE		work_ord_status NOT IN ('CCL', 'C')
	AND			C.user_id = @user_id
	GROUP BY	job_ref_no, current_event, ttl_qty_eaches, work_ord_status, work_ord_ref, B.qa_required,A.prd_code, D.post_event_id

	UPDATE		#JOB_REF_TABLE
	SET			temporary_current_event = 21
	WHERE		current_event = 20 and
				category = 'SUBCON'

	SELECT job_ref_no, current_event, post_event_id
	INTO #JOB_REF_TABLE_TEMP
	FROM #JOB_REF_TABLE
	GROUP BY job_ref_no, current_event, post_event_id

	CREATE TABLE #JOB_EVENT_STATUS (ind INT IDENTITY(1, 1), job_ref_no VARCHAR(50), current_event INT, status NVARCHAR(5), post_event_id INT)
	INSERT INTO  #JOB_EVENT_STATUS(job_ref_no, current_event, status, post_event_id)
	SELECT A.job_ref_no, A.event_id, B.status, C.post_event_id FROM TBL_TXN_JOB_EVENT A
	INNER JOIN VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP B
	ON A.job_ref_no = B.workorder_no
	INNER JOIN #JOB_REF_TABLE_TEMP C
	ON A.job_ref_no = C.job_ref_no
	AND A.event_id = C.current_event

	DECLARE @begin INT = 1, @total INT = (SELECT COUNT(*) FROM #JOB_EVENT_STATUS)

	-- dashboard fine tuning old query

	--WHILE (@begin <= @total)
	--BEGIN
	--	DECLARE @current_event INT, @current_job_ref_no NVARCHAR(20), @total_row INT, @current_status NVARCHAR(5), @current_post_event_id INT

	--	SELECT TOP 1 @current_status = status, @current_event = current_event, @current_job_ref_no = job_ref_no, @current_post_event_id= post_event_id
	--	FROM #JOB_EVENT_STATUS
	--	WHERE ind = @begin
	--	ORDER BY job_ref_no DESC

	--	DECLARE @check_pending_complete BIT = 0

	--	SELECT @check_pending_complete = 1 FROM (SELECT ISNULL(LTRIM(SUBSTRING(A.qi_type, 0, 4)), '') AS qi_type FROM TBL_TXN_WORK_ORDER_JOB_DET A
	--												INNER JOIN TBL_TXN_JOB_EVENT B ON A.job_ref_no = B.job_ref_no
	--												WHERE A.job_ref_no = @current_job_ref_no AND A.current_event = @current_event
	--												GROUP BY qi_type) AS A
	--												WHERE A.qi_type IN ('', 'Q01', 'Q02', 'Q03', 'Q04', 'Q05', 'Q06', 'Q07', 'Q08')
		
	--	UPDATE #JOB_REF_TABLE
	--	SET post_event_id = 
	--	CASE 
	--		WHEN @current_status <> 'R' THEN
	--			CASE WHEN @current_event = 50 THEN 11
	--			WHEN @current_event = 60 THEN 12
	--			WHEN @current_event = 80 THEN 8
	--			WHEN @current_event = 81 THEN 8
	--			ELSE @current_post_event_id END
	--		ELSE 
	--			CASE WHEN @current_event = 50 THEN
	--				CASE 
	--					WHEN @check_pending_complete = 0 THEN 12
	--				ELSE 9 END
	--			WHEN @current_event = 60 THEN 9
	--			WHEN @current_event = 80 THEN 11
	--			ELSE @current_post_event_id END
	--		END
	--	WHERE current_event = @current_event
	--	AND job_ref_no = @current_job_ref_no

	--	SET @begin += 1
	--END
	
	-- dashboard fine tuning old query ends

	-- dashboard fine tuning new query

	update R
	SET post_event_id = (
		CASE 
			WHEN E.status <> 'R' THEN
				CASE WHEN E.current_event = 50 THEN 11
				WHEN E.current_event = 60 THEN 12
				WHEN E.current_event = 80 THEN 8
				WHEN E.current_event = 81 THEN 8
				ELSE E.post_event_id END
			ELSE 
				CASE WHEN E.current_event = 50 THEN
					CASE 
						WHEN isnull((SELECT 1 FROM TBL_TXN_WORK_ORDER_JOB_DET D WHERE job_ref_no = E.job_ref_no AND current_event = E.current_event and qi_type is null), 0) = 0 THEN 12
					ELSE 9 END
				WHEN E.current_event = 60 THEN 9
				WHEN E.current_event = 80 THEN 11
				ELSE E.post_event_id END
			END)
	from #JOB_REF_TABLE R
	inner join #JOB_EVENT_STATUS E on
	R.current_event = E.current_event and R.job_ref_no = E.job_ref_no

	-- dashboard fine tuning new query ends
	---------------------------------------------------------------
 END
 IF (@type = 'COUNT')    
 BEGIN    
  SELECT CAST(0 as INT) as mll_draft, CAST(0 as INT) as mll_submitted,     
  CAST(0 as INT) as inbound_new_with_to, CAST(0 as INT) as inbound_new_without_to, CAST(0 as INT) as inbound_new_with_temp_logger,    
  CAST(0 as INT) as wo_in_process, CAST(0 as INT) as wo_on_hold,    
  CAST(0 as INT) as subcon_new_with_to,    
  CAST(0 as INT) as sc_in_process, CAST(0 as INT) as sc_on_hold,    
  'IP' as wo_status_ip, 'OH' as wo_status_oh,     
  CAST(NULL as DECIMAL(18,2)) as aging    
  INTO #DASHBOARD_TEMP    
    
  IF @dept_code = ''    
  BEGIN    
   UPDATE #DASHBOARD_TEMP    
   SET mll_draft = (SELECT COUNT(mll_no) FROM TBL_MST_MLL_HDR  WHERE mll_status = 'Draft'),    
    mll_submitted = (SELECT COUNT(mll_no) FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_status = 'Submitted')    
  END    
  ELSE    
  BEGIN    
   UPDATE #DASHBOARD_TEMP    
   SET mll_draft = (SELECT COUNT(mll_no) FROM TBL_MST_MLL_HDR A WITH(NOLOCK) LEFT JOIN VASDEV.dbo.TBL_ADM_USER B ON A.creator_user_id = B.user_id WHERE mll_status = 'Draft'   AND (B.department = @dept_code or  ISNULL(A.dept_code,'') =@dept_code )),    
    mll_submitted = (SELECT COUNT(mll_no) FROM TBL_MST_MLL_HDR A WITH(NOLOCK) LEFT JOIN VASDEV.dbo.TBL_ADM_USER B ON A.submitted_by = B.user_id WHERE mll_status = 'Submitted' AND (B.department = @dept_code or  ISNULL(A.dept_code,'') =@dept_code ))    
  END    
      
  UPDATE #DASHBOARD_TEMP    
  SET inbound_new_with_to = (
	SELECT COUNT(inbound_doc) FROM VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER A WITH(NOLOCK) 
	INNER JOIN [VAS].[dbo].[TBL_ADM_USER] C ON C.wh_code = A.whs_no
	WHERE workorder_no IS NULL
	AND CONVERT(BIGINT, ISNULL(vas_order, 0)) > 1
	AND C.user_id = @user_id),    
   inbound_new_without_to = (SELECT COUNT(inbound_doc) FROM VASDEV_INTEGRATION_TH.dbo.VAS_INBOUND_ORDER WHERE inbound_doc NOT IN (select inbound_doc from VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER)),    
   inbound_new_with_temp_logger = (SELECT COUNT(inbound_doc) FROM VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER WITH(NOLOCK) WHERE workorder_no IS NULL AND temp_logger = 'Y'),    
   --FOR SUBCON    
   subcon_new_with_to = (SELECT COUNT(1) FROM VASDEV_INTEGRATION_TH.dbo.VAS_SUBCON_TRANSFER_ORDER WITH(NOLOCK) )--WHERE workorder_no IS NULL)   
  -- (SELECT COUNT(inbound_doc) FROM VASDEV_INTEGRATION_TH.dbo.VAS_SUBCON_TRANSFER_ORDER WITH(NOLOCK) WHERE workorder_no IS NULL)   
    
  UPDATE #DASHBOARD_TEMP    
  SET wo_in_process = (SELECT COUNT(job_ref_no) FROM TBL_TXN_WORK_ORDER_JOB_DET WITH(NOLOCK) WHERE work_ord_status = 'IP'),    
   wo_on_hold = (SELECT COUNT(job_ref_no) FROM TBL_TXN_WORK_ORDER_JOB_DET WITH(NOLOCK) WHERE work_ord_status = 'OH'),    
   --FOR SUBCON    
   sc_in_process = (SELECT COUNT(job_ref_no) FROM TBL_SUBCON_TXN_WORK_ORDER WITH(NOLOCK) WHERE work_ord_status = 'IP'),    
   sc_on_hold = (SELECT COUNT(job_ref_no) FROM TBL_SUBCON_TXN_WORK_ORDER WITH(NOLOCK) WHERE work_ord_status = 'OH')    
    
    /** Old Query **/ 
  /** Aging **/    
  --SELECT job_ref_no, work_ord_status, created_date, CAST(NULL as INT) as total_on_hold_time, CAST(NULL as INT) as to_be_deducted_seconds, CAST(NULL as INT) as total_final_seconds    
  --INTO #WORK_ORDER_T    
  --FROM TBL_TXN_WORK_ORDER    
  --WHERE work_ord_status NOT IN ('C', 'CCL')    
    
  --SELECT job_ref_no, ISNULL(SUM(on_hold_time),0) as ttl_on_hold    
  --INTO #ON_HOLD_T    
  --FROM TBL_TXN_JOB_EVENT WITH(NOLOCK)    
  --GROUP BY job_ref_no    
    
  --UPDATE A    
  --SET total_on_hold_time = B.ttl_on_hold    
  --FROM #WORK_ORDER_T A    
  --INNER JOIN #ON_HOLD_T B ON A.job_ref_no = B.job_ref_no    
    
  --UPDATE #WORK_ORDER_T    
  --SET to_be_deducted_seconds = ISNULL(( (SELECT COUNT(*) FROM TBL_MST_WEEKEND WITH(NOLOCK) WHERE date BETWEEN created_date AND GETDATE()) + (SELECT COUNT(*) FROM TBL_MST_PUBLIC_HOLIDAY WITH(NOLOCK) WHERE date BETWEEN created_date AND GETDATE()) ),0) * 24 * 60 * 60    
    
  --UPDATE #WORK_ORDER_T    
  --SET total_final_seconds = ISNULL((SELECT DATEDIFF(s, created_date, GETDATE())) - (to_be_deducted_seconds + total_on_hold_time),0)    
      
  --UPDATE #DASHBOARD_TEMP    
  --SET aging = (SELECT (SUM(total_final_seconds) / 86400) / COUNT(*) FROM #WORK_ORDER_T)    
  /** Aging **/    
    
  --DROP TABLE #ON_HOLD_T    
  --DROP TABLE #WORK_ORDER_T  
  /** Old Query **/ 
    
  SELECT * FROM #DASHBOARD_TEMP    
  DROP TABLE #DASHBOARD_TEMP    
 END    
 ELSE IF(@type = 'INFO_BY_JOB_EVENT')    
 BEGIN
	SELECT post_event_id, description, CAST(0 as VARCHAR(100)) as count, CAST(0 as VARCHAR(100)) as qty,    
	ISNULL(CAST(0 as VARCHAR(100)),0) as subcon_count,ISNULL(CAST(0 as VARCHAR(100)),0) as subcon_qty    
	INTO #TITLE    
	FROM TBL_MST_EVENT_CONFIGURATION_DTL WITH(NOLOCK)    
	WHERE to_display <> 'X'

	IF((SELECT COUNT(*) FROM #JOB_REF_TABLE) <> 0)
	BEGIN
		SELECT post_event_id, current_event, temporary_current_event, COUNT(DISTINCT job_ref_no) as total, SUM(quantity) as ttl_qty    
		INTO #COUNT    
		FROM #JOB_REF_TABLE A WITH(NOLOCK)    
		WHERE work_order_status NOT IN ('CCL', 'C') and category = 'MLL'    
		GROUP BY current_event, temporary_current_event, post_event_id
      
		SELECT post_event_id AS subcon_post_event_id, current_event, temporary_current_event, COUNT(DISTINCT job_ref_no) as subcon_total, sum(quantity) as subcon_ttl_qty    
		INTO #SUBCON_COUNT    
		FROM #JOB_REF_TABLE A WITH(NOLOCK)    
		WHERE work_order_status NOT IN ('CCL', 'C') and category = 'SUBCON'   
		GROUP BY current_event, temporary_current_event , post_event_id     

		UPDATE		#SUBCON_COUNT
		SET			temporary_current_event = 21
		WHERE		current_event = 20
		
		/** New Query **/ 
		--UPDATE A    
		--SET post_event_id = B.post_event_id    
		--FROM #COUNT A    
		--INNER JOIN TBL_MST_EVENT_CONFIGURATION_HDR B WITH(NOLOCK) ON A.temporary_current_event = B.event_id
    
		--UPDATE A    
		--SET subcon_post_event_id = B.post_event_id    
		--FROM #SUBCON_COUNT A    
		--INNER JOIN TBL_MST_EVENT_CONFIGURATION_HDR B WITH(NOLOCK) ON A.temporary_current_event = B.event_id 
		/** New Query **/ 
    
	/** Old Query **/ 
	  --CREATE TABLE #FINAL(    
	  --  post_event_id INT,    
	  --  final_count INT,    
	  --  final_ttl_qty INT,    
	  --  subcon_post_event_id INT,    
	  --  subcon_final_count INT,    
	  --  subcon_final_ttl_qty INT    
	  -- )  
	  
	  --INSERT INTO    
	  --#FINAL (post_event_id,final_count,final_ttl_qty ) Select post_event_id, SUM(total) as final_count, SUM(ttl_qty) as final_ttl_qty FROM #COUNT GROUP BY post_event_id
	  
	  --INSERT INTO     
	  --#FINAL (subcon_post_event_id,subcon_final_count,subcon_final_ttl_qty ) Select subcon_post_event_id, SUM(subcon_total) as subcon_final_count, SUM(subcon_ttl_qty) as subcon_final_ttl_qty FROM #SUBCON_COUNT GROUP BY subcon_post_event_id    
    /** Old Query **/ 

		SELECT post_event_id, SUM(total) as final_count, SUM(ttl_qty) as final_ttl_qty    
		INTO #FINAL    
		FROM #COUNT    
		GROUP BY post_event_id    
    
		SELECT subcon_post_event_id, SUM(subcon_total) as subcon_final_count, SUM(subcon_ttl_qty) as subcon_final_ttl_qty    
		INTO #FINAL_SUBCON    
		FROM #SUBCON_COUNT    
		GROUP BY subcon_post_event_id    
    
		UPDATE A    
		SET count = B.final_count,    
		qty = B.final_ttl_qty       
		FROM #TITLE A    
		INNER JOIN #FINAL B ON A.post_event_id = B.post_event_id    
      
		UPDATE A    
		SET subcon_count=B.subcon_final_count,    
		subcon_qty=B.subcon_final_ttl_qty      
		FROM #TITLE A    
		INNER JOIN #FINAL_SUBCON B ON A.post_event_id = B.subcon_post_event_id 
		------------------------------------------------------------------------      
		--SELECT CAST(0 as INT) as post_event_id, current_event, ISNULL(qa_required,1) as qa_required, count(current_event) as total, sum(ttl_qty_eaches) as ttl_qty    
		--INTO #COUNT_1    
		--FROM TBL_TXN_WORK_ORDER A WITH(NOLOCK)    
		--INNER JOIN TBL_TXN_WORK_ORDER_JOB_DET B WITH(NOLOCK) ON  A.job_ref_no=B.job_ref_no
		--INNER JOIN [VAS].[dbo].[TBL_ADM_USER] C WITH(NOLOCK) ON C.wh_code = A.whs_no
		--WHERE B.work_ord_status NOT IN ('CCL', 'C') 
		--AND current_event IN(40, 60)
		--AND C.user_id = @user_id  
		--GROUP BY current_event, qa_required    
    
		--SELECT CAST(0 as INT) as subcon_post_event_id, current_event as subcon_current_event, ISNULL(B.qa_required,1) as subcon_qa_required, count(current_event) as subcon_total, sum(ttl_qty_eaches) as subcon_ttl_qty    
		--INTO #COUNT_SUBCON_1    
		--FROM TBL_SUBCON_TXN_WORK_ORDER A WITH(NOLOCK) 
  --		INNER JOIN TBL_MST_SUBCON_DTL B WITH(NOLOCK) 
		--ON A.subcon_wi_no = B.subcon_no 
		--AND A.prd_code = B.prd_code 
		--INNER JOIN [VAS].[dbo].[TBL_ADM_USER] C WITH(NOLOCK) ON C.wh_code = A.whs_no
		--WHERE work_ord_status NOT IN ('CCL', 'C') 
		--AND current_event IN(40, 60)
		--AND C.user_id = @user_id  
		--GROUP BY current_event, B.qa_required    
    
		--UPDATE A    
		--SET post_event_id = B.post_event_id    
		--FROM #COUNT_1 A    
		--INNER JOIN TBL_MST_EVENT_CONFIGURATION_HDR B WITH(NOLOCK) ON A.current_event = B.event_id    
    
		--UPDATE A    
		--SET subcon_post_event_id = B.post_event_id    
		--FROM #COUNT_SUBCON_1 A    
		--INNER JOIN TBL_MST_EVENT_CONFIGURATION_HDR B WITH(NOLOCK) ON A.subcon_current_event = B.event_id    
    
		--SELECT post_event_id, qa_required, SUM(total) as final_count, SUM(ttl_qty) as final_ttl_qty    
		--INTO #FINAL_1    
		--FROM #COUNT_1    
		--GROUP BY post_event_id, qa_required    
    
		--SELECT subcon_post_event_id, subcon_qa_required, SUM(subcon_total) as subcon_final_count, SUM(subcon_ttl_qty) as subcon_final_ttl_qty    
		--INTO #FINAL_SUBCON_1    
		--FROM #COUNT_SUBCON_1    
		--GROUP BY subcon_post_event_id, subcon_qa_required    

		--DECLARE @count22 INT = (SELECT final_count FROM #FINAL_1)
		--	PRINT (@count22)
    
		--UPDATE #TITLE    
		--SET count = ISNULL((SELECT Stuff(    
		--	(SELECT N' / ' + CAST(final_count as VARCHAR(100)) FROM #FINAL_1 ORDER BY qa_required DESC FOR XML PATH(''),TYPE)    
		--	.value('text()[1]','nvarchar(max)'),1,2,N'')),0),    
		--qty = ISNULL((SELECT Stuff(    
		--(SELECT N' / ' + CAST(final_ttl_qty as VARCHAR(100)) FROM #FINAL_1 ORDER BY qa_required DESC FOR XML PATH(''),TYPE)    
		--.value('text()[1]','nvarchar(max)'),1,2,N'')),0)    
		--WHERE post_event_id = 7    
    
		--UPDATE #TITLE    
		--SET subcon_count = ISNULL((SELECT Stuff(    
		--	(SELECT N' / ' + CAST(subcon_final_count as VARCHAR(100)) FROM #FINAL_SUBCON_1 ORDER BY subcon_qa_required DESC FOR XML PATH(''),TYPE)    
		--	.value('text()[1]','nvarchar(max)'),1,2,N'')),0),    
		--subcon_qty = ISNULL((SELECT Stuff(    
		--(SELECT N' / ' + CAST(subcon_final_ttl_qty as VARCHAR(100)) FROM #FINAL_SUBCON_1 ORDER BY subcon_qa_required DESC FOR XML PATH(''),TYPE)    
		--.value('text()[1]','nvarchar(max)'),1,2,N'')) ,0)   
		--WHERE post_event_id = 7

		DECLARE @count_pending_dksh_qa INT,	@count_pending_client_qa INT, @sum_qty INT = 0
		SET @count_pending_dksh_qa = (SELECT COUNT(DISTINCT job_ref_no) FROM #JOB_REF_TABLE WHERE post_event_id = 11)
		SET @count_pending_client_qa = (SELECT COUNT(DISTINCT job_ref_no) FROM #JOB_REF_TABLE WHERE post_event_id = 12)
		SET @sum_qty = (SELECT SUM(quantity) FROM #JOB_REF_TABLE WHERE post_event_id IN (11, 12))

		PRINT ('DKSH: ' + CAST(@count_pending_dksh_qa AS NVARCHAR(100)))
		PRINT ('CLIENT: ' + CAST(@count_pending_client_qa AS NVARCHAR(100)))

		DECLARE @final_count NVARCHAR(MAX)
		IF(@count_pending_dksh_qa <> 0 OR @count_pending_client_qa <> 0)
		BEGIN
			UPDATE #TITLE
			SET count = (SELECT CONCAT(CAST(@count_pending_dksh_qa AS NVARCHAR(100)), ' / ', CAST(@count_pending_client_qa AS NVARCHAR(100))) AS count),
			qty = CAST(@sum_qty AS nvarchar(100))
			WHERE post_event_id = 7
		END

		  DROP TABLE #COUNT    
		  DROP TABLE #FINAL    
		  DROP TABLE #FINAL_SUBCON    
		  DROP TABLE #SUBCON_COUNT    
		  --DROP TABLE #COUNT_1    
		  --DROP TABLE #COUNT_SUBCON_1    
		  --DROP TABLE #FINAL_1    
		  --DROP TABLE #FINAL_SUBCON_1 
	END

  SELECT * FROM #TITLE
  DROP TABLE #TITLE    

 END    
 ELSE IF(@type = 'INFO_BY_JOB_EVENT_DTL_WITHOUT_AGING')    
 BEGIN

  DECLARE @post_event_id_1 INT    
  SET @post_event_id_1 = (SELECT JSON_VALUE(@param, '$.post_event_id'))
  CREATE TABLE #EVENT_1 (event_id INT)

  --FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK) WHERE post_event_id = @post_event_id_1    
   
  SELECT * 
  INTO #TEMP_JOB_DTL_1  
  FROM ( 
  SELECT CASE @post_event_id_1 WHEN '1' THEN '<a href=# onclick="GoToPPM(''' + job_ref_no + ''')">' + job_ref_no + '</a>' ELSE '<a href=# style="color: @style" onclick="GoToJobEvent(''' + job_ref_no + ''')">' + job_ref_no + '</a>' END as job_ref_no  ,     
  job_ref_no as job_no, ISNULL(qa_required, 1) as qa_required, CAST(NULL as VARCHAR(10)) as f_color,    
  post_event_id, CAST(NULL as VARCHAR(10)) as running_no,     
  CAST(0 as INT) as before_deduct_on_hold,    
  CAST(0 as INT) as after_deduct_on_hold,    
  CAST(NULL as VARCHAR(19)) as completion_date, --CAST(0 as INT) as to_be_deducted_seconds,     
  CAST(0 as INT) as total_on_hold_time, --CAST(0 as INT) as total_final_seconds,     
  CAST('' as VARCHAR(100)) as time_elapse, current_event,    
  category as process       
  FROM #JOB_REF_TABLE WITH(NOLOCK)    
  --WHERE current_event IN (SELECT event_id FROM #EVENT_1) 
  WHERE work_order_status NOT IN ('CCL', 'C') 
  AND category = 'MLL'    
  UNION    
  SELECT TOP 10 CASE @post_event_id_1 WHEN '1' THEN '<a href=# onclick="GoToPPM(''' + job_ref_no + ''')">' + job_ref_no + '</a>' ELSE '<a href=# style="color: @style" onclick="GoToJobEvent(''' + job_ref_no + ''')">' + job_ref_no + '</a>' END as job_ref_no,     
  job_ref_no as job_no, ISNULL(qa_required, 1) as qa_required, CAST(NULL as VARCHAR(10)) as f_color,    
  post_event_id, CAST(NULL as VARCHAR(10)) as running_no,     
  CAST(0 as INT) as before_deduct_on_hold,    
  CAST(0 as INT) as after_deduct_on_hold,    
  CAST(NULL as VARCHAR(19)) as completion_date, --CAST(0 as INT) as to_be_deducted_seconds,     
  CAST(0 as INT) as total_on_hold_time, --CAST(0 as INT) as total_final_seconds,     
  CAST('' as VARCHAR(100)) as time_elapse, current_event,    
  category as process     
  FROM #JOB_REF_TABLE WITH(NOLOCK)    
  WHERE 
  --temporary_current_event IN (SELECT event_id FROM #EVENT_1) 
  work_order_status NOT IN ('CCL', 'C') 
  AND category = 'SUBCON'
  ) MAIN

  UPDATE A    
  SET running_no = (SELECT MAX(running_no) FROM TBL_TXN_JOB_EVENT B WITH(NOLOCK) WHERE A.job_no = B.job_ref_no AND B.event_id = current_event)    
  FROM #TEMP_JOB_DTL_1 A  

  -- Old code
  --UPDATE #TEMP_JOB_DTL_1    
  --SET f_color = CASE qa_required WHEN 0 THEN 'red' ELSE '' END    
  --WHERE post_event_id IN (11 ,12) 

  UPDATE #TEMP_JOB_DTL_1    
  SET f_color = CASE post_event_id WHEN 12 THEN 'red' ELSE '' END    
  WHERE post_event_id IN (11 ,12)
    
  UPDATE #TEMP_JOB_DTL_1    
  SET job_ref_no = REPLACE(job_ref_no, '@style', f_color)    
  WHERE post_event_id IN (11 ,12)

  UPDATE #TEMP_JOB_DTL_1
  SET post_event_id = 7
  WHERE post_event_id IN (11 ,12)
    
  SELECT top 10 * 
  FROM #TEMP_JOB_DTL_1 
  WHERE post_event_id = @post_event_id_1
  --ORDER BY CAST(time_elapse as FLOAT) DESC 
  

  DROP TABLE #EVENT_1    
  DROP TABLE #TEMP_JOB_DTL_1    
 END    
 ELSE IF(@type = 'INFO_BY_JOB_EVENT_DTL')    
 BEGIN    
  DECLARE @post_event_id INT    
  SET @post_event_id = (SELECT JSON_VALUE(@param, '$.post_event_id'))    
    
  SELECT event_id     
  INTO #EVENT    
  FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK) WHERE post_event_id = @post_event_id    
      
  SELECT TOP 10 CASE @post_event_id_1 WHEN '1' THEN '<a href=# onclick="GoToPPM(''' + job_ref_no + ''')">' + job_ref_no + '</a>' ELSE '<a href=# style="color: @style" onclick="GoToJobEvent(''' + job_ref_no + ''')">' + job_ref_no + '</a>' END as job_ref_no,     
  job_ref_no as job_no, qa_required, CAST(NULL as VARCHAR(10)) as f_color, work_order_status, @post_event_id as post_event_id, CAST(NULL as VARCHAR(10)) as running_no, CAST(0 as INT) as before_deduct_on_hold, CAST(0 as INT) as after_deduct_on_hold, CAST(NULL as VARCHAR(19)) as completion_date, --CAST(0 as INT) as to_be_deducted_seconds,     
  CAST(0 as INT) as total_on_hold_time, --CAST(0 as INT) as total_final_seconds,     
  CAST('' as VARCHAR(100)) as time_elapse, current_event,    
  category as process    
  INTO #TEMP_JOB_DTL    
  FROM #JOB_REF_TABLE WITH(NOLOCK)     
  WHERE current_event IN (SELECT event_id FROM #EVENT) AND work_order_status NOT IN ('CCL', 'C') and category = 'MLL'    
  UNION    
  SELECT TOP 10 CASE @post_event_id_1 WHEN '1' THEN '<a href=# onclick="GoToPPM(''' + job_ref_no + ''')">' + job_ref_no + '</a>' ELSE '<a href=# style="color: @style" onclick="GoToJobEvent(''' + job_ref_no + ''')">' + job_ref_no + '</a>' END as job_ref_no, job_ref_no as job_no, qa_required, CAST(NULL as VARCHAR(10)) as f_color, work_order_status, @post_event_id as post_event_id, CAST(NULL as VARCHAR(10)) as running_no, CAST(0 as INT) as before_deduct_on_hold, CAST(0 as INT) as after_deduct_on_hold,    
  CAST(NULL as VARCHAR(19)) as completion_date, --CAST(0 as INT) as to_be_deducted_seconds,     
  CAST(0 as INT) as total_on_hold_time, --CAST(0 as INT) as total_final_seconds,     
  CAST('' as VARCHAR(100)) as time_elapse, current_event,    
  category as process    
  FROM #JOB_REF_TABLE WITH(NOLOCK)      
  WHERE current_event IN (SELECT event_id FROM #EVENT) AND work_order_status NOT IN ('CCL', 'C') and category = 'SUBCON'     
    
  UPDATE A    
  SET running_no = (SELECT MAX(running_no) FROM TBL_TXN_JOB_EVENT B WITH(NOLOCK) WHERE A.job_no = B.job_ref_no AND B.event_id = current_event)    
  FROM #TEMP_JOB_DTL A    
    
  UPDATE #TEMP_JOB_DTL    
  SET f_color = CASE qa_required WHEN 0 THEN 'red' ELSE '' END    
  WHERE post_event_id IN (11 ,12)   
    
  UPDATE A    
  SET completion_date = CONVERT(VARCHAR(19), B.to_time, 121)    
  FROM #TEMP_JOB_DTL A    
  INNER JOIN VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER B ON A.job_no = B.workorder_no     
  WHERE A.process='MLL'    
    
  UPDATE A    
  SET completion_date = CONVERT(VARCHAR(19), B.to_time, 121)    
  FROM #TEMP_JOB_DTL A    
  INNER JOIN VASDEV_INTEGRATION_TH.dbo.VAS_SUBCON_TRANSFER_ORDER B ON A.job_no = B.Subcon_Job_No    
  WHERE A.process='SUBCON'    
    
  /** Old Query **/ 	
  --UPDATE A    
  --SET completion_date = CONVERT(VARCHAR(19), B.to_time, 121)    
  --FROM #TEMP_SUBCON_JOB_DTL A    
  --INNER JOIN VASDEV_INTEGRATION_TH.dbo.VAS_SUBCON_TRANSFER_ORDER B ON A.job_no = B.workorder_no    
  /** Old Query **/ 
    
  UPDATE #TEMP_JOB_DTL    
  SET before_deduct_on_hold = (SELECT dbo.GetTotalWorkingMins(completion_date, '', ''))    
    
  SELECT job_ref_no, ISNULL(SUM(on_hold_time),0) as ttl_on_hold    
  INTO #ON_HOLD    
  FROM TBL_TXN_JOB_EVENT WITH(NOLOCK)    
  GROUP BY job_ref_no    
    
  UPDATE A    
  SET total_on_hold_time = B.ttl_on_hold    
  FROM #TEMP_JOB_DTL A    
  INNER JOIN #ON_HOLD B ON A.job_no = B.job_ref_no    
    
  UPDATE A    
  SET after_deduct_on_hold = CAST(before_deduct_on_hold as FLOAT) - (CAST(total_on_hold_time as FLOAT) / CAST(60 as FLOAT))    
  FROM #TEMP_JOB_DTL A    
    
  UPDATE #TEMP_JOB_DTL    
  SET time_elapse = (CAST(after_deduct_on_hold as FLOAT) / CAST(60 as FLOAT)) / CAST(12 as FLOAT)    
  WHERE work_order_status <> 'OH'
  
  /** Old Query **/ 	
  --UPDATE A    
  --SET to_be_deducted_seconds = ( ISNULL(( (SELECT COUNT(*) FROM TBL_MST_WEEKEND WITH(NOLOCK) WHERE date BETWEEN completion_date AND GETDATE()) + (SELECT COUNT(*) FROM TBL_MST_PUBLIC_HOLIDAY WITH(NOLOCK) WHERE date BETWEEN completion_date AND GETDATE()) ) , 0) * 24 * 60 * 60 )    
  --FROM #TEMP_JOB_DTL A    
    
  --UPDATE A    
  --SET total_final_seconds = ISNULL((SELECT DATEDIFF(s,  completion_date, GETDATE())) - (to_be_deducted_seconds + total_on_hold_time),0)    
  --FROM #TEMP_JOB_DTL A    
    
  --UPDATE #TEMP_JOB_DTL    
  --SET time_elapse = (CONVERT(VARCHAR(12), total_final_seconds /60 / 60 / 24) + ' Day(s) '    
  --     + CONVERT(VARCHAR(12), total_final_seconds / 60 / 60 % 24) + ' Hour(s) '    
  --     + CONVERT(VARCHAR(2), total_final_seconds / 60 % 60) + ' Minute(s) '    
  --     + CONVERT(VARCHAR(2), total_final_seconds % 60) + ' Second(s)')    
  /** Old Query **/ 
    select * from #TEMP_JOB_DTL
  SELECT * FROM #TEMP_JOB_DTL ORDER BY CAST(time_elapse as FLOAT) DESC    
  DROP TABLE #EVENT    
  DROP TABLE #ON_HOLD    
  DROP TABLE #TEMP_JOB_DTL    
 END    
 ELSE IF (@type = 'GET_AVG_AGING')    
 BEGIN    
  IF(SELECT COUNT(login) FROM VASDEV.dbo.TBL_ADM_USER WITH(NOLOCK) WHERE user_id = @user_id AND login LIKE 'RRC_%') > 0    
  BEGIN    
   CREATE TABLE #TEMP_AVG(    
    job_ref_no VARCHAR(50),    
    to_time VARCHAR(50),    
    total_on_hold_time INT,    
    before_deduct_on_hold INT,    
    after_deduct_on_hold INT,    
    elapsed_time NUMERIC(18,2)    
   )    
    
   INSERT INTO #TEMP_AVG(job_ref_no, to_time, before_deduct_on_hold)    
   SELECT DISTINCT A.job_ref_no, to_time, dbo.GetTotalWorkingMins(to_time, C.work_ord_status, C.changed_date)     
   FROM TBL_TXN_WORK_ORDER A WITH(NOLOCK)  
   INNER JOIN TBL_TXN_WORK_ORDER_JOB_DET C ON  A.job_ref_no=C.job_ref_no
   INNER JOIN VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER B WITH(NOLOCK) ON A.vas_order = B.vas_order AND A.prd_code = B.prd_code AND A.batch_no = B.batch_no    
   WHERE C.work_ord_status = 'IP'    
    
   SELECT job_ref_no, ISNULL(SUM(on_hold_time),0) / 60 as ttl_on_hold    
   INTO #ON_HOLD_AVG    
   FROM TBL_TXN_JOB_EVENT WITH(NOLOCK)    
   GROUP BY job_ref_no    
    
   UPDATE A    
   SET total_on_hold_time = B.ttl_on_hold    
   FROM #TEMP_AVG A    
   INNER JOIN #ON_HOLD_AVG B ON A.job_ref_no = B.job_ref_no    
    
   UPDATE A    
   SET after_deduct_on_hold = CAST(before_deduct_on_hold as FLOAT) - (CAST(total_on_hold_time as FLOAT) / CAST(60 as FLOAT)) --before_deduct_on_hold - total_on_hold_time    
   FROM #TEMP_AVG A    
    
   UPDATE #TEMP_AVG    
   SET elapsed_time = (CAST(after_deduct_on_hold as FLOAT) / CAST(60 as FLOAT)) / CAST(12 as FLOAT)    
    
   DECLARE @ttl_elapsed_time NUMERIC(18,2), @avg_aging NUMERIC(18,2)    
   SET @ttl_elapsed_time = (SELECT SUM(elapsed_time) FROM #TEMP_AVG)    
   SET @avg_aging = @ttl_elapsed_time / (SELECT COUNT(1) FROM #TEMP_AVG)    
   SELECT @ttl_elapsed_time as ttl_elapsed_time, @avg_aging as avg_aging    
    
   DROP TABLE #TEMP_AVG    
   DROP TABLE #ON_HOLD_AVG    
  END    
  ELSE    
  BEGIN    
   SELECT '--' as ttl_elapsed_time, '--' as avg_aging    
  END    
 END    

if (@type <> 'COUNT')
begin
 
DROP TABLE #JOB_REF_TABLE
DROP TABLE #JOB_REF_TABLE_TEMP
DROP TABLE #JOB_EVENT_STATUS
end
END
GO
