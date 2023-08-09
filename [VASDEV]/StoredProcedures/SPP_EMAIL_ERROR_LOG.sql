SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPP_EMAIL_ERROR_LOG]
	@connection_string NVARCHAR(MAX),
	@method_name NVARCHAR(MAX),
	@error_info NVARCHAR(MAX),
	@login_id INT
AS
BEGIN
	INSERT INTO TBL_ERROR_LOG (connection_string, method_name, error_info, login_id, created_date)
	SELECT @connection_string, @method_name, @error_info, @login_id, GETDATE()

	--DECLARE @body NVARCHAR(MAX)
	--SET @body = 'Error has occurred.<br/><br/>' +
	--			'<b>Date time:</b>' + CONVERT(VARCHAR(20), GETDATE(), 121) + '<br/>
	--			 <b>Connection string:</b> ' + @connection_string + '<br/>				
	--			 <b>Method name:</b> ' + @method_name + '<br/>
	--			 <b>Error info:</b> ' + @error_info + '<br/>
	--			 <b>Login ID:</b> ' + CAST(@login_id as VARCHAR(50)) + '<br/>'

	--EXEC msdb.dbo.sp_send_dbmail
	--	@profile_name = 'VASMail',
	--	@recipients = '',      
	--	@subject = '[Testing] Email ',
	--	@body = @body,
	--	@attach_query_result_as_file = 0,
	--	@body_format ='HTML',
	--	@importance = 'NORMAL';
END
GO
