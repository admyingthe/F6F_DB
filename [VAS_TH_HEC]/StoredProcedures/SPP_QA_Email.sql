SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[SPP_QA_Email]

AS
BEGIN

Declare @mll_status VARCHAR(50)  ='Approved' 
Declare  @mll_no VARCHAR(50) = 'MLL032400RD00003'
Declare  @user_id INT =1
declare @qry nvarchar(max)
declare @column1name varchar(50)

DECLARE @subject NVARCHAR(MAX), @body NVARCHAR(MAX), @profile_name VARCHAR(50), @client_code VARCHAR(50), @client_name VARCHAR(250),  
 @recipients_email VARCHAR(MAX), @copy_recipients_email VARCHAR(MAX), @user_name VARCHAR(250), @dept_code VARCHAR(50), @submitted_by_id INT

 SET @profile_name = (SELECT config_value FROM VAS.dbo.TBL_ADM_CONFIGURATION_TH WITH(NOLOCK) WHERE config = 'email_profile_name')
	SELECT @client_code = client_code, @submitted_by_id = submitted_by FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_no = @mll_no
	SET @client_name = (SELECT client_name FROM TBL_MST_CLIENT WITH(NOLOCK) WHERE client_code = @client_code)
	SET @user_name = (SELECT user_name FROM VAS.dbo.TBL_ADM_USER WITH(NOLOCK) WHERE user_id = @user_id)
	SET @dept_code = (SELECT department FROM VAS.dbo.TBL_ADM_USER WITH(NOLOCK) WHERE user_id = @submitted_by_id)

CREATE TABLE #HTML_STRING  
  (  
  string_a nvarchar(maX),  
  string_b nvarchar(maX),  
  string_c nvarchar(maX)  
  )  
  DECLARE @html NVARCHAR(MAX), @html_file_name VARCHAR(100), @html_full_path VARCHAR(1000), @pdf_full_path VARCHAR(1000), @strCMD VARCHAR(1000), @folder_path NVARCHAR(4000),  
    @remove_files NVARCHAR(MAX), @cmd VARCHAR(8000), @remove_folder NVARCHAR(MAX)  
  SET @folder_path = N'D:\VAS\MY-HEC\MLL\'  
  --For generate pdf use  
    
  -- Generate PDF  
  INSERT INTO #HTML_STRING(string_a, string_b, string_c)  
  EXEC SPP_GENERATE_MLL @mll_no, 0  
  
  SET @html = (SELECT string_a + string_b + string_c FROM #HTML_STRING)  
  SET @html_file_name = @mll_no + '.html' -- 2018/05/0001.html  
  
  --select * from #HTML_STRING  
   
  EXEC SPP_GENERATE_HTML @String = @html, @Path = @folder_path, @Filename = @html_file_name --Generate .html file in @folder_path  
   
  SET @html_full_path = @folder_path + @html_file_name -- D:\VAS\MY-HEC\@guid\html_file_name.html  
  SET @pdf_full_path = @folder_path + @mll_no + '.pdf' -- D:\VAS\MY-HEC\@guid\2018/05/0001.pdf  
  SET @strCMD = 'D:\VAS\wkhtmltopdf.exe --image-dpi -600 --image-dpi 100 -n --print-media-type -q -O landscape --quiet --header-html "" --header-spacing 30 --footer-html ""   ' + @html_full_path + '  ' + @pdf_full_path +'  '  
  
  EXEC xp_cmdshell @strCMD, no_output;  
  DROP TABLE #HTML_STRING  
  
  SELECT @recipients_email = recipients, @copy_recipients_email = copy_recipients FROM TBL_MST_MLL_EMAIL_CONFIGURATION WITH(NOLOCK) WHERE dept_code = @dept_code AND client_code = @client_code  
  
  IF @recipients_email IS NULL  
  BEGIN  
   SET @recipients_email = (SELECT approver_email FROM TBL_MST_DEPARTMENT WHERE dept_code = @dept_code)  
   SET @copy_recipients_email = ''  
  END  
  
  SET @subject = '[VAS Testing]' + @mll_no + ' QA Notification'
  SELECT @body  = '<table style="font-family:arial;font-size:10pt;">'   
      + '<tr><td colspan=2>Client :</td><td>' + A.client_code + ' - ' + B.client_name + '</td></tr>'  
      + '<tr><td colspan=2>MLL No :</td><td>' + @mll_no + '</td></tr>'  
      + '<tr><td colspan=2>Sub : </td><td> ' + A.sub + ' - ' + C.sub_name + '</td></tr>'  
      + '<tr><td colspan=2>Department : </td><td>' + F.dept_name + '</td></tr>'  
      + '<tr><td colspan=2>Effective Date : </td><td>' + CONVERT(VARCHAR(10), start_date, 121) + ' - ' + CONVERT(VARCHAR(10), end_date, 121) + '</td></tr>'  
      + '<tr><td colspan=2>Submitted By : </td><td>' + D.user_name + ' / ' + CONVERT(VARCHAR(10), submitted_date, 121) +  '</td></tr>'  
      + '<tr><td colspan=2>Approved By : </td><td>' + E.user_name + ' / ' + CONVERT(VARCHAR(10), approved_date, 121) +  '</td></tr>'  
      + '<tr><td colspan=2>&nbsp;</td></tr></table>'   
      FROM TBL_MST_MLL_HDR A WITH(NOLOCK)  
      INNER JOIN TBL_MST_CLIENT B WITH(NOLOCK) ON A.client_code = B.client_code  
      INNER JOIN TBL_MST_CLIENT_SUB C WITH(NOLOCK) ON A.client_code = C.client_code AND A.sub = C.sub_code  
      INNER JOIN VAS.dbo.TBL_ADM_USER D WITH(NOLOCK) ON A.submitted_by = D.user_id  
      INNER JOIN VAS.dbo.TBL_ADM_USER E WITH(NOLOCK) ON A.approved_by = E.user_id  
      INNER JOIN TBL_MST_DEPARTMENT F WITH(NOLOCK) ON D.department = F.dept_code  
      WHERE mll_no = @mll_no  

	--  (SELECT config_value FROM VAS.dbo.TBL_ADM_CONFIGURATION_TH WITH(NOLOCK) WHERE config = 'email_profile_name')

SET @Column1Name = '[sep=,' + CHAR(13) + CHAR(10) + 'client_code]'
 SET @qry = 'Select 1'; --'set nocount on;SELECT distinct B.client_code ' + @column1name + ' , C.client_name, A.mll_no, A.prd_code, D.prd_desc, registration_no, E.name,ISNULL(F.name,''NA''),ISNULL(G.name,''NA''), remarks, vas_activities FROM TBL_MST_MLL_DTL A WITH(NOLOCK)  INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no  INNER JOIN TBL_MST_CLIENT C WITH(NOLOCK) ON B.client_code = C.client_code  INNER JOIN TBL_MST_PRODUCT D WITH(NOLOCK) ON A.prd_code = D.prd_code  INNER JOIN TBL_MST_DDL E WITH(NOLOCK) ON A.storage_cond = E.code   LEFT JOIN TBL_MST_DDL F WITH(NOLOCK) ON A.medical_device_usage = F.code   LEFT JOIN TBL_MST_DDL G WITH(NOLOCK) ON A.bm_ifu = G.code  WHERE B.mll_no =''MLL009101RD00013''' 


	  EXEC msdb.dbo.sp_send_dbmail  
  @profile_name = @profile_name,
  @recipients = 'vijitha.sreevishnu@itcinfotech.com',  
  @copy_recipients = 'vijitha.sreevishnu@itcinfotech.com', 
  --@execute_query_database = 'VAS_MY_HEC' ,
  --@query='Select 1',
  --@query_attachment_filename = 'MLL.csv',
  @subject = @subject,  
  @body = @body,  
  @attach_query_result_as_file = 0,  
  --@query_result_separator=',',@query_result_width =32767,
  --@query_result_no_padding=1,
  @body_format ='HTML',  
  @importance = 'NORMAL' ,
  @file_attachments = @pdf_full_path;  

  SET @remove_files = N'D:\VAS\MY-HEC\MLL\' + @mll_no + '*.*'
		SET @cmd = 'DEL /F /Q ' + @remove_files
		EXEC master..xp_cmdshell @cmd, no_output;

END
 

GO
