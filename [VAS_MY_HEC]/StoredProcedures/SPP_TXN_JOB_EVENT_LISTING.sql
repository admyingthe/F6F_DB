SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_TXN_JOB_EVENT_LISTING]  
 @param nvarchar(max),  
 @user_id INT  
AS  
BEGIN  
 SET NOCOUNT ON;  
  
 DECLARE @job_ref_no VARCHAR(50), @page_index INT, @page_size INT, @search_term NVARCHAR(100), @export_ind CHAR(1), @job_type char(1)
 SET @job_ref_no = (SELECT JSON_VALUE(@param, '$.job_ref_no'))  
 SET @job_type = left(@job_ref_no, 1)
 SET @page_index = (SELECT JSON_VALUE(@param, '$.page_index'))  
 SET @page_size = (SELECT JSON_VALUE(@param, '$.page_size'))  
 SET @search_term = (SELECT JSON_VALUE(@param, '$.search_term'))  
 SET @export_ind = (SELECT JSON_VALUE(@param, '$.export_ind'))  
   
 DECLARE @work_ord_ref NVARCHAR(100), @work_ord_status VARCHAR(50)  
 SET @work_ord_ref = CASE WHEN LEFT(@job_ref_no,1) = 'S' THEN (SELECT top 1 work_ord_ref FROM TBL_Subcon_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)
                          ELSE (SELECT work_ord_ref FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no) 
						  END
 SET @work_ord_status = CASE WHEN LEFT(@job_ref_no,1) = 'S' THEN  (SELECT top 1 work_ord_status FROM TBL_Subcon_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no) 
                            ELSE (SELECT work_ord_status FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no) 
							END
  
 -- Get all event_id that mapped to this user --  
 DECLARE @dtUserEvent TABLE(event_id VARCHAR(50))   
  
 INSERT INTO @dtUserEvent   
 SELECT event_id FROM VAS.dbo.TBL_ADM_USER_EVENT WITH(NOLOCK) WHERE user_id = @user_id  
  
 DECLARE @cntUserEvent INTEGER    
 SET @cntUserEvent = (SELECT COUNT(*) FROM @dtUserEvent)  
  
 IF @cntUserEvent = 0   
 INSERT INTO @dtUserEvent   
 SELECT ''  
 -- Get all event_id that mapped to this user --  
  
    CREATE TABLE #JOB_EVENT_TEMP  
 (  
 event_id varchar(50),  
 event_name nvarchar(100),  
 start_date nvarchar(50),  
 end_date nvarchar(50),  
 lead_time_day varchar(50),  
 lead_time_hours varchar(50),  
 lead_time_mins varchar(50),  
 issued_qty varchar(50),  
 completed_qty varchar(50),  
 damaged_qty varchar(50),  
 remarks nvarchar(max),  
 running_no varchar(10),  
 created_by nvarchar(200),  
 parent_running_no varchar(10),  
 sap_status CHAR(1),  
 sap_remarks NVARCHAR(250),  
 auto_ind CHAR(1),  
 sap_ind CHAR(1),  
 req_stock_ind CHAR(1),  
 email_ind CHAR(1),  
 confirm_stock_ind CHAR(1),  
 show_attachment_ind CHAR(1),  
 event_accessright CHAR(1)  
 )  
  
 INSERT INTO #JOB_EVENT_TEMP (event_id, event_name, start_date, end_date,   
 lead_time_day, lead_time_hours, lead_time_mins,   
 issued_qty, completed_qty, damaged_qty, remarks, running_no, parent_running_no, sap_status, sap_remarks, created_by,  
 auto_ind, sap_ind, req_stock_ind, confirm_stock_ind, email_ind, show_attachment_ind)  
 SELECT DISTINCT A.event_id, event_name, CONVERT(VARCHAR(19), start_date, 121), CONVERT(VARCHAR(19), end_date, 121),   
 CASE WHEN CAST((DATEDIFF(second, start_date, end_date) - on_hold_time) / 60 / 60 / 24 % 7 AS NVARCHAR(50)) IS NULL THEN CAST(DATEDIFF(second, start_date, end_date) / 60 / 60 / 24 % 7 AS NVARCHAR(50)) ELSE CAST((DATEDIFF(second, start_date, end_date) - on_hold_time) / 60 / 60 / 24 % 7 AS NVARCHAR(50)) END,  
 CASE WHEN CAST((DATEDIFF(second, start_date, end_date) - on_hold_time) / 60 / 60 % 24  AS NVARCHAR(50)) IS NULL THEN CAST(DATEDIFF(second, start_date, end_date) / 60 / 60 % 24  AS NVARCHAR(50)) ELSE CAST((DATEDIFF(second, start_date, end_date) - on_hold_time) / 60 / 60 % 24  AS NVARCHAR(50)) END,   
 CASE WHEN CAST((DATEDIFF(second, start_date, end_date) - on_hold_time) / 60 % 60 AS NVARCHAR(50)) IS NULL THEN CAST(DATEDIFF(second, start_date, end_date) / 60 % 60 AS NVARCHAR(50)) ELSE CAST((DATEDIFF(second, start_date, end_date) - on_hold_time) / 60 %60 AS NVARCHAR(50)) END,   
 A.issued_qty, completed_qty, damaged_qty, A.remarks, running_no, parent_running_no, ISNULL(C.status, ''), CASE WHEN ISNULL(C.remarks,'') = '' THEN ISNULL(C.to_no,'') ELSE ISNULL(C.remarks, '') END, D.user_name,  
 auto_ind, sap_ind, req_stock_ind, confirm_stock_ind, email_ind, show_attachment_ind  
 FROM TBL_TXN_JOB_EVENT A WITH(NOLOCK)  
 LEFT JOIN TBL_MST_EVENT_CONFIGURATION_HDR B WITH(NOLOCK) ON A.event_id = B.event_id and wo_type_id = @job_type
 LEFT JOIN VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER_SAP C WITH(NOLOCK) ON A.running_no = C.requirement_no AND C.country_code = 'MY'  
 LEFT JOIN VAS.dbo.TBL_ADM_USER D WITH(NOLOCK) ON A.creator_user_id = D.user_id  
 WHERE job_ref_no = @job_ref_no
  
 UPDATE #JOB_EVENT_TEMP  
 SET confirm_stock_ind = ''  
 WHERE confirm_stock_ind = 'Y' AND sap_status = '' AND running_no IN (SELECT parent_running_no FROM #JOB_EVENT_TEMP)  
  
 SELECT IDENTITY(INT, 1, 1) AS row_num, running_no, event_id, auto_ind INTO #TEMP_AUTO FROM #JOB_EVENT_TEMP WHERE auto_ind = 'Y' and event_id NOT IN ('00','10')  
  
 DECLARE @current_running_no VARCHAR(10), @count_auto INT, @i INT = 1, @current_event_id INT, @precedence INT, @latest_event INT, @auto_ind CHAR(1)  
 SET @count_auto = (SELECT COUNT(*) FROM #TEMP_AUTO)  
 WHILE @i <= @count_auto  
 BEGIN  
  SELECT @current_running_no = running_no, @current_event_id = event_id, @auto_ind = auto_ind FROM #TEMP_AUTO WHERE row_num = @i  
  WHILE @auto_ind = 'Y'  
  BEGIN  
   SET @current_event_id = (SELECT precedence FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK) WHERE event_id = @current_event_id and wo_type_id = @job_type)  
   SET @auto_ind = (SELECT auto_ind FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK) WHERE event_id = @current_event_id and wo_type_id = @job_type)  
  END  
  
  -- event_id exists in @dtUserEvent or @dtUserEvent = ''  
   UPDATE #JOB_EVENT_TEMP  
   SET event_accessright = 'Y'  
   WHERE running_no = @current_running_no  
   AND (@cntUserEvent = 0 OR @current_event_id IN (SELECT event_id FROM @dtUserEvent))  
  
  SET @i = @i + 1  
 END  
   
 DROP TABLE #TEMP_AUTO  
  
 UPDATE #JOB_EVENT_TEMP  
 SET event_accessright = 'Y'  
 WHERE event_accessright IS NULL  
 AND (@cntUserEvent = 0 OR event_id IN (SELECT event_id FROM @dtUserEvent))  

 If(LEFT(@job_ref_no,1) = 'S')
	BEGIN

	declare @event_id varchar(2), @main_status varchar(2), @main_indicator varchar(2), @finalStatus varchar(2), @remarks varchar(MAX)

	update	D
	set		D.sap_remarks = A.remarks,
			D.sap_status = case 
			when (A.status = 'P' and A.process_ind = 'S') then 'S'
			when (A.status = 'S' and A.process_ind = 'S') then 'R'
			when (A.status = 'E' and A.process_ind = 'S') then 'E'
			end
	from	VAS_INTEGRATION.dbo.VAS_SUBCON_INBOUND_ORDER A
			inner join
			VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER_SAP B
	on		A.running_no = B.requirement_no
			inner join
			TBL_TXN_JOB_EVENT C
	on		A.running_no = C.running_no
			inner join
			#JOB_EVENT_TEMP D
	on		A.running_no = D.running_no
	where	C.job_ref_no= @job_ref_no

	END

 IF @search_term <> ''  
 BEGIN  
  SELECT COUNT(1) as ttl_rows FROM #JOB_EVENT_TEMP --1  
  WHERE ( event_id LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE event_id END OR  
    event_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE event_name END OR  
    start_date LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE start_date END OR  
    end_date LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE end_date END OR  
    lead_time_day LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE lead_time_day END OR  
    lead_time_hours LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE lead_time_hours END OR  
    lead_time_mins LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE lead_time_mins END OR  
    issued_qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE issued_qty END OR  
    completed_qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE completed_qty END OR  
    damaged_qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE damaged_qty END OR  
    remarks LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE remarks END OR  
    running_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE running_no END OR  
    sap_status LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE sap_status END OR  
    sap_remarks LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE sap_remarks END)  
 END  
 ELSE  
 BEGIN  
  SELECT COUNT(1) as ttl_rows FROM #JOB_EVENT_TEMP --1  
    
 END  
 IF (@export_ind = '0')  
  SELECT * FROM #JOB_EVENT_TEMP --2  
  WHERE (event_id LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE event_id END OR  
    event_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE event_name END OR  
    start_date LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE start_date END OR  
    end_date LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE end_date END OR  
    lead_time_day LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE lead_time_day END OR  
    lead_time_hours LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE lead_time_hours END OR  
    lead_time_mins LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE lead_time_mins END OR  
    issued_qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE issued_qty END OR  
    completed_qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE completed_qty END OR  
    damaged_qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE damaged_qty END OR  
    remarks LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE remarks END OR  
    running_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE running_no END OR  
    sap_status LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE sap_status END OR  
    sap_remarks LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE sap_remarks END)  
  ORDER BY start_date, event_id  
  OFFSET @page_index * @page_size ROWS  
  FETCH NEXT @page_size ROWS ONLY  
 ELSE IF (@export_ind = '1')  
  SELECT * FROM #JOB_EVENT_TEMP --2  
  WHERE (event_id LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE event_id END OR  
    event_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE event_name END OR  
    start_date LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE start_date END OR  
    end_date LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE end_date END OR  
    lead_time_day LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE lead_time_day END OR  
    lead_time_hours LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE lead_time_hours END OR  
    lead_time_mins LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE lead_time_mins END OR  
    issued_qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE issued_qty END OR  
    completed_qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE completed_qty END OR  
    damaged_qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE damaged_qty END OR  
    remarks LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE remarks END OR  
    running_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE running_no END OR  
    sap_status LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE sap_status END OR  
    sap_remarks LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE sap_remarks END)  
  ORDER BY start_date, event_id  
  
 SELECT @export_ind AS export_ind --3  
  
 /** Job Event Header Information **/  

If(LEFT(@job_ref_no,1) = 'S')
BEGIN

 SELECT @job_ref_no as job_ref_no, @work_ord_ref as work_ord_ref,   
 CASE @work_ord_status WHEN 'IP' THEN 'In Process' WHEN 'OH' THEN 'On Hold' WHEN 'CCL' THEN 'Cancelled' + ' (' + cancellation_reason + ')' WHEN 'C' THEN 'Closed' END as work_ord_status  
 INTO #JOB_EVENT_HDR_SUBCON  
 FROM TBL_Subcon_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no --4  

 UPDATE A  
 SET work_ord_status = (SELECT TOP 1 work_ord_status + ' (' + on_hold_reason + ' - ' + on_hold_remarks + ')' FROM TBL_TXN_WORK_ORDER_ACTION_LOG B WITH(NOLOCK) WHERE job_no = @job_ref_no ORDER BY on_hold_date DESC)  
 FROM #JOB_EVENT_HDR_SUBCON A WITH(NOLOCK)  
 WHERE work_ord_status = 'On Hold'  
   
 SELECT * FROM #JOB_EVENT_HDR_SUBCON  
 DROP TABLE #JOB_EVENT_HDR_SUBCON 

END
ELSE If(LEFT(@job_ref_no,1) = 'P')
BEGIN

 SELECT @job_ref_no as job_ref_no, @work_ord_ref as work_ord_ref,   
 CASE @work_ord_status WHEN 'IP' THEN 'In Process' WHEN 'OH' THEN 'On Hold' WHEN 'CCL' THEN 'Cancelled' + ' (' + cancellation_reason + ')' WHEN 'C' THEN 'Closed' END as work_ord_status  
 INTO #JOB_EVENT_HDR_SIA  
 FROM TBL_SIA_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no --4  

 UPDATE A  
 SET work_ord_status = (SELECT TOP 1 work_ord_status + ' (' + on_hold_reason + ' - ' + on_hold_remarks + ')' FROM TBL_TXN_WORK_ORDER_ACTION_LOG B WITH(NOLOCK) WHERE job_no = @job_ref_no ORDER BY on_hold_date DESC)  
 FROM #JOB_EVENT_HDR_SIA A WITH(NOLOCK)  
 WHERE work_ord_status = 'On Hold'  
   
 SELECT * FROM #JOB_EVENT_HDR_SIA  
 DROP TABLE #JOB_EVENT_HDR_SIA

END
ELSE If(LEFT(@job_ref_no,1) = 'C')
BEGIN

 SELECT @job_ref_no as job_ref_no, @work_ord_ref as work_ord_ref,   
 CASE @work_ord_status WHEN 'IP' THEN 'In Process' WHEN 'OH' THEN 'On Hold' WHEN 'CCL' THEN 'Cancelled' + ' (' + cancellation_reason + ')' WHEN 'C' THEN 'Closed' END as work_ord_status  
 INTO #JOB_EVENT_HDR_INVOICE  
 FROM TBL_INVOICE_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no --4  

 UPDATE A  
 SET work_ord_status = (SELECT TOP 1 work_ord_status + ' (' + on_hold_reason + ' - ' + on_hold_remarks + ')' FROM TBL_TXN_WORK_ORDER_ACTION_LOG B WITH(NOLOCK) WHERE job_no = @job_ref_no ORDER BY on_hold_date DESC)  
 FROM #JOB_EVENT_HDR_INVOICE A WITH(NOLOCK)  
 WHERE work_ord_status = 'On Hold'  
   
 SELECT * FROM #JOB_EVENT_HDR_INVOICE  
 DROP TABLE #JOB_EVENT_HDR_INVOICE

END
ELSE
BEGIN
 SELECT @job_ref_no as job_ref_no, @work_ord_ref as work_ord_ref,   
 CASE @work_ord_status WHEN 'IP' THEN 'In Process' WHEN 'OH' THEN 'On Hold' WHEN 'CCL' THEN 'Cancelled' + ' (' + cancellation_reason + ')' WHEN 'C' THEN 'Closed' END as work_ord_status  
 INTO #JOB_EVENT_HDR  
 FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no --4  


 UPDATE A  
 SET work_ord_status = (SELECT TOP 1 work_ord_status + ' (' + on_hold_reason + ' - ' + on_hold_remarks + ')' FROM TBL_TXN_WORK_ORDER_ACTION_LOG B WITH(NOLOCK) WHERE job_no = @job_ref_no ORDER BY on_hold_date DESC)  
 FROM #JOB_EVENT_HDR A WITH(NOLOCK)  
 WHERE work_ord_status = 'On Hold'  

 
 SELECT * FROM #JOB_EVENT_HDR  
 DROP TABLE #JOB_EVENT_HDR 

END
 
  
 
 /** Job Event Header Information **/  
  
 SELECT list_dtl_id, list_col_name as input_name, list_default_display_name as display_name  --5  
 FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_LISTING_DTL WITH(NOLOCK)  
 WHERE list_hdr_id IN (SELECT list_hdr_id FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_LISTING_HDR WITH(NOLOCK) WHERE page_code = 'JOB-EVENT-SEARCH-NEW') AND list_col_name in (SELECT name FROM tempdb.sys.columns where object_id = object_id('tempdb..#JOB_EVENT_TEMP'))
 DROP TABLE #JOB_EVENT_TEMP  
  
END

GO
