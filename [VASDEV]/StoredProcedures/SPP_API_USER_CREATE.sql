SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CHOI CHEE KIEN
-- Create date: 04/07/2023
-- Description:	CREATE ACCOUNT FROM API
-- =============================================
CREATE PROCEDURE SPP_API_USER_CREATE 
	@login   VARCHAR(100),
	 @country_id  INTEGER,  
	 @principal_id VARCHAR(10),  
	 @user_type_id VARCHAR(10),  
	 @department_code VARCHAR(10),  
	 @user_name  NVARCHAR(250),  
	 @email   NVARCHAR(100),  
	 @wh_code  NVARCHAR(50),  
	 @pwd_expiry  INTEGER,  
	 @pwd_expiry_rmd INTEGER,  
	 @max_retry  INTEGER,  
	 @first_login INTEGER  
AS
BEGIN

	SET NOCOUNT ON;

    DECLARE @exists_flag CHAR(1)  
	SET @exists_flag = 0  
	
	BEGIN TRY
		BEGIN TRANSACTION
			IF NOT EXISTS (SELECT 1 FROM TBL_ADM_USER WITH(NOLOCK) WHERE login = @LOGIN)  
			BEGIN  
				INSERT INTO TBL_ADM_USER  
				(login, password, country_id, principal_id, user_type_id, user_name, email, first_login, pwd_expiry, pwd_expiry_rmd, max_retry, status, department, wh_code)  
				VALUES  
				(@login, 'YL/Q5oQ7uZeqYxE88WY6mA==', @country_id, @principal_id, @user_type_id, @user_name, @email, @first_login, @pwd_expiry , @pwd_expiry_rmd, @max_retry, 'A', @department_code, @wh_code)  
  
				IF (@first_login = 1)  
				BEGIN  
					/* Send email to new user */  
					DECLARE @enc_pwd VARCHAR(50) = 'YL/Q5oQ7uZeqYxE88WY6mA==', @dec_pwd VARCHAR(50) = 'P@ssw0rd'  
  
					UPDATE A SET password = @enc_pwd, first_login = 1  
					FROM TBL_ADM_USER A WITH(NOLOCK) WHERE login = @login    
  
					DECLARE @body NVARCHAR(MAX) = ''  
					SET @body = '<head>  
					<style>  
					body { font-family: Arial; font-size:12px; }   
        
					</style>  
					</head>  
					<body><img style="float:right; width:20px!important; height:20px!important;" src="http://portal.dksh.com/vasdev/assets/logo_dksh.png"/>  
					<hr><br/>Dear user,<br/><br/>  
					Your account has been created. Your temporary password is: <span style="font-weight:bold">'+@dec_pwd+'</span><br/><br/>  
					Click this <a href="https://portal.dksh.com/vasdev/index.html">link</a> to login.<br/><br/>  
					<br/><br/><br/>Yours sincerely, <br/><br/>  
					DKSH Ep Client support team</body>'  
  
					EXEC msdb.dbo.sp_send_dbmail  
					@profile_name = 'EPClientAdmin',  
					@recipients = @email,            
					@subject = 'VAS - New user creation',  
					@body = @body,  
					@attach_query_result_as_file = 0,  
					@body_format ='HTML',  
					@importance = 'NORMAL'   
				END  

				SET @exists_flag = 0  
				SELECT @exists_flag AS exists_flag, user_id FROM TBL_ADM_USER WITH(NOLOCK) WHERE login = @login  
  
			END  
			ELSE  
			BEGIN  
				SET @exists_flag = 1  
				SELECT @exists_flag AS exists_flag, 0 as user_id  
			END  
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT ERROR_MESSAGE()
	END CATCH
	
END

GO
