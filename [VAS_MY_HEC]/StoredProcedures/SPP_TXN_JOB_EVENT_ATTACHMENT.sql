SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
