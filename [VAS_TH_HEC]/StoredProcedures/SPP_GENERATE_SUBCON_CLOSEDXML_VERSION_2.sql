SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec SPP_GENERATE_SUBCON_CLOSEDXML_VERSION_2 @param=N'{"client":"0G67","type_of_vas":"SC","sub":"01","page_index":0,"page_size":10,"search_term":"","selected_subcon_no":"","export_ind":0}'  
CREATE  PROCEDURE [dbo].[SPP_GENERATE_SUBCON_CLOSEDXML_VERSION_2]  
 @param nvarchar(max)  
AS  
BEGIN  
 SET NOCOUNT ON;  
  
 DECLARE @client VARCHAR(50), @type_of_vas VARCHAR(50), @sub VARCHAR(50), @subcon_no VARCHAR(100), @excel_ind CHAR(1)  
 SET @client = (SELECT JSON_VALUE(@param, '$.client'))  
 SET @type_of_vas = (SELECT JSON_VALUE(@param, '$.type_of_vas'))  
 SET @sub = (SELECT JSON_VALUE(@param, '$.sub'))  
 SET @subcon_no = (SELECT JSON_VALUE(@param, '$.selected_subcon_no'))  
 SET @excel_ind = (SELECT JSON_VALUE(@param, '$.export_ind'))  
  
 DECLARE @client_code VARCHAR(50), @client_name VARCHAR(350), @sub_code VARCHAR(50), @sub_name NVARCHAR(150)  
 --SET @client_code = (SELECT client_code FROM TBL_MST_SUBCON_HDR WITH(NOLOCK) WHERE subcon_no = @subcon_no)  
 SET @client_name = (SELECT client_name FROM TBL_MST_CLIENT WITH(NOLOCK) WHERE client_code = @client)  
 --SET @sub_code = (SELECT sub FROM TBL_MST_SUBCON_HDR WITH(NOLOCK) WHERE subcon_no = @subcon_no)  
 SET @sub_name = (SELECT sub_name FROM TBL_MST_CLIENT_SUB WITH(NOLOCK) WHERE client_code = @client AND sub_code = @sub)  
  
 DECLARE @form_control VARCHAR(20), @form_control_effective_date VARCHAR(50), @sop_no VARCHAR(50), @supercedes_subcon_no VARCHAR(50), @supercedes_subcon_no_change VARCHAR(50)  
 SET @form_control = (SELECT config_value FROM [VAS].dbo.TBL_ADM_CONFIGURATION_TH WITH(NOLOCK) WHERE config = 'TH_HEC_FORM_CONTROL')  
 SET @form_control_effective_date = (SELECT config_value FROM [VAS].dbo.TBL_ADM_CONFIGURATION_TH WITH(NOLOCK) WHERE config = 'TH_HEC_FORM_CONTROL_DATE')  
 SET @sop_no = (SELECT config_value FROM [VAS].dbo.TBL_ADM_CONFIGURATION_TH WITH(NOLOCK) WHERE config = 'TH_HEC_SOP')  
   
 --IF @subcon_no = ''  
 --BEGIN  
 -- SET @subcon_no = (SELECT TOP 1 subcon_no FROM TBL_MST_SUBCON_HDR WHERE client_code = @client AND type_of_vas = @type_of_vas AND sub = @sub ORDER BY subcon_no DESC)  
 --END  
   
 /** New **/  
 SET @supercedes_subcon_no = ISNULL((SELECT TOP 1 subcon_no FROM TBL_MST_SUBCON_HDR WITH(NOLOCK) WHERE client_code = @client AND type_of_vas = 'RD' AND sub = @sub AND subcon_no < @subcon_no AND subcon_status = 'Approved' ORDER BY subcon_no DESC),'')  
  
 SELECT subcon_no, ISNULL(subcon_desc,'') as subcon_desc,    
 ISNULL(client_ref_no,'') as client_ref_no, ISNULL(revision_no, '') as revision_no, A.creator_user_id, B.user_name as creator_user_name, CONVERT(VARCHAR(11), A.created_date, 13) as created_date, approved_by, ISNULL(C.user_name, '') as approver_name, ISNULL(CONVERT(VARCHAR(11), approved_date, 13), '') as approved_date  
 INTO #NEW_HEADER_TEMP  
 FROM TBL_MST_SUBCON_HDR A WITH(NOLOCK)  
 LEFT JOIN [VAS].dbo.TBL_ADM_USER B WITH(NOLOCK) ON A.creator_user_id = B.user_id   
 LEFT JOIN [VAS].dbo.TBL_ADM_USER C WITH(NOLOCK) ON A.approved_by = C.user_id  
 WHERE client_code = @client AND type_of_vas = @type_of_vas AND sub = @sub  
 --WHERE subcon_no = @subcon_no  
   
 CREATE TABLE #NEW_HEADER_INFO  
 (  
 cell varchar(100),  
 cell_value nvarchar(4000)  
 )  
  
 --INSERT INTO #NEW_HEADER_INFO  
 --(cell, cell_value)  
 --SELECT 'Q2', @form_control  
 --UNION ALL  
 --SELECT 'Q3', 'Effective Date: '+@form_control_effective_date  
 --UNION ALL  
 --SELECT 'Q4', 'SOP Ref: ' + @sop_no + ' Relabelling, Redressing & Repackaging (RS 7)'  
  
 --INSERT INTO #NEW_HEADER_INFO  
 --(cell, cell_value)  
 --SELECT 'A4', 'SOP No:'  
 --UNION ALL  
 --SELECT 'C4', @sop_no  
 --UNION ALL  
 --SELECT 'A5', 'Revision No:'  
 --UNION ALL   
 --SELECT 'C5', @subcon_no   
 ----UNION ALL  
 ----SELECT 'A7', 'Expiry Date'  
 ----UNION ALL  
 ----SELECT 'C7', expiry_date   
 --from #NEW_HEADER_TEMP   
 --UNION ALL  
 --SELECT 'A6', 'Prepared by Department Manager/ Executive/ Date:'  
 --UNION ALL  
 --SELECT 'C6', creator_user_name from #NEW_HEADER_TEMP  
 --UNION ALL  
 --SELECT 'C7', created_date from #NEW_HEADER_TEMP   
  
 INSERT INTO #NEW_HEADER_INFO  
 (cell, cell_value)  
 SELECT 'A2', 'CLIENT'  
 UNION ALL  
 SELECT 'C2', @client_name  
 UNION ALL  
 SELECT 'D2', @sub_name  
  
 -- 1. New header  
 SELECT * FROM #NEW_HEADER_INFO  
 DROP TABLE #NEW_HEADER_INFO  
 DROP TABLE #NEW_HEADER_TEMP  
  
  
 CREATE TABLE #NEW_DETAIL_TEMP  
 (  
  row_num int identity(1,1),  
  client_code VARCHAR(50),  
  client_name NVARCHAR(200),  
  subcon_no  VARCHAR(100),  
  subcon_status VARCHAR(100),  
  prd_desc NVARCHAR(2000),  
  prd_code VARCHAR(50),  
  reg_no VARCHAR(150),   
  expiry_date VARCHAR(150),  
  remarks  NVARCHAR(MAX),  
  vas_activities NVARCHAR(MAX),  
  cell_num INT,  
  row_different_ind CHAR(1) DEFAULT 0  
 )  
  
 INSERT INTO #NEW_DETAIL_TEMP  
 (client_code, client_name, subcon_no,subcon_status, prd_desc, prd_code, reg_no,expiry_date,remarks, vas_activities)  
 SELECT distinct B.client_code, C.client_name, A.subcon_no,A.subcon_status, D.prd_desc, A.prd_code, registration_no,  
 CASE WHEN expiry_date IS NULL THEN '' ELSE CONVERT(VARCHAR(11), expiry_date, 13) END as expiry_date,ISNULL(remarks,''), vas_activities  
 FROM TBL_MST_SUBCON_DTL A WITH(NOLOCK)  
 INNER JOIN TBL_MST_SUBCON_HDR B WITH(NOLOCK) ON A.subcon_no = B.subcon_no  
 INNER JOIN TBL_MST_CLIENT C WITH(NOLOCK) ON B.client_code = C.client_code  
 INNER JOIN TBL_MST_PRODUCT D WITH(NOLOCK) ON A.prd_code = D.prd_code   
 WHERE B.client_code = @client AND B.type_of_vas = @type_of_vas AND B.sub = @sub  
 --WHERE B.subcon_no = @subcon_no  
   
 /***** Temp table for vas activities name *****/  
 DECLARE @count INT = (SELECT COUNT(*) FROM [VAS].dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING A WITH(NOLOCK)  
      INNER JOIN [VAS].dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) ON A.page_dtl_id = B.page_dtl_id   
      WHERE principal_code = 'MY-HEC' AND input_name LIKE 'vas_activities_%')  
   
 DECLARE @i INT = 0, @sql NVARCHAR(MAX) = ''  
 CREATE TABLE #NEW_SUBCON_TEMPNAME (page_dtl_id INT, input_name VARCHAR(50), display_name NVARCHAR(250))  
 WHILE @i < @count  
 BEGIN  
  SET @sql +=' INSERT INTO #NEW_SUBCON_TEMPNAME (page_dtl_id) SELECT DISTINCT JSON_VALUE(vas_activities, + ''$[' + CAST(@i as varchar(50)) + '].page_dtl_id'') FROM #NEW_DETAIL_TEMP'  
  SET @i = @i + 1  
 END  
   
 SET @sql += ' DELETE FROM #NEW_SUBCON_TEMPNAME WHERE page_dtl_id IS NULL'  
 EXEC (@sql)  
  
 UPDATE A  
 SET A.input_name = B.input_name  
 FROM #NEW_SUBCON_TEMPNAME A, [VAS].dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) WHERE A.page_dtl_id = B.page_dtl_id  
   
 UPDATE A  
 SET A.display_name = B.display_name  
 FROM #NEW_SUBCON_TEMPNAME A, [VAS].dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING B WITH(NOLOCK) WHERE A.page_dtl_id = B.page_dtl_id AND principal_code = 'MY-HEC'  
 /***** Temp table for vas activities name *****/  
  
 DECLARE @sqlCommand NVARCHAR(MAX), @j INT = 0, @count_tempname INT  
 SET @count_tempname = (SELECT COUNT(*) FROM #NEW_SUBCON_TEMPNAME)  
 SET @sqlCommand = 'CREATE TABLE #NEW_DETAIL_INFO(row_num INT, client_code VARCHAR(50), client_name NVARCHAR(200), subcon_no VARCHAR(100),subcon_status VARCHAR(100), prd_desc NVARCHAR(2000), prd_code VARCHAR(50), reg_no VARCHAR(150),expiry_date VARCHAR(150), remarks NVARCHAR(MAX), vas_activities NVARCHAR(MAX), cell_num INT, row_different_ind CHAR(1), ' SELECT @sqlCommand += input_name + ' NVARCHAR(2000) NULL, ' FROM #NEW_SUBCON_TEMPNAME WHERE page_dtl_id IS NOT NULL   
 SET @sqlCommand = LEFT(@sqlCommand , len (@sqlCommand) - 1 ) + ') '  
   
 SET @sqlCommand += 'DECLARE @column_temp NVARCHAR(MAX), @tmp NVARCHAR(MAX) SELECT @tmp = @tmp + name + '', '' from tempdb.sys.columns where object_id = object_id(''tempdb..#NEW_DETAIL_INFO'') '  
 SET @sqlCommand += 'SET @column_temp = (SELECT SUBSTRING(@tmp, 0, LEN(@tmp)))'  
 SET @sqlCommand += 'INSERT INTO #NEW_DETAIL_INFO '  
 SET @sqlCommand += 'SELECT *, '  
 WHILE @j < @count_tempname  
 BEGIN  
  SET @sqlCommand += ' JSON_VALUE(vas_activities, + ''$[' + CAST(@j as varchar(50)) + '].prd_code'') '   
  SET @sqlCommand += ' + CASE WHEN JSON_VALUE(vas_activities, + ''$[' + CAST(@j as varchar(50)) + '].radio_val'') = '''' THEN '''' ELSE '' ('' + JSON_VALUE(vas_activities, + ''$[' + CAST(@j as varchar(50)) + '].radio_val'') + '')'' END '  
  IF @j <> @count_tempname-1 SET @sqlCommand += ','  
  SET @j = @j + 1  
 END  
 SET @sqlCommand += ' FROM #NEW_DETAIL_TEMP '  
  
 SET @sqlCommand += 'ORDER BY prd_code '  
   
 SET @sqlCommand += 'SELECT * FROM #NEW_DETAIL_INFO ORDER BY row_num ASC DROP TABLE #NEW_DETAIL_INFO'  
  
 -- 2. New Details  
 EXEC(@sqlCommand)  
 /** New **/  
  
 -- 5. Column names  
 SELECT * FROM #NEW_SUBCON_TEMPNAME  
 WHERE page_dtl_id IS NOT NULL  
 UNION ALL  
 SELECT '', 'row_num', 'No'  
 UNION ALL  
 SELECT '', 'subcon_no', 'Subcon WI No'  
 UNION ALL  
 SELECT '', 'subcon_status', 'Status'  
 UNION ALL  
 SELECT '', 'prd_desc', 'Product Description'  
 UNION ALL  
 SELECT '', 'prd_code', 'Stock Code'  
 UNION ALL  
 SELECT '', 'reg_no', 'MAL/MDA Registration No.'   
 UNION ALL  
 SELECT '', 'expiry_date', 'Expiry Date'  
 UNION ALL  
 SELECT '', 'remarks', 'Remark'  
  
  
 -- 6. To be hide column  
 CREATE TABLE #B (to_be_hide_column varchar(200))  
 INSERT INTO #B (to_be_hide_column)  
 SELECT 'client_code'  
 UNION   
 SELECT 'client_name'  
 --UNION   
 --SELECT 'subcon_no'   
 UNION   
 SELECT 'vas_activities'  
 UNION  
 SELECT 'row_different_ind'  
 UNION   
 SELECT 'cell_num'  
  
 select * from #B  
  
 -- 7. Range to merge  
 create table #c(range_type varchar(200), range varchar(100))  
 insert into #c  
 --select 'merge_range', 'A2:C2'  
 --union   
 --select 'merge_range', 'A4:B4'  
 --union  
 --select 'merge_range', 'A5:B5'  
 --union  
 --select 'merge_range', 'A6:B6'  
 --union  
 --select 'merge_range', 'A7:B7'  
 --union  
 --select 'merge_range', 'A8:B8'  
 --union   
 select 'merge_range', 'A2:B2'  
 --union   
 --select 'merge_range', 'A6:B7'  
 --union   
 --select 'merge_range', 'A11:B12'  
 --union  
 --select 'merge_range', 'A6:B7'  
 --union  
 --select 'merge_range', 'C6:C7'  
 --union  
 --select 'merge_range', 'C11:C12'  
 --union  
 --select 'font_bold', 'A4:C7'  
 union  
 select 'font_bold', 'A3:Q3'  
 union  
 select 'font_bold', 'A2:D2'  
 union   
 select 'h_align_center', 'A:Q' --select 'h_align_center', 'C4:C12'  
 union  
 select 'h_align_right', 'A2:A2'  
 union  
 select 'h_align_left', 'Q2:Q4'  
 union  
 select 'h_align_left', 'A2:A3'  
 --union   
 --select 'top_border', 'A4:A7'  
 --union  
 --select 'top_border', 'B4:B7'  
 --union  
 --select 'top_border', 'C4:C7'  
 --union  
 --select 'bottom_border', 'A7:C7'  
 --union  
 --select 'right_border', 'B4:B7'  
 --union  
 --select 'right_border', 'C4:C7'  
 --union  
 --select 'left_border', 'A4:A7'  
 union  
 select 'top_border', 'A2:D2'  
 union  
 select 'right_border', 'B2'  
 union  
 select 'right_border', 'C2'  
 union  
 select 'right_border', 'D2'  
 select * from #c  
  
  
 IF @subcon_no NOT LIKE '%00001'  
 BEGIN  
  /** Changes **/  
  --SET @supercedes_subcon_no_change = ISNULL((SELECT TOP 1 subcon_no FROM TBL_MST_SUBCON_HDR WITH(NOLOCK) WHERE client_code = @client_code AND type_of_vas = 'SC' AND sub = @sub_code AND subcon_no < @supercedes_subcon_no AND subcon_status = 'Approved' ORDER BY subcon_no DESC),'')  
  
  SELECT subcon_no, ISNULL(subcon_desc,'') as subcon_desc,   
  ISNULL(client_ref_no,'') as client_ref_no, ISNULL(revision_no, '') as revision_no, A.creator_user_id, B.user_name as creator_user_name, CONVERT(VARCHAR(11), A.created_date, 13) as created_date, approved_by, ISNULL(C.user_name, '') as approver_name, ISNULL(CONVERT(VARCHAR(11), approved_date, 13), '') as approved_date  
  INTO #CHANGES_HEADER_TEMP  
  FROM TBL_MST_SUBCON_HDR A WITH(NOLOCK)  
  LEFT JOIN [VAS].dbo.TBL_ADM_USER B WITH(NOLOCK) ON A.creator_user_id = B.user_id   
  LEFT JOIN [VAS].dbo.TBL_ADM_USER C WITH(NOLOCK) ON A.approved_by = C.user_id  
  --WHERE subcon_no = @supercedes_subcon_no  
  
  CREATE TABLE #CHANGES_HEADER_INFO  
  (  
   cell varchar(100),  
   cell_value nvarchar(4000)  
  )  
  
  --INSERT INTO #CHANGES_HEADER_INFO  
  --(cell, cell_value)  
  --SELECT 'Q2', @form_control  
  --UNION ALL  
  --SELECT 'Q3','Effective Date: '+  @form_control_effective_date  
  --UNION ALL  
  --SELECT 'Q4', 'SOP Ref: ' + @sop_no + ' Relabelling, Redressing & Repackaging (RS 7)'  
    
  
  --INSERT INTO #CHANGES_HEADER_INFO  
  --(cell, cell_value)  
  --SELECT 'A4', 'SOP No:'  
  --UNION ALL  
  --SELECT 'C4', @sop_no  
  --UNION ALL  
  --SELECT 'A5', 'Revision No:'  
  --UNION ALL   
  --SELECT 'C5', @supercedes_subcon_no    
  ----UNION ALL  
  ----SELECT 'A7', 'Expiry Date'  
  ----UNION ALL  
  ----SELECT 'C7', expiry_date   
  --from #CHANGES_HEADER_TEMP    
  --UNION ALL  
  --SELECT 'A6', 'Prepared by Department Manager/ Executive/ Date:'  
  --UNION ALL  
  --SELECT 'C6', creator_user_name from #CHANGES_HEADER_TEMP  
  --UNION ALL  
  --SELECT 'C7', created_date from #CHANGES_HEADER_TEMP    
  
  INSERT INTO #CHANGES_HEADER_INFO  
  (cell, cell_value)  
  SELECT 'A2', 'CLIENT'  
  UNION ALL  
  SELECT 'C2', @client_name  
  UNION ALL  
  SELECT 'D2', @sub_name  
  
  -- 3. Changes header  
  SELECT * FROM #CHANGES_HEADER_INFO  
  DROP TABLE #CHANGES_HEADER_INFO  
  DROP TABLE #CHANGES_HEADER_TEMP  
  
  
  CREATE TABLE #CHANGES_DETAIL_TEMP  
  (  
   row_num int identity(1,1),  
   client_code VARCHAR(50),  
   client_name NVARCHAR(200),  
   subcon_no VARCHAR(100),  
   subcon_status VARCHAR(100),  
   prd_desc NVARCHAR(2000),  
   prd_code VARCHAR(50),  
   reg_no VARCHAR(150),    
   expiry_date VARCHAR(50),  
   remarks  NVARCHAR(MAX),  
   vas_activities NVARCHAR(MAX),  
   cell_num INT,  
   row_different_ind CHAR(1) DEFAULT 0 -- 0: no difference, 1: difference between lines, 2: not found in Changes, found in New (newly added line), 3: found in Changes, not found in New (deleted)  
  )  
  
  INSERT INTO #CHANGES_DETAIL_TEMP  
  (client_code, client_name, subcon_no, subcon_status, prd_desc, prd_code, reg_no,expiry_date,remarks, vas_activities)  
  SELECT distinct B.client_code, C.client_name, A.subcon_no,B.subcon_status, D.prd_desc, A.prd_code, registration_no,CASE WHEN expiry_date IS NULL THEN '' ELSE CONVERT(VARCHAR(11), expiry_date, 13) END as expiry_date, ISNULL(remarks,''), vas_activities  
  FROM TBL_MST_SUBCON_DTL A WITH(NOLOCK)  
  INNER JOIN TBL_MST_SUBCON_HDR B WITH(NOLOCK) ON A.subcon_no = B.subcon_no  
  INNER JOIN TBL_MST_CLIENT C WITH(NOLOCK) ON B.client_code = C.client_code  
  INNER JOIN TBL_MST_PRODUCT D WITH(NOLOCK) ON A.prd_code = D.prd_code    
  --WHERE B.subcon_no = @supercedes_subcon_no  
  
  /*** Find difference between current SUBCON and last effective SUBCON ***/  
  SELECT subcon_status,prd_code, registration_no,expiry_date, remarks, vas_activities INTO #TEMP_DIFF_SUBCON  
  FROM  
  (  
  SELECT t1.subcon_status,t1.prd_code,t1.registration_no,CASE WHEN t1.expiry_date IS NULL THEN '' ELSE CONVERT(VARCHAR(11), expiry_date, 13) END as expiry_date, t1.remarks, t1.vas_activities  
  FROM tbl_mst_subcon_dtl t1 where subcon_no = @supercedes_subcon_no  
  UNION ALL  
  SELECT t2.subcon_status,t2.prd_code, t2.registration_no,CASE WHEN t2.expiry_date IS NULL THEN '' ELSE CONVERT(VARCHAR(11), expiry_date, 13) END as expiry_date, t2.remarks, t2.vas_activities  
  FROM tbl_mst_subcon_dtl t2 where subcon_no = @subcon_no  
  ) t  
  GROUP BY subcon_status,prd_code, registration_no,expiry_date, remarks, vas_activities  
  HAVING COUNT(*) = 1  
   
  UPDATE A  
  SET row_different_ind = 1  
  FROM #CHANGES_DETAIL_TEMP A  
  WHERE A.prd_code IN (SELECT prd_code FROM #TEMP_DIFF_SUBCON)  
    
  DROP TABLE #TEMP_DIFF_SUBCON  
  /*** Find difference between current SUBCON and last effective SUBCON ***/  
  
  -- Add in line not found in Changes but in New  
  INSERT INTO #CHANGES_DETAIL_TEMP  
  (client_code, client_name, subcon_no,subcon_status, prd_desc, prd_code, reg_no,expiry_date,remarks, vas_activities, row_different_ind)  
  SELECT distinct  B.client_code, C.client_name, A.subcon_no,B.subcon_status, D.prd_desc, A.prd_code, registration_no,ISNULL(CONVERT(VARCHAR(11), expiry_date, 13),'') As expiry_date, ISNULL(remarks,''), vas_activities, 2  
  FROM TBL_MST_SUBCON_DTL A WITH(NOLOCK)  
  INNER JOIN TBL_MST_SUBCON_HDR B WITH(NOLOCK) ON A.subcon_no = B.subcon_no  
  INNER JOIN TBL_MST_CLIENT C WITH(NOLOCK) ON B.client_code = C.client_code  
  INNER JOIN TBL_MST_PRODUCT D WITH(NOLOCK) ON A.prd_code = D.prd_code    
  WHERE B.subcon_no = @subcon_no AND A.prd_code NOT IN (SELECT prd_code FROM TBL_MST_SUBCON_DTL WITH(NOLOCK) WHERE subcon_no = @supercedes_subcon_no)  
  
  UPDATE A  
  SET row_different_ind = 3  
  FROM #CHANGES_DETAIL_TEMP A  
  WHERE A.prd_code NOT IN (SELECT prd_code FROM TBL_MST_SUBCON_DTL WITH(NOLOCK) WHERE subcon_no = @subcon_no)  
  
  UPDATE #CHANGES_DETAIL_TEMP  
  SET cell_num = row_num + 15  
  
  /***** Temp table for vas activities name *****/  
  DECLARE @count_changes INT = (SELECT COUNT(*) FROM [VAS].dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING A WITH(NOLOCK)  
       INNER JOIN [VAS].dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) ON A.page_dtl_id = B.page_dtl_id   
       WHERE principal_code = 'MY-HEC' AND input_name LIKE 'vas_activities_%')  
  
  DECLARE @i_changes INT = 0, @sql_changes NVARCHAR(MAX) = ''  
  CREATE TABLE #CHANGES_SUBCON_TEMPNAME (page_dtl_id INT, input_name VARCHAR(50), display_name NVARCHAR(250))  
  WHILE @i_changes < @count_changes  
  BEGIN  
   SET @sql_changes +=' INSERT INTO #CHANGES_SUBCON_TEMPNAME (page_dtl_id) SELECT DISTINCT JSON_VALUE(vas_activities, + ''$[' + CAST(@i_changes as varchar(50)) + '].page_dtl_id'') FROM #CHANGES_DETAIL_TEMP'  
   SET @i_changes = @i_changes + 1  
  END  
  SET @sql_changes += ' DELETE FROM #CHANGES_SUBCON_TEMPNAME WHERE page_dtl_id IS NULL'  
  EXEC (@sql_changes)  
  
  UPDATE A  
  SET A.input_name = B.input_name  
  FROM #CHANGES_SUBCON_TEMPNAME A, [VAS].dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) WHERE A.page_dtl_id = B.page_dtl_id  
  
  UPDATE A  
  SET A.display_name = B.display_name  
  FROM #CHANGES_SUBCON_TEMPNAME A, [VAS].dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING B WITH(NOLOCK) WHERE A.page_dtl_id = B.page_dtl_id AND principal_code = 'MY-HEC'  
  /***** Temp table for vas activities name *****/  
  
  DECLARE @sqlCommand_changes NVARCHAR(MAX), @j_changes INT = 0, @count_tempname_changes INT  
  SET @count_tempname_changes = (SELECT COUNT(*) FROM #CHANGES_SUBCON_TEMPNAME)  
  SET @sqlCommand_changes = 'CREATE TABLE #CHANGES_DETAIL_INFO(row_num INT, client_code VARCHAR(50), client_name NVARCHAR(200), subcon_no VARCHAR(100),subcon_status VARCHAR(100), prd_desc NVARCHAR(2000), prd_code VARCHAR(50), reg_no VARCHAR(150),expiry_date VARCHAR(150), remarks NVARCHAR(MAX), vas_activities NVARCHAR(MAX), cell_num INT, row_different_ind CHAR(1), ' SELECT @sqlCommand_changes += input_name + ' NVARCHAR(2000) NULL, ' FROM #CHANGES_SUBCON_TEMPNAME WHERE page_dtl_id IS NOT NULL   
  SET @sqlCommand_changes = LEFT(@sqlCommand_changes , len (@sqlCommand_changes) - 1 ) + ') '  
  
  SET @sqlCommand_changes += 'DECLARE @column_temp NVARCHAR(MAX), @tmp NVARCHAR(MAX) SELECT @tmp = @tmp + name + '', '' from tempdb.sys.columns where object_id = object_id(''tempdb..#CHANGES_DETAIL_INFO'') '  
  SET @sqlCommand_changes += 'SET @column_temp = (SELECT SUBSTRING(@tmp, 0, LEN(@tmp)))'  
  SET @sqlCommand_changes += 'INSERT INTO #CHANGES_DETAIL_INFO '  
  SET @sqlCommand_changes += 'SELECT *, '  
  WHILE @j_changes < @count_tempname_changes  
  BEGIN  
   SET @sqlCommand_changes += ' JSON_VALUE(vas_activities, + ''$[' + CAST(@j_changes as varchar(50)) + '].prd_code'') '   
   SET @sqlCommand_changes += ' + CASE WHEN JSON_VALUE(vas_activities, + ''$[' + CAST(@j_changes as varchar(50)) + '].radio_val'') = '''' THEN '''' ELSE '' ('' + JSON_VALUE(vas_activities, + ''$[' + CAST(@j_changes as varchar(50)) + '].radio_val'') + '')'' END '  
   IF @j_changes <> @count_tempname_changes-1 SET @sqlCommand_changes += ','  
   SET @j_changes = @j_changes + 1  
  END  
  SET @sqlCommand_changes += ' FROM #CHANGES_DETAIL_TEMP '  
  
  SET @sqlCommand_changes += 'ORDER BY prd_code '  
   
  SET @sqlCommand_changes += 'SELECT * FROM #CHANGES_DETAIL_INFO ORDER BY row_num ASC DROP TABLE #CHANGES_DETAIL_INFO'  
  
  -- 4. Changes detail  
  EXEC(@sqlCommand_changes)  
  /** Changes **/  
  
  create table #D(range_type varchar(200), format_value varchar(200), range varchar(100))  
  INSERT INTO #D(range_type, format_value, range)  
  select 'highlight', '#FFFF00', 'A' + CAST(cell_num as VARCHAR(50)) + ':Q' + CAST(cell_num as VARCHAR(50)) FROM #CHANGES_DETAIL_TEMP WHERE row_different_ind = 1  
  union all  
  select 'highlight', '#FFFF00', 'A' + CAST(cell_num as VARCHAR(50)) + ':Q' + CAST(cell_num as VARCHAR(50)) FROM #CHANGES_DETAIL_TEMP WHERE row_different_ind = 2  
  union all  
  select 'font_color', '#ff1e1e', 'A' + CAST(cell_num as VARCHAR(50)) + ':Q' + CAST(cell_num as VARCHAR(50)) FROM #CHANGES_DETAIL_TEMP WHERE row_different_ind = 2  
  union all  
  select 'highlight', '#d1d1d1', 'A' + CAST(cell_num as VARCHAR(50)) + ':Q' + CAST(cell_num as VARCHAR(50)) FROM #CHANGES_DETAIL_TEMP WHERE row_different_ind = 3  
  
  SELECT * FROM #D  
  
  DROP TABLE #D  
  DROP TABLE #CHANGES_SUBCON_TEMPNAME  
  DROP TABLE #CHANGES_DETAIL_TEMP  
 END  
    
 DROP TABLE #B  
 DROP TABLE #C  
 DROP TABLE #NEW_SUBCON_TEMPNAME  
 DROP TABLE #NEW_DETAIL_TEMP   
END  

GO
