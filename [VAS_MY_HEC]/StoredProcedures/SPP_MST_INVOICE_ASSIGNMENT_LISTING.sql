SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec SPP_MST_ASSIGNMENT_LISTING @param=N'{"start_date":"1900-01-01","end_date":"2019-04-04","status":"ALL","page_index":0,"page_size":20,"search_term":"","export_ind":0}',@user_id=1  
--exec SPP_MST_ASSIGNMENT_LISTING @param=N'{"start_date":"1900-01-01","end_date":"2018-12-04","status":"N","page_index":0,"page_size":20,"search_term":"","export_ind":0}',@user_id=1  
CREATE PROCEDURE [dbo].[SPP_MST_INVOICE_ASSIGNMENT_LISTING]  
 @param nvarchar(max),  
 @user_id INT  
AS  
BEGIN  
 SET NOCOUNT ON;  
  
 DECLARE @start_date VARCHAR(20), @end_date VARCHAR(20), @status VARCHAR(20), @page_index INT, @page_size INT, @search_term NVARCHAR(100), @export_ind CHAR(1)  
 SET @start_date = (SELECT JSON_VALUE(@param, '$.start_date'))  
 SET @end_date = (SELECT JSON_VALUE(@param, '$.end_date'))  
 SET @status = (SELECT JSON_VALUE(@param, '$.status'))  
 SET @page_index = (SELECT JSON_VALUE(@param, '$.page_index'))  
 SET @page_size = (SELECT JSON_VALUE(@param, '$.page_size'))  
 SET @search_term = (SELECT JSON_VALUE(@param, '$.search_term'))  
 SET @export_ind = (SELECT JSON_VALUE(@param, '$.export_ind'))  
  
 IF @status = 'ALL' SET @status = NULL  
 ELSE IF @status = 'IP' SET @status = 'In Process'  
 ELSE IF @status = 'N' SET @status = 'New'  
 ELSE IF @status = 'OH' SET @status = 'On Hold'  
  
 CREATE TABLE #ASSIGNMENT_LIST_TEMP  
 (  
 elapsed_time varchar(100),  
 to_time varchar(100),  
 vas_order_date varchar(100),  
 vas_order_time varchar(50),  
 vas_order varchar(100),  
 inbound_doc varchar(50),  
 to_no varchar(50),  
 plant varchar(50),  
 client_code varchar(50),  
 client_name nvarchar(150),  
 prd_code varchar(50),  
 prd_desc nvarchar(150),  
 batch_no varchar(50),  
 expiry_date varchar(50),  
 qty varchar(50),  
 uom varchar(40),  
 status varchar(50),  
 temp_logger varchar(50),  
 work_ord_ref nvarchar(400),  
 prdgrp4 varchar(10),  
 work_ord_no nvarchar(100),  
 job_ref_no VARCHAR(50),  
 to_be_deducted_seconds INT DEFAULT 0,  
 total_on_hold_time INT DEFAULT 0,  
 total_final_seconds INT DEFAULT 0  
 )  
  
 -- Get user accessright to work order submodule (6) -------  
 DECLARE @accessright_id INT, @have_access_to_work_order CHAR(1) = 'Y'  
 SET @accessright_id = (SELECT accessright_id FROM VAS.dbo.TBL_ADM_USER_ACCESSRIGHT WITH(NOLOCK) WHERE user_id = @user_id)  
 IF (SELECT COUNT(*) FROM VAS.dbo.TBL_ADM_ACCESSRIGHT_DTL WITH(NOLOCK) WHERE accessright_id = @accessright_id AND submodule_id = '6' AND action_id = '1') = 0  
  SET @have_access_to_work_order = 'N'  
 ------------------------------------------------------------  

 SELECT DISTINCT inbound_doc INTO #DOC_NUM FROM VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER  
   
 INSERT INTO #ASSIGNMENT_LIST_TEMP (to_time, vas_order_date, vas_order_time, vas_order, inbound_doc, to_no, plant, client_code, client_name, prd_code, prd_desc, batch_no, expiry_date, qty, uom, status, temp_logger, work_ord_ref, prdgrp4, work_ord_no, job_ref_no)  
 SELECT CONVERT(VARCHAR(19), to_time, 121), CONVERT(VARCHAR(10), to_date, 121), CONVERT(TIME(0), to_time), A.vas_order, A.inbound_doc, A.to_no, A.plant,  
 supplier_code as client_code, supplier_name as client_name, A.prd_code, A.prd_desc, A.batch_no, CONVERT(VARCHAR(10), A.expiry_date, 121) as expiry_date, SUM(qty), A.uom, C.name as status, CASE temp_logger WHEN 'Y' THEN 'On' WHEN 'N' THEN '' WHEN 'R' THEN
 'Released' ELSE '' END,  
 CASE @have_access_to_work_order WHEN 'Y' THEN '<a href=# onclick="ShowDetails(''' + B.job_ref_no + ''')">' + B.work_ord_ref + '</a>' ELSE B.work_ord_ref END as work_ord_ref,   
 prdgrp4,  B.work_ord_ref, B.job_ref_no  
 FROM VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER A WITH(NOLOCK)  
 LEFT JOIN TBL_INVOICE_TXN_WORK_ORDER B WITH(NOLOCK) ON A.vas_order = B.vas_order AND A.prd_code = B.prd_code AND A.batch_no = B.batch_no --AND A.item_no = B.item_no  
 LEFT JOIN TBL_MST_DDL C WITH(NOLOCK) ON B.work_ord_status = C.code  
 INNER JOIN TBL_MST_PRODUCT D WITH(NOLOCK) ON A.prd_code = D.prd_code  
 WHERE CONVERT(VARCHAR(10), to_date, 121) BETWEEN CONVERT(VARCHAR(10), @start_date, 121) AND CONVERT(VARCHAR(10), @end_date, 121) AND A.plant <> 'MYHW' AND A.delete_flag IS NULL --exclude PPM SKU  
 GROUP BY A.to_time, A.to_date, A.inbound_doc, A.vas_order, A.to_no, A.prd_code, A.batch_no, A.plant, supplier_code, supplier_name, A.prd_desc, A.expiry_date, A.uom, C.name, temp_logger, B.job_ref_no, B.work_ord_ref, prdgrp4  
 UNION  
 SELECT CONVERT(VARCHAR(19), vas_order_date, 121), CONVERT(VARCHAR(10), vas_order_date, 121), CONVERT(TIME(0), vas_order_date) as vas_order_time, vas_order, inbound_doc, '' as to_no, plant,  
 supplier_code as client_code, supplier_name as client_name, A.prd_code, A.prd_desc, batch_no, CONVERT(VARCHAR(10), expiry_date, 121) as expiry_date, qty, uom, 'New' as status, '' as temp_logger, '' as work_ord_ref, prdgrp4, '' as work_ord_no, '' as job_ref_no  
 FROM VAS_INTEGRATION.dbo.VAS_INBOUND_ORDER A WITH(NOLOCK)  
 INNER JOIN TBL_MST_PRODUCT B WITH(NOLOCK) ON A.prd_code = B.prd_code  
 WHERE inbound_doc NOT IN (SELECT inbound_doc FROM #DOC_NUM) AND CONVERT(VARCHAR(10), vas_order_date, 121) BETWEEN CONVERT(VARCHAR(10), @start_date, 121) AND CONVERT(VARCHAR(10), @end_date, 121)  
 AND A.plant <> 'MYHW' AND A.delete_flag IS NULL  
  
 DROP TABLE #DOC_NUM  
  
 UPDATE #ASSIGNMENT_LIST_TEMP  
 SET status = 'On Hold'  
 WHERE temp_logger = 'On'  
  
 UPDATE #ASSIGNMENT_LIST_TEMP  
 SET status = 'New'  
 WHERE status IS NULL  
  
 SELECT job_ref_no, ISNULL(SUM(on_hold_time),0) as ttl_on_hold  
 INTO #ON_HOLD  
 FROM TBL_TXN_JOB_EVENT WITH(NOLOCK)  
 GROUP BY job_ref_no  
  
 UPDATE A  
 SET total_on_hold_time = ISNULL(B.ttl_on_hold, 0)  
 FROM #ASSIGNMENT_LIST_TEMP A  
 INNER JOIN #ON_HOLD B ON A.job_ref_no = B.job_ref_no  
  
 UPDATE A  
 SET to_be_deducted_seconds = ISNULL(( (SELECT COUNT(*) FROM TBL_MST_WEEKEND WITH(NOLOCK) WHERE date BETWEEN to_time AND GETDATE()) + (SELECT COUNT(*) FROM TBL_MST_PUBLIC_HOLIDAY WITH(NOLOCK) WHERE date BETWEEN to_time AND GETDATE()) ),0) * 24 * 60 * 60  
 FROM #ASSIGNMENT_LIST_TEMP A  
 WHERE status <> 'Closed'  
  
 UPDATE A  
 SET total_final_seconds = ISNULL((SELECT DATEDIFF(s, to_time, GETDATE())) - (to_be_deducted_seconds + total_on_hold_time),0)  
 FROM #ASSIGNMENT_LIST_TEMP A  
 WHERE status <> 'Closed'  
  
 UPDATE A  
 SET elapsed_time = CONVERT(VARCHAR(12), total_final_seconds /60 / 60 / 24) + ' D '  
       + CONVERT(VARCHAR(12), total_final_seconds / 60 / 60 % 24) + ' hr '  
       + CONVERT(VARCHAR(2), total_final_seconds / 60 % 60) + ' min '  
       --+ CONVERT(VARCHAR(2), total_final_seconds % 60) + ' sec ' --CONVERT(VARCHAR(19), ( DATEDIFF(s, created_date, GETDATE()) / 86400 )) + ' Days '+ CONVERT(VARCHAR(19), ( ( DATEDIFF(s, created_date, GETDATE()) % 86400 ) / 3600 )) + ' Hours '+ CONVERT(VARCHAR(19), ( ( ( DATEDIFF(s, created_date, GETDATE()) % 86400 ) % 3600 ) / 60 )) + ' Minutes '  
 FROM #ASSIGNMENT_LIST_TEMP A  
 WHERE to_no <> ''  
  
 UPDATE #ASSIGNMENT_LIST_TEMP  
 SET elapsed_time = ''  
 WHERE status = 'Closed'  
  
 IF @search_term <> '' OR (@status <> NULL OR @status <> '')  
 BEGIN  
  SELECT COUNT(1) as ttl_rows FROM #ASSIGNMENT_LIST_TEMP  --1  
  WHERE ( vas_order LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE vas_order END OR  
    inbound_doc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE inbound_doc END OR  
    to_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE to_no END OR  
    plant LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE plant END OR  
    client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR  
    client_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_code END OR  
    prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END OR  
    prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_desc END OR  
    prdgrp4 LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prdgrp4 END OR  
    batch_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE batch_no END OR  
    qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE qty END OR  
    uom LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE uom END OR  
    temp_logger LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE temp_logger END OR  
    work_ord_ref LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE work_ord_ref END)  
    AND ISNULL(status, '') = COALESCE(@status, ISNULL(status, ''))  
 END  
 ELSE  
 BEGIN  
  SELECT COUNT(1) as ttl_rows FROM #ASSIGNMENT_LIST_TEMP WHERE ISNULL(status, '') = COALESCE(@status, ISNULL(status, '')) --1  
 END  
  
 IF (@export_ind = '0')  
  SELECT * FROM #ASSIGNMENT_LIST_TEMP --2  
  WHERE (vas_order LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE vas_order END OR  
    inbound_doc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE inbound_doc END OR  
    to_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE to_no END OR  
    plant LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE plant END OR  
    client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR  
    client_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_code END OR  
    prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END OR  
    prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_desc END OR  
    prdgrp4 LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prdgrp4 END OR  
    batch_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE batch_no END OR  
    qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE qty END OR  
    uom LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE uom END OR  
    temp_logger LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE temp_logger END OR  
    work_ord_ref LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE work_ord_ref END)  
    AND ISNULL(status, '') = COALESCE(@status, ISNULL(status, ''))  
  ORDER BY vas_order_date DESC  
  OFFSET @page_index * @page_size ROWS  
  FETCH NEXT @page_size ROWS ONLY  
 ELSE IF (@export_ind = '1')  
  SELECT * FROM #ASSIGNMENT_LIST_TEMP --2  
  WHERE (vas_order LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE vas_order END OR  
    inbound_doc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE inbound_doc END OR  
    to_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE to_no END OR  
    plant LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE plant END OR  
    client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR  
    client_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_code END OR  
    prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END OR  
    prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_desc END OR  
    prdgrp4 LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prdgrp4 END OR  
    batch_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE batch_no END OR  
    qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE qty END OR  
    uom LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE uom END OR  
    temp_logger LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE temp_logger END OR  
    work_ord_ref LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE work_ord_ref END)  
    AND ISNULL(status, '') = COALESCE(@status, ISNULL(status, ''))  
  ORDER BY vas_order_date DESC  
  
 SELECT @export_ind AS export_ind --3  
  
 SELECT list_dtl_id, list_col_name as input_name, list_default_display_name as display_name  --4  
 FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_LISTING_DTL WITH(NOLOCK)  
 WHERE list_hdr_id IN (SELECT list_hdr_id FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_LISTING_HDR WITH(NOLOCK) WHERE page_code = 'ASSIGNMENT-SEARCH' --LIKE 'ASSIGNMENT%'  
 ) AND list_col_name in (SELECT name FROM tempdb.sys.columns where object_id = object_id('tempdb..#ASSIGNMENT_LIST_TEMP'))  
  
 DROP TABLE #ON_HOLD  
 DROP TABLE #ASSIGNMENT_LIST_TEMP  
END  
  
  
GO
