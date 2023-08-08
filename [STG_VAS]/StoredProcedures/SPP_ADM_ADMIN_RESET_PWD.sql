/****** Object:  StoredProcedure [dbo].[SPP_ADM_ADMIN_RESET_PWD]    Script Date: 08-Aug-23 8:46:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPP_ADM_ADMIN_RESET_PWD]
	@user_id	INTEGER
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @email NVARCHAR(250), @Lower AS INT, @Upper AS INT, @enc_pwd VARCHAR(50), @dec_pwd VARCHAR(50)
	SET @email = (SELECT email FROM TBL_ADM_USER WITH(NOLOCK) WHERE user_id = @user_id)
	SET @Lower = 1 ---- The lowest random number
	SET @Upper = 10 ---- The highest random number

	SELECT @dec_pwd = rand_pwd, 
		   @enc_pwd = encrypt_rand_pwd 
	FROM TBL_MST_RANDOM_PWD WITH(NOLOCK)
	WHERE id = (SELECT  ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0))

	UPDATE A SET password = @enc_pwd, first_login = 1, pwd_changed_date = GETDATE()
	FROM TBL_ADM_USER A WITH(NOLOCK) WHERE user_id = @user_id  

	DECLARE @body NVARCHAR(MAX) = ''
	SET @body = '<head>
				<style>
				body { font-family: Arial; font-size:12px; } 
						
				</style>
				</head>
				<body><img style="float:right; width:20px!important; height:20px!important;" src="http://portal.dksh.com/epclientdev/assets/logo_dksh.png"/>
				<hr><br/>Dear user,<br/><br/>
				Your temporary password is: <span style="font-weight:bold">'+@dec_pwd+'</span><br/><br/>
				<br/><br/><br/>Yours sincerely, <br/><br/>
				DKSH VAS support team</body>'

	EXEC msdb.dbo.sp_send_dbmail
		 @profile_name = 'VASMail',
		 @recipients = @email,          
		 @subject = 'VAS - Password reset',
		 @body = @body,
		 @attach_query_result_as_file = 0,
		 @body_format ='HTML',
		 @importance = 'NORMAL' 

END

GO
