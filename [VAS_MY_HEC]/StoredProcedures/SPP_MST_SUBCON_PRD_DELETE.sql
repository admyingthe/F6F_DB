SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================================
-- Author:		Vijitha/Jackson
-- Description: Remove product from SUBCON
-- Example Query: exec SPP_MST_SUBCON_PRD_DELETE @delete_obj=N'[{"subcon_no":"WI0001122100004","prd_code":"100016853"}]','Mark for Delete',@user_id=N'1'
-- ===========================================================================================================================

CREATE PROCEDURE [dbo].[SPP_MST_SUBCON_PRD_DELETE]
	@delete_obj NVARCHAR(MAX),
	@subcon_status VARCHAR(50),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @subcon_no VARCHAR(50), @prd_code VARCHAR(50),@client_code VARCHAR(50), @type_of_vas VARCHAR(50), @sub VARCHAR(50), @dept_name varchar(50), @client_name varchar(200)

	DECLARE @subject varchar(MAX),  @recipients_email VARCHAR(MAX),  @copy_recipients_email VARCHAR(MAX), @user_name varchar(50), @submitted_by_email VARCHAR(50), @body NVARCHAR(MAX), @profile_name VARCHAR(50)

	--SET @subcon_no = (SELECT JSON_VALUE(@delete_obj, '$.subcon_no'))
	--SET @prd_code = (SELECT JSON_VALUE(@delete_obj, '$.prd_code'))

	SELECT ROW_NUMBER ( ) OVER(ORDER BY subcon_no ASC) As id,*
	INTO #SUBCONTMP
	FROM OPENJSON(JSON_QUERY(@delete_obj))
	WITH (
		subcon_no VARCHAR(50) '$.subcon_no',
		prd_code VARCHAR(50) '$.prd_code'
	);

-----------------------------------------------------------------------
--- VALIDATION START HERE
-----------------------------------------------------------------------
CREATE TABLE #ASSIGNMENT_LIST_TEMP                    
(                                                                                     
	Subcon_SWI_No nvarchar(150), 
	status varchar(50) 
)                                    
       
INSERT INTO		#ASSIGNMENT_LIST_TEMP
(
	Subcon_SWI_No, status
)                    
SELECT		subcon_WI_no,
			work_ord_status 
from		TBL_Subcon_TXN_WORK_ORDER 
WHERE		subcon_WI_no in (SELECT subcon_no from #SUBCONTMP)            
GROUP BY	subcon_WI_no, work_ord_status  

CREATE TABLE #FINAL_ASSIGNMENT_LIST_TEMP                    
(                                                                                     
	Subcon_SWI_No nvarchar(150)
)                                    
       
INSERT INTO		#FINAL_ASSIGNMENT_LIST_TEMP
(
	Subcon_SWI_No
) 
select		Subcon_SWI_No
from		#ASSIGNMENT_LIST_TEMP
where		status in ('IP', 'OH')
GROUP BY	Subcon_SWI_No

SELECT	A.*,
		case 
		when B.Subcon_SWI_No is null then 1 
		else 0 end validity_status
into	#VALIDATION_TABLE
FROM	#SUBCONTMP A
		LEFT JOIN
		#FINAL_ASSIGNMENT_LIST_TEMP B
ON		A.subcon_no = B.Subcon_SWI_No 

if @subcon_status = 'Active' or @subcon_status = 'Mark for Delete' or @subcon_status = 'Mark for Re-activation' or @subcon_status = 'Reactivate'
begin
update	#VALIDATION_TABLE
set		validity_status = 1
end

if (select count(*) from #VALIDATION_TABLE where validity_status = 0) > 0
begin
print 'invalid'
end
else 
begin

-----------------------------------------------------------------------
--- VALIDATION END HERE
-----------------------------------------------------------------------

DECLARE @LoopCounter INT = (SELECT count(*) FROM #SUBCONTMP)
WHILE(@LoopCounter > 0)
			BEGIN
			   SELECT @subcon_no = subcon_no			  
			   FROM #SUBCONTMP WHERE Id = @LoopCounter
			   SELECT @prd_code = prd_code
			   FROM #SUBCONTMP WHERE Id = @LoopCounter

	--IF @subcon_status= 'Mark for Deletion'
		BEGIN
			   UPDATE TBL_MST_SUBCON_DTL
				SET subcon_status = case when @subcon_status = 'Reactivate' then 'Active' else @subcon_status end
				WHERE subcon_no = @subcon_no 
				and prd_code=@prd_code
				PRINT @subcon_status
				INSERT INTO TBL_ADM_AUDIT_TRAIL
				(module, key_code, action, action_by, action_date)
			SELECT 'SUBCON', 
					@subcon_no, 
					CASE 
					WHEN @subcon_status='Mark for Delete' THEN 'Marked for deletion - ' 
					when @subcon_status='Active' THEN 'Activated - ' 
					when @subcon_status='Reactivate' THEN 'Activated - ' 
					WHEN @subcon_status = 'Mark for Re-activation' THEN 'Requested for Re-activation - ' 
					ELSE 'Deleted - ' END + @prd_code, 
					@user_id, GETDATE()
				IF (SELECT COUNT(*) FROM TBL_MST_SUBCON_DTL WITH(NOLOCK) WHERE subcon_no = @subcon_no and subcon_status!=@subcon_status) = 0
					BEGIN
						UPDATE TBL_MST_SUBCON_HDR
						SET subcon_status=@subcon_status
						WHERE subcon_no = @subcon_no 
				END
			END
	--ELSE 
	--	BEGIN
	--		DELETE FROM TBL_MST_SUBCON_DTL
	--		WHERE subcon_no = @subcon_no AND prd_code = @prd_code

	--		INSERT INTO TBL_ADM_AUDIT_TRAIL
	--	(module, key_code, action, action_by, action_date)
	--	SELECT 'SUBCON', @subcon_no, 'Deleted item ' + @prd_code, @user_id, GETDATE()

	--	IF (SELECT COUNT(*) FROM TBL_MST_SUBCON_DTL WITH(NOLOCK) WHERE subcon_no = @subcon_no) = 0
	--		BEGIN
	--			DELETE FROM TBL_MST_SUBCON_HDR WHERE subcon_no = @subcon_no
	--		END
		--END
	SET @LoopCounter  = @LoopCounter  - 1 
	END	

END
select * from #VALIDATION_TABLE

select	@client_code = A.client_code, 
		@client_name = B.client_name,
		@type_of_vas = type_of_vas, 
		@sub = sub 
from	TBL_MST_SUBCON_HDR A
		inner join
		TBL_MST_CLIENT B
on		A.client_code = B.client_code
where	subcon_no = @subcon_no

if (@subcon_status = 'Mark for Re-activation')
begin

SELECT	@recipients_email = approver_email,
		@submitted_by_email = B.email
FROM	TBL_MST_DEPARTMENT A WITH(NOLOCK) 
		INNER JOIN 
		VAS.dbo.TBL_ADM_USER B WITH(NOLOCK) 
ON		A.dept_code = B.department 
		WHERE	user_id = @user_id

SET		@profile_name = (SELECT config_value FROM VAS.dbo.TBL_ADM_CONFIGURATION WITH(NOLOCK) WHERE config = 'email_profile_name')
SET		@subject = '[VAS Testing] [' + @client_name + ']' + @subcon_no + ' ' + @prd_code + ' is pending your reactivation'
SET		@body =	'<table style="font-family:arial; font-size:10pt">'
				  + '<tr>Dear Sir/Madam, <br/><br/></tr>'
				  + '<tr>This is testing site. <br/><br/></tr>'
				  + '<tr>A gentle reminder that there is a submitted Subcon WI awaiting your reactivation. Please remember to login to VAS system and take action. <br/><br/></tr>'
				  + '<tr>Click <a href="http://portal.dksh.com/vas_dev/Login"><u>Here</u></a> here to access VAS system. </br></tr>'
				  --?url_swi_no=' + @subcon_no + '
				  + '<tr>Thank you for your attention.</br></br></br></tr>'
				  + '<tr>----------------------------------------------------------------------------------------------------</br></tr>'
				  + '<tr>This is auto-generated mail. Please do not reply to this email.</tr></table>'

		EXEC msdb.dbo.sp_send_dbmail
		@profile_name = @profile_name,
		@recipients = @recipients_email,
		--@copy_recipients = @submitted_by_email,
		@subject = @subject,
		@body = @body,
		@attach_query_result_as_file = 0,
		@body_format ='HTML',
		@importance = 'NORMAL'

end

else if (@subcon_status = 'Reactivate')
begin

select	@recipients_email = C.recipients,
		@copy_recipients_email = C.copy_recipients,
		@user_name = A.login,
		@dept_name = B.dept_name
FROM	VAS.dbo.TBL_ADM_USER A 
		inner join  
		TBL_MST_DEPARTMENT B
on		A.department = B.dept_code
		inner join
		TBL_MST_MLL_EMAIL_CONFIGURATION C
on		B.dept_code = C.dept_code 
where	user_id = @user_id and C.client_code = @client_code

SET		@profile_name = (SELECT config_value FROM VAS.dbo.TBL_ADM_CONFIGURATION WITH(NOLOCK) WHERE config = 'email_profile_name')

SET @subject = '[VAS Testing] [' + @client_name + ']' + @subcon_no + ' '+ @prd_code + ' is reactivated by ' + @user_name

SELECT @body  = '<table style="font-family:arial;font-size:10pt;">' 
						+ '<tr>Dear Sir/Madam, <br/><br/></tr>'
						+ '<tr><td colspan=2>Client :</td><td>' + A.client_code + ' - ' + B.client_name + '</td></tr>'
						+ '<tr><td colspan=2>Sub : </td><td> ' + A.sub + ' - ' + C.sub_name + '</td></tr>'
						+ '<tr><td colspan=2>Department : </td><td>' + @dept_name + '</td></tr>'
						+ '<tr><td colspan=2>Date Reactivated : </td><td>' +  + CONVERT(VARCHAR(10), getdate(), 121) +  + '</td></tr>'
						+ '<tr><td colspan=2>&nbsp;</td></tr>'
						+ '<tr>Thank you for your attention.</br></br></br></tr>'
				  + '<tr>----------------------------------------------------------------------------------------------------</br></tr>'
				  + '<tr>This is auto-generated mail. Please do not reply to this email.</tr></table>'
				from	TBL_MST_SUBCON_HDR A
						inner join
						TBL_MST_CLIENT B
				on		A.client_code = B.client_code
						inner join
						TBL_MST_CLIENT_SUB C
				on		C.client_code = B.client_code and
						C.sub_code = A.sub
				WHERE	subcon_no = @subcon_no

		EXEC msdb.dbo.sp_send_dbmail
		@profile_name = @profile_name,
		@recipients = @recipients_email,
		--@copy_recipients = @submitted_by_email,
		@subject = @subject,
		@body = @body,
		@attach_query_result_as_file = 0,
		@body_format ='HTML',
		@importance = 'NORMAL'

end

DROP TABLE #SUBCONTMP	
-----------------------------------------------------------------------
--- VALIDATION START HERE
-----------------------------------------------------------------------
DROP TABLE #ASSIGNMENT_LIST_TEMP
DROP TABLE #FINAL_ASSIGNMENT_LIST_TEMP
DROP TABLE #VALIDATION_TABLE
-----------------------------------------------------------------------
--- VALIDATION END HERE
-----------------------------------------------------------------------
END

GO
