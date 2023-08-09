SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================
-- Author:		Smita Thorat
-- Create date: 2022-05-15
-- Description: Assignment Listing
-- Example Query:EXEC [SPP_MST_ASSIGNMENT_LISTING] @param=N'{"start_date":"1900-01-01","end_date":"2022-09-29","status":"N","page_index":0,"page_size":20,"search_term":"0000000022","search_term_mll":"","export_ind":0}',@user_id=10085
-- Example Query:EXEC [SPP_MST_ASSIGNMENT_LISTING] @param=N'{"start_date":"1900-01-01","end_date":"2022-09-29","status":"IP","page_index":0,"page_size":20,"search_term":"","search_term_mll":"","export_ind":1}',@user_id=8032
-- ==============================
--exec [SPP_MST_ASSIGNMENT_LISTING] '{"start_date":"1900-01-01","end_date":"2023-02-24","status":"N","page_index":0,"page_size":20,"search_term":"","search_term_mll":"","export_ind":0}', 8032

CREATE PROCEDURE [dbo].[SPP_MST_ASSIGNMENT_LISTING]  
 @param nvarchar(max),  
 @user_id INT  
AS  
BEGIN  
 SET NOCOUNT ON;  
  
 DECLARE @start_date VARCHAR(20), @end_date VARCHAR(20), @status VARCHAR(20), @page_index INT, @page_size INT, @search_term NVARCHAR(100),@search_term_mll NVARCHAR(100), @export_ind CHAR(1)  
 SET @start_date = (SELECT JSON_VALUE(@param, '$.start_date'))  
 SET @end_date = (SELECT JSON_VALUE(@param, '$.end_date'))  
 SET @status = (SELECT JSON_VALUE(@param, '$.status'))  
 SET @page_index = (SELECT JSON_VALUE(@param, '$.page_index'))  
 SET @page_size = (SELECT JSON_VALUE(@param, '$.page_size'))  
 SET @search_term = (SELECT JSON_VALUE(@param, '$.search_term'))  
 SET @search_term_mll = (SELECT JSON_VALUE(@param, '$.search_term_mll'))  
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
 qas_no nvarchar(max),
 revision_no varchar(50),
 mll_no varchar(100),
 plant varchar(50),  
 client_code varchar(50),  
 client_name nvarchar(150),  
 prd_code varchar(50),  
 prd_desc nvarchar(150),  
 batch_no varchar(50),  
 expiry_date varchar(50),
 manufacturing_date varchar(50),
 qty varchar(50),  
 uom varchar(40),  
 status varchar(50),  
 temp_logger varchar(50), 
 qi_type varchar(50),
sloc varchar(10) ,
 work_ord_ref nvarchar(400),  
 prdgrp4 varchar(50),  
 work_ord_no nvarchar(200),  
 job_ref_no VARCHAR(50),  
 to_be_deducted_seconds INT DEFAULT 0,  
 total_on_hold_time INT DEFAULT 0,  
 total_final_seconds INT DEFAULT 0,
   temp_logger_remark nvarchar(500), 
  temp_logger_released varchar(500)
 )  
  
 -- Get user accessright to work order submodule (6) -------  
 DECLARE @accessright_id INT, @have_access_to_work_order CHAR(1) = 'Y'  
 SET @accessright_id = (SELECT accessright_id FROM VASDEV.dbo.TBL_ADM_USER_ACCESSRIGHT WITH(NOLOCK) WHERE user_id = @user_id)  
 IF (SELECT COUNT(*) FROM VASDEV.dbo.TBL_ADM_ACCESSRIGHT_DTL WITH(NOLOCK) WHERE accessright_id = @accessright_id AND submodule_id = '6' AND action_id = '1') = 0  
  SET @have_access_to_work_order = 'N'  
 ------------------------------------------------------------  
  
  -- Get user warehouse Code-------  
 DECLARE @wh_code varchar(10)
 SET @wh_code = (SELECT wh_code FROM VASDEV.dbo.TBL_ADM_USER WITH(NOLOCK) WHERE user_id = @user_id)  --T50
 --select @wh_code
 ------------------------------------------------------------  
  --select * from VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER
  -- select * from  VASDEV_INTEGRATION_TH.dbo.VAS_INBOUND_ORDER
  --  select * from    TBL_TXN_WORK_ORDER
   DECLARE @JobFormat VARCHAR(25)=(SELECT  [format_code] FROM [TBL_REDRESSING_JOB_FORMAT])
 
 SELECT DISTINCT inbound_doc INTO #INBOUND_DOC_NUM FROM VASDEV_INTEGRATION_TH.dbo.VAS_INBOUND_ORDER  WHERE whs_no=@wh_code

 SELECT DISTINCT inbound_doc INTO #DOC_NUM FROM VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER  
   
 SELECT A.to_time, A.to_date, A.vas_order_time, A.vas_order, A.inbound_doc, A.to_no, A.plant, A.client_code,  A.client_name, A.prd_code, A.prd_desc, A.batch_no,  A.expiry_date, 
 A.manufacturing_date, SUM(ISNULL(A.qty ,0)) - SUM(ISNULL(B.qty ,0)) qty, A.uom,A.status, A.temp_logger,A.qi_type,A.work_ord_ref,   A.prdgrp4,   A.work_ord_no, A.job_ref_no  ,A.mll_no,A.sloc
 INTO #INBOUND_TEMP FROM 
 (
	 SELECT CONVERT(VARCHAR(19), vas_order_date, 121) to_time, CONVERT(VARCHAR(10), vas_order_date, 121) to_date, CONVERT(TIME(0), vas_order_date) as vas_order_time, vas_order, inbound_doc, '' as to_no, plant,  
	supplier_code as client_code, supplier_name as client_name, prd_code, prd_desc, batch_no, CONVERT(VARCHAR(10), expiry_date, 121) as expiry_date, '' AS manufacturing_date,
	SUM(ISNULL(qty ,0)) qty, uom, 'New' as status, '' as temp_logger,qi_type, '' as work_ord_ref,'' prdgrp4, '' as work_ord_no, '' as job_ref_no ,''mll_no ,whs_no,''sloc
	FROM VASDEV_INTEGRATION_TH.dbo.VAS_INBOUND_ORDER 
	GROUP BY vas_order_date,vas_order, inbound_doc,plant,supplier_code,supplier_name, prd_code, prd_desc, batch_no, uom,qi_type,expiry_date,whs_no
)A
FULL JOIN 
 (
  		 SELECT  distinct  A.vas_order, A.inbound_doc,  A.plant,  
		 supplier_code as client_code, supplier_name as client_name, A.prd_code, A.prd_desc, A.batch_no, CONVERT(VARCHAR(10), A.expiry_date, 121) as expiry_date, CONVERT(VARCHAR(10), A.manufacturing_date, 121)manufacturing_date, sum(qty) qty, A.uom, '' status, 
		 temp_logger,  	  ''  prdgrp4,  '' job_ref_no  ,'' mll_no,qi_type,sloc 
		 FROM VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER A WITH(NOLOCK)  
		 WHERE CONVERT(VARCHAR(10), to_date, 121) BETWEEN CONVERT(VARCHAR(10), @start_date, 121) AND CONVERT(VARCHAR(10), @end_date, 121) 
		 AND  A.plant <> 'MYHW' AND A.delete_flag IS NULL --exclude PPM SKU  
		 AND A.whs_no=@wh_code 
		 --AND  (A.workorder_no IS NULL OR A.workorder_no='')
		 GROUP BY inbound_doc, vas_order,  prd_code,batch_no,plant, supplier_code, supplier_name,prd_desc, expiry_date, manufacturing_date, uom,  temp_logger,  qi_type,sloc
)B 
ON A.inbound_doc = B.inbound_doc AND A.vas_order = B.vas_order AND A.prd_code = B.prd_code AND A.batch_no = B.batch_no --AND A.workorder_no =B.job_ref_no--AND A.item_no = B.item_no 
WHERE A.qty-ISNULL(B.qty ,0)>0 AND A.inbound_doc  IN (SELECT isnull(inbound_doc,'') FROM #DOC_NUM)  AND  (A.job_ref_no IS NULL OR A.job_ref_no='')
AND A.whs_no=@wh_code 
GROUP BY A.to_time, A.to_date, A.vas_order_time,A.vas_order, A.inbound_doc,A.plant,A.client_code,A.client_name,A.to_no, A.prd_code, A.prd_desc, A.batch_no, 
A.uom,A.qi_type,A.expiry_date, A.manufacturing_date,A.status,A.temp_logger,A.work_ord_ref,A.prdgrp4,A.work_ord_no,A.job_ref_no ,A.mll_no,A.sloc

--SELECT CONVERT(VARCHAR(19), vas_order_date, 121) to_time, CONVERT(VARCHAR(10), vas_order_date, 121) to_date, CONVERT(TIME(0), vas_order_date) as vas_order_time, A.vas_order, A.inbound_doc, '' as to_no, A.plant,  
--A.supplier_code as client_code, A.supplier_name as client_name, A.prd_code, A.prd_desc, A.batch_no, CONVERT(VARCHAR(10), A.expiry_date, 121) as expiry_date, '' AS manufacturing_date,
--A.qty-ISNULL(B.qty ,0)qty , A.uom, 'New' as status, '' as temp_logger,A.qi_type, '' as work_ord_ref,'' prdgrp4, '' as work_ord_no, '' as job_ref_no ,''mll_no INTO #INBOUND_TEMP
--FROM VASDEV_INTEGRATION_TH.dbo.VAS_INBOUND_ORDER A 
--FULL JOIN 
-- (
--  		 SELECT  distinct  A.vas_order, A.inbound_doc,  A.plant,  
--		 supplier_code as client_code, supplier_name as client_name, A.prd_code, A.prd_desc, A.batch_no, CONVERT(VARCHAR(10), A.expiry_date, 121) as expiry_date, CONVERT(VARCHAR(10), A.manufacturing_date, 121)manufacturing_date, sum(qty) qty, A.uom, '' status, 
--		 temp_logger,  	  ''  prdgrp4,  '' job_ref_no  ,'' mll_no,qi_type--B.work_ord_ref,
--		 FROM VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER A WITH(NOLOCK)  
--		 WHERE CONVERT(VARCHAR(10), to_date, 121) BETWEEN CONVERT(VARCHAR(10), @start_date, 121) AND CONVERT(VARCHAR(10), @end_date, 121) 
--		 AND  A.plant <> 'MYHW' AND A.delete_flag IS NULL --exclude PPM SKU  
--		 AND A.whs_no=@wh_code 
--		 AND  (A.workorder_no IS NULL OR A.workorder_no='')
--		 GROUP BY inbound_doc, vas_order,  prd_code,batch_no,plant, supplier_code, supplier_name,prd_desc, expiry_date, manufacturing_date, uom,  temp_logger,  qi_type

-- --	 SELECT   vas_order, inbound_doc,  plant, client_code,  client_name, prd_code, prd_desc, batch_no,  expiry_date, manufacturing_date, sum(qty) qty, uom,status, temp_logger,qi_type,work_ord_ref,   prdgrp4,  work_ord_ref work_ord_no, job_ref_no  ,mll_no
--	-- FROM
--	-- (
--	--	 SELECT  distinct  A.vas_order, A.inbound_doc, A.to_no, A.plant,  
--	--	 supplier_code as client_code, supplier_name as client_name, A.prd_code, A.prd_desc, A.batch_no, CONVERT(VARCHAR(10), A.expiry_date, 121) as expiry_date, CONVERT(VARCHAR(10), A.manufacturing_date, 121)manufacturing_date, qty, A.uom, C.name as status, 
--	--	 temp_logger,  
--	--	 CASE @have_access_to_work_order WHEN 'Y' THEN '<a href=# onclick="ShowDetails(''' + B.job_ref_no + ''',''' + A.prd_code + ''',''' + A.batch_no + ''',''' + A.vas_order + ''',''' + A.inbound_doc + ''',''' + A.to_no + ''')">' + CASE WHEN @JobFormat='JobFormat' THEN B.job_ref_no ELSE B.work_ord_ref  END  + '</a>' ELSE B.work_ord_ref END as work_ord_ref,   
--	--	 prdgrp4,   B.job_ref_no  ,B.mll_no,qi_type--B.work_ord_ref,
--	--	 FROM VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER A WITH(NOLOCK)  
--	--	 LEFT JOIN TBL_TXN_WORK_ORDER B WITH(NOLOCK) ON A.vas_order = B.vas_order AND A.prd_code = B.prd_code AND A.batch_no = B.batch_no AND A.workorder_no =B.job_ref_no--AND A.item_no = B.item_no  
--	--	 LEFT JOIN TBL_TXN_WORK_ORDER_JOB_DET J WITH(NOLOCK) ON  J.job_ref_no=B.job_ref_no
--	--	 LEFT JOIN TBL_MST_DDL C WITH(NOLOCK) ON J.work_ord_status = C.code  
--	--	 INNER JOIN TBL_MST_PRODUCT D WITH(NOLOCK) ON A.prd_code = D.prd_code  
--	--	 WHERE CONVERT(VARCHAR(10), to_date, 121) BETWEEN CONVERT(VARCHAR(10), @start_date, 121) AND CONVERT(VARCHAR(10), @end_date, 121) 
--	--	 AND A.plant <> 'MYHW' AND A.delete_flag IS NULL --exclude PPM SKU  
--	--	 AND A.whs_no=@wh_code -- AND B.whs_no=@wh_code
--	--	 AND C.ddl_code='ddlAssignmentStatus' or C.name is null AND (A.workorder_no IS NULL OR A.workorder_no='')
--	--)E GROUP BY inbound_doc, vas_order,  prd_code,batch_no,plant, client_code, client_name,prd_desc, expiry_date, manufacturing_date, uom, status, temp_logger, job_ref_no,work_ord_ref, prdgrp4  ,mll_no,qi_type--,workorder_no
--)B 
--ON A.inbound_doc = B.inbound_doc AND A.vas_order = B.vas_order AND A.prd_code = B.prd_code AND A.batch_no = B.batch_no --AND A.workorder_no =B.job_ref_no--AND A.item_no = B.item_no 
--WHERE A.qty-ISNULL(B.qty ,0)>0 AND A.inbound_doc  IN (SELECT inbound_doc FROM #DOC_NUM)  AND  (A.workorder_no IS NULL OR A.workorder_no='')
-- AND A.whs_no=@wh_code 

--SELECT * FROM #INBOUND_TEMP



 INSERT INTO #ASSIGNMENT_LIST_TEMP (to_time, vas_order_date, vas_order_time, vas_order, inbound_doc, to_no, plant, client_code, client_name, prd_code, prd_desc, batch_no, expiry_date, manufacturing_date, qty, uom, status, temp_logger,qi_type, work_ord_ref, prdgrp4, work_ord_no, job_ref_no,mll_no,sloc, qas_no, revision_no,temp_logger_remark,temp_logger_released)  
 SELECT  to_time, to_date, vas_order_time, vas_order, inbound_doc, to_no, plant, client_code,  client_name, prd_code, prd_desc, batch_no,  expiry_date, manufacturing_date, sum(qty), uom,status, temp_logger,qi_type,work_ord_ref,   prdgrp4,   work_ord_no, job_ref_no  ,mll_no,sloc, qas_no, revision_no,temp_logger_remark,temp_logger_released
 FROM
 (
	 SELECT   CONVERT(VARCHAR(19), to_time, 121)to_time, CONVERT(VARCHAR(10), to_date, 121)to_date, CONVERT(TIME(0), to_time)vas_order_time, A.vas_order, A.inbound_doc, A.to_no, A.plant,  
	 supplier_code as client_code, supplier_name as client_name, A.prd_code, A.prd_desc, A.batch_no, CONVERT(VARCHAR(10), A.expiry_date, 121) as expiry_date, CONVERT(VARCHAR(10), A.manufacturing_date, 121)manufacturing_date, qty, A.uom, C.name as status, 
	 CASE temp_logger WHEN 'Y' THEN 'On' WHEN 'N' THEN '' WHEN 'R' THEN  'Released' ELSE '' END temp_logger,  
	 CASE @have_access_to_work_order WHEN 'Y' THEN '<a href=# onclick="ShowDetails(''' + B.job_ref_no + ''',''' + A.prd_code + ''',''' + A.batch_no + ''',''' + A.vas_order + ''',''' + A.inbound_doc + ''',''' + A.to_no + ''')">' + CASE WHEN @JobFormat='JobFormat' THEN B.job_ref_no ELSE B.work_ord_ref  END  + '</a>' ELSE B.work_ord_ref END as work_ord_ref,   
	 prdgrp4, CASE WHEN @JobFormat='JobFormat' THEN B.job_ref_no ELSE B.work_ord_ref  END work_ord_no,  B.job_ref_no  ,B.mll_no,A.qi_type,A.sloc--B.work_ord_ref,
	 , E.mll_desc as qas_no, E.revision_no as revision_no , temp_logger_remark, CONCAT((SELECT user_name FROM VASDEV.dbo.TBL_ADM_USER where user_id=temp_logger_released_by), ' ',  dbo.SF_CONVERT_TH_TIME( temp_logger_released_date)) AS temp_logger_released
	 FROM VASDEV_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER A WITH(NOLOCK)  
	 LEFT JOIN TBL_TXN_WORK_ORDER B WITH(NOLOCK) ON A.vas_order = B.vas_order AND A.prd_code = B.prd_code AND A.batch_no = B.batch_no AND A.workorder_no =B.job_ref_no--AND A.item_no = B.item_no  
	 LEFT JOIN TBL_TXN_WORK_ORDER_JOB_DET J WITH(NOLOCK) ON  J.job_ref_no=B.job_ref_no
	 LEFT JOIN TBL_MST_DDL C WITH(NOLOCK) ON J.work_ord_status = C.code  
	 LEFT JOIN TBL_MST_PRODUCT D WITH(NOLOCK) ON A.prd_code = D.prd_code  
	 LEFT JOIN TBL_MST_MLL_HDR E WITH(NOLOCK) ON B.mll_no = E.mll_no
	 WHERE CONVERT(VARCHAR(10), to_date, 121) BETWEEN CONVERT(VARCHAR(10), @start_date, 121) AND CONVERT(VARCHAR(10), @end_date, 121) 
	 AND A.plant <> 'MYHW' AND A.delete_flag IS NULL --exclude PPM SKU  
	 AND A.whs_no=@wh_code -- AND B.whs_no=@wh_code
	  AND (C.ddl_code='ddlAssignmentStatus' or C.name is null)
	  AND A.inbound_doc in (SELECT DISTINCT isnull(inbound_doc,'') FROM  #INBOUND_DOC_NUM)
)F GROUP BY to_time, to_date,vas_order_time,inbound_doc, vas_order, to_no, prd_code,batch_no,plant, client_code, client_name,prd_desc, expiry_date, manufacturing_date, uom, status, temp_logger, job_ref_no,work_ord_ref, prdgrp4  ,mll_no,qi_type,sloc,work_ord_no, qas_no, revision_no,temp_logger_remark,temp_logger_released
 UNION ALL 
	SELECT CONVERT(VARCHAR(19), vas_order_date, 121), CONVERT(VARCHAR(10), vas_order_date, 121), CONVERT(TIME(0), vas_order_date) as vas_order_time, A.vas_order, A.inbound_doc, '' as to_no, A.plant,  
	supplier_code as client_code, supplier_name as client_name, A.prd_code, A.prd_desc, A.batch_no, CONVERT(VARCHAR(10), A.expiry_date, 121) as expiry_date, '' AS manufacturing_date,
	qty, A.uom, 'New' as status, '' as temp_logger,qi_type, '' as work_ord_ref, prdgrp4, '' as work_ord_no, '' as job_ref_no ,''mll_no,''sloc, D.mll_desc as qas_no, D.revision_no as revision_no,'' as temp_logger_remark, '' as temp_logger_released
	FROM VASDEV_INTEGRATION_TH.dbo.VAS_INBOUND_ORDER A WITH(NOLOCK)  
	LEFT JOIN TBL_MST_PRODUCT B WITH(NOLOCK) ON A.prd_code = B.prd_code  
	LEFT JOIN TBL_TXN_WORK_ORDER C WITH(NOLOCK) ON A.vas_order = C.vas_order AND A.prd_code = C.prd_code AND A.batch_no = C.batch_no AND A.workorder_no =C.job_ref_no
	LEFT JOIN TBL_MST_MLL_HDR D WITH(NOLOCK) ON C.mll_no = D.mll_no
	WHERE A.inbound_doc NOT IN (SELECT isnull(inbound_doc,'') FROM #DOC_NUM) AND CONVERT(VARCHAR(10), vas_order_date, 121) BETWEEN CONVERT(VARCHAR(10), @start_date, 121) AND CONVERT(VARCHAR(10), @end_date, 121)  
	AND A.plant <> 'MYHW' AND A.delete_flag IS NULL  
	AND A.whs_no=@wh_code
 UNION ALL
	SELECT A.*, D.mll_desc as qas_no, D.revision_no as revision_no,'' as temp_logger_remark,''as temp_logger_released FROM #INBOUND_TEMP A
	LEFT JOIN TBL_TXN_WORK_ORDER C WITH(NOLOCK) ON A.vas_order = C.vas_order AND A.prd_code = C.prd_code AND A.batch_no = C.batch_no AND A.work_ord_no =C.job_ref_no
	LEFT JOIN TBL_MST_MLL_HDR D WITH(NOLOCK) ON C.mll_no = D.mll_no
 
 DROP TABLE #DOC_NUM  
 DROP TABLE #INBOUND_TEMP


  --select * from #ASSIGNMENT_LIST_TEMP

-- MY logic
if (NOT EXISTS(SELECT 1 FROM TBL_ADM_QI_TYPE))
begin
	UPDATE #ASSIGNMENT_LIST_TEMP  
	SET status = 'On Hold'  
	WHERE temp_logger = 'On' 
end

 UPDATE #ASSIGNMENT_LIST_TEMP  
 SET status = 'New'  
 WHERE status IS NULL  

 --select H.mll_no,prd_code from [TBL_MST_MLL_DTL] D 
 --INNER JOIN [TBL_MST_MLL_HDR] H ON D.mll_no=H.mll_no
 --order by approved_date desc

 --Added By Smita for Updating MLL No 
;WITH cte2 AS(
	SELECT H.mll_desc, H.revision_no, H.mll_no,D.prd_code,approved_date,ROW_NUMBER() OVER (PARTITION BY prd_code ORDER BY approved_date desc) row_num
    FROM [TBL_MST_MLL_DTL] D 
    INNER JOIN [TBL_MST_MLL_HDR] H ON D.mll_no=H.mll_no
	INNER JOIN TBL_MST_CLIENT_SUB S ON H.client_code =S.client_code and H.sub=S.sub_code
	where S.wh_code=@wh_code AND H.mll_status='Approved' AND (GETDATE() BETWEEN start_date AND end_date)  
)
SELECT * INTO #TEMPMLL FROM cte2 WHERE cte2.row_num=1;



Update TEMP  set mll_no =TEMPMLL.mll_no , qas_no = TEMPMLL.mll_desc, revision_no = TEMPMLL.revision_no
FROM
    #TEMPMLL TEMPMLL
INNER JOIN
    #ASSIGNMENT_LIST_TEMP TEMP
ON  TEMPMLL.prd_code=TEMP.prd_code --AND TEMPMLL.client_code = TEMP.client_code  
where  TEMP.mll_no is null


update TEMP
SET TEMP.qi_type=I.qi_type
FROM #ASSIGNMENT_LIST_TEMP  TEMP
INNER JOIN VASDEV_INTEGRATION_TH.dbo.VAS_INBOUND_ORDER I ON TEMP.vas_order=I.vas_order  AND TEMP.prd_code = I.prd_code AND TEMP.batch_no =I.batch_no AND TEMP.inbound_doc = I.inbound_doc



DROP table #TEMPMLL

 UPDATE #ASSIGNMENT_LIST_TEMP  
 SET mll_no = ''  
 WHERE mll_no IS NULL 
--Added By Smita for Updating MLL No 

UPDATE #ASSIGNMENT_LIST_TEMP  
 SET qas_no = ''  
 WHERE qas_no IS NULL 

UPDATE #ASSIGNMENT_LIST_TEMP  
 SET revision_no = ''  
 WHERE revision_no IS NULL

 UPDATE #ASSIGNMENT_LIST_TEMP  
 SET sloc = ''  
 WHERE sloc IS NULL 
  
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


-- TH Logic
if (EXISTS(SELECT 1 FROM TBL_ADM_QI_TYPE)) 
begin
	UPDATE #ASSIGNMENT_LIST_TEMP  
	SET temp_logger = 'On' , status = 'On Hold'  
	WHERE qi_type in (select replace(concat(qi_type, '-', qi_desc), ' + ', '+') from TBL_ADM_QI_TYPE where status = 'Active') 
	      AND ISNULL(LTRIM(RTRIM(to_no)),'')<>'' AND (IsNull(temp_logger , '') = '')
end
  
 IF @search_term <> '' OR @search_term_mll<>'' OR(@status <> NULL OR @status <> '')  
 BEGIN  
  SELECT COUNT(1) as ttl_rows FROM #ASSIGNMENT_LIST_TEMP  --1  
  WHERE ( vas_order LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE vas_order END OR  
    inbound_doc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE inbound_doc END OR  
    to_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE to_no END OR  
    plant LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE plant END OR  
    client_name LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_name END OR  
    client_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_code END OR  
	client_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE client_code END OR  
    prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END OR  
    prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_desc END OR  
    prdgrp4 LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prdgrp4 END OR  
    batch_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE batch_no END OR  
    qty LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE qty END OR  
    uom LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE uom END OR  
    temp_logger LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE temp_logger END OR  
    work_ord_ref LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE work_ord_ref END OR
	sloc  LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE sloc END)
    AND ISNULL(status, '') = COALESCE(@status, ISNULL(status, ''))  
	AND (mll_no LIKE CASE WHEN @search_term_mll <> '' THEN '%' + @search_term_mll + '%' ELSE mll_no END OR
	qas_no LIKE CASE WHEN @search_term_mll <> '' THEN '%' + @search_term_mll + '%' ELSE mll_no END   OR
	temp_logger_remark LIKE CASE WHEN @search_term_mll <> '' THEN '%' + @search_term_mll + '%' ELSE temp_logger_remark END   OR
	temp_logger_released LIKE CASE WHEN @search_term_mll <> '' THEN '%' + @search_term_mll + '%' ELSE temp_logger_released END   

	)
	
 END  
 ELSE  
 BEGIN  
  SELECT COUNT(1) as ttl_rows FROM #ASSIGNMENT_LIST_TEMP WHERE ISNULL(status, '') = COALESCE(@status, ISNULL(status, '')) --1  
 END  




  --SELECT * FROM #ASSIGNMENT_LIST_TEMP




 IF (@export_ind = '0')  
  SELECT * FROM #ASSIGNMENT_LIST_TEMP --2  
  WHERE (vas_order LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE vas_order END OR  
    inbound_doc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE inbound_doc END OR		
	qi_type LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE qi_type END OR  
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
    work_ord_ref LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE work_ord_ref END OR
	sloc  LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE sloc END)
    AND ISNULL(status, '') = COALESCE(@status, ISNULL(status, ''))  
	AND (mll_no LIKE CASE WHEN @search_term_mll <> '' THEN '%' + @search_term_mll + '%' ELSE mll_no END OR
	qas_no LIKE CASE WHEN @search_term_mll <> '' THEN '%' + @search_term_mll + '%' ELSE mll_no END OR
		temp_logger_remark LIKE CASE WHEN @search_term_mll <> '' THEN '%' + @search_term_mll + '%' ELSE temp_logger_remark END   OR
	temp_logger_released LIKE CASE WHEN @search_term_mll <> '' THEN '%' + @search_term_mll + '%' ELSE temp_logger_released END
	
	)
  ORDER BY vas_order_date DESC  
  OFFSET @page_index * @page_size ROWS  
  FETCH NEXT @page_size ROWS ONLY  
 ELSE IF (@export_ind = '1')  
  SELECT * FROM #ASSIGNMENT_LIST_TEMP --2  
  WHERE (vas_order LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE vas_order END OR  
    inbound_doc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE inbound_doc END OR	
	qi_type LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE qi_type END OR  
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
    work_ord_ref LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE work_ord_ref END OR
	sloc  LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE sloc END)
    AND ISNULL(status, '') = COALESCE(@status, ISNULL(status, ''))  
	AND (mll_no LIKE CASE WHEN @search_term_mll <> '' THEN '%' + @search_term_mll + '%' ELSE mll_no END OR
	qas_no LIKE CASE WHEN @search_term_mll <> '' THEN '%' + @search_term_mll + '%' ELSE mll_no END OR
	temp_logger_remark LIKE CASE WHEN @search_term_mll <> '' THEN '%' + @search_term_mll + '%' ELSE temp_logger_remark END   OR
	temp_logger_released LIKE CASE WHEN @search_term_mll <> '' THEN '%' + @search_term_mll + '%' ELSE temp_logger_released END
	)
  ORDER BY vas_order_date DESC  
  
 SELECT @export_ind AS export_ind --3  
  
 SELECT list_dtl_id, list_col_name as input_name, list_default_display_name as display_name  --4  
 FROM VASDEV.dbo.TBL_ADM_CONFIG_PAGE_LISTING_DTL WITH(NOLOCK)  
 WHERE list_hdr_id IN (SELECT list_hdr_id FROM VASDEV.dbo.TBL_ADM_CONFIG_PAGE_LISTING_HDR WITH(NOLOCK) WHERE page_code = 'ASSIGNMENT-SEARCH' --LIKE 'ASSIGNMENT%'  
 ) AND list_col_name in (SELECT name FROM tempdb.sys.columns where object_id = object_id('tempdb..#ASSIGNMENT_LIST_TEMP'))  
  
 DROP TABLE #ON_HOLD  
 DROP TABLE #ASSIGNMENT_LIST_TEMP  
END

GO
