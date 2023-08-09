SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
--Exec [dbo].[SPP_TXN_JOB_EVENT_UPDATEWI] @param= N'{"job_ref_no":"S2021/11/0001","New_Subcon_WI_no":"WI0349102100011","selected_event_id":"1"}',1  
  
CREATE Procedure [dbo].[SPP_TXN_JOB_EVENT_UPDATEWI]   
@param NVARCHAR(1000),    
@user_id INT    
AS    
BEGIN    
    
DECLARE @job_ref_no NVARCHAR(50) = (SELECT JSON_VALUE(@param, '$.job_ref_no'))    
DECLARE @New_Subcon_WI_no NVARCHAR(50) = (SELECT JSON_VALUE(@param, '$.New_Subcon_WI_no'))    
Declare @Old_Subcon_WI_NO NVARCHAR(100)= (SELECT subcon_WI_no FROM TBL_subcon_TXN_WORK_ORDER WHERE job_ref_no = @job_ref_no)  
Declare @product_code NVARCHAR(100)= (SELECT prd_code FROM TBL_subcon_TXN_WORK_ORDER WHERE job_ref_no = @job_ref_no)  

IF((Select COUNT(*) from TBL_MST_SUBCON_DTL where subcon_no=@New_Subcon_WI_no and prd_code=@product_code and subcon_status<>'Delete')=0)
BEGIN
	SELECT 'Subcon WI No doesn''t exist/deleted'
END
ELSE IF ((Select current_event from TBL_subcon_TXN_WORK_ORDER WHERE job_ref_no = @job_ref_no)<25)
BEGIN
	SELECT 'Confirm Stock event must exist'
END
ELSE IF ((Select current_event from TBL_subcon_TXN_WORK_ORDER WHERE job_ref_no = @job_ref_no)>=40)
BEGIN
	SELECT 'VAS event must not exist'
END
ELSE
BEGIN

	Update TBL_subcon_TXN_WORK_ORDER   
	SET subcon_WI_no = @New_Subcon_WI_no  
	WHERE job_ref_no = @job_ref_no  

	UPDATE  VAS_INTEGRATION.dbo.VAS_SUBCON_TRANSFER_ORDER
	SET SWI_No=@New_Subcon_WI_no where subcon_job_no=@job_ref_no

	INSERT INTO TBL_ADM_AUDIT_TRAIL      
	  (module, key_code, action, action_by, action_date)      
	  --SELECT 'JOB-EVENT', @job_ref_no, 'WI No has been updated through Job Event from' + @Old_Subcon_WI_NO + ' to '+ @New_Subcon_WI_no, @user_id, GETDATE()   
	  SELECT 'Subcon Assignment List(Update BatchNo/ExpiryDate)', @job_ref_no, 'WI No has been updated through '+@job_ref_no+' from ' + @Old_Subcon_WI_NO + ' to '+ @New_Subcon_WI_no, @user_id, GETDATE()   

	  SELECT 'Success'

END    
END  
  
GO
