SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 --exec [SPP_MST_Subcon_ASSIGNMENT_LISTING] @param=N'{"start_date":"1900-01-01","end_date":"2022-01-03","status":"N","page_index":0,"page_size":20,"search_term":"8105092830","export_ind":0}',@user_id=1                    
          
CREATE PROCEDURE [dbo].[SPP_MST_Subcon_ASSIGNMENT_LISTING]                    
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
 Subcon_order_date varchar(100),                    
 Subcon_order_time varchar(50),                    
 Subcon_Doc varchar(100),                    
 Subcon_Item_No varchar(50),              
 Component varchar(100),            
 Subcon_Outbound_PO varchar(50),                    
 to_no varchar(50),                    
 plant varchar(50),                    
 client_code varchar(50),                    
 client_name nvarchar(150),                    
 prd_code varchar(50),                    
 prd_desc nvarchar(150),                    
 Subcon_SWI_No nvarchar(150),                    
 Subcon_Job_No nvarchar(150),                    
 qty varchar(50),                    
 uom varchar(40),                    
 status varchar(50),               
 batch_no nvarchar(50),              
 expiry_date nvarchar(50),    
 remark nvarchar(max),
 work_ord_ref nvarchar(400),                  
 to_be_deducted_seconds INT DEFAULT 0,                    
 total_on_hold_time INT DEFAULT 0,                    
 total_final_seconds BIGINT DEFAULT 0,
 current_event INT,
 job_ref_no varchar(100)
 )                    
                    
 -- Get user accessright to work order submodule (6) -------                    
 DECLARE @accessright_id INT, @have_access_to_work_order CHAR(1) = 'Y'                    
 SET @accessright_id = (SELECT accessright_id FROM VASDEV.dbo.TBL_ADM_USER_ACCESSRIGHT WITH(NOLOCK) WHERE user_id = @user_id)                    
 IF (SELECT COUNT(*) FROM VASDEV.dbo.TBL_ADM_ACCESSRIGHT_DTL WITH(NOLOCK) WHERE accessright_id = @accessright_id AND submodule_id = '6' AND action_id = '1') = 0                    
  SET @have_access_to_work_order = 'N'                    
 ------------------------------------------------------------                    
                    
INSERT INTO #ASSIGNMENT_LIST_TEMP         
(to_time, Subcon_order_date, Subcon_order_time, subcon_doc, Subcon_Item_No,component,Subcon_Outbound_PO,to_no, plant, client_code, client_name, prd_code, prd_desc,Subcon_SWI_No,qty, uom,         
status,batch_no,expiry_date,remark,work_ord_ref,Subcon_Job_No,current_event, job_ref_no)                    
SELECT 
cast(CONVERT(VARCHAR(10), to_date, 121) as varchar)+' '+cast(CONVERT(TIME(0), to_time) as varchar),
--CONVERT(VARCHAR(19), to_time, 121) to_time,                     
       CONVERT(VARCHAR(10), to_date, 121) to_date,                     
    CONVERT(TIME(0), to_time),                     
    A.Subcon_Doc, Subcon_Item_No, component,outbound_doc,                   
    A.to_no,                     
    A.plant,                    
   supplier_code as client_code,            
   supplier_name as client_name,                     
   A.prd_code,                     
   A.prd_desc,          
   SWI_No,   
   qty,
   --SUM(qty),       
   A.uom,                     
   --CASE WHEN B.work_ord_ref IS NOT NULL THEN 'In progress' ELSE NULL END as status,               
   --C.name as status,
   case when A.Subcon_Job_No is NULL then NULL else C.name end as status,
   A.batch_no,              
   Convert(varchar(10),A.expiry_date,121),  
   A.remark,
   B.work_ord_ref,
   '<a href=# onclick="ShowDetails(''' + job_ref_no + ''')">' + B.work_ord_ref + '</a>' as work_ord_ref,
   B.current_event,
   A.Subcon_Job_No
   --(Select TOP 1 job_ref_no FROM TBL_Subcon_TXN_WORK_ORDER WITH(NOLOCK) WHERE Subcon_WI_No = A.SWI_No)                    
 FROM VASDEV_INTEGRATION.dbo.VAS_Subcon_TRANSFER_ORDER A WITH(NOLOCK)                    
 LEFT JOIN TBL_Subcon_TXN_WORK_ORDER B WITH(NOLOCK) ON  A.prd_code = B.prd_code AND A.batch_no = B.batch_no and  A.SWI_No = B.subcon_WI_no and A.Subcon_Job_No=B.job_ref_no--  A.SWI_No = B.subcon_WI_no AND A.item_no = B.item_no --                    
 LEFT JOIN TBL_MST_DDL C WITH(NOLOCK) ON B.work_ord_status = C.code                    
 INNER JOIN TBL_MST_PRODUCT D WITH(NOLOCK) ON A.prd_code = D.prd_code                    
 WHERE CONVERT(VARCHAR(10), to_date, 121) BETWEEN CONVERT(VARCHAR(10), @start_date, 121)                    
 AND CONVERT(VARCHAR(10), @end_date, 121) AND A.plant <> 'MYHW' AND A.delete_flag IS NULL --exclude PPM SKU                    
 GROUP BY A.to_time, A.to_date, A.Subcon_Doc,A.component,Subcon_Item_No,outbound_doc, A.to_no, A.prd_code,SWI_No, A.plant, supplier_code, supplier_name, A.prd_desc, A.uom,qty,C.name, B.job_ref_no, B.work_ord_ref, prdgrp4  ,A.batch_no,A.expiry_date,A.remark,B.current_event, A.Subcon_Job_No           
              
 --   UPDATE #ASSIGNMENT_LIST_TEMP                    
 --SET status = 'On Hold'                    
 --WHERE temp_logger = 'On'                    
                    
 UPDATE #ASSIGNMENT_LIST_TEMP                    
 SET status = 'New'                    
 WHERE job_ref_no is null
 and status IS NULL  
                    
 SELECT job_ref_no, ISNULL(SUM(on_hold_time),0) as ttl_on_hold                    
 INTO #ON_HOLD                    
 FROM TBL_TXN_JOB_EVENT WITH(NOLOCK)                    
 GROUP BY job_ref_no                    
                    
 UPDATE A                    
 SET total_on_hold_time = ISNULL(B.ttl_on_hold, 0)                    
 FROM #ASSIGNMENT_LIST_TEMP A                    
 INNER JOIN #ON_HOLD B ON A.Subcon_Job_No = B.job_ref_no                    
                    
 UPDATE A                    
 SET to_be_deducted_seconds = ISNULL(( (SELECT COUNT(*) FROM TBL_MST_WEEKEND WITH(NOLOCK) WHERE date BETWEEN to_time AND GETDATE()) + (SELECT COUNT(*) FROM TBL_MST_PUBLIC_HOLIDAY WITH(NOLOCK) WHERE date BETWEEN to_time AND GETDATE()) ),0) * 24 * 60 * 60  
 FROM #ASSIGNMENT_LIST_TEMP A                    
 WHERE status <> 'Closed'                    
                    
 UPDATE A                    
 SET total_final_seconds = ISNULL((SELECT DATEDIFF_BIG(s, to_time, GETDATE())) - (to_be_deducted_seconds + total_on_hold_time),0)                    
 FROM #ASSIGNMENT_LIST_TEMP A                    
 WHERE status <> 'Closed'                    
                    
 UPDATE A                    
 SET elapsed_time = CONVERT(VARCHAR(12), total_final_seconds /60 / 60 / 24) + ' D '  + CONVERT(VARCHAR(12), total_final_seconds / 60 / 60 % 24) + ' hr '  + CONVERT(VARCHAR(2), total_final_seconds / 60 % 60) + ' min '                    
       --+ CONVERT(VARCHAR(2), total_final_seconds % 60) + ' sec ' --CONVERT(VARCHAR(19), ( DATEDIFF(s, created_date, GETDATE()) / 86400 )) + ' Days '+ CONVERT(VARCHAR(19), ( ( DATEDIFF(s, created_date, GETDATE()) % 86400 ) / 3600 )) + ' Hours '+ CONVERT(VARCHAR(19), ( ( ( DATEDIFF(s, created_date, GETDATE()) % 86400 ) % 3600 ) / 60 )) + ' Minutes '                    
 FROM #ASSIGNMENT_LIST_TEMP A                    
 WHERE to_no <> ''                    
                    
 UPDATE #ASSIGNMENT_LIST_TEMP                    
 SET elapsed_time = ''                    
 WHERE status = 'Closed'                    
                    
                     
 IF @search_term <> '' OR (@status <> NULL OR @status <> '')                    
 BEGIN                    
  SELECT COUNT(1) as ttl_rows FROM #ASSIGNMENT_LIST_TEMP  --1                    
  WHERE (                    
    to_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE to_no END OR                    
    plant LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE plant END OR                    
    client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR                    
    client_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_code END OR                    
    prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END OR                    
    prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_desc END OR                    
    qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE qty END OR                    
    uom LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE uom END OR
	subcon_Doc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE Subcon_Doc END OR
	Component LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE Component END OR
	Subcon_Outbound_PO LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE Subcon_Outbound_PO END OR
	Subcon_SWI_No LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE Subcon_SWI_No END OR
	batch_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE batch_no END
    )                    
    AND ISNULL(status, '') = COALESCE(@status, ISNULL(status, ''))                    
 END                    
 ELSE                    
 BEGIN                    
  SELECT COUNT(1) as ttl_rows FROM #ASSIGNMENT_LIST_TEMP WHERE ISNULL(status, '') = COALESCE(@status, ISNULL(status, '')) --1                    
END                    
                    
 IF (@export_ind = '0')                    
  SELECT * FROM #ASSIGNMENT_LIST_TEMP --2                    
  WHERE (                    
    to_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE to_no END OR                    
    plant LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE plant END OR                  
    client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR                    
    client_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_code END OR                    
    prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END OR                    
    prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_desc END OR                    
    qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE qty END OR                    
    uom LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE uom END OR
	subcon_Doc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE Subcon_Doc END OR
	Component LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE Component END OR
	Subcon_Outbound_PO LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE Subcon_Outbound_PO END OR
	Subcon_SWI_No LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE Subcon_SWI_No END OR
	batch_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE batch_no END
    )                    
    AND ISNULL(status, '') = COALESCE(@status, ISNULL(status, ''))                    
  ORDER BY 1 DESC                    
  OFFSET @page_index * @page_size ROWS                    
  FETCH NEXT @page_size ROWS ONLY                    
 ELSE IF (@export_ind = '1')                    
  SELECT * FROM #ASSIGNMENT_LIST_TEMP --2                    
  WHERE (to_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE to_no END OR                    
    plant LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE plant END OR                    
    client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR                    
    client_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_code END OR                    
    prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END OR                    
    prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_desc END OR                    
    qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE qty END OR                    
    uom LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE uom END OR
	subcon_Doc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE Subcon_Doc END OR
	Component LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE Component END OR
	Subcon_Outbound_PO LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE Subcon_Outbound_PO END OR
	Subcon_SWI_No LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE Subcon_SWI_No END OR
	batch_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE batch_no END
    )                    
    AND ISNULL(status, '') = COALESCE(@status, ISNULL(status, ''))        
  ORDER BY 1 DESC                    
                    
 SELECT @export_ind AS export_ind                    
                    
 SELECT list_dtl_id, list_col_name as input_name, list_default_display_name as display_name  --4                    
 FROM VASDEV.dbo.TBL_ADM_CONFIG_PAGE_LISTING_DTL WITH(NOLOCK)                    
 WHERE list_hdr_id         
 IN (SELECT list_hdr_id FROM VASDEV.dbo.TBL_ADM_CONFIG_PAGE_LISTING_HDR WITH(NOLOCK) WHERE page_code ='SUBCON-ASSIGNMENT-SEARCH')        
 AND list_col_name in (SELECT name FROM tempdb.sys.columns where object_id = object_id('tempdb..#ASSIGNMENT_LIST_TEMP'))                  
        
	/***** Audit Trail *****/
	SELECT TOP 10 action, B.user_name as action_by, CONVERT(VARCHAR(20), action_date, 121) as action_date  --5--
	FROM TBL_ADM_AUDIT_TRAIL A WITH(NOLOCK)
	INNER JOIN VASDEV.dbo.TBL_ADM_USER B WITH(NOLOCK) ON A.action_by = B.user_id
	WHERE module = 'Subcon Assignment List(Update BatchNo/ExpiryDate)' 
	ORDER BY action_date DESC
	/***********************/		             
 DROP TABLE #ON_HOLD  
 DROP TABLE #ASSIGNMENT_LIST_TEMP                    
                    
END 
GO
