SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CHOI CHEE KIEN
-- Create date: 13-04-2023
-- Description:	Combined Assignment List (VAS ORDER AND SUBCON ORDER)
-- =============================================

--exec [SPP_MST_COMBINED_ASSIGNMENT_LISTING] @param=N'{"start_date":"2023-06-01","end_date":"2023-06-09","status":"N","wo_type":"Redressing","page_index":0,"page_size":20,"search_term":"","export_ind":0}', @user_id=N'8032'

CREATE PROCEDURE [dbo].[SPP_MST_COMBINED_ASSIGNMENT_LISTING]  
	@param nvarchar(max),  
	@user_id INT  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @start_date VARCHAR(20), @end_date VARCHAR(20), @status VARCHAR(20), @wo_type varchar(50), @page_index INT, @page_size INT, @search_term NVARCHAR(100), @export_ind CHAR(1)  
 SET @start_date = (SELECT JSON_VALUE(@param, '$.start_date'))  
 SET @end_date = (SELECT JSON_VALUE(@param, '$.end_date'))  
 SET @status = (SELECT JSON_VALUE(@param, '$.status'))  
 SET @wo_type = (SELECT JSON_VALUE(@param, '$.wo_type'))
 SET @page_index = (SELECT JSON_VALUE(@param, '$.page_index'))  
 SET @page_size = (SELECT JSON_VALUE(@param, '$.page_size'))  
 SET @search_term = (SELECT JSON_VALUE(@param, '$.search_term'))  
 SET @export_ind = (SELECT JSON_VALUE(@param, '$.export_ind'))  
 
 IF @status = 'ALL' SET @status = NULL  
 ELSE SET @status = (SELECT name from TBL_MST_DDL where code = @status and ddl_code = 'ddlAssignmentStatus' and delete_flag = 0)
  
 CREATE TABLE #ASSIGNMENT_LIST_TEMP  
 (  
 type varchar(50),
 elapsed_time varchar(100),  
 to_time varchar(100),  
 vas_order_date varchar(100),  
 vas_order_time varchar(50),  
 [vas_order] varchar(100),  
 Subcon_Item_No varchar(50),              
 component varchar(100),
 inbound_doc varchar(50),  
 to_no varchar(50),  
 plant varchar(50),  
 client_code varchar(50),  
 client_name nvarchar(150),  
 prd_code varchar(50),  
 prd_desc nvarchar(150), 
 Subcon_SWI_No nvarchar(150),                    
 work_ord_ref_subcon_job_no nvarchar(400), 
 qty varchar(50),  
 uom varchar(40),  
 status varchar(50),  
 temp_logger varchar(50),  
 batch_no varchar(50),  
 expiry_date varchar(50),
 job_ref_no VARCHAR(50), 
 work_ord_ref nvarchar(400),  
 to_be_deducted_seconds INT DEFAULT 0,  
 total_on_hold_time INT DEFAULT 0,  
 total_final_seconds INT DEFAULT 0,
 su_no varchar(20),
 arr_date varchar(50),
 arr_time time,
 bin_no varchar(20)
 )  
  
 -- Get user accessright to work order submodule (6) -------  
 DECLARE @accessright_id INT, @have_access_to_work_order CHAR(1) = 'Y'  
 SET @accessright_id = (SELECT accessright_id FROM VAS.dbo.TBL_ADM_USER_ACCESSRIGHT WITH(NOLOCK) WHERE user_id = @user_id)  
 IF (SELECT COUNT(*) FROM VAS.dbo.TBL_ADM_ACCESSRIGHT_DTL WITH(NOLOCK) WHERE accessright_id = @accessright_id AND submodule_id = '6' AND action_id = '1') = 0  
  SET @have_access_to_work_order = 'N'  
 ------------------------------------------------------------  
  
 SELECT DISTINCT inbound_doc INTO #DOC_NUM FROM VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER  
   
 IF (@wo_type = 'Redressing')
 begin
	 INSERT INTO #ASSIGNMENT_LIST_TEMP (type, to_time, vas_order_date, vas_order_time, vas_order, subcon_item_no, component, inbound_doc, to_no, plant, client_code,
	 client_name, prd_code, prd_desc, Subcon_SWI_No, work_ord_ref, qty, uom, status, temp_logger, batch_no, expiry_date, job_ref_no, work_ord_ref_subcon_job_no, su_no, arr_date, arr_time, bin_no
	 )

	 SELECT 'Redressing', CONVERT(VARCHAR(19), to_time, 121), CONVERT(VARCHAR(10), to_date, 121), CONVERT(TIME(0), to_time), A.vas_order, '', '', 
	 A.inbound_doc, A.to_no, A.plant, A.supplier_code as client_code, A.supplier_name as client_name, A.prd_code, A.prd_desc, '', 
	 CASE @have_access_to_work_order WHEN 'Y' THEN '<a href=# onclick="ShowDetails(''' + B.job_ref_no + ''')">' + B.work_ord_ref + '</a>' 
	 ELSE B.work_ord_ref END as work_ord_ref, 
	 SUM(A.qty), A.uom,
	 CASE WHEN temp_logger = 'Y' THEN 'On Hold'
	 WHEN C.name IS NULL THEN 'New'
	 ELSE C.name
	 END AS status,
	 CASE temp_logger WHEN 'Y' THEN 'On' WHEN 'N' THEN '' WHEN 'R' THEN 'Released' ELSE '' END,
	 A.batch_no, CONVERT(VARCHAR(10), A.expiry_date, 121) as expiry_date, B.job_ref_no, B.work_ord_ref as 'work_ord_ref_subcon_job_no', A.su_no, Convert(varchar(10), E.arr_date, 121), E.arr_time, A.dsto_stg_bin
	 FROM VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER A WITH(NOLOCK)  
	 LEFT JOIN TBL_TXN_WORK_ORDER B WITH(NOLOCK) ON A.vas_order = B.vas_order AND A.prd_code = B.prd_code AND A.batch_no = B.batch_no --AND A.item_no = B.item_no  
	 LEFT JOIN TBL_MST_DDL C WITH(NOLOCK) ON B.work_ord_status = C.code AND C.ddl_code = 'ddlAssignmentStatus' 
	 INNER JOIN TBL_MST_PRODUCT D WITH(NOLOCK) ON A.prd_code = D.prd_code  
	 LEFT JOIN VAS_INTEGRATION.dbo.VAS_INBOUND_ORDER E WITH(NOLOCK) ON  A.inbound_doc = E.inbound_doc AND A.vas_order = E.vas_order AND A.prd_code = E.prd_code AND A.batch_no = E.batch_no
	 WHERE CONVERT(VARCHAR(10), to_date, 121) BETWEEN CONVERT(VARCHAR(10), @start_date, 121) AND CONVERT(VARCHAR(10), @end_date, 121) AND A.plant <> 'MYHW' 
	 AND A.delete_flag IS NULL --exclude PPM SKU  
	 GROUP BY A.to_time, A.to_date, A.inbound_doc, A.vas_order, A.to_no, A.prd_code, A.batch_no, A.plant, A.supplier_code, A.supplier_name, A.prd_desc, 
	 A.expiry_date, A.uom, C.name, temp_logger, B.job_ref_no, B.work_ord_ref, prdgrp4, A.su_no, E.arr_date, E.arr_time, A.dsto_stg_bin

	 UNION  

	 SELECT 'Redressing', CONVERT(VARCHAR(19), A.vas_order_date, 121), CONVERT(VARCHAR(10), A.vas_order_date, 121), 
	 CONVERT(TIME(0), A.vas_order_date) as order_time, A.vas_order, '', '', A.inbound_doc, '' as to_no, A.plant, A.supplier_code as client_code, A.supplier_name as client_name, 
	 A.prd_code, A.prd_desc, '' as Subcon_SWI_No, '' as work_ord_ref_subcon_job_no, A.qty, A.uom, 'New' as status, '' as temp_logger, A.batch_no, CONVERT(VARCHAR(10), A.expiry_date, 121) as expiry_date,
	 '' as job_ref_no, '' as work_ord_ref, E.su_no, Convert(varchar(10), A.arr_date, 121), A.arr_time, E.dsto_stg_bin
	 FROM VAS_INTEGRATION.dbo.VAS_INBOUND_ORDER A WITH(NOLOCK)  
	 INNER JOIN TBL_MST_PRODUCT B WITH(NOLOCK) ON A.prd_code = B.prd_code  
	 LEFT JOIN VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER E WITH(NOLOCK) ON  A.inbound_doc = E.inbound_doc AND A.vas_order = E.vas_order AND A.prd_code = E.prd_code AND A.batch_no = E.batch_no
	 WHERE A.inbound_doc NOT IN (SELECT inbound_doc FROM #DOC_NUM) AND CONVERT(VARCHAR(10), A.vas_order_date, 121) BETWEEN CONVERT(VARCHAR(10), @start_date, 121) 
	 AND CONVERT(VARCHAR(10), @end_date, 121)  
	 AND A.plant <> 'MYHW' AND A.delete_flag IS NULL 
 end

 ELSE IF (@wo_type = 'Subcon')
 begin
	INSERT INTO #ASSIGNMENT_LIST_TEMP (type, to_time, vas_order_date, vas_order_time, vas_order, subcon_item_no, component, inbound_doc, to_no, plant, client_code,
	 client_name, prd_code, prd_desc, Subcon_SWI_No, work_ord_ref, qty, uom, status, temp_logger, batch_no, expiry_date, job_ref_no, work_ord_ref_subcon_job_no, su_no, arr_date, arr_time, bin_no
	 )
	 SELECT 'Subcon',
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
	   '<a href=# onclick="ShowDetails(''' + job_ref_no + ''')">' + B.work_ord_ref + '</a>' as work_ord_ref,
	   qty,
	   --SUM(qty),       
	   A.uom,                     
	   --CASE WHEN B.work_ord_ref IS NOT NULL THEN 'In progress' ELSE NULL END as status,               
	   --C.name as status,
	   case when A.Subcon_Job_No IS NOT NULL then C.name
	   when C.name IS NULL AND job_ref_no IS NULL THEN 'New'
	   else NULL end,
	   '' as temp_logger,
	   A.batch_no,              
	   Convert(varchar(10),A.expiry_date,121),
	   A.Subcon_Job_No,
	   B.work_ord_ref,
	   --B.current_event
	   --(Select TOP 1 job_ref_no FROM TBL_Subcon_TXN_WORK_ORDER WITH(NOLOCK) WHERE Subcon_WI_No = A.SWI_No) 
	   null, null, null, null
	 FROM VAS_INTEGRATION.dbo.VAS_Subcon_TRANSFER_ORDER A WITH(NOLOCK)                    
	 LEFT JOIN TBL_Subcon_TXN_WORK_ORDER B WITH(NOLOCK) ON  A.prd_code = B.prd_code AND A.batch_no = B.batch_no and  A.SWI_No = B.subcon_WI_no and A.Subcon_Job_No=B.job_ref_no--  A.SWI_No = B.subcon_WI_no AND A.item_no = B.item_no --                    
	 LEFT JOIN TBL_MST_DDL C WITH(NOLOCK) ON B.work_ord_status = C.code AND C.ddl_code = 'ddlAssignmentStatus'                    
	 INNER JOIN TBL_MST_PRODUCT D WITH(NOLOCK) ON A.prd_code = D.prd_code                    
	 WHERE CONVERT(VARCHAR(10), to_date, 121) BETWEEN CONVERT(VARCHAR(10), @start_date, 121)                    
	 AND CONVERT(VARCHAR(10), @end_date, 121) AND A.plant <> 'MYHW' AND A.delete_flag IS NULL --exclude PPM SKU                    
	 GROUP BY A.to_time, A.to_date, A.Subcon_Doc,A.component,Subcon_Item_No,outbound_doc, A.to_no, A.prd_code,SWI_No, A.plant, supplier_code, supplier_name, A.prd_desc, A.uom,qty,C.name, B.job_ref_no, B.work_ord_ref, prdgrp4  ,A.batch_no,A.expiry_date,A.remark,B.current_event, A.Subcon_Job_No
 end
 ELSE IF (@wo_type = 'SIA' or @wo_type = 'Invoice')
 begin
	INSERT INTO #ASSIGNMENT_LIST_TEMP (type, to_time, vas_order_date, vas_order_time, vas_order, subcon_item_no, component, inbound_doc, to_no, plant, client_code,
	 client_name, prd_code, prd_desc, Subcon_SWI_No, work_ord_ref, qty, uom, status, temp_logger, batch_no, expiry_date, job_ref_no, work_ord_ref_subcon_job_no, su_no, arr_date, arr_time, bin_no
	 )
	  SELECT A.type, CONVERT(VARCHAR(8), A.arrival_date, 108), CONVERT(VARCHAR(10), A.created_date, 121), CONVERT(TIME(0), A.created_date), A.vas_order, '', '', 
	 A.ref_doc_no, A.to_no, A.plant, A.client_code, B.client_name, A.prd_code, C.prd_desc, '', '<a href=# onclick="ShowDetails(''' + D.job_ref_no + ''')">' + D.work_ord_ref + '</a>',
	 A.quantity, A.uom,
	 CASE WHEN E.name IS NULL THEN 'New' ELSE E.name END,
	 '', A.batch_no, A.expiry_date, D.job_ref_no, D.work_ord_ref, null, null, null, null
	 FROM TBL_TXN_SIA_INV A
	 JOIN TBL_MST_CLIENT B ON A.client_code = B.client_code
	 JOIN TBL_MST_PRODUCT C ON A.prd_code = C.prd_code
	 LEFT JOIN TBL_SIA_TXN_WORK_ORDER D ON A.vas_order = D.vas_order AND A.prd_code = D.prd_code AND A.batch_no = D.batch_no
	 LEFT JOIN TBL_MST_DDL E ON D.work_ord_status = E.code AND E.ddl_code = 'ddlAssignmentStatus' 
	 WHERE A.type = @wo_type AND CONVERT(VARCHAR(10), A.created_date, 121) BETWEEN CONVERT(VARCHAR(10), @start_date, 121) 
	 AND CONVERT(VARCHAR(10), @end_date, 121)  
	 AND A.plant <> 'MYHW' --AND A.delete_flag IS NULL 
 end

 DROP TABLE #DOC_NUM  
  
 --UPDATE #ASSIGNMENT_LIST_TEMP  
 --SET status = 'On Hold'  
 --WHERE temp_logger = 'On'  
  
 --UPDATE #ASSIGNMENT_LIST_TEMP  
 --SET status = 'New'  
 --WHERE status IS NULL  
  
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
  WHERE ( [vas_order] LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE [vas_order] END OR 
	Subcon_Item_No LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE Subcon_Item_No END OR 
	component LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE component END OR
	Subcon_SWI_No LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE Subcon_SWI_No END OR
	work_ord_ref_subcon_job_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE work_ord_ref_subcon_job_no END OR
    inbound_doc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE inbound_doc END OR  
    to_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE to_no END OR  
    plant LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE plant END OR  
    client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR  
    client_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_code END OR  
    prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END OR  
    prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_desc END OR  
    --prdgrp4 LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prdgrp4 END OR  
    batch_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE batch_no END OR  
    qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE qty END OR  
    uom LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE uom END OR  
    temp_logger LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE temp_logger END OR  
	su_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE su_no END OR  
	bin_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE bin_no END OR  
    work_ord_ref LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE work_ord_ref END OR
	[type] LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE [type] END)
    AND ISNULL(status, '') = COALESCE(@status, ISNULL(status, ''))  
 END  
 ELSE  
 BEGIN  
  SELECT COUNT(1) as ttl_rows FROM #ASSIGNMENT_LIST_TEMP WHERE ISNULL(status, '') = COALESCE(@status, ISNULL(status, '')) --1  
 END  
  
 IF (@export_ind = '0')  
  SELECT * FROM #ASSIGNMENT_LIST_TEMP --2  
  WHERE ([vas_order] LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE [vas_order] END OR  
	Subcon_Item_No LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE Subcon_Item_No END OR 
	component LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE component END OR
	Subcon_SWI_No LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE Subcon_SWI_No END OR
	work_ord_ref_subcon_job_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE work_ord_ref_subcon_job_no END OR
    inbound_doc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE inbound_doc END OR  
    to_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE to_no END OR  
    plant LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE plant END OR  
    client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR  
    client_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_code END OR  
    prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END OR  
    prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_desc END OR  
    --prdgrp4 LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prdgrp4 END OR  
    batch_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE batch_no END OR  
    qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE qty END OR  
    uom LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE uom END OR  
    temp_logger LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE temp_logger END OR  
	su_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE su_no END OR  
	bin_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE bin_no END OR  
    work_ord_ref LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE work_ord_ref END OR
	[type] LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE [type] END)  
    AND ISNULL(status, '') = COALESCE(@status, ISNULL(status, ''))  
  ORDER BY vas_order_date DESC  
  OFFSET @page_index * @page_size ROWS  
  FETCH NEXT @page_size ROWS ONLY  
 ELSE IF (@export_ind = '1')  
  SELECT * FROM #ASSIGNMENT_LIST_TEMP --2  
  WHERE ([vas_order] LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE [vas_order] END OR 
	Subcon_Item_No LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE Subcon_Item_No END OR 
	component LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE component END OR
	Subcon_SWI_No LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE Subcon_SWI_No END OR
	work_ord_ref_subcon_job_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE work_ord_ref_subcon_job_no END OR
    inbound_doc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE inbound_doc END OR  
    to_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE to_no END OR  
    plant LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE plant END OR  
    client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR  
    client_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_code END OR  
    prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END OR  
    prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_desc END OR  
    --prdgrp4 LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prdgrp4 END OR  
    batch_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE batch_no END OR  
    qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE qty END OR  
    uom LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE uom END OR  
    temp_logger LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE temp_logger END OR  
	su_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE su_no END OR  
	bin_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE bin_no END OR  
    work_ord_ref LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE work_ord_ref END OR
	[type] LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE [type] END)   
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
