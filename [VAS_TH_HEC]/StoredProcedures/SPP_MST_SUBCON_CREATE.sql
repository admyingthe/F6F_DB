SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
-- ======================================================================================================================  
-- Author:  Vijitha  
-- Create date: 2021-10-25  
-- Description: Create new SUBCON  
-- Example Query: exec SPP_MST_SUBCON_CREATE @submit_obj=N'{"client_code":"0G67","type_vas":"SC","sub":"01","search_vas":"Search","export":"Export","add":"Add","delete":"Mark For Deletion","subcon_no":"WI0G67102100001","prd_code":"100751006","prd_desc":"DHASEDYL DM SYRUP 100ML","reg_no":"MAL20051379AZ","remarks":"2424","client_ref_no":"etetet","attachment":"","expiry_date":"2021-10-29","qa_required_view":"on","save_close":"Save and Close","vas_activities":[{"prd_code":"450001028","radio_val":"","page_dtl_id":8154},{"prd_code":"","radio_val":"","page_dtl_id":8155},{"prd_code":"","radio_val":"","page_dtl_id":8156},{"prd_code":"","radio_val":"","page_dtl_id":8157},{"prd_code":"","radio_val":"","page_dtl_id":8158},{"prd_code":"","radio_val":"","page_dtl_id":8159},{"prd_code":"","radio_val":"","page_dtl_id":8160},{"prd_code":"","radio_val":"","page_dtl_id":8161},{"prd_code":"","radio_val":"","page_dtl_id":8162}],"mode":"New"}',@user_id=N'1'  
-- Output : prd_code  
-- ==============================================================SUBCON=========================================================  
CREATE PROCEDURE [dbo].[SPP_MST_SUBCON_CREATE]  
 @submit_obj nvarchar(max),  
 @user_id INT  
AS  
BEGIN  
 SET NOCOUNT ON;  
  
 DECLARE @client_code VARCHAR(50), @type_of_vas VARCHAR(50), @sub VARCHAR(50), @subcon_no VARCHAR(100), @subcon_desc NVARCHAR(250), @prd_code VARCHAR(50), @registration_no VARCHAR(50), @remarks NVARCHAR(MAX),@expiry_date VARCHAR(50),@qa_required_view VARCHAR(50),
 @vas_activities NVARCHAR(MAX), @mode VARCHAR(50), @client_ref_no NVARCHAR(100), @revision_no NVARCHAR(100)  
 SET @client_code = (SELECT JSON_VALUE(@submit_obj, '$.client_code'))  
 SET @type_of_vas = (SELECT JSON_VALUE(@submit_obj, '$.type_vas'))  
 SET @sub = (SELECT JSON_VALUE(@submit_obj, '$.sub'))  
 SET @subcon_no = (SELECT JSON_VALUE(@submit_obj, '$.subcon_no'))  
 SET @prd_code = (SELECT JSON_VALUE(@submit_obj, '$.prd_code'))  
 SET @registration_no = ISNULL((SELECT JSON_VALUE(@submit_obj, '$.reg_no')), '')  
 SET @expiry_date =  CASE WHEN (SELECT JSON_VALUE(@submit_obj, '$.expiry_date')) = '' THEN NULL ELSE (SELECT JSON_VALUE(@submit_obj, '$.expiry_date')) END  
 SET @remarks = ISNULL((SELECT REPLACE(JSON_VALUE(@submit_obj, '$.remarks'), '&#39;', '''')), '')  
 SET @vas_activities = (SELECT JSON_QUERY(@submit_obj, '$.vas_activities'))  
 SET @mode = (SELECT JSON_VALUE(@submit_obj, '$.mode'))  
 SET @client_ref_no = (SELECT JSON_VALUE(@submit_obj, '$.client_ref_no'))  
 SET @revision_no = ISNULL((SELECT JSON_VALUE(@submit_obj, '$.revision_no')), '')  
 SET @qa_required_view = ISNULL((SELECT JSON_VALUE(@submit_obj, '$.qa_required_view')), '')  

 EXEC REPLACE_SPECIAL_CHARACTER @remarks, @remarks OUTPUT  
  
 IF (@mode = 'New')  
 BEGIN  
  IF(SELECT COUNT(*) FROM TBL_MST_SUBCON_HDR WITH(NOLOCK) WHERE subcon_no = @subcon_no) = 0  
  BEGIN  
   INSERT INTO TBL_MST_SUBCON_HDR  
   (client_code, type_of_vas, sub, subcon_no,subcon_desc, subcon_status, client_ref_no, revision_no, created_date, creator_user_id)  
   VALUES  
   (@client_code, @type_of_vas, @sub, @subcon_no,@subcon_desc, 'Active',  @client_ref_no, @revision_no, GETDATE(), @user_id)  
  
   IF(SELECT COUNT(*) FROM TBL_MST_SUBCON_DTL WITH(NOLOCK) WHERE subcon_no = @subcon_no AND prd_code = @prd_code) = 0  
   BEGIN  
    INSERT INTO TBL_MST_SUBCON_DTL  
    (subcon_no, prd_code,  registration_no, remarks, vas_activities, qa_required,expiry_date,subcon_status)  
    VALUES  
    (@subcon_no, @prd_code, @registration_no, @remarks, @vas_activities, @qa_required_view,@expiry_date,'Active')  
  
    SELECT @prd_code as prd_code  
   END  
   ELSE  
   BEGIN  
    PRINT '1'  
    SELECT '' as prd_code  
   END  
  END  
  ELSE  
  BEGIN  
   PRINT '2'  
   SELECT '' as prd_code  
  END  
  
  INSERT INTO TBL_ADM_AUDIT_TRAIL  
  (module, key_code, action, action_by, action_date)  
  SELECT 'SUBCON', @subcon_no, 'Created ' + @prd_code, @user_id, GETDATE()  
  
 END  
 ELSE IF(@mode = 'Add')  
 BEGIN  
  IF(SELECT COUNT(*) FROM TBL_MST_SUBCON_DTL WITH(NOLOCK) WHERE subcon_no = @subcon_no AND prd_code = @prd_code) = 0  
  BEGIN  
   INSERT INTO TBL_MST_SUBCON_DTL  
   (subcon_no, prd_code, registration_no, remarks, vas_activities, qa_required,expiry_date,subcon_status)  
   VALUES  
   (@subcon_no, @prd_code, @registration_no, @remarks, @vas_activities,@qa_required_view,@expiry_date,'Active')  
  
   INSERT INTO TBL_ADM_AUDIT_TRAIL  
   (module, key_code, action, action_by, action_date)  
   SELECT 'SUBCON', @subcon_no, 'Added new item ' + @prd_code, @user_id, GETDATE()  
  
   SELECT @prd_code as prd_code  
  END  
  ELSE  
   SELECT '' as prd_code  
 END  
 ELSE IF (@mode = 'Edit')  
 BEGIN  
    
  UPDATE TBL_MST_SUBCON_HDR  
  SET client_ref_no = @client_ref_no,  
   revision_no = @revision_no  
  WHERE subcon_no = @subcon_no  
  
  UPDATE TBL_MST_SUBCON_DTL  
  SET   
   registration_no = @registration_no,  
   remarks = @remarks,  
   vas_activities = @vas_activities,  
   qa_required = @qa_required_view,  
   expiry_date=@expiry_date  
  WHERE subcon_no = @subcon_no AND prd_code = @prd_code  
  
  INSERT INTO TBL_ADM_AUDIT_TRAIL  
  (module, key_code, action, action_by, action_date)  
  SELECT 'SUBCON', @subcon_no, 'Edited item ' + @prd_code, @user_id, GETDATE()  
  
  SELECT @prd_code as prd_code  
 END  
END  
  
GO
