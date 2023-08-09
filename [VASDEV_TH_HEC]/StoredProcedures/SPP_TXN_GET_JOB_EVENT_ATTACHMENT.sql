SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_TXN_GET_JOB_EVENT_ATTACHMENT]
@job_ref_no NVARCHAR(20),
@event_id NVARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT file_name,'', file_data 
	FROM TBL_TXN_JOB_EVENT_EMAIL_ATTACHMENT 
	WITH(NOLOCK)
	WHERE job_ref_no = @job_ref_no
	UNION
	SELECT A.file_name, A.attachment, file_data 
	FROM VASDEV.dbo.TBL_ADM_EMAIL_READER_ATTACHMENT A
	WITH (NOLOCK)
	INNER JOIN VASDEV.dbo.TBL_ADM_EMAIL_READER B WITH (NOLOCK) ON A.mail_id = B.mail_id
	INNER JOIN TBL_TXN_JOB_EVENT C WITH (NOLOCK) ON SUBSTRING(RIGHT(B.mail_subject, 12), 1, 10) = C.parent_running_no
	CROSS APPLY (SELECT attachment AS '*' FOR XML PATH('')) T (file_data)
	WHERE C.parent_running_no = (SELECT TOP 1 parent_running_no FROM TBL_TXN_JOB_EVENT WITH (NOLOCK) WHERE job_ref_no = @job_ref_no AND event_id = @event_id)
	AND job_ref_no = @job_ref_no
	GROUP BY A.file_name, A.attachment, T.file_data
END
GO
