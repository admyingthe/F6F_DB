SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ========================================================================
-- Author:		Ying
-- Create date: 2023-04-20
-- Description: Reopen/Close Reopened PPM of Job
-- Example Query: exec SPP_TXN_PPM_UDAPTE_REOPEN @param=N'{"job_ref_no":"V2022/08/0001", "action":"Reopen"}', @user_id=N'8032'

-- THIS SPP IS NOT COMPLETE --
-- V2022/08/0001 [VAS]

-- ========================================================================

CREATE PROCEDURE SPP_TXN_PPM_UDAPTE_REOPEN
	@param NVARCHAR(MAX), 
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @job_ref_no VARCHAR(50), @action VARCHAR(50), @from_vas_event_running_no VARCHAR(50)
	SET @job_ref_no = (SELECT JSON_VALUE(@param, '$.job_ref_no'))
	SET @action = (SELECT JSON_VALUE(@param, '$.action'))

	-- only update the last line (and double check if the event_id = 80)
	SET @from_vas_event_running_no = (SELECT TOP 1 running_no FROM TBL_TXN_JOB_EVENT WHERE job_ref_no = @job_ref_no ORDER BY running_no desc)
	DECLARE @count INT = (select count(*) from TBL_TXN_JOB_EVENT WHERE job_ref_no = @job_ref_no AND running_no = @from_vas_event_running_no AND event_id = 40)

	IF (@count = 1)
	BEGIN
		UPDATE TBL_TXN_JOB_EVENT SET currently_reopened_PPM = (CASE WHEN @action = 'Reopen' then 1 WHEN @action = 'Close' then 0 END) WHERE job_ref_no = @job_ref_no AND running_no = @from_vas_event_running_no AND event_id = 40

		INSERT INTO TBL_ADM_AUDIT_TRAIL (module, key_code, action, action_by, action_date)
		VALUES('JOB-EVENT-NEW', @job_ref_no, 'PPM reopened at running number: ' + CAST(@from_vas_event_running_no as varchar(50)), @user_id, GETDATE())

		SELECT 1 AS success
	END
	ELSE
	BEGIN
		SELECT 0 AS success
	END
END
GO
