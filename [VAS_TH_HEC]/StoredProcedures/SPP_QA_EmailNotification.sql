SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[SPP_QA_EmailNotification]  --'MLL009101RD00013'
@mll_no nvarchar(1000)  
AS  
BEGIN  
  
Declare @profile_name nvarchar(2000) = (SELECT config_value FROM VAS.dbo.TBL_ADM_CONFIGURATION_TH WITH(NOLOCK) WHERE config = 'email_profile_name' )  
  
DECLARE @email_addresses nvarchar(max)  
SET @email_addresses = NULL  
SELECT @email_addresses = COALESCE(@email_addresses + ',','') + email FROM VAS.DBO.TBL_ADM_USER WHERE [LOGIN] like 'QA%'  
  
Declare @body nvarchar(MAX) = '<html><p>From VAS TEAM</p></html>'  
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
  DECLARE @excel_full_path NVARCHAR(MAX)= @folder_path + @mll_no + '.xlsx' -- D:\VAS\MY-HEC\@guid\2018/05/0001.pdf 
  SET @strCMD = 'D:\VAS\wkhtmltopdf.exe --image-dpi -600 --image-dpi 100 -n --print-media-type -q -O landscape --quiet --header-html "" --header-spacing 30 --footer-html ""   ' + @html_full_path + '  ' + @pdf_full_path +'  '  
  
    DECLARE @strCMD_excel NVARCHAR(MAX) = 'D:\VAS\wkhtmltopdf.exe --image-dpi -600 --image-dpi 100 -n --print-media-type -q -O landscape --quiet --header-html "" --header-spacing 30 --footer-html ""   ' + @html_full_path + '  ' + @excel_full_path +'  '  


  EXEC xp_cmdshell @strCMD, no_output; 
  
  EXEC xp_cmdshell @strCMD_excel, no_output; 

  DROP TABLE #HTML_STRING

  DECLARE @attachments_Path NVARCHAR(MAX) = @pdf_full_path + ';'+ @excel_full_path  
  
EXEC msdb.dbo.sp_send_dbmail              
    @profile_name = @profile_name,              
    @recipients = 'jackson.pais@itcinfotech.com',              
    @blind_copy_recipients = 'jackson.pais@itcinfotech.com',                  
    @subject = 'VAS QA Notification',              
    @body = @body,              
    @attach_query_result_as_file = 0,              
    @body_format ='HTML',              
    @importance = 'NORMAL',              
    @file_attachments = @attachments_Path 
  
END

GO
