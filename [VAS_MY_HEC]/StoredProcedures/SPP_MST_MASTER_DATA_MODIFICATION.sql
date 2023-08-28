SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec SPP_MST_MASTER_DATA_MODIFICATION @submit_obj=N'{"module":"MLL_EMAIL_CONFIG","ind":"recipients","dept":"D1","client_code":"0F32","email":" olive.chong@dksh.com"}',@user_id=N'1'
--exec SPP_MST_MASTER_DATA_MODIFICATION @submit_obj=N'{"module":"MLL_EMAIL_CONFIG","ind":"add_recipients","dept":"D1","client_code":"0053","email":"a@a.com"}',@user_id=N'1'
--select * from TBL_MST_MLL_EMAIL_CONFIGURATION where dept_code = 'D1' and client_code = '0053'
CREATE PROCEDURE [dbo].[SPP_MST_MASTER_DATA_MODIFICATION]
	@submit_obj NVARCHAR(MAX),
	@user_id VARCHAR(10)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @module VARCHAR(50), @client_code VARCHAR(50),@ind VARCHAR(50), @dept_code VARCHAR(50), @email NVARCHAR(250), @email_list NVARCHAR(MAX), @string NVARCHAR(MAX)
	SET @module = (SELECT JSON_VALUE(@submit_obj, '$.module'))

	IF @module = 'MLL_EMAIL_CONFIG'
	BEGIN
		SET @ind = (SELECT JSON_VALUE(@submit_obj, '$.ind'))
		SET @dept_code = (SELECT JSON_VALUE(@submit_obj, '$.dept'))
		SET @client_code = (SELECT JSON_VALUE(@submit_obj, '$.client_code'))
		SET @email = (SELECT JSON_VALUE(@submit_obj, '$.email'))

		IF @ind = 'remove_recipients' OR @ind = 'add_recipients'
		BEGIN
			UPDATE TBL_MST_MLL_EMAIL_CONFIGURATION
			SET recipients = REPLACE(recipients, @email, '')
			WHERE dept_code = @dept_code AND client_code = @client_code

			SET @email_list = (SELECT recipients FROM TBL_MST_MLL_EMAIL_CONFIGURATION WITH(NOLOCK) WHERE dept_code = @dept_code AND client_code = @client_code)
		END
		ELSE IF @ind = 'remove_copyrecipients' OR @ind = 'add_copyrecipients'
		BEGIN
			UPDATE TBL_MST_MLL_EMAIL_CONFIGURATION
			SET copy_recipients = REPLACE(copy_recipients, @email, '')
			WHERE dept_code = @dept_code AND client_code = @client_code

			SET @email_list = (SELECT copy_recipients FROM TBL_MST_MLL_EMAIL_CONFIGURATION WITH(NOLOCK) WHERE dept_code = @dept_code AND client_code = @client_code)
		END
		
		SELECT * INTO #EMAIL FROM SF_SPLIT(ISNULL(@email_list,''), ';', '') WHERE Data <> ''

		IF @ind = 'add_recipients' OR @ind = 'add_copyrecipients'
		BEGIN
			INSERT INTO #EMAIL (Data)
			VALUES(@email)
		END
		
		SET @string = (
		SELECT ISNULL(STUFF((SELECT DISTINCT ';' + Data 
		FROM #EMAIL
		FOR XML PATH('')) ,1,1,''), '') )

		DROP TABLE #EMAIL

		-- reupdate recipients/copy recipients
		IF @ind = 'remove_recipients' OR @ind = 'add_recipients'
		BEGIN
			UPDATE TBL_MST_MLL_EMAIL_CONFIGURATION
			SET recipients = ISNULL(@string,'')
			WHERE dept_code = @dept_code AND client_code = @client_code
		END
		ELSE IF @ind = 'remove_copyrecipients' OR @ind = 'add_copyrecipients'
		BEGIN
			UPDATE TBL_MST_MLL_EMAIL_CONFIGURATION
			SET copy_recipients = ISNULL(@string,'')
			WHERE dept_code = @dept_code AND client_code = @client_code
		END
	END

	ELSE IF @module = 'MASTER_DATA_CLIENT'
	BEGIN
		--exec SPP_MST_MASTER_DATA_MODIFICATION @submit_obj=N'{"module":"MASTER_DATA_CLIENT","ind":"add_client","client_code":"0002 ","client_name":"DENIS FRERES"}',@user_id=N'1'
		DECLARE @client_name NVARCHAR(500)
		SET @client_code = (SELECT JSON_VALUE(@submit_obj, '$.client_code'))
		SET @client_name = (SELECT JSON_VALUE(@submit_obj, '$.client_name'))

		IF (SELECT COUNT(1) FROM TBL_MST_CLIENT WHERE client_code = RTRIM(LTRIM(@client_code))) = 0 
		BEGIN
			
			INSERT INTO TBL_MST_CLIENT (client_code, client_name, created_date) 
			VALUES(RTRIM(LTRIM(@client_code)), RTRIM(LTRIM(@client_name)), GETDATE())

			INSERT INTO TBL_MST_MLL_EMAIL_CONFIGURATION 
			(dept_code, client_code, recipients, copy_recipients)
			SELECT dept_code, RTRIM(LTRIM(@client_code)), '', '' 
			FROM TBL_MST_DEPARTMENT A WHERE NOT EXISTS (SELECT 1 FROM TBL_MST_MLL_EMAIL_CONFIGURATION B WHERE A.dept_code = B.dept_code AND B.client_code = RTRIM(LTRIM(@client_code)))

			INSERT INTO TBL_MST_QA_EMAIL_CONFIGURATION 
			(dept_code, client_code, recipients, copy_recipients)
			SELECT dept_code, RTRIM(LTRIM(@client_code)), '', '' 
			FROM TBL_MST_DEPARTMENT A WHERE NOT EXISTS (SELECT 1 FROM TBL_MST_QA_EMAIL_CONFIGURATION B WHERE A.dept_code = B.dept_code AND B.client_code = RTRIM(LTRIM(@client_code)))

		END
	END

	ELSE IF @module = 'MLL_APPROVER_EMAIL_CONFIG'
	BEGIN
		SET @ind = (SELECT JSON_VALUE(@submit_obj, '$.ind'))
		SET @dept_code = (SELECT JSON_VALUE(@submit_obj, '$.dept'))
		SET @email = (SELECT JSON_VALUE(@submit_obj, '$.email'))

		UPDATE TBL_MST_DEPARTMENT
		SET approver_email = REPLACE(approver_email, @email, '')
		WHERE dept_code = @dept_code

		SET @email_list = (SELECT approver_email FROM TBL_MST_DEPARTMENT WITH(NOLOCK) WHERE dept_code = @dept_code)
		
		SELECT * INTO #APPROVER_EMAIL FROM SF_SPLIT(ISNULL(@email_list,''), ';', '') WHERE Data <> ''

		IF @ind = 'add_approver_email_recipients'
		BEGIN
			INSERT INTO #APPROVER_EMAIL (Data)
			VALUES(@email)
		END

		SET @string = (
		SELECT ISNULL(STUFF((SELECT DISTINCT ';' + Data 
		FROM #APPROVER_EMAIL
		FOR XML PATH('')) ,1,1,''), '') )

		DROP TABLE #APPROVER_EMAIL

		-- reupdate approver_email
		UPDATE TBL_MST_DEPARTMENT
		SET approver_email = ISNULL(@string,'')
		WHERE dept_code = @dept_code
	END
	

	SELECT 'Added/Updated'
END

GO
