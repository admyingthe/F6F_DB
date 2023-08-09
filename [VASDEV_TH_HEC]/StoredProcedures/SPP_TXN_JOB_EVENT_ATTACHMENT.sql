SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =====================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Insert/Retrieve/Delete attachments - Job Event send email to Client QA
-- Example Query: -- exec SPP_TXN_JOB_EVENT_ATTACHMENT @file_data=N'',@file_name=N'',@file_extension=N'',@job_ref_no=N'2018/06/0019',@guid=N'ce403042-2bd2-4185-be9b-29e97d16b91b',@user_id=N'1',@ind=N'G'
--				  -- exec SPP_TXN_JOB_EVENT_ATTACHMENT @file_data=N'',@file_name=N'Chrysanthemum.jpg',@file_extension=N'',@job_ref_no=N'2018/06/0019',@guid=N'ce403042-2bd2-4185-be9b-29e97d16b91b',@user_id=N'1',@ind=N'D'
-- Remarks: 1) A - Insert
--			2) G - Retrieve
--			3) D - Delete
-- =====================================================================================

CREATE PROCEDURE [dbo].[SPP_TXN_JOB_EVENT_ATTACHMENT]
	@file_data nvarchar(max),
	@file_name	nvarchar(100),
	@file_extension varchar(50),
	@job_ref_no varchar(50),
	@guid nvarchar(100),
	@user_id int,
	@ind	char(5)
AS
BEGIN
	SET NOCOUNT ON;

	IF (@ind = 'A')
		INSERT INTO TBL_TXN_JOB_EVENT_EMAIL_ATTACHMENT 
		(job_ref_no, guid, uploaded_by, uploaded_date, file_name, file_data, file_extension)
		VALUES(@job_ref_no, @guid, @user_id, GETDATE(), @file_name, @file_data, @file_extension)
	
	ELSE IF (@ind = 'G')
		SELECT file_name, file_data, file_extension FROM TBL_TXN_JOB_EVENT_EMAIL_ATTACHMENT WITH(NOLOCK)
		WHERE job_ref_no = @job_ref_no AND guid = @guid

	ELSE IF (@ind = 'D')
		DELETE FROM TBL_TXN_JOB_EVENT_EMAIL_ATTACHMENT 
		WHERE job_ref_no = @job_ref_no AND file_name = @file_name AND guid = @guid
END
GO
