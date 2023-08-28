SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
-- ======================================================================================================================================  
-- Author:  Vijitha  
-- Create date: 2021-10-25  
-- Description: Retrieve SUBCON listing  
-- Example Query: exec SPP_MST_SUBCON_LISTING @param=N'{"client":"0805","type_of_vas":"SC","sub":"00","page_index":0,"page_size":20,"search_term":"","selected_subcon_no":"","export_ind":0}'  
-- Output:  
-- 1) dtCount - Total rows  
-- 2) dtHdr - Header  
-- 3) dtDtl - Details  
-- 4) dtExportInd - Export indicator  
-- 5) dtAuditTrail - Audit trail  
-- 6) dtExportColumnName - Export column display name  
-- ======================================================================================================================================  
 -- exec SPP_MST_SUBCON_LISTING @param=N'{"client":"0323","type_of_vas":"SC","sub":"00","page_index":0,"page_size":20,"search_term":"","selected_subcon_no":"","export_ind":0}'




CREATE PROCEDURE [dbo].[SPP_MST_SUBCON_LISTING]  
 @param nvarchar(max)  
AS  
BEGIN  
 SET NOCOUNT ON;  
  
 DECLARE @client VARCHAR(50), @type_of_vas VARCHAR(50), @sub VARCHAR(50), @page_index INT, @page_size INT, @search_term NVARCHAR(100), @selected_subcon_no VARCHAR(100), @export_ind CHAR(1)  
 SET @client = (SELECT JSON_VALUE(@param, '$.client'))  
 SET @type_of_vas = (SELECT JSON_VALUE(@param, '$.type_of_vas'))  
 SET @sub = (SELECT JSON_VALUE(@param, '$.sub'))  
 SET @page_index = (SELECT JSON_VALUE(@param, '$.page_index'))  
 SET @page_size = (SELECT JSON_VALUE(@param, '$.page_size'))  
 SET @search_term = (SELECT JSON_VALUE(@param, '$.search_term'))  
 SET @selected_subcon_no = (SELECT JSON_VALUE(@param, '$.selected_subcon_no'))  
 SET @export_ind = (SELECT JSON_VALUE(@param, '$.export_ind'))  
 IF @selected_subcon_no = ''  
 BEGIN  
  SET @selected_subcon_no = (SELECT TOP 1 Subcon_no FROM TBL_MST_SUBCON_HDR WHERE client_code = @client AND type_of_vas = @type_of_vas AND sub = @sub ORDER BY created_date DESC)  
 END  
 /***** Header *****/  
 SELECT subcon_no, subcon_desc,A.created_date, 
 CASE WHEN LTRIM(RTRIM(subcon_status)) = 'Submitted' THEN 'Submitted by ' + B.user_name + ' on ' + CONVERT(VARCHAR(10),submitted_date, 121)  
      WHEN LTRIM(RTRIM(subcon_status)) = 'Approved' THEN 'Approved by ' + C.user_name + ' on ' + CONVERT(VARCHAR(10),approved_date, 121)  
   WHEN LTRIM(RTRIM(subcon_status)) = 'Rejected' THEN 'Rejected by ' + D.user_name + ' on ' + CONVERT(VARCHAR(10),rejected_date, 121) + ' (' + rejection_reason + ')'  
 ELSE LTRIM(RTRIM(subcon_status)) END as subcon_status, E.dept_name as department, ISNULL(subcon_change_remarks, '') as subcon_change_remarks, ISNULL(subcon_urgent, '') as subcon_urgent  
 INTO #SUBCON_HDR   
 FROM TBL_MST_SUBCON_HDR A WITH(NOLOCK)  
 LEFT JOIN VAS.dbo.TBL_ADM_USER B WITH(NOLOCK) ON A.submitted_by = B.user_id   
 LEFT JOIN VAS.dbo.TBL_ADM_USER C WITH(NOLOCK) ON A.approved_by = C.user_id  
 LEFT JOIN VAS.dbo.TBL_ADM_USER D WITH(NOLOCK) ON A.rejected_by = D.user_id  
 LEFT JOIN VAS.dbo.TBL_ADM_USER F WITH(NOLOCK) ON A.creator_user_id = F.user_id  
 LEFT JOIN TBL_MST_DEPARTMENT E WITH(NOLOCK) ON F.department = E.dept_code  
 WHERE client_code = @client AND type_of_vas = @type_of_vas AND sub = @sub ORDER BY A.created_date DESC  
 --WHERE subcon_no = @selected_subcon_no  
 /******************/  
 /***** Details *****/  
 CREATE TABLE #SUBCON_DTL  
 (  
  client_code VARCHAR(50),  
  client_name NVARCHAR(200),  
  subcon_no VARCHAR(100),  
  subcon_status VARCHAR(100),  
  expiry_date  VARCHAR(100),  
  prd_code VARCHAR(50),  
  prd_desc NVARCHAR(MAX),  
  reg_no VARCHAR(MAX),  
  remarks  NVARCHAR(MAX),  
  vas_activities NVARCHAR(MAX),  
  qa_required INT,  
  created_date  Datetime,
  row_different_ind CHAR(1) DEFAULT 0,  
 )  
  
 IF @search_term <> ''  
 BEGIN  
  INSERT INTO #SUBCON_DTL  
  (client_code, client_name, subcon_no,subcon_status,expiry_date, prd_code, prd_desc, reg_no, remarks, vas_activities, qa_required,created_date)  
  SELECT distinct B.client_code, C.client_name, A.subcon_no,A.subcon_status,CASE WHEN expiry_date IS NULL THEN '' ELSE CONVERT(VARCHAR(11), expiry_date, 13) END as expiry_date, A.prd_code, D.prd_desc, registration_no,     
         remarks, vas_activities, qa_required,B.created_date  
  FROM TBL_MST_SUBCON_DTL A WITH(NOLOCK)  
  INNER JOIN TBL_MST_SUBCON_HDR B WITH(NOLOCK) ON A.subcon_no = B.subcon_no  
  INNER JOIN TBL_MST_CLIENT C WITH(NOLOCK) ON B.client_code = C.client_code  
  INNER JOIN TBL_MST_PRODUCT D WITH(NOLOCK) ON A.prd_code = D.prd_code    
  WHERE B.client_code = @client AND type_of_vas = @type_of_vas AND sub = @sub --AND B.subcon_no = @selected_subcon_no  
  AND ( 
	A.subcon_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE A.subcon_no END OR	
	A.prd_code LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE A.prd_code END OR  
    prd_desc LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE prd_desc END OR  
    registration_no LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE registration_no END OR  
    remarks LIKE CASE WHEN @search_term <> '' THEN '%' + @search_term + '%' ELSE remarks END)  
 END  
 ELSE  
 BEGIN  
  INSERT INTO #SUBCON_DTL  
  (client_code, client_name, subcon_no,subcon_status,expiry_date, prd_code, prd_desc, reg_no, remarks, vas_activities, qa_required,created_date)  
  SELECT distinct B.client_code, C.client_name, A.subcon_no,A.subcon_status,CASE WHEN expiry_date IS NULL THEN '' ELSE CONVERT(VARCHAR(11), expiry_date, 13) END as expiry_date, A.prd_code, D.prd_desc, registration_no,            
         remarks, vas_activities, qa_required,B.created_date  
  FROM TBL_MST_SUBCON_DTL A WITH(NOLOCK)  
  INNER JOIN TBL_MST_SUBCON_HDR B WITH(NOLOCK) ON A.subcon_no = B.subcon_no  
  INNER JOIN TBL_MST_CLIENT C WITH(NOLOCK) ON B.client_code = C.client_code  
  INNER JOIN TBL_MST_PRODUCT D WITH(NOLOCK) ON A.prd_code = D.prd_code  
  WHERE B.client_code = @client AND type_of_vas = @type_of_vas AND sub = @sub --AND B.subcon_no = @selected_subcon_no  
    
 END  
 /*******************/  
  
 /*** Find difference between current SUBCON and last effective SUBCON ***/  
 DECLARE @last_effective_subcon_no VARCHAR(50)  
 SET @last_effective_subcon_no = (SELECT TOP 1 subcon_no FROM TBL_MST_SUBCON_HDR WITH(NOLOCK) WHERE client_code = @client AND type_of_vas = @type_of_vas AND sub = @sub --AND subcon_no <> @selected_subcon_no   
 AND LTRIM(RTRIM(subcon_status)) = 'Approved' ORDER BY created_date DESC)  
   
 IF @last_effective_subcon_no <> ''  
 BEGIN  
  SELECT prd_code, registration_no, remarks, vas_activities INTO #TEMP_DIFF_SUBCON  
  FROM  
  (  
  SELECT t1.prd_code,t1.registration_no, t1.remarks, t1.vas_activities  
  FROM tbl_mst_subcon_dtl t1 where subcon_no = @selected_subcon_no  
  UNION ALL  
  SELECT t2.prd_code, t2.registration_no, t2.remarks, t2.vas_activities  
  FROM tbl_mst_subcon_dtl t2 where subcon_no = @last_effective_subcon_no  
  ) t  
  GROUP BY prd_code, registration_no, remarks, vas_activities  
  HAVING COUNT(*) = 1  
  
  UPDATE A  
  SET row_different_ind = 1  
  FROM #SUBCON_DTL A, #TEMP_DIFF_SUBCON B  
  WHERE A.prd_code = B.prd_code AND A.reg_no = B.registration_no AND A.remarks = B.remarks AND A.vas_activities = B.vas_activities  
  AND @selected_subcon_no NOT LIKE '%00001'  
  
  DROP TABLE #TEMP_DIFF_SUBCON  
 END  
 /*** Find difference between current SUBCON and last effective SUBCON ***/  
  
 /***** Temp table for vas activities name *****/  
 DECLARE @count INT = (SELECT COUNT(*) FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING A WITH(NOLOCK)  
      INNER JOIN VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) ON A.page_dtl_id = B.page_dtl_id   
      WHERE principal_code = 'MY-HEC' AND input_name LIKE 'vas_activities_%')  
  
 DECLARE @i INT = 0, @sql NVARCHAR(MAX) = ''  
 CREATE TABLE #SUBCON_TEMPNAME (page_dtl_id INT, input_name VARCHAR(50), display_name NVARCHAR(250))  
 WHILE @i < @count  
 BEGIN  
  SET @sql +=' INSERT INTO #SUBCON_TEMPNAME (page_dtl_id) SELECT DISTINCT JSON_VALUE(vas_activities, + ''$[' + CAST(@i as varchar(50)) + '].page_dtl_id'') FROM #SUBCON_DTL'  
  SET @i = @i + 1  
 END  
 SET @sql += ' DELETE FROM #SUBCON_TEMPNAME WHERE page_dtl_id IS NULL'  
 EXEC (@sql)  
  
 UPDATE A  
 SET A.input_name = B.input_name  
 FROM #SUBCON_TEMPNAME A, VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) WHERE A.page_dtl_id = B.page_dtl_id  
  
 UPDATE A  
 SET A.display_name = B.display_name  
 FROM #SUBCON_TEMPNAME A, VAS.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING B WITH(NOLOCK) WHERE A.page_dtl_id = B.page_dtl_id AND principal_code = 'MY-HEC'  
 /***** Temp table for vas activities name *****/  
  
 DECLARE @sqlCommand NVARCHAR(MAX), @j INT = 0, @count_tempname INT  
 SET @count_tempname = (SELECT COUNT(*) FROM #SUBCON_TEMPNAME)  
 SET @sqlCommand = 'CREATE TABLE #SUBCON_DTL_2(client_code VARCHAR(50), client_name NVARCHAR(200), subcon_no VARCHAR(100),subcon_status VARCHAR(100),expiry_date VARCHAR(100), prd_code VARCHAR(50), prd_desc NVARCHAR(MAX), reg_no VARCHAR(50), remarks NVARCHAR(MAX), vas_activities NVARCHAR(MAX), qa_required INT,created_date DATETIME,  row_different_ind CHAR(1), ' SELECT @sqlCommand += input_name + ' NVARCHAR(2000) NULL, ' FROM #SUBCON_TEMPNAME WHERE page_dtl_id IS NOT NULL   
 SET @sqlCommand = LEFT(@sqlCommand , len (@sqlCommand) - 1 ) + ') '  
  
 SET @sqlCommand += 'DECLARE @column_temp NVARCHAR(MAX), @tmp NVARCHAR(MAX) SELECT @tmp = @tmp + name + '', '' from tempdb.sys.columns where object_id = object_id(''tempdb..#SUBCON_DTL_2'') '  
 SET @sqlCommand += 'SET @column_temp = (SELECT SUBSTRING(@tmp, 0, LEN(@tmp)))'  
 SET @sqlCommand += 'INSERT INTO #SUBCON_DTL_2 '  
 SET @sqlCommand += 'SELECT *, '  
 WHILE @j < @count_tempname  
 BEGIN  
  SET @sqlCommand += ' JSON_VALUE(vas_activities, + ''$[' + CAST(@j as varchar(50)) + '].prd_code'') '   
  SET @sqlCommand += ' + CASE WHEN JSON_VALUE(vas_activities, + ''$[' + CAST(@j as varchar(50)) + '].radio_val'') = '''' THEN '''' ELSE '' ('' + JSON_VALUE(vas_activities, + ''$[' + CAST(@j as varchar(50)) + '].radio_val'') + '')'' END '  
  IF @j <> @count_tempname-1 SET @sqlCommand += ','  
  SET @j = @j + 1  
 END  
 SET @sqlCommand += ' FROM #SUBCON_DTL '  
  
 IF (@export_ind = '0')  
  SET @sqlCommand += 'ORDER BY created_date desc OFFSET ' + CAST(@page_index * @page_size as varchar(250)) + ' ROWS FETCH NEXT ' + cast(@page_size as varchar(50)) + ' ROWS ONLY SELECT * FROM #SUBCON_DTL_2 DROP TABLE #SUBCON_DTL_2'  
 ELSE IF (@export_ind = '1')  
  SET @sqlCommand += 'ORDER BY created_date desc SELECT * FROM #SUBCON_DTL_2 DROP TABLE #SUBCON_DTL_2'  
  
  
 /*** Output ***/  
 SELECT COUNT(1) as ttl_rows FROM #SUBCON_DTL            --1--  
 SELECT * FROM #SUBCON_HDR                 --2--  
 IF (SELECT COUNT(*) FROM #SUBCON_DTL) > 0 EXEC(@sqlCommand) ELSE SELECT * FROM #SUBCON_DTL  --3--  
 SELECT @export_ind AS export_ind              --4--  
   
  
 /***** Audit Trail *****/  
 SELECT TOP 10 (action+' - '+A.key_code) as action, B.user_name as action_by, CONVERT(VARCHAR(20), action_date, 121) as action_date  --5--  
 FROM TBL_ADM_AUDIT_TRAIL A WITH(NOLOCK)  
 INNER JOIN VAS.dbo.TBL_ADM_USER B WITH(NOLOCK) ON A.action_by = B.user_id 
 INNER JOIN dbo.TBL_MST_SUBCON_HDR C ON A.key_code= C.subcon_no
 WHERE module = 'SUBCON' AND client_code = @client AND type_of_vas = @type_of_vas AND sub = @sub --AND key_code = @selected_subcon_no  
 ORDER BY action_date DESC  
 /***********************/  
  
 IF @export_ind = '1'  
  EXEC SPP_GENERATE_SUBCON @selected_subcon_no, 1  
 ELSE IF @export_ind = '0'  
  SELECT * FROM #SUBCON_TEMPNAME --6--  
  WHERE page_dtl_id IS NOT NULL  
  UNION ALL  
  SELECT list_dtl_id as page_dtl_id, list_col_name, list_default_display_name as display_name   
  FROM [VAS].[dbo].TBL_ADM_CONFIG_PAGE_LISTING_DTL WITH(NOLOCK)  
  WHERE list_hdr_id IN (SELECT list_hdr_id FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_LISTING_HDR WITH(NOLOCK) WHERE page_code LIKE 'SUBCON%') AND list_col_name in (SELECT name FROM tempdb.sys.columns where object_id = object_id('tempdb..#SUBCON_DTL'))  
   
  -- SELECT * FROM #SUBCON_HDR
 SELECT top(1) subcon_no as last_subcon_no FROM #SUBCON_HDR ORDER BY created_date DESC, subcon_no desc--7--  
  
 DROP TABLE #SUBCON_TEMPNAME  
 DROP TABLE #SUBCON_HDR  
 DROP TABLE #SUBCON_DTL  
END
GO
