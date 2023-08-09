SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		YING
-- Create date: 05-07-2023
-- Description:	ADD/REMOVE RATE APPROVER LIST
-- =============================================

-- exec [SPP_MST_GET_RATE_APPROVER_CONFIG]

CREATE PROCEDURE [dbo].[SPP_MST_MODIFY_RATE_APPROVER_CONFIG] 
	@submit_obj NVARCHAR(MAX),
	@user_id VARCHAR(10)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @module VARCHAR(50), @client_code VARCHAR(50),@ind VARCHAR(50), @email NVARCHAR(250), @email_list NVARCHAR(MAX), @string NVARCHAR(MAX)
	
		SET @ind = (SELECT JSON_VALUE(@submit_obj, '$.ind'))
		SET @client_code = (SELECT JSON_VALUE(@submit_obj, '$.client_code'))
		SET @email = (SELECT JSON_VALUE(@submit_obj, '$.email'))

		IF @ind = 'remove_recipients' OR @ind = 'add_recipients'
		BEGIN
			UPDATE TBL_MST_RATE_APPROVER_CONFIGURATION
			SET recipients = REPLACE(recipients, @email, '')
			WHERE client_code = @client_code

			SET @email_list = (SELECT recipients FROM TBL_MST_RATE_APPROVER_CONFIGURATION WITH(NOLOCK) WHERE client_code = @client_code)
		END
		ELSE IF @ind = 'remove_copyrecipients' OR @ind = 'add_copyrecipients'
		BEGIN
			UPDATE TBL_MST_RATE_APPROVER_CONFIGURATION
			SET copy_recipients = REPLACE(copy_recipients, @email, '')
			WHERE client_code = @client_code

			SET @email_list = (SELECT copy_recipients FROM TBL_MST_RATE_APPROVER_CONFIGURATION WITH(NOLOCK) WHERE client_code = @client_code)
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
			UPDATE TBL_MST_RATE_APPROVER_CONFIGURATION
			SET recipients = ISNULL(@string,'')
			WHERE client_code = @client_code
		END
		ELSE IF @ind = 'remove_copyrecipients' OR @ind = 'add_copyrecipients'
		BEGIN
			UPDATE TBL_MST_RATE_APPROVER_CONFIGURATION
			SET copy_recipients = ISNULL(@string,'')
			WHERE client_code = @client_code
		END

	SELECT 'Added/Updated'

END

GO
