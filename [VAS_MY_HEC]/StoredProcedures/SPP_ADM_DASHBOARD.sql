SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
-- =================================================================================================================    
-- Author:  Siow Shen Yee    
-- Create date: 2018-07-13    
-- Description: Retrieve Dashboard    
-- Example Query:     
-- 1) exec SPP_ADM_DASHBOARD @param=N'{"section": "", "type": "COUNT"}',@user_id=N'1'    
-- 2) exec SPP_ADM_DASHBOARD @param=N'{"section":"","type":"INFO_BY_JOB_EVENT"}',@user_id=N'1'    
-- 3) exec SPP_ADM_DASHBOARD @param=N'{"section":"","type":"INFO_BY_JOB_EVENT_DTL","post_event_id":7}',@user_id=N'1'    
-- 4) exec SPP_ADM_DASHBOARD @param=N'{"section":"","type":"GET_AVG_AGING"}',@user_id=N'1'    
-- =================================================================================================================    
    
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
 SET @dept_code = (SELECT department FROM VAS.dbo.TBL_ADM_USER WHERE user_id = @user_id) 
 

  	--Start/13 Dec 2022/ Smita Thorat//Added for Showing all records to Admin login
	DECLARE @Count_user INTEGER

	SET @Count_user=(SELECT count(1) from  VAS.dbo.[TBL_ADM_USER_ACCESSRIGHT] UA
					INNER JOIN VAS.dbo.TBL_ADM_ACCESSRIGHT A ON UA.accessright_id =A.accessright_id
					INNER JOIN VAS.dbo.TBL_ADM_USER U ON UA.user_id =U.user_id
					where A.accessright_name='bsadmin' AND U.user_id=@user_id)

	IF @Count_user=1
	BEGIN
		SET @dept_code=''
	END
	--End/13 Dec 2022/ Smita Thorat//Added for Showing all records to Admin login

 
 if (@type <> 'COUNT')
 begin

 ---------------------------------------------------------------
create table #JOB_REF_TABLE(category varchar(10), job_ref_no varchar(50), current_event int, temporary_current_event int, count int, quantity int, work_order_status varchar(5), work_order_ref varchar(500), qa_required int)

insert into #JOB_REF_TABLE (category, job_ref_no, current_event,temporary_current_event, count, quantity, work_order_status, work_order_ref, qa_required)
select		'MLL'[category], job_ref_no, current_event, current_event, count(job_ref_no)[count], ttl_qty_eaches, work_ord_status, work_ord_ref, qa_required 
from		TBL_TXN_WORK_ORDER 
WHERE		work_ord_status NOT IN ('CCL', 'C')
group by	job_ref_no, current_event, ttl_qty_eaches, work_ord_status, work_ord_ref, qa_required
union
SELECT		'SUBCON'[category], job_ref_no, current_event, current_event, count(job_ref_no)[count], ttl_qty_eaches, work_ord_status, work_ord_ref, B.qa_required 
FROM		TBL_SUBCON_TXN_WORK_ORDER A WITH(NOLOCK)   
			INNER JOIN 
			TBL_MST_SUBCON_DTL B WITH(NOLOCK) 
ON			A.subcon_wi_no = B.subcon_no AND 
			A.prd_code = B.prd_code 
WHERE		work_ord_status NOT IN ('CCL', 'C')
group by	job_ref_no, current_event, ttl_qty_eaches, work_ord_status, work_ord_ref, B.qa_required

update		#JOB_REF_TABLE
set			temporary_current_event = 21
where		current_event = 20 and
			category = 'SUBCON'
---------------------------------------------------------------
 end
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
   SET mll_draft = (SELECT COUNT(mll_no) FROM TBL_MST_MLL_HDR A WITH(NOLOCK) LEFT JOIN VAS.dbo.TBL_ADM_USER B ON A.creator_user_id = B.user_id WHERE mll_status = 'Draft' AND B.department = @dept_code),    
    mll_submitted = (SELECT COUNT(mll_no) FROM TBL_MST_MLL_HDR A WITH(NOLOCK) LEFT JOIN VAS.dbo.TBL_ADM_USER B ON A.submitted_by = B.user_id WHERE mll_status = 'Submitted' AND B.department = @dept_code)    
  END    
      
  UPDATE #DASHBOARD_TEMP    
  SET inbound_new_with_to = (SELECT COUNT(inbound_doc) FROM VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER WITH(NOLOCK) WHERE workorder_no IS NULL),    
   inbound_new_without_to = (SELECT COUNT(inbound_doc) FROM VAS_INTEGRATION.dbo.VAS_INBOUND_ORDER WHERE inbound_doc NOT IN (select inbound_doc from VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER)),    
   inbound_new_with_temp_logger = (SELECT COUNT(inbound_doc) FROM VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER WITH(NOLOCK) WHERE workorder_no IS NULL AND temp_logger = 'Y'),    
   --FOR SUBCON    
   subcon_new_with_to = (SELECT COUNT(1) FROM VAS_INTEGRATION.dbo.VAS_SUBCON_TRANSFER_ORDER WITH(NOLOCK) )--WHERE workorder_no IS NULL)   
  -- (SELECT COUNT(inbound_doc) FROM VAS_INTEGRATION.dbo.VAS_SUBCON_TRANSFER_ORDER WITH(NOLOCK) WHERE workorder_no IS NULL)   
    
  UPDATE #DASHBOARD_TEMP    
  SET wo_in_process = (SELECT COUNT(job_ref_no) FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE work_ord_status = 'IP'),    
   wo_on_hold = (SELECT COUNT(job_ref_no) FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE work_ord_status = 'OH'),    
   --FOR SUBCON    
   sc_in_process = (SELECT COUNT(job_ref_no) FROM TBL_SUBCON_TXN_WORK_ORDER WITH(NOLOCK) WHERE work_ord_status = 'IP'),    
   sc_on_hold = (SELECT COUNT(job_ref_no) FROM TBL_SUBCON_TXN_WORK_ORDER WITH(NOLOCK) WHERE work_ord_status = 'OH')    
    
    
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

  SELECT CAST(0 as INT) as post_event_id, current_event, 			current_event as temporary_current_event, count(current_event) as total, sum(quantity) as ttl_qty    
  INTO #COUNT    
  FROM #JOB_REF_TABLE A WITH(NOLOCK)    
  WHERE work_order_status NOT IN ('CCL', 'C') and category = 'MLL'    
  GROUP BY current_event    
      
  SELECT CAST(0 as INT) as subcon_post_event_id, current_event, current_event as temporary_current_event, count(current_event) as subcon_total, sum(quantity) as subcon_ttl_qty    
  INTO #SUBCON_COUNT    
  FROM #JOB_REF_TABLE A WITH(NOLOCK)    
  WHERE work_order_status NOT IN ('CCL', 'C') and category = 'SUBCON'   
  GROUP BY current_event      

update		#SUBCON_COUNT
set			temporary_current_event = 21
where		current_event = 20	

  UPDATE A    
  SET post_event_id = B.post_event_id    
  FROM #COUNT A    
  INNER JOIN TBL_MST_EVENT_CONFIGURATION_HDR B WITH(NOLOCK) ON A.temporary_current_event = B.event_id 
    
  UPDATE A    
  SET subcon_post_event_id = B.post_event_id    
  FROM #SUBCON_COUNT A    
  INNER JOIN TBL_MST_EVENT_CONFIGURATION_HDR B WITH(NOLOCK) ON A.temporary_current_event = B.event_id   
    
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
  SELECT CAST(0 as INT) as post_event_id, current_event, ISNULL(qa_required,1) as qa_required, count(current_event) as total, sum(ttl_qty_eaches) as ttl_qty    
  INTO #COUNT_1    
  FROM TBL_TXN_WORK_ORDER A WITH(NOLOCK)    
  WHERE work_ord_status NOT IN ('CCL', 'C') AND current_event IN(40, 60)    
  GROUP BY current_event, qa_required    
    
  SELECT CAST(0 as INT) as subcon_post_event_id, current_event as subcon_current_event, ISNULL(B.qa_required,1) as subcon_qa_required, count(current_event) as subcon_total, sum(ttl_qty_eaches) as subcon_ttl_qty    
  INTO #COUNT_SUBCON_1    
  FROM TBL_SUBCON_TXN_WORK_ORDER A WITH(NOLOCK) 
  			INNER JOIN 
			TBL_MST_SUBCON_DTL B WITH(NOLOCK) 
ON			A.subcon_wi_no = B.subcon_no AND 
			A.prd_code = B.prd_code   
  WHERE work_ord_status NOT IN ('CCL', 'C') AND current_event IN(40, 60)    
  GROUP BY current_event, B.qa_required    
    
  UPDATE A    
  SET post_event_id = B.post_event_id    
  FROM #COUNT_1 A    
  INNER JOIN TBL_MST_EVENT_CONFIGURATION_HDR B WITH(NOLOCK) ON A.current_event = B.event_id    
    
  UPDATE A    
  SET subcon_post_event_id = B.post_event_id    
  FROM #COUNT_SUBCON_1 A    
  INNER JOIN TBL_MST_EVENT_CONFIGURATION_HDR B WITH(NOLOCK) ON A.subcon_current_event = B.event_id    
    
  SELECT post_event_id, qa_required, SUM(total) as final_count, SUM(ttl_qty) as final_ttl_qty    
  INTO #FINAL_1    
  FROM #COUNT_1    
  GROUP BY post_event_id, qa_required    
    
  SELECT subcon_post_event_id, subcon_qa_required, SUM(subcon_total) as subcon_final_count, SUM(subcon_ttl_qty) as subcon_final_ttl_qty    
  INTO #FINAL_SUBCON_1    
  FROM #COUNT_SUBCON_1    
  GROUP BY subcon_post_event_id, subcon_qa_required    
    
  UPDATE #TITLE    
  SET count = (SELECT Stuff(    
     (SELECT N' / ' + CAST(final_count as VARCHAR(100)) FROM #FINAL_1 ORDER BY qa_required DESC FOR XML PATH(''),TYPE)    
     .value('text()[1]','nvarchar(max)'),1,2,N'')),    
   qty = (SELECT Stuff(    
    (SELECT N' / ' + CAST(final_ttl_qty as VARCHAR(100)) FROM #FINAL_1 ORDER BY qa_required DESC FOR XML PATH(''),TYPE)    
    .value('text()[1]','nvarchar(max)'),1,2,N''))    
  WHERE post_event_id = 7    
    
  UPDATE #TITLE    
  SET subcon_count = ISNULL((SELECT Stuff(    
     (SELECT N' / ' + CAST(subcon_final_count as VARCHAR(100)) FROM #FINAL_SUBCON_1 ORDER BY subcon_qa_required DESC FOR XML PATH(''),TYPE)    
     .value('text()[1]','nvarchar(max)'),1,2,N'')),0),    
   subcon_qty = ISNULL((SELECT Stuff(    
    (SELECT N' / ' + CAST(subcon_final_ttl_qty as VARCHAR(100)) FROM #FINAL_SUBCON_1 ORDER BY subcon_qa_required DESC FOR XML PATH(''),TYPE)    
    .value('text()[1]','nvarchar(max)'),1,2,N'')) ,0)   
  WHERE post_event_id = 7    
         
  SELECT * FROM #TITLE
  DROP TABLE #FINAL    
  DROP TABLE #FINAL_SUBCON    
  DROP TABLE #COUNT    
  DROP TABLE #SUBCON_COUNT    
  DROP TABLE #TITLE    
  DROP TABLE #COUNT_1    
  DROP TABLE #COUNT_SUBCON_1    
  DROP TABLE #FINAL_1    
  DROP TABLE #FINAL_SUBCON_1 
    
 END    
 ELSE IF(@type = 'INFO_BY_JOB_EVENT_DTL_WITHOUT_AGING')    
 BEGIN    
  DECLARE @post_event_id_1 INT    
  SET @post_event_id_1 = (SELECT JSON_VALUE(@param, '$.post_event_id'))       
  SELECT event_id     
  INTO #EVENT_1    
  FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK) WHERE post_event_id = @post_event_id_1    
   
  select * 
  INTO #TEMP_JOB_DTL_1  
  from ( 
  SELECT CASE @post_event_id_1 WHEN '1' THEN '<a href=# onclick="GoToPPM(''' + job_ref_no + ''')">' + job_ref_no + '</a>' ELSE '<a href=# style="color: @style" onclick="GoToJobEvent(''' + job_ref_no + ''')">' + job_ref_no + '</a>' END as job_ref_no  ,     
  job_ref_no as job_no, ISNULL(qa_required, 1) as qa_required, CAST(NULL as VARCHAR(10)) as f_color,    
  @post_event_id_1 as post_event_id, CAST(NULL as VARCHAR(10)) as running_no,     
  CAST(0 as INT) as before_deduct_on_hold,    
  CAST(0 as INT) as after_deduct_on_hold,    
  CAST(NULL as VARCHAR(19)) as completion_date, --CAST(0 as INT) as to_be_deducted_seconds,     
  CAST(0 as INT) as total_on_hold_time, --CAST(0 as INT) as total_final_seconds,     
  CAST('' as VARCHAR(100)) as time_elapse, current_event,    
  category as process       
  FROM #JOB_REF_TABLE WITH(NOLOCK)    
  WHERE current_event IN (SELECT event_id FROM #EVENT_1) AND work_order_status NOT IN ('CCL', 'C') and category = 'MLL'    
  UNION    
  SELECT TOP 10 CASE @post_event_id_1 WHEN '1' THEN '<a href=# onclick="GoToPPM(''' + job_ref_no + ''')">' + job_ref_no + '</a>' ELSE '<a href=# style="color: @style" onclick="GoToJobEvent(''' + job_ref_no + ''')">' + job_ref_no + '</a>' END as job_ref_no,     
  job_ref_no as job_no, ISNULL(qa_required, 1) as qa_required, CAST(NULL as VARCHAR(10)) as f_color,    
  @post_event_id_1 as post_event_id, CAST(NULL as VARCHAR(10)) as running_no,     
  CAST(0 as INT) as before_deduct_on_hold,    
  CAST(0 as INT) as after_deduct_on_hold,    
  CAST(NULL as VARCHAR(19)) as completion_date, --CAST(0 as INT) as to_be_deducted_seconds,     
  CAST(0 as INT) as total_on_hold_time, --CAST(0 as INT) as total_final_seconds,     
  CAST('' as VARCHAR(100)) as time_elapse, current_event,    
  category as process     
  FROM #JOB_REF_TABLE WITH(NOLOCK)    
  WHERE temporary_current_event IN (SELECT event_id FROM #EVENT_1) AND work_order_status NOT IN ('CCL', 'C') and category = 'SUBCON'  
  ) MAIN

  UPDATE A    
  SET running_no = (SELECT MAX(running_no) FROM TBL_TXN_JOB_EVENT B WITH(NOLOCK) WHERE A.job_no = B.job_ref_no AND B.event_id = current_event)    
  FROM #TEMP_JOB_DTL_1 A    

  UPDATE #TEMP_JOB_DTL_1    
  SET f_color = CASE qa_required WHEN 0 THEN 'red' ELSE '' END    
  WHERE @post_event_id_1 = 7    
    
  UPDATE #TEMP_JOB_DTL_1    
  SET job_ref_no = REPLACE(job_ref_no, '@style', f_color)    
  WHERE @post_event_id_1 = 7    
    
  SELECT top 10 * FROM #TEMP_JOB_DTL_1 --ORDER BY CAST(time_elapse as FLOAT) DESC    
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
  WHERE @post_event_id_1 = 7    
    
  UPDATE A    
  SET completion_date = CONVERT(VARCHAR(19), B.to_time, 121)    
  FROM #TEMP_JOB_DTL A    
  INNER JOIN VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER B ON A.job_no = B.workorder_no     
  WHERE A.process='MLL'    
    
  UPDATE A    
  SET completion_date = CONVERT(VARCHAR(19), B.to_time, 121)    
  FROM #TEMP_JOB_DTL A    
  INNER JOIN VAS_INTEGRATION.dbo.VAS_SUBCON_TRANSFER_ORDER B ON A.job_no = B.Subcon_Job_No    
  WHERE A.process='SUBCON'    
    
  --UPDATE A    
  --SET completion_date = CONVERT(VARCHAR(19), B.to_time, 121)    
  --FROM #TEMP_SUBCON_JOB_DTL A    
  --INNER JOIN VAS_INTEGRATION.dbo.VAS_SUBCON_TRANSFER_ORDER B ON A.job_no = B.workorder_no     
    
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
    select * from #TEMP_JOB_DTL
  SELECT * FROM #TEMP_JOB_DTL ORDER BY CAST(time_elapse as FLOAT) DESC    
  DROP TABLE #EVENT    
  DROP TABLE #ON_HOLD    
  DROP TABLE #TEMP_JOB_DTL    
 END    
 ELSE IF (@type = 'GET_AVG_AGING')    
 BEGIN    
  IF(SELECT COUNT(login) FROM VAS.dbo.TBL_ADM_USER WITH(NOLOCK) WHERE user_id = @user_id AND login LIKE 'RRC_%') > 0    
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
   SELECT DISTINCT job_ref_no, to_time, dbo.GetTotalWorkingMins(to_time, work_ord_status, A.changed_date)     
   FROM TBL_TXN_WORK_ORDER A WITH(NOLOCK)     
   INNER JOIN VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER B WITH(NOLOCK) ON A.vas_order = B.vas_order AND A.prd_code = B.prd_code AND A.batch_no = B.batch_no    
   WHERE work_ord_status = 'IP'    
    
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

end
END
GO
