SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
--EXEC SPP_MLL_PDF 'MLL005300RD00003','create'
-- =============================================
CREATE PROCEDURE [dbo].[SPP_MLL_PDF]
	@MLL_No varchar(50),
	@action varchar(10)
AS
BEGIN
	SET NOCOUNT ON;

if @action = 'create'
begin

CREATE TABLE #HTML_STRING
(
	string_a nvarchar(maX),
	string_b nvarchar(maX),
	string_c nvarchar(maX)
)
DECLARE	@html NVARCHAR(MAX), @html_file_name VARCHAR(100), @html_full_path VARCHAR(1000), @pdf_full_path VARCHAR(1000), @strCMD VARCHAR(1000), @folder_path NVARCHAR(4000), @remove_files NVARCHAR(MAX), @cmd VARCHAR(8000), @remove_folder NVARCHAR(MAX)
DECLARE @recipients NVARCHAR(MAX), @copy_recipients  NVARCHAR(MAX)
DECLARE @EXCEL_FILE_NAME NVARCHAR(1000) = @MLL_No+'_'+convert(varchar, getdate(), 112)+'.csv'

SET @folder_path = N'D:\VAS\MY-HEC\MLL\'

INSERT INTO #HTML_STRING(string_a, string_b, string_c)
EXEC SPP_GENERATE_MLL @mll_no, 0

SET @html = (SELECT string_a + string_b + string_c FROM #HTML_STRING)
SET @html_file_name = @mll_no + '.html' 
	
EXEC SPP_GENERATE_HTML @String = @html, @Path = @folder_path, @Filename = @html_file_name
 
SET @html_full_path = @folder_path + @html_file_name -- D:\VAS\MY-HEC\@guid\html_file_name.html
SET @pdf_full_path = @folder_path + @mll_no + '.pdf' -- D:\VAS\MY-HEC\@guid\2018/05/0001.pdf
SET @strCMD = 'D:\VAS\wkhtmltopdf.exe --image-dpi -600 --image-dpi 100 -n --print-media-type -q -O landscape --quiet --header-html "" --header-spacing 30 --footer-html ""   ' + @html_full_path + '  ' + @pdf_full_path +'  '

EXEC xp_cmdshell @strCMD, no_output;
DROP TABLE #HTML_STRING

end

else if (@action = 'remove')
begin

SET @remove_files = N'D:\VAS\MY-HEC\MLL\' + @mll_no + '*.*'
SET @cmd = 'DEL /F /Q ' + @remove_files
EXEC xp_cmdshell @cmd, no_output;

end
END

GO
