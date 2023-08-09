SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
-- ========================================================================  
-- Author:  Siow Shen Yee  
-- Create date: 2018-07-13  
-- Description: Complete PPM. Add event to Job Event transaction  
-- Example Query: exec SPP_TXN_PPM_COMPLETE @param=N'{"job_ref_no":"2018/06/0029"}',@user_id=1  
-- ========================================================================  
  
CREATE PROCEDURE [dbo].[SPP_TXN_PPM_COMPLETE]  
	@param NVARCHAR(MAX),  
	@user_id INT  
AS  
BEGIN  
	SET NOCOUNT ON;  
  
	--Added to get Thailand Time along with date
	DECLARE @CurrentDateTime AS DATETIME
	SET @CurrentDateTime=(SELECT DATEADD(hh, -1 ,GETDATE()) )
	--Added to get Thailand Time along with date

	DECLARE @job_ref_no VARCHAR(50), @from_vas_event_running_no VARCHAR(50)
	SET @job_ref_no = (SELECT JSON_VALUE(@param, '$.job_ref_no'))  
  
	DECLARE @running_no VARCHAR(50) = 1, @len INT = 8  
	SELECT TOP 1 @running_no = CAST(CAST(RIGHT(running_no, @len) as INT) + 1 AS VARCHAR(50))  
		FROM (SELECT running_no FROM TBL_TXN_JOB_EVENT WITH(NOLOCK)) A ORDER BY CAST(RIGHT(running_no, @len) AS INT) DESC  
	SET @running_no = 'TH' + REPLICATE('0', @len - LEN(@running_no)) + @running_no  
  
	DECLARE @start_date DATETIME  
	SET @start_date = (SELECT start_date FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND event_id = '00')  

	SET @from_vas_event_running_no = (SELECT TOP 1 running_no FROM TBL_TXN_JOB_EVENT WHERE job_ref_no = @job_ref_no ORDER BY running_no desc)
	
	IF EXISTS (SELECT 1 FROM TBL_TXN_JOB_EVENT WHERE job_ref_no = @job_ref_no AND running_no = @from_vas_event_running_no AND event_id = 40 AND currently_reopened_PPM = 1)
	BEGIN
		-- Reopen PPM
		UPDATE TBL_TXN_JOB_EVENT SET currently_reopened_PPM = 0 WHERE job_ref_no = @job_ref_no AND running_no = @from_vas_event_running_no AND event_id = 40
	END
	ELSE 
	BEGIN
		-- insert to TBL_TXN_JOB_EVENT only for first time closing PPM
		INSERT INTO TBL_TXN_JOB_EVENT  
		(running_no, job_ref_no, event_id, start_date, end_date, created_date, creator_user_id)  
		SELECT @running_no, @job_ref_no, '10', @start_date, @CurrentDateTime, @CurrentDateTime, @user_id  
	END
  
	UPDATE TBL_TXN_WORK_ORDER_JOB_DET  
	SET current_event = '10'  
	WHERE job_ref_no = @job_ref_no  
 
	UPDATE TBL_Subcon_TXN_WORK_ORDER  
	SET current_event = '10'  
	WHERE job_ref_no = @job_ref_no  

	INSERT INTO TBL_ADM_AUDIT_TRAIL  
	(module, key_code, action, action_by, action_date)  
	SELECT 'PPM-SEARCH', @job_ref_no, 'Completed PPM', @user_id, @CurrentDateTime  
END  


GO
