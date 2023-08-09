SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Siow Shen Yee
-- Create date: 2018-08-14
-- Description:	MLL - Trigger email
-- exec SPP_MST_MLL_EMAIL 'Approved', 'MLL040602RD00002', '8032'
-- =============================================
CREATE  PROCEDURE [dbo].[SPP_MST_MLL_EMAIL]
	@mll_status VARCHAR(50),
	@mll_no VARCHAR(50),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @subject NVARCHAR(MAX), @body NVARCHAR(MAX), @profile_name VARCHAR(50), @client_code VARCHAR(50), @client_name VARCHAR(250),
	@recipients_email VARCHAR(MAX), @copy_recipients_email VARCHAR(MAX), @user_name VARCHAR(250), @dept_code VARCHAR(50), @submitted_by_id INT,
	@qas_no VARCHAR(MAX), @revision_no VARCHAR(10)

	SET @profile_name = (SELECT config_value FROM VAS.dbo.TBL_ADM_CONFIGURATION_TH WITH(NOLOCK) WHERE config = 'email_profile_name')
	SELECT @client_code = client_code, @submitted_by_id = submitted_by,@dept_code=ISNULL(dept_code,'') FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_no = @mll_no
	SET @client_name = (SELECT client_name FROM TBL_MST_CLIENT WITH(NOLOCK) WHERE client_code = @client_code)
	SET @user_name = (SELECT user_name FROM VAS.dbo.TBL_ADM_USER WITH(NOLOCK) WHERE user_id = @user_id)
	IF @dept_code=''
	BEGIN
		SET @dept_code = (SELECT department FROM VAS.dbo.TBL_ADM_USER WITH(NOLOCK) WHERE user_id = @submitted_by_id)
	END

	DECLARE @submitted_by_email VARCHAR(50)
	SET @submitted_by_email = (SELECT email FROM VAS.dbo.TBL_ADM_USER WITH(NOLOCK) WHERE user_id = @user_id)
	select @qas_no = mll_desc, @revision_no = revision_no from TBL_MST_MLL_HDR where mll_no = @mll_no

	IF @mll_status = 'Submitted' -- Trigger email to respective department's approver
	BEGIN
		--SET @recipients_email = (SELECT approver_email FROM TBL_MST_DEPARTMENT A WITH(NOLOCK) INNER JOIN VAS.dbo.TBL_ADM_USER B WITH(NOLOCK) ON A.dept_code = B.department WHERE user_id = @user_id)
		SET @recipients_email = (SELECT approver_email FROM TBL_MST_DEPARTMENT A WITH(NOLOCK)    WHERE A.dept_code=@dept_code)
		SET @subject = '[VAS Testing] [' + @client_name + '] ' + @mll_no + ' (' + @qas_no + '-' + @revision_no + ')' + ' is pending your approval'
		SET @body = '<table style="font-family:arial; font-size:10pt">'
				  + '<tr>Dear Sir/Madam, <br/><br/></tr>'
				  + '<tr>This is testing site. <br/><br/></tr>'
				  + '<tr>A gentle reminder that there is a submitted MLL awaiting your approval. Please remember to login to VAS system and take action. <br/><br/></tr>'
				  + '<tr>Click <a href="http://portal.dksh.com/vas_dev/Login?url_mll_no=' + @mll_no + '"><u>Here</u></a> here to access VAS system. </br></tr>'
				  + '<tr>Thank you for your attention.</br></br></br></tr>'
				  + '<tr>----------------------------------------------------------------------------------------------------</br></tr>'
				  + '<tr>This is auto-generated mail. Please do not reply to this email.</tr></table>'

		EXEC msdb.dbo.sp_send_dbmail
		@profile_name = @profile_name,
		@recipients = @recipients_email,
		@copy_recipients = @submitted_by_email,
		@subject = @subject,
		@body = @body,
		@attach_query_result_as_file = 0,
		@body_format ='HTML',
		@importance = 'NORMAL'
	END
	ELSE IF @mll_status = 'Approved'
	BEGIN

	SET @user_name = (SELECT user_name FROM VAS.dbo.TBL_ADM_USER WITH(NOLOCK) WHERE user_id =   (SELECT approved_by FROM TBL_MST_MLL_HDR WHERE mll_no=@mll_no))


		--For generate pdf use
		CREATE TABLE #HTML_STRING
		(
		string_a nvarchar(maX),
		string_b nvarchar(maX),
		string_c nvarchar(maX)
		)
		DECLARE @html NVARCHAR(MAX), @html_file_name VARCHAR(100), @html_full_path VARCHAR(1000), @pdf_full_path VARCHAR(1000), @strCMD VARCHAR(1000), @folder_path NVARCHAR(4000),
				@remove_files NVARCHAR(MAX), @cmd VARCHAR(8000), @remove_folder NVARCHAR(MAX)
		SET @folder_path = N'D:\VAS\TH-HEC\MLL\'
		--For generate pdf use
		
		-- Generate PDF
		INSERT INTO #HTML_STRING(string_a, string_b, string_c)
		EXEC SPP_GENERATE_MLL @mll_no, 0

		SET @html = (SELECT string_a + string_b + string_c FROM #HTML_STRING)
		SET @html_file_name = @mll_no + '.html' -- 2018/05/0001.html

		--select * from #HTML_STRING
	
		EXEC SPP_GENERATE_HTML @String = @html, @Path = @folder_path, @Filename = @html_file_name --Generate .html file in @folder_path
 
		SET @html_full_path = @folder_path + @html_file_name -- D:\VAS\TH-HEC\@guid\html_file_name.html
		SET @pdf_full_path = @folder_path + @mll_no + '.pdf' -- D:\VAS\TH-HEC\@guid\2018/05/0001.pdf
		SET @strCMD = 'D:\VAS\wkhtmltopdf.exe --image-dpi -600 --image-dpi 100 -n --print-media-type -q -O landscape --quiet --header-html "" --header-spacing 30 --footer-html ""   ' + @html_full_path + '  ' + @pdf_full_path +'  '

		EXEC xp_cmdshell @strCMD, no_output;
		DROP TABLE #HTML_STRING

		SELECT @recipients_email = recipients, @copy_recipients_email = copy_recipients FROM TBL_MST_MLL_EMAIL_CONFIGURATION WITH(NOLOCK) WHERE dept_code = @dept_code AND client_code = @client_code

		IF @recipients_email IS NULL
		BEGIN
			SET @recipients_email = (SELECT approver_email FROM TBL_MST_DEPARTMENT WHERE dept_code = @dept_code)
			SET @copy_recipients_email = ''
		END

		SET @subject = '[VAS Testing] ' + @mll_no + ' (' + @qas_no + '-' + @revision_no + ')' + ' is approved by ' + @user_name
		SELECT @body  = '<table style="font-family:arial;font-size:10pt;">' 
						+ '<tr><td colspan=2>Client :</td><td>' + A.client_code + ' - ' + B.client_name + '</td></tr>'
						+ '<tr><td colspan=2>MLL No :</td><td>' + @mll_no + '</td></tr>'
						+ '<tr><td colspan=2>QAS No :</td><td>'+ @qas_no + '-' + @revision_no + '</td></tr>'
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
						INNER JOIN TBL_MST_DEPARTMENT F WITH(NOLOCK) ON E.department = F.dept_code
						--INNER JOIN TBL_MST_DEPARTMENT F WITH(NOLOCK) ON D.department = F.dept_code
						WHERE mll_no = @mll_no

		EXEC msdb.dbo.sp_send_dbmail
		@profile_name = @profile_name,
		@recipients = @recipients_email,
		@copy_recipients = @copy_recipients_email, --@submitted_by_email, 
		@subject = @subject,
		@body = @body,
		@attach_query_result_as_file = 0,
		@body_format ='HTML',
		@importance = 'NORMAL',
		@file_attachments = @pdf_full_path;

		SET @remove_files = N'D:\VAS\TH-HEC\MLL\' + @mll_no + '*.*'
		SET @cmd = 'DEL /F /Q ' + @remove_files
		EXEC master..xp_cmdshell @cmd, no_output;
	END
	ELSE IF @mll_status = 'Rejected'
	BEGIN
		--SELECT @recipients_email = recipients, @copy_recipients_email = copy_recipients FROM TBL_MST_MLL_EMAIL_CONFIGURATION WITH(NOLOCK) WHERE dept_code = @dept_code AND client_code = @client_code
		SELECT @recipients_email = A.recipients, @copy_recipients_email = B.approver_email 
		FROM [TBL_MST_MLL_EMAIL_CONFIGURATION] A WITH(NOLOCK) 
		LEFT JOIN TBL_MST_DEPARTMENT B WITH (NOLOCK) ON A.dept_code = B.dept_code 
		WHERE A.dept_code = @dept_code AND client_code = @client_code

		IF @recipients_email IS NULL
		BEGIN
			SET @recipients_email = (SELECT approver_email FROM TBL_MST_DEPARTMENT WHERE dept_code = @dept_code)
			SET @copy_recipients_email = ''
		END

		SET @subject = '[VAS Testing] ' + @mll_no + ' (' + @qas_no + '-' + @revision_no + ')' + ' is rejected by ' + @user_name
		SELECT @body  = '<table style="font-family:arial;font-size:10pt;">' 
						+ '<tr><td colspan=2>Client :</td><td>' + A.client_code + ' - ' + B.client_name + '</td></tr>'
						+ '<tr><td colspan=2>MLL No :</td><td>' + @mll_no + '</td></tr>'
						+ '<tr><td colspan=2>Sub : </td><td> ' + A.sub + ' - ' + C.sub_name + '</td></tr>'
						+ '<tr><td colspan=2>Department : </td><td>' + F.dept_name + '</td></tr>'
						+ '<tr><td colspan=2>Effective Date : </td><td>' + CONVERT(VARCHAR(10), start_date, 121) + ' - ' + CONVERT(VARCHAR(10), end_date, 121) + '</td></tr>'
						+ '<tr><td colspan=2>Submitted By : </td><td>' + D.user_name + ' / ' + CONVERT(VARCHAR(10), submitted_date, 121) +  '</td></tr>'
						+ '<tr><td colspan=2>Rejected By : </td><td>' + E.user_name + ' / ' + CONVERT(VARCHAR(10), rejected_date, 121) + '</td></tr>'
						+ '<tr><td colspan=2>Rejected Reason : </td><td>' + rejection_reason + '</td></tr>'
						+ '<tr><td colspan=2>&nbsp;</td></tr></table>' 
						FROM TBL_MST_MLL_HDR A WITH(NOLOCK)
						INNER JOIN TBL_MST_CLIENT B WITH(NOLOCK) ON A.client_code = B.client_code
						INNER JOIN TBL_MST_CLIENT_SUB C WITH(NOLOCK) ON A.client_code = C.client_code AND A.sub = C.sub_code
						INNER JOIN VAS.dbo.TBL_ADM_USER D WITH(NOLOCK) ON A.submitted_by = D.user_id
						INNER JOIN VAS.dbo.TBL_ADM_USER E WITH(NOLOCK) ON A.rejected_by = E.user_id
						INNER JOIN TBL_MST_DEPARTMENT F WITH(NOLOCK) ON D.department = F.dept_code
						WHERE mll_no = @mll_no

		EXEC msdb.dbo.sp_send_dbmail
		@profile_name = @profile_name,
		@recipients = @recipients_email,
		@copy_recipients = @submitted_by_email,
		@subject = @subject,
		@body = @body,
		@attach_query_result_as_file = 0,
		@body_format ='HTML',
		@importance = 'NORMAL'
	END
END

GO
