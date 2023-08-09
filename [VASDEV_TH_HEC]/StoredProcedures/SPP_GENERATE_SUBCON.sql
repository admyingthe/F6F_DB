SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
-- ========================================================  
-- Author:  Vijitha  
-- Create date: 2021-10-21  
-- Description: Generate SUBCON HTML string  
-- Example Query: exec SPP_GENERATE_SUBCON N'WI0G67102100001', 0   
-- ========================================================  
  
CREATE PROCEDURE [dbo].[SPP_GENERATE_SUBCON]  
 @subcon_no VARCHAR(50),  
 @excel_ind INT  
AS  
BEGIN  
 SET NOCOUNT ON;  
  
 DECLARE @client_code VARCHAR(50), @client_name VARCHAR(150), @sub_code VARCHAR(50), @sub_name NVARCHAR(150)  
 SET @client_code = (SELECT client_code FROM TBL_MST_SUBCON_HDR WITH(NOLOCK) WHERE subcon_no = @subcon_no)  
 SET @client_name = (SELECT client_name FROM TBL_MST_CLIENT WITH(NOLOCK) WHERE client_code = @client_code)  
 SET @sub_code = (SELECT sub FROM TBL_MST_SUBCON_HDR WITH(NOLOCK) WHERE subcon_no = @subcon_no)  
 SET @sub_name = (SELECT sub_name FROM TBL_MST_CLIENT_SUB WITH(NOLOCK) WHERE client_code = @client_code AND sub_code = @sub_code)  
  
 SELECT subcon_no, ISNULL(subcon_desc,'') as subcon_desc,   
 ISNULL(client_ref_no,'') as client_ref_no, ISNULL(revision_no, '') as revision_no, A.creator_user_id, B.user_name as creator_user_name, CONVERT(VARCHAR(11), A.created_date, 13) as created_date, approved_by, ISNULL(C.user_name, 'Auto') as approver_name, CONVERT(VARCHAR(11), approved_date, 13) as approved_date  
 INTO #GENERATE_SUBCON_HDR   
 FROM TBL_MST_SUBCON_HDR A WITH(NOLOCK)  
 LEFT JOIN VASDEV.dbo.TBL_ADM_USER B WITH(NOLOCK) ON A.creator_user_id = B.user_id   
 LEFT JOIN VASDEV.dbo.TBL_ADM_USER C WITH(NOLOCK) ON A.approved_by = C.user_id  
 WHERE subcon_no = @subcon_no  
  
 DECLARE @form_control VARCHAR(20), @form_control_effective_date VARCHAR(50), @sop_no VARCHAR(50), @supercedes_subcon_no VARCHAR(50)  
 SET @form_control = (SELECT config_value FROM VASDEV.dbo.TBL_ADM_CONFIGURATION_TH WITH(NOLOCK) WHERE config = 'TH_HEC_FORM_CONTROL')  
 SET @form_control_effective_date = (SELECT config_value FROM VASDEV.dbo.TBL_ADM_CONFIGURATION_TH WITH(NOLOCK) WHERE config = 'TH_HEC_FORM_CONTROL_DATE')  
 SET @sop_no = (SELECT config_value FROM VASDEV.dbo.TBL_ADM_CONFIGURATION_TH WITH(NOLOCK) WHERE config = 'TH_HEC_SOP')  
  
 SET @supercedes_subcon_no = ISNULL((SELECT TOP 1 subcon_no FROM TBL_MST_SUBCON_HDR WITH(NOLOCK) WHERE client_code = @client_code AND type_of_vas = 'RD' AND sub = @sub_code AND subcon_no < @subcon_no AND subcon_status = 'Approved' ORDER BY subcon_no DESC)
,'')  
  
 DECLARE @header_string NVARCHAR(MAX) = ''  
  
 IF @excel_ind = 1  
  SELECT @header_string = '<table><tr style="height:40px"><td style="width:40px"></td><td style="width:280px"></td><td style="width:100px"></td><td style="width:100px"></td><td style="width:100px"></td><td style="width:100px"></td><td style="width:100px">
</td><td style="width:100px"></td><td style="width:100px"></td><td style="width:100px"></td><td style="width:100px"></td><td style="width:100px"></td><td style="width:100px"></td><td style="width:150px"></td><td style="width:350px"><img src="http://portal
.dksh.com/vas_dev/images/dk_logo.png"/></td></tr>'  
        + '<tr style="font-family:Arial Narrow; font-size:13px;"><td colspan="3" style="width:40px">SOP Ref: ' + @sop_no + ' Relabelling, Redressing & Repackaging (RS 7)</td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>
<td></td><td></td><td>' + @form_control + '</td></tr>'  
        + '<tr style="font-family:Arial Narrow; font-size:13px;"><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td>Effective Date: ' + @form_control_effective_date + '</td></tr></table>'  
        + '<table style="font-family:Arial Narrow; font-size:13px; font-weight:bold">'  
        + '<tr style="border-bottom: 0.5pt solid; border-top: 0.5pt solid"><td colspan="2" style="border-right: 0.5pt solid">SOP No:</td><td style="border-top: 0.5pt solid; border-right: 0.5pt solid; text-align:center">' + @sop_no + '</td></tr>'  
        + '<tr style="border-bottom: 0.5pt solid; border-top: 0.5pt solid"><td colspan="2" style="border-right: 0.5pt solid">Revision No:</td><td style="border-right: 0.5pt solid; text-align:center;">' + subcon_no + '</td></tr>'  
        + '<tr style="border-bottom: 0.5pt solid; border-top: 0.5pt solid"><td colspan="2" style="border-right: 0.5pt solid">Supercedes Revision No:</td><td style="border-right: 0.5pt solid; text-align:center">' + @supercedes_subcon_no + '</td></tr>'     
     
        + '<tr rowspan="2" style="border-bottom: 0.5pt solid; border-top: 0.5pt solid"><td colspan="2" style="border-right: 0.5pt solid">Prepared by Department Manager/ Executive/ Date:</td><td style="border-right: 0.5pt solid; text-align:center">' + ISNULL(creator_user_name,'') + '<br/>' + ISNULL(created_date,'') + '</td></tr>'  
        + '<tr rowspan="2" style="border-bottom: 0.5pt solid"><td colspan="2" style="border-right: 0.5pt solid">Approved by GM/ Date:</td><td style="border-right: 0.5pt solid; text-align:center">' +  ISNULL(approver_name,'') + '<br/>' + ISNULL(approved_date,'') + '</td></tr></table><br/>'  
  FROM #GENERATE_SUBCON_HDR  
 ELSE  
  SELECT @header_string = '<div style="width:94.8px; height:37.2px"><img src="http://portal.dksh.com/vas_dev/images/logo_dksh.png" style="margin-top:5px; margin-right: 10px; height: 30px; position:absolute; top:0px; right:0px"/></div>'  
        + '<span style="font-family:Arial Narrow; font-size:13px; margin-top:10px; margin-right: 10px; height: 30px; position:absolute; top:30px; right:0px">' + @form_control + '</span>'  
        + '<span style="font-family:Arial Narrow; font-size:13px; margin-top:10px; margin-right: 10px; height: 30px; position:absolute; top:50px; right:0px">Effective Date: ' + @form_control_effective_date + '</span>'  
        + '<span style="font-family:Arial Narrow; font-size:13px; margin-top:10px; margin-right: 10px; height: 30px; position:absolute; top:70px; right:0px">SOP Ref: ' + @sop_no + ' Relabelling, Redressing & Repackaging (RS 7)</span></div>'  
        + '<div style="width: 100%;"><table style="border-collapse: collapse; border: 0.5pt solid; padding: 8px; font-family:Arial Narrow; font-size:13px; font-weight:bold;">'  
        + '<tr style="border-bottom: 0.5pt solid"><td style="width: 300px; border-right: 0.5pt solid">SOP No:</td><td style="width: 150px; text-align:center">' + @sop_no + '</td></tr>'  
        + '<tr style="border-bottom: 0.5pt solid"><td style="width: 300px; border-right: 0.5pt solid">Revision No:</td><td style="width: 150px; text-align:center">' + subcon_no + '</td></tr>'  
        + '<tr style="border-bottom: 0.5pt solid"><td style="width: 300px; border-right: 0.5pt solid">Supercedes Revision No:</td><td style="width: 150px; text-align:center">' + @supercedes_subcon_no + '</td></tr>'          
        + '<tr rowspan="2" style="border-bottom: 0.5pt solid"><td style="width: 300px; border-right: 0.5pt solid">Prepared by Department Manager/ Executive/ Date:</td><td style="width: 150px; text-align:center">' + ISNULL(creator_user_name,'') + '<br/>' +
 ISNULL(created_date,'') + '</td></tr>'  
        + '<tr rowspan="2"><td style="width: 300px; border-right: 0.5pt solid">Approved by GM/ Date:</td><td style="width: 150px; text-align:center">' +  ISNULL(approver_name,'') + '<br/>' + ISNULL(approved_date,'') + '</td></tr></table></div><br /><br />'  
  FROM #GENERATE_SUBCON_HDR  
  
 CREATE TABLE #GENERATE_SUBCON_DTL  
 (  
  row_num   INT IDENTITY(1,1),  
  client_code  VARCHAR(50),  
  client_name  NVARCHAR(200),  
  subcon_no   VARCHAR(100),  
  prd_code  VARCHAR(50),  
  prd_desc  NVARCHAR(MAX),  
  reg_no   VARCHAR(MAX),    
  remarks   NVARCHAR(MAX),  
  vas_activities NVARCHAR(MAX),  
  string_1  NVARCHAR(MAX),  
  string_2  NVARCHAR(MAX),  
  string_3  NVARCHAR(MAX)  
 )  
  
 INSERT INTO #GENERATE_SUBCON_DTL  
 (client_code, client_name, subcon_no, prd_code, prd_desc, reg_no, remarks, vas_activities)  
 SELECT distinct B.client_code, C.client_name, A.subcon_no, A.prd_code, D.prd_desc, registration_no, remarks, vas_activities  
 FROM TBL_MST_SUBCON_DTL A WITH(NOLOCK)  
 INNER JOIN TBL_MST_SUBCON_HDR B WITH(NOLOCK) ON A.subcon_no = B.subcon_no  
 INNER JOIN TBL_MST_CLIENT C WITH(NOLOCK) ON B.client_code = C.client_code  
 INNER JOIN TBL_MST_PRODUCT D WITH(NOLOCK) ON A.prd_code = D.prd_code   
 WHERE B.subcon_no = @subcon_no --and A.prd_code = '100062292'  
  
 /***** Temp table for vas activities name *****/  
 DECLARE @count INT = (SELECT COUNT(*) FROM VASDEV.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING A WITH(NOLOCK)  
      INNER JOIN VASDEV.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) ON A.page_dtl_id = B.page_dtl_id   
      WHERE principal_code = 'MY-HEC' AND input_name LIKE 'vas_activities_%')  
  
 DECLARE @i INT = 0, @sql NVARCHAR(MAX) = ''  
 CREATE TABLE #GENERATE_SUBCON_TEMPNAME (row_id INT IDENTITY(1,1), page_dtl_id INT, input_name VARCHAR(50), display_name NVARCHAR(250))  
 WHILE @i < @count  
 BEGIN  
  SET @sql +=' INSERT INTO #GENERATE_SUBCON_TEMPNAME (page_dtl_id) SELECT DISTINCT JSON_VALUE(vas_activities, + ''$[' + CAST(@i as varchar(50)) + '].page_dtl_id'') FROM #GENERATE_SUBCON_DTL'  
  SET @i = @i + 1  
 END  
 SET @sql += ' DELETE FROM #GENERATE_SUBCON_TEMPNAME WHERE page_dtl_id IS NULL'  
 EXEC (@sql)  
  
 UPDATE A  
 SET A.input_name = B.input_name  
 FROM #GENERATE_SUBCON_TEMPNAME A, VASDEV.dbo.TBL_ADM_CONFIG_PAGE_INPUT_DTL B WITH(NOLOCK) WHERE A.page_dtl_id = B.page_dtl_id  
  
 UPDATE A  
 SET A.display_name = B.display_name  
 FROM #GENERATE_SUBCON_TEMPNAME A, VASDEV.dbo.TBL_ADM_CONFIG_PAGE_INPUT_SETTING B WITH(NOLOCK) WHERE A.page_dtl_id = B.page_dtl_id AND principal_code = 'MY-HEC'  
 /***** Temp table for vas activities name *****/  
  
 DECLARE @j INT = 1, @vas_activities_string NVARCHAR(4000) = '', @vas_activities_name NVARCHAR(250)  
 WHILE @j <= (SELECT COUNT(*) FROM #GENERATE_SUBCON_TEMPNAME)  
 BEGIN  
  SET @vas_activities_name = (SELECT display_name FROM #GENERATE_SUBCON_TEMPNAME WHERE row_id = @j)  
  SET @vas_activities_string += '<th style="width: 150px; border-right:0.5pt solid">' + @vas_activities_name + '</th>'  
  SET @j = @j + 1  
 END  
  
 CREATE TABLE #A  
 (  
 row_num  INT,  
 json_string NVARCHAR(MAX),  
 html_string NVARCHAR(max)  
 )  
   
 CREATE TABLE #B  
 (  
 row_num INT,  
 key_value INT,  
 page_dtl_id VARCHAR(50),  
 prd_code VARCHAR(50),  
 radio_val CHAR(10),  
 html_string NVARCHAR(MAX)  
 )  
  
 INSERT INTO #A  
 SELECT row_num, vas_activities, NULL FROM #GENERATE_SUBCON_DTL  
  
 INSERT INTO #B  
 SELECT P.row_num, AttsData.[key] as key_value, JSON_VALUE(AttsData.[value], '$.page_dtl_id') page_dtl_id, JSON_VALUE(AttsData.[value], '$.prd_code') prd_code, RTRIM(LTRIM(JSON_VALUE(AttsData.[value], '$.radio_val'))) radio_val, cast(null as varchar(max))
 as html_string  
 FROM #A P CROSS APPLY OPENJSON (P.json_string) AS AttsData  
  
 UPDATE #B  
 SET html_string = '<td style="text-align:center; border-right:0.5pt solid">' + prd_code + '(' + RTRIM(LTRIM(radio_val)) + ')' + '</td>'  
  
 CREATE NONCLUSTERED INDEX ABC  
 ON #B (row_num)  
 INCLUDE (html_string)  
  
 SELECT DISTINCT row_num,  
     STUFF((  
        SELECT ' ' + html_string  
        FROM #B t1  
        WHERE t1.row_num = t2.row_num  
  ORDER BY key_value  
        FOR XML PATH('')  
    ), 1, 1, '') AS final_string INTO #C  
 FROM #B t2  
  
 --update a  
 --set html_string = replace(replace(c.final_string, '&lt;', '<'), '&gt;' ,'>')  
 --from #a a inner join #c c on a.row_num = c.row_num  
   
 UPDATE A  
 SET string_2 = REPLACE(REPLACE(C.final_string, '&lt;', '<'), '&gt;' ,'>')  
 FROM #GENERATE_SUBCON_DTL A INNER JOIN #C C ON A.row_num = C.row_num  
  
 UPDATE #GENERATE_SUBCON_DTL  
 SET string_1 = '<tr style="border-bottom:0.5pt solid; border-right:0.5pt solid">'  
      + '<td style="text-align:center; border-left:0.5pt solid; border-right:0.5pt solid">' + CAST(row_num as VARCHAR(20)) + '</td>'  
      + '<td style="text-align:left; border-right:0.5pt solid">' + prd_desc + '</td>'  
      + '<td style="text-align:center; border-right:0.5pt solid">' + prd_code + '</td>'  
      + '<td style="text-align:center; border-right:0.5pt solid">' + ISNULL(reg_no,'') + '</td>',  
  string_3 = '<td style="text-align:left; border-right:0.5pt solid">' + ISNULL(remarks,'') + '</td></tr>'  
  
 DECLARE @body_data NVARCHAR(MAX) = ''  
    
 --DECLARE @string1 NVARCHAR(MAX), @string2 NVARCHAR(MAX), @string3 NVARCHAR(MAX)  
 --SET @string1 = (SELECT string_1 FROM #GENERATE_SUBCON_DTL)  
 --SET @string2 = (SELECT string_2 FROM #GENERATE_SUBCON_DTL)  
 --SET @string3 = (SELECT string_3 FROM #GENERATE_SUBCON_DTL)  
  
 --SET @body_data = @string1 + @string2 + @string3  
  
 SET @body_data = (SELECT STUFF((  
        SELECT ' ' + string_1 + string_2 + string_3  
        FROM #GENERATE_SUBCON_DTL t1  
        FOR XML PATH('')  
    ), 1, 1, '') )  
  
 DECLARE @body_column NVARCHAR(MAX) = ''  
 SET @body_column += '<div style="width:100%"><table style="border-collapse: collapse; padding: 8px; font-family:Arial Narrow; font-size: 13px">'  
 SET @body_column += '<tr style="border-top:0.5pt solid">'  
        + '<th colspan="2" style="width: 350px; text-align:left; border-right:0.5pt solid; border-left:0.5pt solid">CLIENT:</th>'  
        + '<th style="width: 150px; text-align:center; border-right:0.5pt solid">' + @client_name + '</th>'  
        + '<th style="width: 150px; text-align:center; border-right:0.5pt solid">' + @sub_name + '</th></tr>'  
 SET @body_column += '<tr style="border-top:0.5pt solid; border-bottom:0.5pt solid; text-align:center">'  
        + '<th style="width: 30px; border-left:0.5pt solid; border-right:0.5pt solid">No</th>'  
        + '<th style="width: 400px; border-right:0.5pt solid">Product Description</th>'  
        + '<th style="width: 100px; border-right:0.5pt solid">Stock Code</th>'  
        + '<th style="width: 150px; border-right:0.5pt solid">MAL/MDA Registration No.</th>'  
 SET @body_column += @vas_activities_string   
        + '<th style="width: 150px; border-right:0.5pt solid">Storage Condition</th>'  
        + '<th style="width: 150px; border-right:0.5pt solid">Medial Device Usage</th>'  
        + '<th style="width: 150px; border-right:0.5pt solid">BM IFU</th>'  
        + '<th style="width: 350px; border-right:0.5pt solid">Remark</th></tr>'  
   
 SELECT @header_string as header_string, @body_column as body_column, replace(replace(@body_data, '&lt;', '<'), '&gt;' ,'>') as body_data  
  
 DROP TABLE #A  
 DROP TABLE #B  
 DROP TABLE #C  
 DROP TABLE #GENERATE_SUBCON_HDR  
 DROP TABLE #GENERATE_SUBCON_DTL  
 DROP TABLE #GENERATE_SUBCON_TEMPNAME  
END

GO
