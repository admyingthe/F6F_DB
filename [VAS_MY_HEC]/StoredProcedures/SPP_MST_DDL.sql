SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
-- ===============================================================================================================================================    
-- Author:  Siow Shen Yee    
-- Create date: 2018-07-13    
-- Description: Retrieve all dropdown data     
-- Example Query:    
-- 1) MLL - exec SPP_MST_DDL @ddl_obj=N'{"user_id":"1","language_id":"0","ddl_code":"ddlClient"}'    
--        - exec SPP_MST_DDL @ddl_obj=N'{"user_id":"1","language_id":"0","ddl_code":"ddlSub","client_code":"0091"}'    
--    - exec SPP_MST_DDL @ddl_obj=N'{"user_id":"1","language_id":"0","ddl_code":"ddlVASActivities"}'    
--    - exec SPP_MST_DDL @ddl_obj=N'{"user_id":"1","language_id":"0","ddl_code":"ddlJobEventNew"}'    
--    - exec SPP_MST_DDL @ddl_obj=N'{"user_id":"1","language_id":"0","ddl_code":"ddlTypeOfVAS"}'    
--    - exec SPP_MST_DDL @ddl_obj=N'{"user_id":"1","language_id":"0","ddl_code":"ddlMLLNo","client_code":"0091","type_of_vas":"RD","sub":"00"}'    
-- 2) Assignment List - exec SPP_MST_DDL @ddl_obj=N'{"user_id":"1","language_id":"0","ddl_code":"ddlAssignmentStatus"}'    
-- 3) Work Order List - exec SPP_MST_DDL @ddl_obj=N'{"user_id":"1","language_id":"0","ddl_code":"ddlWorkOrderStatus"}'    
--       - exec SPP_MST_DDL @ddl_obj=N'{"user_id":"1","language_id":"0","ddl_code":"ddlPendingJob"}'    
-- 4) Job Event - exec SPP_MST_DDL @ddl_obj=N'{"user_id":"1","language_id":"0","ddl_code":"ddlJobEventNew","job_ref_no":"S2021/12/0001"}'    
-- 5) PPM - exec SPP_MST_DDL @ddl_obj=N'{"user_id":"1","language_id":"0","ddl_code":"ddlPPMProduct","job_ref_no":"2018/07/0009"}'    
-- ===============================================================================================================================================    
    
CREATE PROCEDURE [dbo].[SPP_MST_DDL]    
 @ddl_obj nvarchar(max) = ''    
AS    
BEGIN    
 SET NOCOUNT ON;    
    
    DECLARE @ddl_code VARCHAR(50), @user_id INT    
 SET @ddl_code = (SELECT JSON_VALUE(@ddl_obj, '$.ddl_code'))    
    SET @user_id = (SELECT JSON_VALUE(@ddl_obj, '$.user_id'))    
    
 CREATE TABLE #TEMP (code varchar(50), name nvarchar(100))    
 DECLARE @i INT = 0    
    
 /***** MLL *****/    
 IF @ddl_code = 'ddlClient'    
  SELECT client_code as code, RTRIM(client_code) + ' - ' + RTRIM(client_name) as name FROM TBL_MST_CLIENT WITH(NOLOCK) ORDER BY client_name    
 ELSE IF @ddl_code = 'ddlTypeOfVAS'    
  SELECT code, name FROM TBL_MST_DDL WITH(NOLOCK) WHERE ddl_code = @ddl_code AND delete_flag = 0    
 ELSE IF @ddl_code = 'ddlSubconTypeOfVAS'    
  SELECT code, name FROM TBL_MST_DDL WITH(NOLOCK) WHERE ddl_code = @ddl_code AND delete_flag = 0    
 ELSE IF @ddl_code = 'ddlProduct'    
 BEGIN    
  DECLARE @client_code VARCHAR(50), @mll_no VARCHAR(50)    
  SET @client_code = (SELECT JSON_VALUE(@ddl_obj, '$.client_code'))     
  SET @mll_no = (SELECT JSON_VALUE(@ddl_obj, '$.mll_no'))    
      
  SELECT prd_code as code, prd_desc as name FROM TBL_MST_PRODUCT WITH(NOLOCK)    
  WHERE princode = @client_code AND prd_code NOT IN (SELECT prd_code FROM TBL_MST_MLL_DTL WITH(NOLOCK) WHERE mll_no = @mll_no)    
 END    
 ELSE IF @ddl_code LIKE 'ddlVASActivities%'    
  SELECT RTRIM(LTRIM(prd_code)) as value, RTRIM(LTRIM(prd_code)) + ' - ' + prd_desc as name FROM TBL_MST_PRODUCT WITH(NOLOCK) WHERE prd_type = 'ZPK4'    
 ELSE IF @ddl_code = 'ddlStorageCond'    
  SELECT code, name FROM TBL_MST_DDL WITH(NOLOCK) WHERE ddl_code = @ddl_code AND delete_flag = 0    
 ELSE IF @ddl_code = 'ddlMedicalDeviceUsage'    
  SELECT code, name FROM TBL_MST_DDL WITH(NOLOCK) WHERE ddl_code = @ddl_code AND delete_flag = 0    
    ELSE IF @ddl_code = 'ddlBMIFU'    
  SELECT code, name FROM TBL_MST_DDL WITH(NOLOCK) WHERE ddl_code = @ddl_code AND delete_flag = 0    
 ELSE IF @ddl_code = 'ddlMLLNo' --OR @ddl_code = 'ddlCopyMasterVAS'    
 BEGIN    
  DECLARE @selected_client_code VARCHAR(50), @type_of_vas VARCHAR(50), @sub VARCHAR(50)    
  SET @selected_client_code = (SELECT JSON_VALUE(@ddl_obj, '$.client_code'))    
  SET @type_of_vas = (SELECT JSON_VALUE(@ddl_obj, '$.type_of_vas'))    
  SET @sub = (SELECT JSON_VALUE(@ddl_obj, '$.sub'))    
  SELECT mll_no as code, mll_no as name FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE client_code = @selected_client_code AND type_of_vas = @type_of_vas AND sub = @sub    
 END    
  ELSE IF @ddl_code = 'ddlSubconWINo' 
 BEGIN  
  SET @selected_client_code = (SELECT JSON_VALUE(@ddl_obj, '$.client_code'))  
  SET @type_of_vas = (SELECT JSON_VALUE(@ddl_obj, '$.type_of_vas'))  
  SET @sub = (SELECT JSON_VALUE(@ddl_obj, '$.sub'))  
  SELECT subcon_no as code, subcon_no as name FROM TBL_MST_SUBCON_HDR WITH(NOLOCK) WHERE client_code = @selected_client_code AND type_of_vas = @type_of_vas AND sub = @sub  and subcon_status <> 'Delete'
  ORDER BY created_date DESC , subcon_no DESC
 END  
 ELSE IF @ddl_code = 'ddlCopyMasterVAS'    
 BEGIN    
  DECLARE @copy_client_code VARCHAR(50), @copy_type_of_vas VARCHAR(50), @copy_sub VARCHAR(50)    
  SET @copy_client_code = (SELECT JSON_VALUE(@ddl_obj, '$.client_code'))    
  SET @copy_type_of_vas = (SELECT JSON_VALUE(@ddl_obj, '$.type_of_vas'))    
  SET @copy_sub = (SELECT JSON_VALUE(@ddl_obj, '$.sub'))    
  SELECT mll_no as code, mll_no as name FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE client_code = @copy_client_code AND type_of_vas = @copy_type_of_vas AND sub = @copy_sub AND mll_status = 'Approved' ORDER BY mll_no DESC    
 END    
 ELSE IF @ddl_code = 'ddlSub'    
 BEGIN    
  DECLARE @client_code_for_sub VARCHAR(50)    
  SET @client_code_for_sub = (SELECT JSON_VALUE(@ddl_obj, '$.client_code'))    
  SELECT sub_code as code, sub_code +  ' - ' + sub_name as name FROM TBL_MST_CLIENT_SUB WITH(NOLOCK) WHERE client_code = @client_code_for_sub  order by sub_code asc

 END    
 /***** MLL *****/    
    
 /***** Assignment *****/    
 ELSE IF @ddl_code = 'ddlAssignmentStatus'    
 -- hard code because requirement doesn't want 'Cancelled' and 'Closed' to show in DDL but wants them in table when users filter 'All'
  SELECT code, name FROM TBL_MST_DDL WITH(NOLOCK) WHERE ddl_code = @ddl_code AND delete_flag = 0 and code not in ('C', 'CCL')
  
 ELSE IF @ddl_code = 'ddlWOType'
  SELECT * FROM (VALUES ('Redressing', 'Redressing'), ('Subcon', 'Subcon'), ('SIA', 'SIA'), ('Invoice', 'Invoice')) AS t(code, name)

 /***** Assignment *****/    
    
 /***** Work Order *****/    
 ELSE IF @ddl_code = 'ddlWorkOrderStatus'    
  SELECT code, name FROM TBL_MST_DDL WITH(NOLOCK) WHERE ddl_code = @ddl_code AND delete_flag = 0    
 ELSE IF @ddl_code = 'ddlPendingJob'    
  SELECT 'SELECT' as code, 'Select' as name    
  UNION ALL    
  SELECT CAST(post_event_id as VARCHAR(10)) as code, description as name FROM TBL_MST_EVENT_CONFIGURATION_DTL WITH(NOLOCK) WHERE to_display <> 'X'    
 /***** Work Order *****/    
    
 /***** Master Data *****/    
 ELSE IF @ddl_code = 'ddlTableName'    
 SELECT 'SELECT' as code, 'Select' as name    
 UNION ALL    
 SELECT table_name as code, table_name as name FROM INFORMATION_SCHEMA.TABLES WITH(NOLOCK) WHERE table_name IN ('TBL_MST_CLIENT_SUB', 'TBL_MST_CLIENT', 'TBL_MST_EVENT_CONFIGURATION_HDR')    
 /***** Master Data *****/    
    
 /***** Job Event (New) *****/    
 ELSE IF @ddl_code = 'ddlJobEventNew'    
 BEGIN    
  DECLARE @dtUserEvent TABLE(event_id VARCHAR(50))     
    
  INSERT INTO @dtUserEvent     
  SELECT event_id FROM VAS.dbo.TBL_ADM_USER_EVENT WITH(NOLOCK) WHERE user_id = @user_id    
    
  DECLARE @cntUserEvent INTEGER      
  SET @cntUserEvent = (SELECT COUNT(*) FROM @dtUserEvent)    
    
  IF @cntUserEvent = 0     
  INSERT INTO @dtUserEvent     
  SELECT ''     
    
  DECLARE @current_job_ref_no VARCHAR(100), @current_event INT    
  SET @current_job_ref_no = (SELECT JSON_VALUE(@ddl_obj, '$.job_ref_no'))    
  SET @current_event = CASE WHEN LEFT(@current_job_ref_no,1) = 'S' THEN  (SELECT top 1 ISNULL(current_event,'') FROM TBL_Subcon_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @current_job_ref_no)  
						WHEN LEFT(@current_job_ref_no,1) = 'P' THEN (SELECT top 1 ISNULL(current_event,'') FROM TBL_SIA_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @current_job_ref_no)  
						WHEN LEFT(@current_job_ref_no,1) = 'C' THEN (SELECT top 1 ISNULL(current_event,'') FROM TBL_INVOICE_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @current_job_ref_no)
                        ELSE (SELECT ISNULL(current_event,'') FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @current_job_ref_no)  
      END  
   declare @job_type varchar(1) = (select LEFT(@current_job_ref_no,1) )

  --SELECT event_id as code, event_name as name FROM TBL_MST_EVENT_CONFIGURATION_NEW WITH(NOLOCK)    
  --WHERE precedence = '' OR precedence IN (SELECT event_id FROM TBL_TXN_JOB_EVENT WHERE job_ref_no = @current_job_ref_no)    
    
  --If(LEFT(@current_job_ref_no,1) = 'S' AND @current_event = 20)  
  --BEGIN  
  --   SELECT '--' as code, 'Select' as name    
  -- UNION ALL   
  --SELECT event_id as code, event_name as name FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK)    
  --WHERE precedence = 21  
  --END 
  --If(LEFT(@current_job_ref_no,1) = 'S' )  
  --BEGIN
  --SELECT '--' as code, 'Select' as name    
  --UNION ALL   
  --SELECT event_id as code, event_name as name FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK)    
  --WHERE event_id in (45,60,50,40,30,25,21,20,10) order by code 
  --END

  -- CR 21: Invoice and SIA
  --ELSE IF ((LEFT(@current_job_ref_no,1) = 'P') OR LEFT(@current_job_ref_no,1) = 'C')
  --BEGIN
		--SELECT '--' as code, 'Select' as name    
		--UNION ALL     
		--SELECT event_id as code, event_name as name FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK)    
		--WHERE precedence = @current_event AND auto_ind <> 'Y' and sap_ind <> 'Y'
		--AND CASE @cntUserEvent WHEN 0 THEN '' ELSE event_id END IN (SELECT event_id FROM @dtUserEvent)    
		--UNION ALL    
		--SELECT event_id as code, event_name as name FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK)    
		--WHERE @current_event > precedence AND to_show_after_event = 'Y' and sap_ind <> 'Y'   
		--ORDER BY code  
  --END
  --ELSE  
  --BEGIN 

   --SELECT '--' as code, 'Select' as name    
   --UNION ALL     
   --SELECT event_id as code, event_name as name FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK)    
   --WHERE precedence = @current_event AND auto_ind <> 'Y'    
   --AND CASE @cntUserEvent WHEN 0 THEN '' ELSE event_id END IN (SELECT event_id FROM @dtUserEvent)    
   --UNION ALL    
   --SELECT event_id as code, event_name as name FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK)    
   --WHERE @current_event > precedence AND to_show_after_event = 'Y'    
   --ORDER BY code   

   -- if job ref no starts with V or G
   --SELECT '--' AS code, 'Select' AS name
   --UNION ALL
   --SELECT T.event_ID as code, case when (T.event_display_name <> '') then T.event_display_name else H.event_name end as name
   --FROM TBL_MST_EVENT_CONFIGURATION_BY_WO_TYPE T WITH(NOLOCK)
   --INNER JOIN TBL_MST_EVENT_CONFIGURATION_HDR H ON T.event_ID = H.eventID
   --WHERE T.precedence = @current_event AND H.auto_ind <> 'Y' and T.WO_type_ID = @job_type    
   --AND CASE @cntUserEvent WHEN 0 THEN '' ELSE T.event_id END IN (SELECT event_id FROM @dtUserEvent)    
   --UNION ALL
   --SELECT T.event_ID as code, case when (T.event_display_name <> '') then T.event_display_name else H.event_name end as name
   --FROM TBL_MST_EVENT_CONFIGURATION_BY_WO_TYPE T WITH(NOLOCK)
   --INNER JOIN TBL_MST_EVENT_CONFIGURATION_HDR H ON T.event_ID = H.eventID
   --WHERE @current_event > T.precedence AND H.to_show_after_event = 'Y' and T.WO_type_ID = @job_type
   --ORDER BY code 

   SELECT '--' AS code, 'Select' AS name    
   UNION ALL     
   SELECT event_id AS code, event_name AS name FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK)    
   WHERE (
	  (precedence = @current_event AND auto_ind <> 'Y' AND CASE @cntUserEvent WHEN 0 THEN '' ELSE event_id END IN (SELECT event_id FROM @dtUserEvent))
      OR (@current_event > precedence AND to_show_after_event = 'Y')
   )
   AND wo_type_id = @job_type AND is_deleted = 0
   ORDER BY code 
   
  --END  
  
  
 END    
 ELSE IF @ddl_code = 'ddlOnHoldReason'    
 BEGIN    
  SELECT code, name FROM TBL_MST_DDL WITH(NOLOCK) WHERE ddl_code = @ddl_code AND delete_flag = 0    
 END    
 /***** Job Event (New) *****/    
    
 /***** PPM *****/    
 ELSE IF @ddl_code = 'ddlPPMProduct'    
 BEGIN    
  DECLARE @ppm_job_ref_no VARCHAR(50)    
  SET @ppm_job_ref_no = (SELECT JSON_VALUE(@ddl_obj, '$.job_ref_no'))     
  SELECT prd_code as code, prd_desc as name FROM TBL_MST_PRODUCT WITH(NOLOCK)     
  WHERE prd_type = 'ZPK4'     
  AND prd_code NOT IN (SELECT prd_code FROM TBL_TXN_PPM WITH(NOLOCK) WHERE job_ref_no = @ppm_job_ref_no)    
 END    
 /***** PPM *****/    
 /***** Upload WI *****/    
 ELSE IF @ddl_code = 'ddlMLLNoWI'    
 BEGIN    
  DECLARE @selected_client_code_wi VARCHAR(50), @type_of_vas_wi VARCHAR(50), @sub_wi VARCHAR(50)    
  SET @selected_client_code_wi = (SELECT JSON_VALUE(@ddl_obj, '$.client_code'))    
  SET @type_of_vas_wi = (SELECT JSON_VALUE(@ddl_obj, '$.type_of_vas'))    
  SET @sub_wi = (SELECT JSON_VALUE(@ddl_obj, '$.sub'))    
  SELECT mll_no as code, mll_no as name FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE client_code = @selected_client_code_wi AND type_of_vas = @type_of_vas_wi AND sub = @sub_wi AND mll_status NOT IN ('Approved', 'Rejected', 'Submitted')    
 END    
 /***** Upload WI *****/   
 --/***** Upload WI *****/    
 --ELSE IF @ddl_code = 'ddlSUBCONNoWI'    
 --BEGIN    
 -- DECLARE @selected_client_code_wi_Subcon VARCHAR(50), @type_of_vas_wi_Subcon VARCHAR(50), @sub_wi_Subcon VARCHAR(50)    
 -- SET @selected_client_code_wi_Subcon = (SELECT JSON_VALUE(@ddl_obj, '$.client_code'))    
 -- SET @type_of_vas_wi_Subcon = (SELECT JSON_VALUE(@ddl_obj, '$.type_of_vas'))    
 -- SET @sub_wi_Subcon = (SELECT JSON_VALUE(@ddl_obj, '$.sub'))    
 -- SELECT subcon_no as code, subcon_no as name 
 -- FROM TBL_MST_SUBCON_HDR WITH(NOLOCK) 
 -- WHERE client_code = @selected_client_code_wi_Subcon AND type_of_vas = @type_of_vas_wi_Subcon AND sub = @sub_wi_Subcon AND subcon_status NOT IN ('Delete','Mark for Delete')  
 -- ORDER BY created_date DESC, subcon_no DESC
 --END    
 --/***** Upload WI *****/   
	 /***** Activity Report Listing *****/    
	ELSE IF (@ddl_code = 'ddlClientARL' or @ddl_code = 'ddlClientJES')
	BEGIN
		SELECT 'All' as code, ' --Select All--' as name, '' as client_name
		UNION 
		SELECT client_code as code, RTRIM(client_code) + ' - ' + RTRIM(client_name) as name, client_name FROM TBL_MST_CLIENT WITH(NOLOCK) ORDER BY client_name    
	END
	ELSE IF (@ddl_code = 'ddlProductARL' or @ddl_code = 'ddlProductJES')
	BEGIN    
		DECLARE @client_code_ARL VARCHAR(50)
		SET @client_code_ARL = (SELECT JSON_VALUE(@ddl_obj, '$.client_code'))     
      
		SELECT prd_code as code, RTRIM(prd_code) + ' - ' + RTRIM(prd_desc) as name FROM TBL_MST_PRODUCT WITH(NOLOCK)    
		WHERE princode = @client_code_ARL 
	END  
	ELSE IF @ddl_code = 'ddlActivityType'    
	BEGIN 
		SELECT distinct(activity_type) into #tempact FROM TBL_ADM_JOB_VENDOR WITH(NOLOCK) 

		select activity_type as code, activity_type as name from #tempact 
		drop table #tempact
	END    
	/***** Activity Report Listing *****/ 
 ELSE IF @ddl_code = 'ddlWHCode'
	BEGIN
		SELECT code, name FROM TBL_MST_DDL WITH(NOLOCK) WHERE ddl_code = @ddl_code AND delete_flag = 0  
	END
ELSE IF @ddl_code = 'ddlVASActivityRateCode'  
	BEGIN  
		SELECT VAS_Activity_Rate_Code as code, VAS_Activity_Rate_Code as name FROM TBL_TXN_VAS_ACTIVITY_RATE_HDR WITH(NOLOCK)  
	END  
END

GO
