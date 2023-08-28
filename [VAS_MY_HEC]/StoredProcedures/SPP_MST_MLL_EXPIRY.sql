SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-18
-- Description:	(Run by Job) Send out email for MLL that will expired in 1 or 2 months time.
-- -- ============================================================================
CREATE PROCEDURE [dbo].[SPP_MST_MLL_EXPIRY]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT A.client_code, B.client_name, type_of_vas, A.sub, C.sub_name, mll_no, start_date, end_date, 
	A.creator_user_id, D.department, E.dept_name, E.approver_email, F.recipients, F.copy_recipients, CAST(NULL as CHAR(5)) as email_ind
	INTO #ACTIVE_MLL
	FROM TBL_MST_MLL_HDR A WITH(NOLOCK)
	INNER JOIN TBL_MST_CLIENT B WITH(NOLOCK) ON A.client_code = B.client_code
	INNER JOIN TBL_MST_CLIENT_SUB C WITH(NOLOCK) ON A.client_code = C.client_code AND A.sub = C.sub_code
	INNER JOIN VAS.dbo.TBL_ADM_USER D WITH(NOLOCK) ON A.creator_user_id = D.user_id
	INNER JOIN TBL_MST_DEPARTMENT E WITH(NOLOCK) ON D.department = E.dept_code
	LEFT JOIN TBL_MST_MLL_EMAIL_CONFIGURATION F WITH(NOLOCK) ON E.dept_code = F.dept_code AND A.client_code = F.client_code
	WHERE mll_status = 'Approved' AND GETDATE() BETWEEN start_date AND end_date

	UPDATE #ACTIVE_MLL
	SET email_ind = 'ONE'
	WHERE CONVERT(VARCHAR(10), end_date, 121) = DATEADD(MONTH, 1, CONVERT(VARCHAR(10), GETDATE(), 121))

	UPDATE #ACTIVE_MLL
	SET email_ind = 'TWO'
	WHERE CONVERT(VARCHAR(10), end_date, 121) = DATEADD(MONTH, 2, CONVERT(VARCHAR(10), GETDATE(), 121))

	SELECT IDENTITY(INT, 1, 1) as num, *
	INTO #GOINGTOEXPIREDMLL
	FROM #ACTIVE_MLL WITH(NOLOCK)
	WHERE email_ind IS NOT NULL

	DROP TABLE #ACTIVE_MLL
	SELECT * FROM #GOINGTOEXPIREDMLL
	/** Send out email **/

	-- Email Profile --
	DECLARE @profile_name VARCHAR(50), @subject NVARCHAR(500), @body NVARCHAR(MAX), @recipients NVARCHAR(500), @copy_recipients NVARCHAR(500)
	SET @profile_name = (SELECT config_value FROM VAS.dbo.TBL_ADM_CONFIGURATION WITH(NOLOCK) WHERE config = 'email_profile_name')
	-- Email Profile --

	DECLARE @count INT, @i INT = 1, @email_ind CHAR(5)
	SET @count = (SELECT COUNT(1) FROM #GOINGTOEXPIREDMLL)
	WHILE @i <= @count
	BEGIN
		SELECT @email_ind = email_ind, @recipients = CASE WHEN recipients IS NULL THEN approver_email ELSE recipients END, @copy_recipients = copy_recipients
		FROM #GOINGTOEXPIREDMLL WITH(NOLOCK) WHERE num = @i

		IF @email_ind = 'ONE'
		BEGIN
			SET @subject = (SELECT '[VAS Testing]' + mll_no + ' is expiring on ONE month' FROM #GOINGTOEXPIREDMLL WITH(NOLOCK) WHERE num = @i)
			
		END
		ELSE IF @email_ind = 'TWO'
		BEGIN
			SET @subject = (SELECT '[VAS Testing]' + mll_no + ' is expiring on TWO months' FROM #GOINGTOEXPIREDMLL WITH(NOLOCK) WHERE num = @i)
		END

		SELECT @body = '<table style="font-family:arial;font-size:10pt;">'
			+ '<tr>Dear Sir/Madam, </br></br></tr>'
			+ '<tr>This is testing site. <br/><br/></tr>'
			+ '<tr>A gentle reminder that the following MLL is going to expire. Please remember to login to VAS system and take action. </br></br></tr></table>'
			+ '<table style="font-family:arial;font-size:10pt;">'
			+ '<tr><td colspan=2>Client :</td><td>' + client_code + ' - ' + client_name + '</td></tr>'
			+ '<tr><td colspan=2>MLL No :</td><td>' + mll_no + '</td></tr>'
			+ '<tr><td colspan=2>Sub : </td><td> ' + sub + ' - ' + sub_name + '</td></tr>'
			+ '<tr><td colspan=2>Department : </td><td>' + dept_name + '</td></tr>'
			+ '<tr><td colspan=2>Effective Date : </td><td>' + CONVERT(VARCHAR(10), start_date, 121) + ' - ' + CONVERT(VARCHAR(10), end_date, 121) + '</td></tr>'
			+ '<tr><td colspan=2>&nbsp;</td></tr></table></br>' 
			+ '<table style="font-family:arial;font-size:10pt;">'
			+ '<tr>Click <a href="http://portal.dksh.com/vas_dev"><u>Here</u></a> here to access VAS system. </br></tr>'
			+ '<tr>Thank you for your attention.</br></br></br></tr>'
			+ '<tr>----------------------------------------------------------------------------------------------------</br></tr>'
			+ '<tr>This is auto-generated mail. Please do not reply to this email.</tr></table>'
		FROM #GOINGTOEXPIREDMLL WITH(NOLOCK)
		WHERE num = @i

		EXEC msdb.dbo.sp_send_dbmail
		@profile_name = @profile_name,
		@recipients = '', --@recipients,
		@copy_recipients = '', --@copy_recipients,
		@blind_copy_recipients = 'shen.yee.siow@dksh.com', 
		@subject = @subject,
		@body = @body,
		@attach_query_result_as_file = 0,
		@body_format ='HTML',
		@importance = 'NORMAL'
		
		SET @i = @i + 1
	END

	DROP TABLE #GOINGTOEXPIREDMLL
END

GO
