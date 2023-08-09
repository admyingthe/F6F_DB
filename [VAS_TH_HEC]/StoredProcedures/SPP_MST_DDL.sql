SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===============================================================================================================================================    
-- Author:  Smita Thorat    
-- Create date: 2018-05-13    
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
-- 5) PPM - exec SPP_MST_DDL @ddl_obj=N'{"user_id":"8032","language_id":"0","ddl_code":"ddlPPMByForAddPPM","job_ref_no":"V2022/08/0002"}'
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
		SELECT prd_code as value, prd_code + '-' + prd_desc as name FROM TBL_MST_PRODUCT WITH(NOLOCK) WHERE prd_type  like 'ZPK%'     
	ELSE IF @ddl_code = 'ddlStorageCond'    
		SELECT code, name FROM TBL_MST_DDL WITH(NOLOCK) WHERE ddl_code = @ddl_code AND delete_flag = 0    
	ELSE IF @ddl_code = 'ddlMedicalDeviceUsage'    
		SELECT code, name FROM TBL_MST_DDL WITH(NOLOCK) WHERE ddl_code = @ddl_code AND delete_flag = 0    
	ELSE IF @ddl_code = 'ddlBMIFU'    
		SELECT code, name FROM TBL_MST_DDL WITH(NOLOCK) WHERE ddl_code = @ddl_code AND delete_flag = 0    
	ELSE IF @ddl_code = 'ddlMLLNo' --OR @ddl_code = 'ddlCopyMasterVAS'    
	BEGIN    
		DECLARE @selected_client_code VARCHAR(50), @type_of_vas VARCHAR(50), @sub VARCHAR(50), @qas_rev_no VARCHAR(50), @qas_no nvarchar(max), @rev_no varchar(10), @new_mll_flag bit
		SET @selected_client_code = (SELECT JSON_VALUE(@ddl_obj, '$.client_code'))    
		SET @type_of_vas = (SELECT JSON_VALUE(@ddl_obj, '$.type_of_vas'))    
		SET @sub = (SELECT JSON_VALUE(@ddl_obj, '$.sub'))    
		SET @qas_rev_no = (SELECT JSON_VALUE(@ddl_obj, '$.qas_rev_no'))
		SET @qas_rev_no = coalesce(dbo.URLDecode(@qas_rev_no), ' - ')
		set @new_mll_flag = (SELECT JSON_VALUE(@ddl_obj, '$.new_mll_flag'))

		set @qas_no = (SELECT top 1 value from STRING_SPLIT(replace(@qas_rev_no, ' - ', ','), ','))
		set @rev_no = (SELECT SUBSTRING(@qas_rev_no, LEN(@qas_rev_no) - CHARINDEX(' - ', REVERSE(@qas_rev_no)) + 2, LEN(@qas_rev_no)))

		SELECT mll_no as code, mll_no as name FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE client_code = @selected_client_code AND type_of_vas = @type_of_vas AND sub = @sub 
		AND (@qas_rev_no = 'All' or (mll_desc IS NULL AND @qas_no = '') or mll_desc = @qas_no)  --qas_no like '%' + @qas_no + '%'
		AND (@new_mll_flag = 1 or (revision_no = @rev_no OR (revision_no IS NULL AND @rev_no = '')))
		
	END    
	ELSE IF @ddl_code = 'ddlSubconWINo' 
	BEGIN  
		SET @selected_client_code = (SELECT JSON_VALUE(@ddl_obj, '$.client_code'))  
		SET @type_of_vas = (SELECT JSON_VALUE(@ddl_obj, '$.type_of_vas'))  
		SET @sub = (SELECT JSON_VALUE(@ddl_obj, '$.sub'))  
		SELECT subcon_no as code, subcon_no as name FROM TBL_MST_SUBCON_HDR WITH(NOLOCK) WHERE client_code = @selected_client_code AND type_of_vas = @type_of_vas AND sub = @sub  and subcon_status <> 'Delete'
		ORDER BY created_date DESC
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
		SELECT sub_code as code, sub_code +  ' - ' + sub_name as name FROM TBL_MST_CLIENT_SUB WITH(NOLOCK) WHERE client_code = @client_code_for_sub   order by sub_code asc 
	END    
	ELSE IF @ddl_code = 'ddlQASNo'
	BEGIN
		DECLARE @client_code_for_qas VARCHAR(50), @sub_for_qas varchar(50)
		SET @client_code_for_qas = (SELECT JSON_VALUE(@ddl_obj, '$.client_code'))   
		SET @sub_for_qas = (SELECT JSON_VALUE(@ddl_obj, '$.sub'))  
		--SELECT 'All' as code, '--Select All--' as name union
		--SELECT '' as code, '(blank QAS No)' as name union
		SELECT distinct(concat(mll_desc, ' - ', revision_no)) as code, concat(mll_desc, ' - ', revision_no) as name FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE client_code = @client_code_for_qas and sub = @sub_for_qas --and mll_desc is not null and mll_desc <> ''
	END
	 /***** MLL *****/    
    
	 /***** Assignment *****/    
	ELSE IF @ddl_code = 'ddlAssignmentStatus'    
		-- hard code because requirement doesn't want 'Cancelled' and 'Closed' to show in DDL but wants them in table when users filter 'All'
		SELECT code, name FROM TBL_MST_DDL WITH(NOLOCK) WHERE ddl_code = @ddl_code AND delete_flag = 0 and code not in ('C', 'CCL')
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
		

		--Added to get GMP required value based on mll gmp_required value AND QI_type related events
		DECLARE @gmp_required CHAR(1)='N'
		DECLARE @gmp_count INTEGER =0

		SET @gmp_count=(SELECT  count(gmp_required) FROM TBL_TXN_WORK_ORDER  W 
		INNER JOIN 	TBL_MST_MLL_DTL D ON W.prd_code =D.prd_code AND W.mll_no=D.mll_no
		WHERE  job_ref_no=@current_job_ref_no AND D.gmp_required=1)

		IF @gmp_count >0
		SET @gmp_required ='Y'
		------------------------------------------------------------------------------------------------------
		------------------------------------------------------------------------------------------------------
		DECLARE @qa_approval CHAR(1) ='N'
		DECLARE @qi_type NVARCHAR(300) 
		SELECT @qi_type= qi_type FROM  TBL_TXN_WORK_ORDER_JOB_DET WHERE  job_ref_no=@current_job_ref_no 

		IF @qi_type like '%Q09%' OR @qi_type like '%Q10%' OR @qi_type like '%Q11%'  OR @qi_type like '%Q12%' 
		BEGIN
			SET @qa_approval='Y'
		END

		--Added to get GMP required value based on mll gmp_required value AND QI_type related events





		SET @current_event = CASE WHEN LEFT(@current_job_ref_no,1) = 'S' THEN  (SELECT top 1 ISNULL(current_event,'') FROM TBL_Subcon_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @current_job_ref_no)  
						ELSE (SELECT ISNULL(current_event,'') FROM TBL_TXN_WORK_ORDER_JOB_DET WITH(NOLOCK) WHERE job_ref_no = @current_job_ref_no) 	END  
   
	  --SELECT event_id as code, event_name as name FROM TBL_MST_EVENT_CONFIGURATION_NEW WITH(NOLOCK)    
	  --WHERE precedence = '' OR precedence IN (SELECT event_id FROM TBL_TXN_JOB_EVENT WHERE job_ref_no = @current_job_ref_no)    
    
		If(LEFT(@current_job_ref_no,1) = 'S' AND @current_event =20)  
		BEGIN  
			SELECT '--' as code, 'Select' as name    
			UNION ALL   
			SELECT event_id as code, event_name as name FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK)    
			WHERE precedence = 21  
		END 
	  --If(LEFT(@current_job_ref_no,1) = 'S' )  
	  --BEGIN
	  --SELECT '--' as code, 'Select' as name    
	  --UNION ALL   
	  --SELECT event_id as code, event_name as name FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK)    
	  --WHERE event_id in (45,60,50,40,30,25,21,20,10) order by code 
	  --END
	    ELSE IF (@current_event = 40 AND EXISTS (SELECT 1 FROM TBL_TXN_JOB_EVENT WHERE job_ref_no = @current_job_ref_no AND event_id = 40 AND currently_reopened_PPM = 1)) 
		BEGIN
			-- Do not allow users to add new job events when the PPM is currently reopened
			SELECT '--' as code, 'Select' as name  
		END
		ELSE  
		BEGIN 
  		   SELECT '--' as code, 'Select' as name    
		   UNION ALL     
		   SELECT event_id as code, event_name as name FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK)    
		   WHERE precedence = @current_event AND auto_ind <> 'Y'    AND (gmp_required=@gmp_required OR gmp_required='')  AND (show_qa_approval=@qa_approval OR show_qa_approval='')
		   AND CASE @cntUserEvent WHEN 0 THEN '' ELSE event_id END IN (SELECT event_id FROM @dtUserEvent)     
		   --UNION ALL    
		   --SELECT event_id as code, event_name as name FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK)    
		   --WHERE @current_event > precedence AND to_show_after_event = 'Y'  AND (gmp_required=@gmp_required OR gmp_required='')  
		   --ORDER BY code   
		END  
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
		WHERE prd_type like 'ZPK%'
		AND prd_code NOT IN (SELECT prd_code FROM TBL_TXN_PPM WITH(NOLOCK) WHERE job_ref_no = @ppm_job_ref_no)    
	END    
	ELSE IF @ddl_code = 'ddlSrcProduct'    
	BEGIN  
		DECLARE @src_prd_job_ref_no VARCHAR(50)    
		SET @src_prd_job_ref_no = (SELECT JSON_VALUE(@ddl_obj, '$.job_ref_no'))
		select * from (
			SELECT 'All' as code, ' --Default for all--' as name
			UNION 
			SELECT prd_code as code, prd_desc as name FROM TBL_MST_PRODUCT WITH(NOLOCK)     
			WHERE prd_code IN (SELECT prd_code FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @src_prd_job_ref_no)
		) t
		ORDER BY CASE WHEN code = 'All' THEN 1 ELSE 2 END, code  
	END    
	 /***** PPM *****/    
	 /***** Upload WI *****/    
	ELSE IF @ddl_code = 'ddlMLLNoWI'    
	BEGIN    
		DECLARE @selected_client_code_wi VARCHAR(50), @type_of_vas_wi VARCHAR(50), @sub_wi VARCHAR(50)    
		SET @selected_client_code_wi = (SELECT JSON_VALUE(@ddl_obj, '$.client_code'))    
		SET @type_of_vas_wi = (SELECT JSON_VALUE(@ddl_obj, '$.type_of_vas'))    
		SET @sub_wi = (SELECT JSON_VALUE(@ddl_obj, '$.sub'))    
		SELECT mll_no as code, mll_no + ' - ' + mll_desc as name FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE client_code = @selected_client_code_wi AND type_of_vas = @type_of_vas_wi AND sub = @sub_wi AND mll_status NOT IN ('Approved', 'Rejected', 'Submitted')    
	END    
	 /***** Upload WI *****/    
	 /***** Activity Report Listing *****/    
	ELSE IF @ddl_code = 'ddlClientARL'    
	BEGIN
		SELECT 'All' as code, ' --Select All--' as name, '' as client_name
		UNION 
		SELECT client_code as code, RTRIM(client_code) + ' - ' + RTRIM(client_name) as name, client_name FROM TBL_MST_CLIENT WITH(NOLOCK) ORDER BY client_name    
	END
	ELSE IF @ddl_code = 'ddlProductARL'    
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
	ELSE IF @ddl_code = 'ddlPPMBy'
	BEGIN
		SELECT code, name FROM TBL_MST_DDL WITH(NOLOCK) WHERE ddl_code = @ddl_code AND delete_flag = 0  
	END
	ELSE IF @ddl_code = 'ddlPPMByForAddPPM'
	BEGIN
		DECLARE @job_ref_no VARCHAR(100)  
		SET @job_ref_no = (SELECT JSON_VALUE(@ddl_obj, '$.job_ref_no'))  


		SELECT code, name FROM TBL_MST_DDL WITH(NOLOCK) WHERE ddl_code = 'ddlPPMBy' AND delete_flag = 0  
		SELECT distinct batch_no code,batch_no name FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no 
		SELECT distinct Convert(varchar(10),expiry_date,121) code,Convert(varchar(10),expiry_date,121) name
		FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE expiry_date is not null AND job_ref_no = @job_ref_no 
		SELECT distinct CASE WHEN Convert(varchar(10),manufacturing_date,121)='1900-01-01' THEN ' ' ELSE  Convert(varchar(10),manufacturing_date,121) END code,
		CASE WHEN Convert(varchar(10),manufacturing_date,121)='1900-01-01' THEN ' ' ELSE  Convert(varchar(10),manufacturing_date,121) END name
		FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE  manufacturing_date is not null   AND  job_ref_no = @job_ref_no 
		SELECT distinct plant code,plant name FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no 

	END
	ELSE IF @ddl_code = 'ddlWHCode'
	BEGIN
		SELECT code, name FROM TBL_MST_DDL WITH(NOLOCK) WHERE ddl_code = @ddl_code AND delete_flag = 0  
	END
	ELSE IF @ddl_code = 'ddlRedressJobRefFormat'
	BEGIN
		SELECT code, name FROM TBL_MST_DDL WITH(NOLOCK) WHERE ddl_code = @ddl_code AND delete_flag = 0  
	END
	ELSE IF @ddl_code = 'ddlEventConfig'
	BEGIN
		SELECT code, name FROM TBL_MST_DDL WITH(NOLOCK) 
		WHERE ddl_code = @ddl_code AND delete_flag = 0
		ORDER BY code
	END
	ELSE IF @ddl_code = 'ddlStorageType'
	BEGIN

		-- Get user warehouse Code-------  
		 DECLARE @wh_code varchar(10)
		 SET @wh_code = (SELECT wh_code FROM VAS.dbo.TBL_ADM_USER WITH(NOLOCK) WHERE user_id = @user_id)  --T50
		 --select @wh_code
		 ------------------------------------------------------------ 

		SELECT DISTINCT storage_type AS code, storage_type AS name FROM TBL_ADM_STORAGE_TYPE_AND_BIN 
		WHERE status = 'Active' AND warehouse_no=@wh_code
		ORDER BY storage_type ASC
	END
	ELSE IF @ddl_code = 'ddlDepartment'
	BEGIN
		SELECT dept_code as code, dept_name as name FROM TBL_MST_DEPARTMENT WITH(NOLOCK)
	END
	/***** VAS Activity Rate *****/ 
	ELSE IF @ddl_code = 'ddlVASActivityRateCode'  
	BEGIN  
		DECLARE @client_code_rate VARCHAR(50), @prd_code_rate VARCHAR(50)
		SET @client_code_rate = (SELECT JSON_VALUE(@ddl_obj, '$.client_code'))
		SET @prd_code_rate = (SELECT JSON_VALUE(@ddl_obj, '$.prd_code'))
		SELECT VAS_Activity_Rate_Code as code, VAS_Activity_Rate_Code as name FROM TBL_MST_VAS_ACTIVITY_RATE_HDR WITH(NOLOCK) where client_code = @client_code_rate and prd_code = @prd_code_rate and status in ('P', 'A', 'R')
	END  
	ELSE IF @ddl_code = 'ddlClientRate'  
	BEGIN  
		SELECT 'All' as code, ' --Default for all--' as name, '' as client_name
		UNION 
		SELECT client_code as code, RTRIM(client_code) + ' - ' + RTRIM(client_name) as name, client_name FROM TBL_MST_CLIENT WITH(NOLOCK) ORDER BY client_name
	END  
	ELSE IF @ddl_code = 'ddlProductRate'  
	BEGIN  
		DECLARE @client_code_rate_2 VARCHAR(50)
		SET @client_code_rate_2 = (SELECT JSON_VALUE(@ddl_obj, '$.client_code'))
		
		IF (@client_code_rate_2 = 'ALL')
		BEGIN
			SELECT 'All' as code, ' --Default for all--' as name
		END
		ELSE
		BEGIN
			select * from (
				SELECT 'All' as code, ' --Default for all--' as name
				UNION 
				SELECT prd_code as code, RTRIM(prd_code) + ' - ' + RTRIM(prd_desc) as name FROM TBL_MST_PRODUCT WITH(NOLOCK)    
				WHERE princode = @client_code_rate_2 and prd_type like 'ZPK%'
			) t
			ORDER BY CASE WHEN code = 'All' THEN 1 ELSE 2 END, code  
		END
	END  
	/***** VAS Activity Rate *****/ 
END
GO
