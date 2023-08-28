SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
      
-- ===============================================================================================================================================================================================================      
-- Author:  Siow Shen Yee      
-- Create date: 2018-07-13      
-- Description: Submit / Approve / Reject / Update header of MLL      
-- Example Query: - exec SPP_MST_MLL_SUBMIT @param=N'{"mll_no":"MLL005300RD00004","mll_status":"Submitted","signature_data":"","start_date":"2018-05-30","end_date":"9999-12-31","submitted_date_ind":1}',@user_id=N'1'      
--      - exec SPP_MST_MLL_SUBMIT @param=N'{"mll_no":"MLL014300RD00008","mll_status":"Approved","start_date":"2018-05-24","end_date":"9999-12-31"}',@user_id=N'1'      
--      - exec SPP_MST_MLL_SUBMIT @param=N'{"mll_no":"MLL009100RD00003","mll_status":" ","start_date":"2018-08-23","end_date":"2018-12-31","mll_desc":"a&#39;b"}',@user_id=N'1'      
--      - exec SPP_MST_MLL_SUBMIT @param=N'{"mll_no":"MLL009100RD00004","mll_status":" ","start_date":"2018-12-04","end_date":"2018-12-31","mll_desc":"ABBOTT (HEASMPH)","mll_change_remarks":"test change","mll_urgent":"Y"}',@user_id=N'1'      
-- ===============================================================================================================================================================================================================      
      
CREATE PROCEDURE [dbo].[SPP_MST_MLL_SUBMIT]      
 @param NVARCHAR(MAX),      
 @user_id INT      
AS      
BEGIN      
 SET NOCOUNT ON;      
 DECLARE @mll_no VARCHAR(50), @mll_status VARCHAR(50), @mll_desc NVARCHAR(200), @client_code VARCHAR(50), @type_of_vas VARCHAR(50), @sub VARCHAR(50), @mll_change_remarks NVARCHAR(200), @mll_urgent VARCHAR(10)      
 SET @mll_no = (SELECT JSON_VALUE(@param, '$.mll_no'))      
 SET @mll_status = (SELECT JSON_VALUE(@param, '$.mll_status'))      
 SET @mll_desc = (SELECT JSON_VALUE(@param, '$.mll_desc'))      
 SET @mll_change_remarks = (SELECT JSON_VALUE(@param, '$.mll_change_remarks'))      
 SET @mll_urgent = (SELECT JSON_VALUE(@param, '$.mll_urgent'))      
 SELECT @client_code = client_code, @type_of_vas = type_of_vas, @sub = sub FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_no = @mll_no   
 
 --declare @dept_code varchar(10)
 --select @dept_code = department from VAS.dbo.TBL_ADM_USER where user_id = @user_id
          
  
 EXEC REPLACE_SPECIAL_CHARACTER @mll_desc, @mll_desc OUTPUT      
 EXEC REPLACE_SPECIAL_CHARACTER @mll_change_remarks, @mll_change_remarks OUTPUT      
      
 IF @mll_status = 'Submitted'      
 BEGIN      
  DECLARE @signature_data NVARCHAR(MAX), @submitted_start_date DATETIME, @submitted_end_date DATETIME, @submitted_date_ind INT      
  SET @submitted_start_date = (SELECT JSON_VALUE(@param, '$.start_date'))      
  SET @submitted_end_date = (SELECT JSON_VALUE(@param, '$.end_date'))      
  SET @signature_data = (SELECT JSON_VALUE(@param, '$.signature_data'))      
  SET @submitted_date_ind = (SELECT JSON_VALUE(@param, '$.submitted_date_ind'))      
        
  -- Submitted date ind = 1 means not auto approved      
  IF @submitted_date_ind = 1      
  BEGIN      
   UPDATE TBL_MST_MLL_HDR      
   SET mll_status = @mll_status,      
    mll_desc = @mll_desc,      
    digital_signature = @signature_data,      
    start_date = @submitted_start_date,      
    end_date = @submitted_end_date,      
    submitted_by = @user_id,    
	--submitted_user_dept_code = @dept_code,
    submitted_date = GETDATE(),       
    mll_change_remarks = @mll_change_remarks,      
    mll_urgent = @mll_urgent      
   WHERE mll_no = @mll_no      
  END      
      
 END      
 ELSE IF @mll_status = 'Approved'      
 BEGIN      
  DECLARE @start_date DATETIME, @end_date DATETIME      
  SET @start_date = (SELECT JSON_VALUE(@param, '$.start_date'))      
  SET @end_date = (SELECT JSON_VALUE(@param, '$.end_date'))      
        
  IF @start_date < GETDATE() SET @start_date = GETDATE()      
      
  UPDATE TBL_MST_MLL_HDR      
  SET end_date = @start_date - 1      
  WHERE client_code = @client_code AND type_of_vas = @type_of_vas AND sub = @sub AND end_date > @start_date AND mll_status = 'Approved'      
      
  UPDATE TBL_MST_MLL_HDR      
  SET mll_status = @mll_status,      
   mll_desc = @mll_desc,      
   start_date = @start_date,      
   end_date = @end_date,      
approved_by = @user_id,      
--approved_user_dept_code = @dept_code,
   approved_date = GETDATE(),      
   mll_change_remarks = @mll_change_remarks,      
   mll_urgent = @mll_urgent      
  WHERE mll_no = @mll_no      
      
  -- Insert into Integration table --      
  SELECT A.mll_no, A.prd_code, start_date, end_date,      
  json_value(vas_activities, '$[0].radio_val') as radio_val_1,       
  json_value(vas_activities, '$[1].radio_val') as radio_val_2,       
  json_value(vas_activities, '$[2].radio_val') as radio_val_3,      
  json_value(vas_activities, '$[3].radio_val') as radio_val_4,       
  json_value(vas_activities, '$[4].radio_val') as radio_val_5,       
  json_value(vas_activities, '$[5].radio_val') as radio_val_6,       
  json_value(vas_activities, '$[6].radio_val') as radio_val_7,       
  json_value(vas_activities, '$[7].radio_val') as radio_val_8,       
  json_value(vas_activities, '$[8].radio_val') as radio_val_9, CAST(NULL as VARCHAR(10)) as radio_val      
  INTO #temp_vas_activities_current      
  FROM TBL_MST_MLL_DTL A WITH(NOLOCK)      
  INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no      
  WHERE --A.mll_no = @mll_no      
  B.client_code = @client_code AND B.type_of_vas = @type_of_vas AND B.sub = @sub      
  AND B.mll_status = 'Approved' AND end_date > GETDATE()-- AND end_date < start_date      
      
  UPDATE #temp_vas_activities_current      
  SET radio_val = CASE WHEN (radio_val_1 IN ('Y','P')      
         OR radio_val_2 IN ('Y','P')      
         OR radio_val_3 IN ('Y','P')      
         OR radio_val_4 IN ('Y','P')      
         OR radio_val_5 IN ('Y','P')      
         OR radio_val_6 IN ('Y','P')      
         OR radio_val_7 IN ('Y','P')      
         OR radio_val_8 IN ('Y','P')      
         OR radio_val_9 IN ('Y','P')) THEN 'Y' ELSE 'N' END      
      
  UPDATE #temp_vas_activities_current      
  SET radio_val = 'N'    
  Where (radio_val_1 ='P' OR radio_val_2 = 'P' OR radio_val_3 = 'P' OR     
                             radio_val_4= 'P' OR radio_val_5 = 'P' OR radio_val_6 = 'P' OR radio_val_7 = 'P' OR radio_val_8 = 'P' OR radio_val_9 ='P' )     
        AND (radio_val_1 ='N' OR radio_val_2 = 'N' OR radio_val_3 = 'N' OR     
                             radio_val_4= 'N' OR radio_val_5 = 'N' OR radio_val_6 = 'N' OR radio_val_7 = 'N' OR radio_val_8 = 'N' OR radio_val_9 ='N')     
    
  UPDATE #temp_vas_activities_current      
  SET radio_val = 'Y'    
  Where (radio_val_1 ='P' OR radio_val_2 = 'P' OR radio_val_3 = 'P' OR     
                             radio_val_4= 'P' OR radio_val_5 = 'P' OR radio_val_6 = 'P' OR radio_val_7 = 'P' OR radio_val_8 = 'P' OR radio_val_9 ='P' )     
        AND (radio_val_1 ='Y' OR radio_val_2 = 'Y' OR radio_val_3 = 'Y' OR     
                             radio_val_4= 'Y' OR radio_val_5 = 'Y' OR radio_val_6 = 'Y' OR radio_val_7 = 'Y' OR radio_val_8 = 'Y' OR radio_val_9 ='Y')     
        
  -- to be inserted      
  SELECT * INTO #active_material FROM #temp_vas_activities_current WHERE radio_val = 'Y'      
      
    
      
  INSERT INTO VAS_INTEGRATION.dbo.VAS_CONDITIONS (prd_code, start_date, end_date, previous_val, current_val, created_date, process_ind)      
  SELECT prd_code, start_date, end_date, 'N', 'Y', GETDATE(), 0 FROM #active_material      
      
  -- get supercedes approved mll no to find Y -> N      
  DECLARE @supercedes_mll_no VARCHAR(50)      
  SET @supercedes_mll_no = ISNULL((SELECT TOP 1 mll_no FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE client_code = ( SELECT substring(@mll_no, 4, 4) ) AND type_of_vas = 'RD' AND sub = (select substring(@mll_no, 8, 2)) AND mll_no < @mll_no AND mll_status = 'Approved' ORDER BY mll_no DESC),'')      
        
  SELECT A.mll_no, A.prd_code, start_date, end_date,      
  json_value(vas_activities, '$[0].radio_val') as radio_val_1,       
  json_value(vas_activities, '$[1].radio_val') as radio_val_2,       
  json_value(vas_activities, '$[2].radio_val') as radio_val_3,      
  json_value(vas_activities, '$[3].radio_val') as radio_val_4,       
  json_value(vas_activities, '$[4].radio_val') as radio_val_5,       
  json_value(vas_activities, '$[5].radio_val') as radio_val_6,       
  json_value(vas_activities, '$[6].radio_val') as radio_val_7,       
  json_value(vas_activities, '$[7].radio_val') as radio_val_8,       
  json_value(vas_activities, '$[8].radio_val') as radio_val_9, CAST(NULL as VARCHAR(10)) as radio_val      
  INTO #temp_vas_activities_previous      
  FROM TBL_MST_MLL_DTL A WITH(NOLOCK)      
  INNER JOIN TBL_MST_MLL_HDR B WITH(NOLOCK) ON A.mll_no = B.mll_no      
  WHERE A.mll_no = @supercedes_mll_no      
      
  UPDATE #temp_vas_activities_previous      
  SET radio_val = CASE WHEN (radio_val_1 IN ('Y','P')      
         OR radio_val_2 IN ('Y','P')      
         OR radio_val_3 IN ('Y','P')      
         OR radio_val_4 IN ('Y','P')      
         OR radio_val_5 IN ('Y','P')      
         OR radio_val_6 IN ('Y','P')      
         OR radio_val_7 IN ('Y','P')      
         OR radio_val_8 IN ('Y','P')      
         OR radio_val_9 IN ('Y','P')) THEN 'Y' ELSE 'N' END     
    
  UPDATE #temp_vas_activities_previous      
  SET radio_val = 'N'    
  Where (radio_val_1 ='P' OR radio_val_2 = 'P' OR radio_val_3 = 'P' OR     
                             radio_val_4= 'P' OR radio_val_5 = 'P' OR radio_val_6 = 'P' OR radio_val_7 = 'P' OR radio_val_8 = 'P' OR radio_val_9 ='P' )     
        AND (radio_val_1 ='N' OR radio_val_2 = 'N' OR radio_val_3 = 'N' OR     
                             radio_val_4= 'N' OR radio_val_5 = 'N' OR radio_val_6 = 'N' OR radio_val_7 = 'N' OR radio_val_8 = 'N' OR radio_val_9 ='N')     
    
  UPDATE #temp_vas_activities_previous      
  SET radio_val = 'Y'    
  Where (radio_val_1 ='P' OR radio_val_2 = 'P' OR radio_val_3 = 'P' OR     
                             radio_val_4= 'P' OR radio_val_5 = 'P' OR radio_val_6 = 'P' OR radio_val_7 = 'P' OR radio_val_8 = 'P' OR radio_val_9 ='P' )     
        AND (radio_val_1 ='Y' OR radio_val_2 = 'Y' OR radio_val_3 = 'Y' OR     
                             radio_val_4= 'Y' OR radio_val_5 = 'Y' OR radio_val_6 = 'Y' OR radio_val_7 = 'Y' OR radio_val_8 = 'Y' OR radio_val_9 ='Y')     
    
  -- Y -> N      
  INSERT INTO VAS_INTEGRATION.dbo.VAS_CONDITIONS (prd_code, start_date, end_date, previous_val, current_val, created_date, process_ind)      
  SELECT prd_code, start_date, end_date, 'Y', 'N', GETDATE(), 0 FROM #temp_vas_activities_previous A WHERE radio_val = 'Y' AND prd_code NOT IN (SELECT prd_code FROM #active_material)      
      
  DROP TABLE #temp_vas_activities_previous      
  DROP TABLE #active_material      
      
 END      
 ELSE IF @mll_status = 'Rejected'      
 BEGIN      
  DECLARE @rejection_reason NVARCHAR(150)      
  SET @rejection_reason = (SELECT JSON_VALUE(@param, '$.rejection_reason'))      
      
  UPDATE TBL_MST_MLL_HDR      
  SET mll_status = 'Rejected',      
   mll_desc = @mll_desc,      
   rejection_reason = @rejection_reason,      
   rejected_by = @user_id,     
   --rejected_user_dept_code = @user_id,
   rejected_date = GETDATE()      
  WHERE mll_no = @mll_no      
 END      
 ELSE IF @mll_status = ' '      
 BEGIN      
  SET @mll_status = 'Updated header'      
  DECLARE @selected_start_date DATETIME, @selected_end_date DATETIME      
  SET @selected_start_date = (SELECT JSON_VALUE(@param, '$.start_date'))      
  SET @selected_end_date = (SELECT JSON_VALUE(@param, '$.end_date'))      
      
  UPDATE TBL_MST_MLL_HDR      
  SET start_date = (SELECT working_day FROM dbo.[TF_COR_GET_WORKING_DAYS](@selected_start_date, 0)), --avoid starting date is on weekend      
   end_date = @selected_end_date,      
   mll_desc = @mll_desc,      
   mll_change_remarks = @mll_change_remarks,      
   mll_urgent = @mll_urgent      
  WHERE mll_no = @mll_no      
 END      
      
 IF @mll_status <> ' '   
 begin
  INSERT INTO TBL_ADM_AUDIT_TRAIL      
  (module, key_code, action, action_by, action_date)      
  SELECT 'MLL', @mll_no, @mll_status, @user_id, GETDATE()      
   
 --   IF @mll_status <> 'Approved' 
	--begin
 EXEC SPP_MST_MLL_EMAIL @mll_status, @mll_no, @user_id  
 --end

 end
 

 IF @mll_status = 'Approved' 
 BEGIN
	 --DECLARE @VAS_Insert CHAR(1),@VAS_Readdress CHAR(1),@VAS_Inject CHAR(1),@VAS_Others CHAR(1)

	 --SELECT @VAS_Insert = radio_val_6,@VAS_Readdress = radio_val_7,@VAS_Inject = radio_val_8,@VAS_Others =radio_val_9 
	 --FROM #temp_vas_activities_current 
	 --WHERE mll_no = @mll_no

	-- IF(@VAS_Insert  ='Y' OR @VAS_Readdress  ='Y' OR @VAS_Inject  ='Y' OR @VAS_Others  ='Y')
	-- BEGIN
	-- print '1'
	-- DECLARE @tab char(1) = CHAR(9)
	--EXEC [SPP_SEND_EMAIL_QA] @mll_no,@client_code
	
	-- END
	 DROP TABLE #temp_vas_activities_current  
 END  

 SELECT '1'      
END
GO
