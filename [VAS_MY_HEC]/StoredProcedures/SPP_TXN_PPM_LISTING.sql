SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
-- ========================================================================    
-- Author:  Siow Shen Yee    
-- Create date: 2018-07-13    
-- Description: Retrieve PPM Listing    
-- Example Query: exec SPP_TXN_PPM_LISTING @param=N'{"job_ref_no":"S2022/01/0020","page_index":0,"page_size":10,"search_term":"","export_ind":0}', @user_id=N'1'    
-- Output:    
-- 1) dtCount - Total rows    
-- 2) dt - Data    
-- 3) dtExportInd - Export indicator    
-- 4) dtJobRefNo - Job Ref No    
-- 5) dtExportColumnName - Export column display name    
-- ========================================================================    
    
CREATE PROCEDURE [dbo].[SPP_TXN_PPM_LISTING]     
 @param NVARCHAR(MAX),    
 @user_id INT    
AS    
BEGIN    
 SET NOCOUNT ON;    
    
 DECLARE @job_ref_no VARCHAR(50), @page_index INT, @page_size INT, @search_term NVARCHAR(100), @export_ind CHAR(1)    
 SET @job_ref_no = (SELECT JSON_VALUE(@param, '$.job_ref_no'))    
 SET @page_index = (SELECT JSON_VALUE(@param, '$.page_index'))    
 SET @page_size = (SELECT JSON_VALUE(@param, '$.page_size'))    
 SET @search_term = (SELECT JSON_VALUE(@param, '$.search_term'))    
 SET @export_ind = (SELECT JSON_VALUE(@param, '$.export_ind'))    
    
 IF (SELECT COUNT(1) FROM TBL_TXN_PPM WITH(NOLOCK) WHERE job_ref_no = @job_ref_no) = 0    
 BEGIN    
  DECLARE @json NVARCHAR(MAX), @prd_code VARCHAR(50), @mll_no VARCHAR(50), @required_qty INT ,@subcon_wi_no VARCHAR(50)   
  IF(LEFT(@job_ref_no,1) = 'S')  
  BEGIN
    SELECT @subcon_wi_no = subcon_WI_no, @prd_code = prd_code, @required_qty = qty_of_goods + 5 FROM TBL_Subcon_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no    
	SET @json = (SELECT vas_activities FROM TBL_MST_SUBCON_DTL WITH(NOLOCK) WHERE subcon_no = @subcon_wi_no AND prd_code = @prd_code)    
  END
  ELSE
  BEGIN
    SELECT @mll_no = mll_no, @prd_code = prd_code, @required_qty = qty_of_goods + 5 FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no    
    SET @json = (SELECT vas_activities FROM TBL_MST_MLL_DTL WITH(NOLOCK) WHERE mll_no = @mll_no AND prd_code = @prd_code)    
  END  
    
  SELECT * INTO #PPM_PRD FROM OPENJSON ( @json ) WITH ( prd_list VARCHAR(2000) '$.prd_code' ) WHERE prd_list <> ''    
    
  SELECT DISTINCT IDENTITY(INT,1,1) as num, LTRIM(Split.a.value('.', 'VARCHAR(100)')) AS prd_code    
  INTO #TEMP_PPM_TXN    
  FROM (SELECT CAST ('<M>' + REPLACE(prd_list, ',', '</M><M>') + '</M>' AS XML) AS prd_code      
  FROM #PPM_PRD) AS A CROSS APPLY prd_code.nodes ('/M') AS Split(a);    
    
  INSERT INTO TBL_TXN_PPM    
  (line_no, job_ref_no, prd_code, required_qty, sap_qty, issued_qty, manual_ppm, created_date, creator_user_id)    
  SELECT num, @job_ref_no, prd_code, @required_qty, 0, 0, 0, GETDATE(), @user_id    
  FROM #TEMP_PPM_TXN    
    
  DROP TABLE #PPM_PRD    
  DROP TABLE #TEMP_PPM_TXN    
 END    
    
 CREATE TABLE #TEMP_DATA(    
  row_num INT IDENTITY(1,1),    
  prd_code VARCHAR(50),    
  prd_desc NVARCHAR(500),    
  plant VARCHAR(50),    
  sloc VARCHAR(50),    
  required_qty INT DEFAULT 0,    
  sap_qty DECIMAL(18,0) DEFAULT 0,    
  balance_qty INT DEFAULT 0,    
  issued_qty INT DEFAULT 0,    
  remarks NVARCHAR(2000),    
  sap_status CHAR(1),    
  sap_remarks NVARCHAR(2000),    
  system_running_no VARCHAR(10),    
  line_no INT,    
  manual_ppm INT,    
  event_accessright CHAR(1) -- Y: Editable; N: Not editable    
 )    
    
 INSERT INTO #TEMP_DATA    
 (prd_code, prd_desc, plant, sloc, required_qty, sap_qty, issued_qty, remarks, system_running_no, line_no, manual_ppm, sap_status, sap_remarks, event_accessright)    
 SELECT A.prd_code, B.prd_desc, 'MYHW', '1000', required_qty, sap_qty, issued_qty, A.remarks, system_running_no, line_no, manual_ppm, C.status, ' TO NO. ' + ISNULL(C.to_no, '') + ' - ' + C.remarks  , 'Y'    
 FROM TBL_TXN_PPM A WITH(NOLOCK)    
 INNER JOIN TBL_MST_PRODUCT B WITH(NOLOCK) ON A.prd_code = B.prd_code    
 LEFT JOIN VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER_SAP C WITH(NOLOCK)   
 ON A.system_running_no = C.requirement_no AND A.prd_code = C.prd_code AND C.country_code = 'MY'    
 WHERE job_ref_no = @job_ref_no    
 ORDER BY line_no    
    
 --DECLARE @prd_code_list VARCHAR(MAX), @plant_list VARCHAR(MAX), @storage_loc_list VARCHAR(MAX), @GETITEMS_XML_OUTPUT AS XML    
 --SELECT @prd_code_list = COALESCE(@prd_code_list + ',', '') + '000000000' + LTRIM(prd_code), @plant_list = COALESCE(@plant_list + ',', '') + plant, @storage_loc_list = COALESCE(@storage_loc_list + ',', '') + sloc    
 --FROM #TEMP_DATA    
    
 --EXEC SPP_SAP_RFC_YMM_FM_BAPI_STOCK_ENQUIRY @prd_code_list = @prd_code_list, @plant_list = @plant_list, @storage_loc_list = @storage_loc_list, @XML = @GETITEMS_XML_OUTPUT OUTPUT    
    
 --SELECT     
 -- Tbl.Col.value('MATNR[1]', 'nvarchar(1000)') as MATNR,     
 -- Tbl.Col.value('MAKTX[1]', 'nvarchar(1000)') as MAKTX,    
 -- Tbl.Col.value('AVAI_STOCK[1]', 'nvarchar(1000)') as AVAI_STOCK,    
 -- Tbl.Col.value('WERKS[1]', 'nvarchar(1000)') as WERKS,    
 -- Tbl.Col.value('LGORT[1]', 'nvarchar(1000)') as LGORT,    
 -- Tbl.Col.value('KMEIN[1]', 'nvarchar(1000)') as KMEIN,    
 -- Cast(NULL as nvarchar(250)) as whs_desc     
 --INTO #TEMP    
 --FROM   @GETITEMS_XML_OUTPUT.nodes('//T_DATA/item') Tbl(Col)    
    
 --UPDATE A    
 --SET sap_qty = 50    
 --FROM #TEMP_DATA A    
 --INNER JOIN #TEMP B ON A.prd_code = B.MATNR AND A.plant = B.WERKS AND A.sloc = B.LGORT    
    
 DECLARE @i INT = 1, @ttl_rows INT, @ppm_prd_code VARCHAR(50), @uom VARCHAR(50), @GETITEMS_XML_OUTPUT AS XML    
 --DECLARE @XML_TEMP TABLE (xml_text NVARCHAR(MAX))    
 SET @ttl_rows = (SELECT COUNT(1) FROM #TEMP_DATA)    
 WHILE @i <= @ttl_rows    
 BEGIN    
  SET @ppm_prd_code = (SELECT prd_code FROM #TEMP_DATA WITH(NOLOCK) WHERE row_num = @i)    
  SET @uom = (SELECT base_uom FROM TBL_MST_PRODUCT WITH(NOLOCK) WHERE prd_code = @ppm_prd_code)    
    
  EXEC SPP_SAP_RFC_BAPI_MATERIAL_AVAILABILITY_2 @prd_code = @ppm_prd_code, @plant = 'MYHW', @unit = @uom, @XML = @GETITEMS_XML_OUTPUT OUTPUT    
    
  UPDATE #TEMP_DATA    
  SET sap_qty = (SELECT CAST(Tbl.Col.value('COM_QTY[1]', 'decimal(18,0)') AS INT) FROM @GETITEMS_XML_OUTPUT.nodes('//WMDVEX/item') Tbl(Col))    
  WHERE row_num = @i AND system_running_no IS NULL    
    
  SET @i = @i + 1    
 END    
      
 /** Save SAP returned quantity into table (first time) **/    
 UPDATE A    
 SET sap_qty = B.sap_qty    
 FROM TBL_TXN_PPM A WITH(NOLOCK)    
 INNER JOIN #TEMP_DATA B WITH(NOLOCK) ON A.job_ref_no = @job_ref_no AND A.prd_code = B.prd_code    
    
 UPDATE #TEMP_DATA    
 SET sap_qty = 0    
 WHERE sap_qty IS NULL    
    
 UPDATE #TEMP_DATA    
 SET balance_qty = required_qty - issued_qty    
    
 /** Populate issued quantity **/    
 UPDATE #TEMP_DATA    
 SET issued_qty = CASE WHEN ISNULL(sap_qty,0) - required_qty >= 0 THEN required_qty ELSE ISNULL(sap_qty,0) END     
 WHERE issued_qty = 0    
    
 UPDATE A    
 SET issued_qty = B.issued_qty    
 FROM TBL_TXN_PPM A WITH(NOLOCK)    
 INNER JOIN #TEMP_DATA B WITH(NOLOCK) ON A.job_ref_no = @job_ref_no AND A.prd_code = B.prd_code    
 WHERE A.issued_qty = 0    
 /** Populate issued quantity **/    
    
 UPDATE A    
 SET event_accessright = 'N'    
 FROM #TEMP_DATA A    
 LEFT JOIN VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER_SAP B WITH(NOLOCK) ON A.system_running_no = B.requirement_no AND A.prd_code = B.prd_code    
 WHERE B.status = 'R'    
    
 DECLARE @ppm_status CHAR(10), @cntPPMEvent INT    
 SET @cntPPMEvent = (SELECT COUNT(1) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND event_id = '10')    
 IF @cntPPMEvent > 0 SET @ppm_status = 'Closed' ELSE SET @ppm_status = 'Open'    
    
 INSERT INTO TBL_ADM_AUDIT_TRAIL    
 (module, key_code, action , action_by, action_date)    
 VALUES('PPM-SEARCH', @job_ref_no, 'Created PPM', @user_id, GETDATE())    
     
 /** OUTPUT **/    
 IF @search_term <> ''    
  SELECT COUNT(1) as ttl_rows FROM #TEMP_DATA -- 1    
  WHERE ( prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END)    
 ELSE     
  SELECT COUNT(1) as ttl_rows FROM #TEMP_DATA -- 1    
    
 SELECT * FROM #TEMP_DATA -- 2    
 WHERE ( prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_code END)    
 ORDER BY line_no asc    
 OFFSET @page_index * @page_size ROWS    
 FETCH NEXT @page_size ROWS ONLY    
    
 SELECT @export_ind as export_ind --3    
   
 IF(LEFT(@job_ref_no,1) = 'V')  
 BEGIN  
   SELECT @job_ref_no as job_ref_no, work_ord_ref as work_ord_ref, @ppm_status as ppm_status    
   FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no --4    
 END  
 ELSE IF(LEFT(@job_ref_no,1) = 'S')  
 BEGIN  
   SELECT @job_ref_no as job_ref_no, work_ord_ref as work_ord_ref, @ppm_status as ppm_status    
   FROM TBL_Subcon_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no --4  
 END  
    
 SELECT list_dtl_id, list_col_name as input_name, list_default_display_name as display_name  --5    
 FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_LISTING_DTL WITH(NOLOCK)    
 WHERE list_hdr_id IN (SELECT list_hdr_id FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_LISTING_HDR WITH(NOLOCK) WHERE page_code = 'PPM-SEARCH') AND list_col_name in (SELECT name FROM tempdb.sys.columns where object_id = object_id('tempdb..#TEMP_DATA'))    
    
 DROP TABLE #TEMP_DATA    
END
GO
