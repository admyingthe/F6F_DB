SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==========================================================================================
-- Author:		LE TIEN DUNG
-- Create date: 2022-22-12
-- Description: Retrieve Prd_code for listing Detail Vendor in Job
-- Example Query: exec SPP_GET_PRD_CODE_DLL @param=N'{"job_ref_no":"G2022/08/0004"}'
-- ==========================================================================================

CREATE PROC [dbo].[SPP_GET_PRD_CODE_DLL]
@param NVARCHAR(MAX)
AS
BEGIN
	DECLARE @job_ref_no NVARCHAR(20) = (SELECT JSON_VALUE(@param, '$.job_ref_no'))
	DECLARE @system_running_no NVARCHAR(20) = ''

	SELECT TOP 1 @system_running_no = running_no FROM TBL_TXN_JOB_EVENT 
	WHERE job_ref_no=@job_ref_no
	AND event_id=80 
	ORDER BY created_date DESC

	SELECT DISTINCT prd_code
	FROM TBL_TXN_WORK_ORDER A WITH(NOLOCK) 
	WHERE A.job_ref_no = @job_ref_no 
	--AND running_no=@system_running_no
END
GO
