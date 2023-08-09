SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
-- ========================================================================    
-- Author:      
-- Create date:     
-- Description: Complete PPM. Add event to Job Event transaction    
-- Example Query: exec [SPP_TXN_SUBCON_PPM_COMPLETE] @param=N'{"job_ref_no":"2018/06/0029"}',@user_id=1    
-- ========================================================================    
    
CREATE PROCEDURE [dbo].[SPP_TXN_SUBCON_PPM_COMPLETE]    
 @param NVARCHAR(MAX),    
 @user_id INT    
AS    
BEGIN    
 SET NOCOUNT ON;    
    
 DECLARE @job_ref_no VARCHAR(50)    
 SET @job_ref_no = (SELECT JSON_VALUE(@param, '$.job_ref_no'))    
    
 DECLARE @running_no VARCHAR(50) = 1, @len INT = 8    
 SELECT TOP 1 @running_no = CAST(CAST(RIGHT(running_no, @len) as INT) + 1 AS VARCHAR(50))    
        FROM (SELECT running_no FROM TBL_TXN_JOB_EVENT WITH(NOLOCK)) A ORDER BY CAST(RIGHT(running_no, @len) AS INT) DESC    
 SET @running_no = 'MY' + REPLICATE('0', @len - LEN(@running_no)) + @running_no    
    
 DECLARE @start_date DATETIME    
 SET @start_date = (SELECT start_date FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND event_id = '00')    
    
 INSERT INTO TBL_TXN_JOB_EVENT    
 (running_no, job_ref_no, event_id, start_date, end_date, created_date, creator_user_id)    
 SELECT @running_no, @job_ref_no, '10', @start_date, GETDATE(), GETDATE(), @user_id    
    
 UPDATE [VAS_Subcon_TRANSFER_ORDER]    
 SET current_event = '10'    
 WHERE job_ref_no = @job_ref_no    
    
 INSERT INTO TBL_ADM_AUDIT_TRAIL    
 (module, key_code, action, action_by, action_date)    
 SELECT 'PPM-SEARCH', @job_ref_no, 'Completed PPM', @user_id, GETDATE()    
END 
GO
