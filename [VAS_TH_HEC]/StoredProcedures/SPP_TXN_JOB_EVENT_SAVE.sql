SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================================================                
-- Author:  Smita Thorat                
-- Create date: 2022-04-13                
-- Description: Save Job events                
-- Example Query: exec SPP_TXN_JOB_EVENT_SAVE @submit_obj=N'{"job_ref_no":"S2021/11/0001","search":"Search","job_ref_wo_no":"S2021/11/0001","work_ord_ref":"BYRON ORIGINS/Meditree/BANANA1/May 20 2024 12:00AM","work_ord_status":"In Process","add":"Add","export":"Export","complete":"Complete","job_event":"20","start_date":"2021-11-14 20:22:26","issued_qty":"","email":"","email_photos":"","remarks":"","completed_qty":"","save":"Save","damaged_qty":"","guid":"5a57623d-da02-4524-8ece-f552af42938b"}',@user_id=N'1'      --exec SPP_TXN_JOB_EVENT_SAVE @submit_obj=N'{"job_ref_no":"2018/07/0018","search":"Search","job_ref_wo_no":"2018/07/0018","work_ord_ref":"NOVARTIS/F/LOOK/TEST3-C/2025-02-03","work_ord_status":"In Process","add":"Add","export":"Export","complete":"Close Job","job_event":"60","start_date":"2021-03-23 09:26:47","original_qty":"500","qa_qty":"500","email":"shen.yee.siow@dksh.com","inbound_damaged_qty":"","save":"Save","issued_qty":"500","remarks":"","completed_qty":"","damaged_qty":"","on_hold_job":"On Hold Job","release_job":"Release Job","cancel_job":"Cancel Job","on_hold_reason":"","on_hold_remarks":"","on_hold_confirm":"Confirm","ques_a":"N","ques_b":"N","ques_c":"N","ques_d":"N","internal_qa_completed_qty":"","internal_qa_required":"1","guid":"36f1e980-b87f-49b8-b201-0e62327fbe63"}',@user_id=N'1'                
-- Example Query: exec SPP_TXN_JOB_EVENT_SAVE @submit_obj=N'{"job_ref_no":"V2022/08/0002","items":[{"prd_code":"100166392","batch_no":"220207-01","storage_type":"A32","bin_no":"VAS-02","completed_qty":"40","damaged_qty":"10"}],"search":"Search","job_ref_wo_no":"V2022/08/0002","work_ord_ref":"V2022/08/0002","work_ord_status":"In Process","add":"Add","export":"Export","complete":"Close Job","job_event":"80","start_date":"2022-08-08 10:32:01","original_qty":"50","qa_qty":"","prod_code":"100166392=>>220207-01=>>=>>=>>","email":"","issued_qty":"50","batch_no":"220207-01","save":"Save","uom":"CV","storage_type_and_bin_no":"A32","completed_qty":"40","damaged_qty":"10","station_no":"","remarks":"Testing of Submit to SAP","on_hold_job":"On Hold Job","release_job":"Release Job","cancel_job":"Cancel Job","on_hold_reason":"","on_hold_remarks":"","on_hold_confirm":"Confirm","ques_a":"N","ques_b":"N","ques_c":"N","ques_d":"N","internal_qa_completed_qty":"","internal_qa_required":"1","guid":"dfc7cf58-243c-4088-b3e0-bc7879c12ed1"}',@user_id=N'1'     
-- Example Query VAS: exec SPP_TXN_JOB_EVENT_SAVE @submit_obj=N'{"job_ref_no":"V2022/08/0002","search":"Search","job_ref_wo_no":"V2022/08/0002","work_ord_ref":"V2022/08/0002","work_ord_status":"In Process","add":"Add","export":"Export","complete":"Close Job","job_event":"40","start_date":"2022-08-10 19:29:34","original_qty":"50","qa_qty":"","prod_code":"","email":"","issued_qty":"50","batch_no":"","save":"Save","uom":"CV","storage_type":"","bin_no":"","completed_qty":"","damaged_qty":"","station_no":"","remarks":"Testing of VAS","on_hold_job":"On Hold Job","release_job":"Release Job","cancel_job":"Cancel Job","on_hold_reason":"","on_hold_remarks":"","on_hold_confirm":"Confirm","ques_a":"N","ques_b":"N","ques_c":"N","ques_d":"N","internal_qa_completed_qty":"","internal_qa_required":"1","guid":"e3ee8ba8-8bc7-417e-92c5-dd0494b5efec"}',@user_id=N'8032'  

-- Example STOSAP: exec SPP_TXN_JOB_EVENT_SAVE @submit_obj=N'{"job_ref_no":"V2022/08/0002","items":[{"prd_code":"100166392","batch_no":"220207-01","storage_type":"A32","bin_no":"VAS-05","completed_qty":"40","damaged_qty":"10","issued_qty":50,"uom":"CV","sloc":"1010","plant":"TH54","whs_no":"T50","stock_category":"Q"}],"search":"Search","job_ref_wo_no":"V2022/08/0002","work_ord_ref":"V2022/08/0002","work_ord_status":"In Process","add":"Add","export":"Export","complete":"Close Job","job_event":"80","start_date":"2022-08-10 19:36:39","original_qty":"50","qa_qty":"","prod_code":"100166392=>>220207-01=>>=>>=>>","email":"","issued_qty":"50","batch_no":"220207-01","save":"Save","uom":"CV","storage_type_and_bin_no":"A32","completed_qty":"40","damaged_qty":"10","station_no":"","remarks":"Testing of Submit to SAP","on_hold_job":"On Hold Job","release_job":"Release Job","cancel_job":"Cancel Job","on_hold_reason":"","on_hold_remarks":"","on_hold_confirm":"Confirm","ques_a":"N","ques_b":"N","ques_c":"N","ques_d":"N","internal_qa_completed_qty":"","internal_qa_required":"1","guid":"868cb9c0-1998-431b-bd25-bcb0491db877"}',@user_id=N'8032'  

-- Example STOSAP: exec SPP_TXN_JOB_EVENT_SAVE @submit_obj=N'{"job_ref_no":"V2022/08/0002","search":"Search","job_ref_wo_no":"V2022/08/0002","work_ord_ref":"V2022/08/0002","work_ord_status":"In Process","add":"Add","export":"Export","complete":"Close Job","job_event":"40","start_date":"2022-08-11 01:11:43","original_qty":"50","qa_qty":"","prod_code":"","email":"","issued_qty":"50","batch_no":"","save":"Save","uom":"CV","storage_type":"","bin_no":"","completed_qty":"","damaged_qty":"","station_no":"","remarks":"Testing of VAS again","on_hold_job":"On Hold Job","release_job":"Release Job","cancel_job":"Cancel Job","on_hold_reason":"","on_hold_remarks":"","on_hold_confirm":"Confirm","ques_a":"N","ques_b":"N","ques_c":"N","ques_d":"N","internal_qa_completed_qty":"","internal_qa_required":"1","guid":"c1924fbb-1fcc-426e-909e-20791749d892"}',@user_id=N'8032'

-- Example QA Final INS: exec SPP_TXN_JOB_EVENT_SAVE @submit_obj=N'{"job_ref_no":"V2022/08/0002","search":"Search","job_ref_wo_no":"V2022/08/0002","work_ord_ref":"V2022/08/0002","work_ord_status":"In Process","add":"Add","export":"Export","complete":"Close Job","job_event":"48","start_date":"2022-08-11 16:53:15","original_qty":"50","qa_qty":"","prod_code":"100166392=>>220207-01=>>null=>>null=>>null","email":"","issued_qty":"30","batch_no":"220207-01","save":"Save","uom":"CV","storage_type":"","bin_no":"","completed_qty":"","damaged_qty":"","station_no":"","remarks":"Testing of QA Final Inspection 2","on_hold_job":"On Hold Job","release_job":"Release Job","cancel_job":"Cancel Job","on_hold_reason":"","on_hold_remarks":"","on_hold_confirm":"Confirm","ques_a":"N","ques_b":"N","ques_c":"N","ques_d":"N","internal_qa_completed_qty":"","internal_qa_required":"1","guid":"54959551-edf9-4909-b80d-c23f2e648b2c"}',@user_id=N'8032'

-- Example QA Final INS: exec SPP_TXN_JOB_EVENT_SAVE @submit_obj=N'{"job_ref_no":"V2022/08/0002","search":"Search","job_ref_wo_no":"V2022/08/0002","work_ord_ref":"V2022/08/0002","work_ord_status":"In Process","add":"Add","export":"Export","complete":"Close Job","job_event":"60","start_date":"2022-08-12 20:52:37","qa_qty":"30","email":"smita.thorat@itcinfotech.com","prod_code":"","batch_no":"","save":"Save","issued_qty":"30","uom":"CV","storage_type":"","bin_no":"","completed_qty":"","damaged_qty":"","station_no":"","remarks":"","on_hold_job":"On Hold Job","release_job":"Release Job","cancel_job":"Cancel Job","on_hold_reason":"","on_hold_remarks":"","on_hold_confirm":"Confirm","ques_a":"N","ques_b":"N","ques_c":"N","ques_d":"N","internal_qa_completed_qty":"30","internal_qa_required":"1","guid":"7e26296a-b8e3-410c-ac37-a5230d6fbec4"}',@user_id=N'8032'

--exec SPP_TXN_JOB_EVENT_SAVE @submit_obj=N'{"job_ref_no":"V2022/08/0018","search":"Search","job_ref_wo_no":"V2022/08/0018","work_ord_ref":"V2022/08/0018","work_ord_status":"In Process","qi_type":"Q09-Redress+Redress Approve","add":"Add","export":"Export","complete":"Close Job","job_event":"60","start_date":"2022-08-30 15:40:35","qa_qty":"10","email":"smita.thorat@itcinfotech.com","prod_code":"","batch_no":"","save":"Save","issued_qty":"10","uom":"PAC","storage_type":"","bin_no":"","completed_qty":"","damaged_qty":"","station_no":"","remarks":"","on_hold_job":"On Hold Job","release_job":"Release Job","cancel_job":"Cancel Job","on_hold_reason":"","on_hold_remarks":"","on_hold_confirm":"Confirm","ques_a":"N","ques_b":"N","ques_c":"N","ques_d":"N","internal_qa_completed_qty":"10","internal_qa_required":"1","guid":"2d244079-6b87-4d54-a91a-ee40582da8f9"}',@user_id=N'8032'
--exec SPP_TXN_JOB_EVENT_SAVE @submit_obj=N'{"job_ref_no":"G2022/09/00018","search":"Search","job_ref_wo_no":"G2022/09/00018","work_ord_ref":"G2022/09/00018","work_ord_status":"In Process","qi_type":"","add":"Add","export":"Export","complete":"Close Job","job_event":"80","start_date":"2022-09-08 16:48:16","qa_qty":"37","email":"","prod_code":"121042799=>>20220830=>>null=>>null=>>null","batch_no":"20220830","save":"Save","issued_qty":"9","uom":"EA","storage_type_and_bin_no":"A41","completed_qty":"2","damaged_qty":"7","station_no":"","remarks":"","on_hold_job":"On Hold Job","release_job":"Release Job","cancel_job":"Cancel Job","on_hold_reason":"","on_hold_remarks":"","on_hold_confirm":"Confirm","ques_a":"N","ques_b":"N","ques_c":"N","ques_d":"N","internal_qa_completed_qty":"37","internal_qa_required":"1","items":[{"prd_code":"121042798","batch_no":"20220830","storage_type":"A41","bin_no":"VAS-01","completed_qty":10,"damaged_qty":0,"issued_qty":10,"uom":"EA","sloc":"1060","plant":"TH64","whs_no":"T51","stock_category":"Q ","special_stock_indicator":null,"special_stock":null},{"prd_code":"121039686","batch_no":"20220830","storage_type":"AV1","bin_no":"AH1-011-27","completed_qty":6,"damaged_qty":"3","issued_qty":10,"uom":"EA","sloc":"1060","plant":"TH64","whs_no":"T51","stock_category":"Q ","special_stock_indicator":null,"special_stock":null},{"prd_code":"121042736","batch_no":"20220830","storage_type":"AV1","bin_no":"AH1-011-27","completed_qty":4,"damaged_qty":"5","issued_qty":10,"uom":"EA","sloc":"1060","plant":"TH64","whs_no":"T51","stock_category":"Q ","special_stock_indicator":null,"special_stock":null},{"prd_code":"121042799","batch_no":"20220830","storage_type":"AV1","bin_no":"AH1-011-27","completed_qty":2,"damaged_qty":"7","issued_qty":10,"uom":"EA","sloc":"1060","plant":"TH64","whs_no":"T51","stock_category":"Q ","special_stock_indicator":null,"special_stock":null}],"guid":"e01a8d0d-77f2-4a0a-a7ae-efdf7acc8178"}',@user_id=N'10084'
-- =====================================================================================             


CREATE  PROCEDURE [dbo].[SPP_TXN_JOB_EVENT_SAVE]                
 @submit_obj NVARCHAR(MAX),                
 @user_id INT,                
 --@folder_path NVARCHAR(MAX) = null,
 @html_file_name NVARCHAR(MAX) = null
AS                
BEGIN                
 SET NOCOUNT ON;                
                
 BEGIN TRY                
                
	 DECLARE @event_id INT, @job_ref_no VARCHAR(50), @start_date VARCHAR(50), @issued_qty INT, @remarks NVARCHAR(500),                
	 @qa_qty INT, @email NVARCHAR(500), @completed_qty INT, @damaged_qty INT, @guid VARCHAR(500), @internal_qa_completed_qty INT,                
	 @original_qty INT, @inbound_damaged_qty INT  ,  @storage_type VARCHAR(10), @bin_no VARCHAR(20)  ,@qi_type VARCHAR(300)      
                
	 SET @event_id = (SELECT JSON_VALUE(@submit_obj, '$.job_event'))                
	 SET @job_ref_no = (SELECT JSON_VALUE(@submit_obj, '$.job_ref_no'))                
	 SET @start_date = (SELECT JSON_VALUE(@submit_obj, '$.start_date'))                
	 SET @issued_qty = (SELECT JSON_VALUE(@submit_obj, '$.issued_qty'))                
	 SET @original_qty = (SELECT JSON_VALUE(@submit_obj, '$.original_qty'))                
	 SET @inbound_damaged_qty = (SELECT JSON_VALUE(@submit_obj, '$.inbound_damaged_qty'))                
	 SET @remarks = (SELECT JSON_VALUE(@submit_obj, '$.remarks'))
                
	 EXEC REPLACE_SPECIAL_CHARACTER @remarks, @remarks OUTPUT                
                
	 SET @qa_qty = (SELECT JSON_VALUE(@submit_obj, '$.qa_qty'))                
	 SET @email = (SELECT JSON_VALUE(@submit_obj, '$.email'))                
	 SET @completed_qty = (SELECT JSON_VALUE(@submit_obj, '$.completed_qty'))                
	 SET @damaged_qty = (SELECT JSON_VALUE(@submit_obj, '$.damaged_qty'))                
	 SET @guid = (SELECT JSON_VALUE(@submit_obj, '$.guid'))                
	 SET @internal_qa_completed_qty = (SELECT JSON_VALUE(@submit_obj, '$.internal_qa_completed_qty')) 

	 DECLARE @folder_path NVARCHAR(4000)                
	SET @folder_path = N'D:\VAS\TH-HEC\' + @guid + '\'  
	 
	 --Added to get Thailand Time along with date
	 DECLARE @CurrentDateTime AS DATETIME
	 SET @CurrentDateTime=(SELECT DATEADD(hh, -1 ,GETDATE()) )
      --Added to get Thailand Time along with date
	  

	 -- To get the value of TOTAL QUANTITY from MPO to compare with completed quantity input by user                
	 DECLARE @ttl_qty_eaches INT                
	 SET @ttl_qty_eaches = (SELECT SUM(ttl_qty_eaches) FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)                
	 -----------------------------------------------------------------------------------------------------------------                
                
	 -- Check if same event had been added before (except --                
	 -- IF (SELECT COUNT(*) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND event_id = @event_id AND event_id NOT IN ('40','50','60')) >= 1                
	 IF (SELECT COUNT(*) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND event_id = @event_id AND event_id NOT IN (SELECT event_id FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK) WHERE to_show_after_event = 'Y')) >= 1              
	 BEGIN                
		SELECT 'Y' as duplicate                
	 END                
	 ELSE                
	 BEGIN                
	  -------------------------------------------------------------------------------------------------------------------                
	  -- To get previous running no, search in TBL_TXN_WORK_ORDER_ACTION_LOG                
	  -- If found, calculate the time between release date and on hold date                
	  -- Calculated time will be inserted into on_hold_time in TBL_TXN_JOB_EVENT of the newly created event                
	  DECLARE @last_running_no VARCHAR(10), @total_time_taken_in_sec INT                
	  SET @last_running_no = (SELECT MAX(running_no) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)                
                
	  IF (SELECT COUNT(*) FROM TBL_TXN_WORK_ORDER_ACTION_LOG WITH(NOLOCK) WHERE current_running_no = @last_running_no) > 0                
	  BEGIN                
		SET @total_time_taken_in_sec = (SELECT SUM(dbo.TotalOnHold(on_hold_date, released_date)) FROM TBL_TXN_WORK_ORDER_ACTION_LOG WITH(NOLOCK) WHERE current_running_no = @last_running_no)  --(SELECT SUM(DATEDIFF(s, on_hold_date, released_date)) FROM TBL_TXN_WORK_ORDER_ACTION_LOG WITH(NOLOCK) WHERE current_running_no = @last_running_no)                
	  END                
	  -------------------------------------------------------------------------------------------------------------------                
                
	  DECLARE @running_no VARCHAR(50) = 1, @len INT = 8                
	  SELECT TOP 1 @running_no = CAST(CAST(RIGHT(running_no, @len) as INT) + 1 AS VARCHAR(50))                
			 FROM (SELECT running_no FROM TBL_TXN_JOB_EVENT WITH(NOLOCK)) A ORDER BY CAST(RIGHT(running_no, @len) AS INT) DESC                
	  SET @running_no = 'TH' + REPLICATE('0', @len - LEN(@running_no)) + @running_no       
	  
	     DECLARE @JobFormat VARCHAR(25)=(SELECT  [format_code] FROM [TBL_REDRESSING_JOB_FORMAT])

		 SET @qi_type=(SELECT qi_type FROM TBL_TXN_WORK_ORDER_JOB_DET WHERE job_ref_no= @job_ref_no)
 
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ @event_id = '20'  Request for stock +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	  IF @event_id = '20' --Request for stock                
	  BEGIN
			
			SET @storage_type = (SELECT JSON_VALUE(@submit_obj, '$.storage_type'))
			SET @bin_no = (SELECT JSON_VALUE(@submit_obj, '$.bin_no'))
		   --1. Insert into txn table                
		   INSERT INTO TBL_TXN_JOB_EVENT                
		   (running_no, job_ref_no, event_id, start_date, end_date, issued_qty, damaged_qty, remarks, on_hold_time, created_date, creator_user_id, storage_type, bin_no)                
		   SELECT @running_no, @job_ref_no, @event_id, CONVERT(varchar(23), REPLACE(@start_date, 'T', ' '), 121), @CurrentDateTime, @issued_qty, @inbound_damaged_qty, @remarks, @total_time_taken_in_sec, @CurrentDateTime, @user_id, @storage_type, @bin_no                
                
			--2. Insert into sap integration table                
			IF(LEFT(@job_ref_no,1) = 'S')              
			BEGIN              
        
				UPDATE TBL_Subcon_TXN_WORK_ORDER                
				SET qty_of_goods = @issued_qty                
				WHERE job_ref_no = @job_ref_no                
          
				UPDATE TBL_Subcon_TXN_WORK_ORDER                
				SET current_event = @event_id                
				WHERE job_ref_no = @job_ref_no           
           
		   END              
		   BEGIN 
		   
				INSERT INTO VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP                
				(country_code, process_ind, vas_order, whs_no, workorder_no, requirement_no,prd_code, uom, plant, sloc, batch_no, movement_type,                  
				qty, stock_category, created_date, created_by, status, ssto_unit_no,  ssto_section, ssto_stg_bin,storage_type_destination,bin_destination,special_stock_indicator,special_stock,qi_type)                
				SELECT  'TH', 'A', vas_order, whs_no, CASE WHEN @JobFormat='JobFormat' THEN B.job_ref_no ELSE B.work_ord_ref  END  work_ord_ref, running_no,prd_code, uom, plant, sloc, batch_no, '890',
				CASE WHEN LEFT(@job_ref_no,1) = 'G' THEN  SUM(ttl_qty_eaches) ELSE  issued_qty END, stock_category, @CurrentDateTime, @user_id, 'P', dsto_unit_no, dsto_section, dsto_stg_bin ,@storage_type, @bin_no,special_stock_indicator,special_stock ,@qi_type                
				FROM TBL_TXN_JOB_EVENT A WITH(NOLOCK)                
				INNER JOIN TBL_TXN_WORK_ORDER B WITH(NOLOCK) ON A.job_ref_no = B.job_ref_no  
				WHERE running_no = @running_no 
				GROUP BY vas_order, whs_no,B.job_ref_no,work_ord_ref,running_no,prd_code, uom, plant, sloc, batch_no,stock_category,dsto_unit_no, dsto_section, dsto_stg_bin,issued_qty,special_stock_indicator,special_stock
                  
				UPDATE TBL_TXN_WORK_ORDER_JOB_DET
				SET qty_of_goods = @issued_qty
				WHERE job_ref_no = @job_ref_no
		   END              
                
                
		   --3. Insert into TBL_TMP_SAP_ORDER table                
		   INSERT INTO TBL_TMP_SAP_ORDER                
		   (running_no, created_date, creator_user_id)                
		   VALUES (@running_no, @CurrentDateTime, @user_id)                
               
	  END 
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ @event_id = '25'  Confirm Stock +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	  ELSE IF @event_id = '25' --Confirm Stock
	  BEGIN          
			UPDATE TBL_Subcon_TXN_WORK_ORDER          
			SET current_event = @event_id          
			Where job_ref_no = @job_ref_no          
          
			INSERT INTO TBL_TXN_JOB_EVENT (running_no, job_ref_no, event_id, start_date, end_date, issued_qty, remarks, on_hold_time, created_date, creator_user_id)                
			SELECT @running_no, @job_ref_no, @event_id, CONVERT(varchar(23), REPLACE(@start_date, 'T', ' '), 121), @CurrentDateTime, @issued_qty, @remarks, @total_time_taken_in_sec, @CurrentDateTime, @user_id                
	  END          
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ @event_id = '30'  Mock Sample +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++         
	  ELSE IF @event_id = '30' --Mock Sample
	  BEGIN    
	      
			
			SET @storage_type =( SELECT storage_type FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND @event_id=20)
			SET @bin_no = (SELECT bin_no FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND @event_id=20)

		   DECLARE @ques_a CHAR(1), @ques_b CHAR(1), @ques_c CHAR(1), @ques_d CHAR(1), @station_no VARCHAR(100)           
		   SET @ques_a = (SELECT JSON_VALUE(@submit_obj, '$.ques_a'))
		   SET @ques_b = (SELECT JSON_VALUE(@submit_obj, '$.ques_b'))
		   SET @ques_c = (SELECT JSON_VALUE(@submit_obj, '$.ques_c'))
		   SET @ques_d = (SELECT JSON_VALUE(@submit_obj, '$.ques_d'))
		   SET @station_no = (SELECT JSON_VALUE(@submit_obj, '$.station_no'))
                
		   --1. Insert into txn table                
		   INSERT INTO TBL_TXN_JOB_EVENT                
		   (running_no, job_ref_no, event_id, start_date, end_date, issued_qty, remarks, on_hold_time, created_date, creator_user_id, station_no, storage_type, bin_no)                
		   SELECT @running_no, @job_ref_no, @event_id, CONVERT(varchar(23), REPLACE(@start_date, 'T', ' '), 121), @CurrentDateTime, @issued_qty, @remarks, @total_time_taken_in_sec, @CurrentDateTime, @user_id, @station_no , @storage_type, @bin_no               
           
		   IF(LEFT(@job_ref_no,1) = 'S')            
		   BEGIN        
				UPDATE TBL_Subcon_TXN_WORK_ORDER                
				SET ques_a = @ques_a, ques_b = @ques_b,ques_c = @ques_c, ques_d = @ques_d                
				WHERE job_ref_no = @job_ref_no          
        
				UPDATE TBL_Subcon_TXN_WORK_ORDER          
				SET current_event = @event_id          
				Where job_ref_no = @job_ref_no          
		   END        
		   ELSE        
		   BEGIN        
				UPDATE TBL_TXN_WORK_ORDER_JOB_DET
				SET ques_a = @ques_a, ques_b = @ques_b, ques_c = @ques_c, ques_d = @ques_d
				WHERE job_ref_no = @job_ref_no           
		   END                 
	  END 
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ @event_id = '40'  VAS +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++         
	  ELSE IF @event_id = '40' --VAS                
	  BEGIN                
			--1. Insert into txn table      
			
			SET @storage_type =( SELECT storage_type FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND @event_id=20)
			SET @bin_no = (SELECT bin_no FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND @event_id=20)

			INSERT INTO TBL_TXN_JOB_EVENT                
			(running_no, job_ref_no, event_id, start_date, end_date, issued_qty, remarks, on_hold_time, created_date, creator_user_id, storage_type, bin_no)                
			SELECT @running_no, @job_ref_no, @event_id, CONVERT(varchar(23), REPLACE(@start_date, 'T', ' '), 121), @CurrentDateTime, @issued_qty, @remarks, @total_time_taken_in_sec, @CurrentDateTime, @user_id, @storage_type, @bin_no                
               
			DECLARE @mll_mo VARCHAR(50), @subcon_wi_no VARCHAR(50), @prd_code VARCHAR(50), @qa_required INT             
            
			IF(LEFT(@job_ref_no,1) = 'S')            
			BEGIN            
				UPDATE TBL_Subcon_TXN_WORK_ORDER                
				SET completion_date = @CurrentDateTime,                
				num_of_days_to_complete = (SELECT top 1 CASE WHEN DATEDIFF(day, commencement_date, completion_date) = 0 THEN 1 ELSE DATEDIFF(day, commencement_date, completion_date) END 
				FROM TBL_Subcon_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)              
				WHERE job_ref_no = @job_ref_no            
                   
				SELECT @subcon_wi_no = subcon_WI_no, @prd_code = prd_code FROM TBL_Subcon_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no                
				SET @qa_required = (SELECT qa_required FROM TBL_MST_MLL_DTL WITH(NOLOCK) WHERE mll_no = @subcon_wi_no AND prd_code = @prd_code)                
                
				UPDATE TBL_Subcon_TXN_WORK_ORDER                
				SET qa_required = @qa_required                
				WHERE job_ref_no = @job_ref_no            
              
			END            
			ELSE            
			BEGIN   

				DECLARE @commencement_date DATETIME,@completion_date DATETIME

				SET @commencement_date=(SELECT CASE WHEN CONVERT (VARCHAR(10),commencement_date,121)='1900-01-01' THEN  CONVERT(varchar(23), REPLACE(@start_date, 'T', ' '), 121) ELSE commencement_date END  
									FROM TBL_TXN_WORK_ORDER_JOB_DET WHERE job_ref_no = @job_ref_no )

			
				SET @completion_date=@CurrentDateTime

				UPDATE TBL_TXN_WORK_ORDER_JOB_DET                
				SET completion_date = @completion_date, 
				    commencement_date=@commencement_date,
				num_of_days_to_complete = (SELECT CASE WHEN DATEDIFF(day, @commencement_date, @completion_date) = 0 THEN 1 ELSE DATEDIFF(day, @commencement_date, @completion_date) END FROM TBL_TXN_WORK_ORDER_JOB_DET WITH(NOLOCK) WHERE job_ref_no = @job_ref_no)                
				WHERE job_ref_no = @job_ref_no            
          
		  
		 

				--SELECT @mll_mo = mll_no, @prd_code = prd_code FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no                
				--SET @qa_required = (SELECT qa_required FROM TBL_MST_MLL_DTL WITH(NOLOCK) WHERE mll_no = @mll_mo AND prd_code = @prd_code)                
                

				--UPDATE TBL_TXN_WORK_ORDER                
				--SET qa_required = @qa_required                
				--WHERE job_ref_no = @job_ref_no      
				
				UPDATE WO
				SET WO.qa_required = D.qa_required                
				FROM TBL_TXN_WORK_ORDER  WO 
				INNER JOIN TBL_MST_MLL_DTL D ON WO.mll_no=D.mll_no and WO.prd_code=D.prd_code
				WHERE job_ref_no = @job_ref_no      

				

			END            
                
	   /** To check whether QA is required or not **/                
	   --SELECT TOP 1 @running_no = CAST(CAST(RIGHT(running_no, @len) as INT) + 1 AS VARCHAR(50))                
	   --      FROM (SELECT running_no FROM TBL_TXN_JOB_EVENT WITH(NOLOCK)) A ORDER BY CAST(RIGHT(running_no, @len) AS INT) DESC                
	   --SET @running_no = 'MY' + REPLICATE('0', @len - LEN(@running_no)) + @running_no                
                
                  
                   
	   --IF @qa_required = 0 -- QA is not required, system to auto insert                
	   --BEGIN                
	   -- SET @event_id = '50'                
                
	   -- INSERT INTO TBL_TXN_JOB_EVENT                
	   -- (running_no, job_ref_no, event_id, start_date, end_date, issued_qty, completed_qty, remarks, on_hold_time, created_date, creator_user_id)                
	   -- SELECT @running_no, @job_ref_no, @event_id, CONVERT(varchar(23), REPLACE(GETDATE(), 'T', ' '), 121), GETDATE(), @issued_qty, @internal_qa_completed_qty, 'System Auto - QA is set to not required', @total_time_taken_in_sec, GETDATE(), '0'             
  
   
                
	   -- DECLARE @com_qty_1 INT                
	   -- SET @com_qty_1 = (SELECT ISNULL(SUM(completed_qty),0) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND event_id = '50')                
                
	   -- UPDATE TBL_TXN_WORK_ORDER                
	   -- SET qty_of_goods = @com_qty_1                
	   -- WHERE job_ref_no = @job_ref_no                
	   --END                
	   /** To check whether QA is required or not **/           
                
	  END    
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ @event_id = '50'  QA Final Release +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
	  ELSE IF @event_id = '50' --QA Final Release                
	  BEGIN                
			--1. Insert into txn table    
			
			SET @storage_type =( SELECT storage_type FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND @event_id=20)
			SET @bin_no = (SELECT bin_no FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND @event_id=20)

			INSERT INTO TBL_TXN_JOB_EVENT                
			(running_no, job_ref_no, event_id, start_date, end_date, issued_qty, completed_qty, remarks, on_hold_time, created_date, creator_user_id, storage_type, bin_no)                
			SELECT @running_no, @job_ref_no, @event_id, CONVERT(varchar(23), REPLACE(@start_date, 'T', ' '), 121), @CurrentDateTime, @issued_qty, @internal_qa_completed_qty, @remarks, @total_time_taken_in_sec, @CurrentDateTime, @user_id  ,@storage_type ,@bin_no             
            
			DECLARE @com_qty INT    
			                
			SET @com_qty = (SELECT ISNULL(SUM(completed_qty),0) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND event_id = '50')                
			IF(LEFT(@job_ref_no,1) = 'S')            
			BEGIN 
				UPDATE TBL_Subcon_TXN_WORK_ORDER                
				SET qty_of_goods = @internal_qa_completed_qty                
				WHERE job_ref_no = @job_ref_no        
			end
			else 
			begin
				UPDATE TBL_TXN_WORK_ORDER_JOB_DET                
				SET qty_of_goods = @com_qty                
				WHERE job_ref_no = @job_ref_no     
			end           
	  END 
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ @event_id = '60'  Trigger email to client QA +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  

	  ELSE IF @event_id = '60' --Trigger email to client QA                
	  BEGIN                
			--1. Insert into txn table                
			INSERT INTO TBL_TXN_JOB_EVENT  (running_no, job_ref_no, event_id, start_date, end_date, issued_qty, completed_qty, remarks, on_hold_time, created_date, creator_user_id)                
			SELECT @running_no, @job_ref_no, @event_id, CONVERT(varchar(23), REPLACE(@start_date, 'T', ' '), 121), @CurrentDateTime, @issued_qty, @qa_qty, @remarks, @total_time_taken_in_sec, @CurrentDateTime, @user_id                
                
			UPDATE TBL_TXN_WORK_ORDER_JOB_DET                
			SET qty_of_goods = @internal_qa_completed_qty                
			WHERE job_ref_no = @job_ref_no   
   
			                
			--SET @com_qty = (SELECT ISNULL(SUM(completed_qty),0) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND event_id = '50')  


		   IF(LEFT(@job_ref_no,1) = 'S')            
		   BEGIN 
				UPDATE TBL_Subcon_TXN_WORK_ORDER                
				SET qty_of_goods = @qa_qty                
				WHERE job_ref_no = @job_ref_no        
		   end
		   else 
		   begin
				--UPDATE TBL_TXN_WORK_ORDER_JOB_DET                
				--SET qty_of_goods = @com_qty                
				--WHERE job_ref_no = @job_ref_no     

				UPDATE TBL_TXN_WORK_ORDER_JOB_DET                
				SET qty_of_goods = @internal_qa_completed_qty                
				WHERE job_ref_no = @job_ref_no   
		   end   
                  
		   --2. Trigger email to client                
		   SET ARITHABORT ON                
		   --- Get data into temp table ---                
		   DECLARE @file_extension VARCHAR(50), @file_data NVARCHAR(MAX), @file_name NVARCHAR(250)                
                
		   CREATE TABLE #TEMP                
		   (                
		   row_id INT IDENTITY(1,1),                
		   job_ref_no VARCHAR(50),                
		   guid VARCHAR(250),                
		   file_name NVARCHAR(250),                
		   file_data VARBINARY(MAX),                
		   file_extension VARCHAR(50)                
		   )                  
                
		   INSERT INTO #TEMP (job_ref_no, guid, file_name, file_extension)                
		   SELECT job_ref_no, guid, file_name, file_extension FROM TBL_TXN_JOB_EVENT_EMAIL_ATTACHMENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND guid = @guid                
                
		   UPDATE A                
		   SET A.file_data = CAST(N'' AS xml).value('xs:base64Binary(sql:column("B.file_data"))', 'varbinary(max)')                
		   FROM #TEMP A, TBL_TXN_JOB_EVENT_EMAIL_ATTACHMENT B WITH(NOLOCK)                
		   WHERE A.job_ref_no = B.job_ref_no AND A.guid = B.guid AND A.file_name = B.file_name                
			--- Get data into temp table ---                
                
		   --- Check if folder exists ---   
		  if (@html_file_name is null)
		  begin
			   CREATE TABLE #ResultSet (Directory varchar(200))                
			   INSERT INTO #ResultSet EXEC master.dbo.xp_subdirs N'D:\VAS\TH-HEC\'                
			   DECLARE @folder_exists INT                 
			   SET @folder_exists = (SELECT COUNT(*) FROM #ResultSet WHERE Directory = @guid)                              
			   IF (@folder_exists = 0)                
			   BEGIN                
				DECLARE @cmdpath VARCHAR(4000)                
				SET @cmdpath = 'MD ' + @folder_path                
				EXEC master..xp_cmdshell @cmdpath, no_output;                
			   END                
			   DROP TABLE #ResultSet   
		   end
		   --- Check if folder exists ---                
               
		   --- Convert binary file to physical files ---                
		   DECLARE @img_path VARBINARY(MAX), @timestamp NVARCHAR(500), @ObjectToken INT, @id INT = 1, @tbl_count INT                
		   SET @tbl_count = (SELECT COUNT(1) FROM #TEMP)                
		   WHILE @tbl_count >= @id                 
		   BEGIN                
			SELECT @img_path = file_data from #TEMP WHERE row_id = @id                
			SELECT @timestamp =  @folder_path + file_name FROM #TEMP  WHERE row_id = @id                
			EXEC sp_OACreate 'ADODB.Stream', @ObjectToken OUTPUT                
			EXEC sp_OASetProperty @ObjectToken, 'Type', 1                
			EXEC sp_OAMethod @ObjectToken, 'Open'                
			EXEC sp_OAMethod @ObjectToken, 'Write', NULL, @img_path                
			EXEC sp_OAMethod @ObjectToken, 'SaveToFile', NULL, @timestamp, 2                
			EXEC sp_OAMethod @ObjectToken, 'Close'                
			EXEC sp_OADestroy @ObjectToken                
			SET @id = @id + 1                
		   END                 
		   --- Convert binary file to physical files ---                
               
		   --Generate pdf--                
		   DECLARE @html NVARCHAR(MAX), @barcode_html VARCHAR(MAX), @parameter NVARCHAR(MAX), @html_full_path VARCHAR(1000), @pdf_full_path VARCHAR(1000), @strCMD VARCHAR(1000)                
		   --@html_file_name VARCHAR(100), 
		   SET @parameter = N'{"job_ref_no":"' + @job_ref_no + '"}'                
           
		   CREATE TABLE #HTML_STRING                
		   (                
		   string_a nvarchar(maX),                
		   string_b nvarchar(maX),                
		   string_c nvarchar(maX),                
		   string_d nvarchar(maX)                
		   )                

		   if (@html_file_name is null)
		   begin
			   IF(LEFT(@job_ref_no,1) = 'S')            
			   BEGIN 
					INSERT INTO #HTML_STRING (string_a, string_b, string_c, string_d)   
					EXEC SPP_TXN_SUBCON_WORK_ORDER_PRINT @parameter     
			   end
			   else 
			   begin
					INSERT INTO #HTML_STRING (string_a, string_b, string_c, string_d)   
					EXEC SPP_TXN_WORK_ORDER_PRINT @parameter     
			   end              
             
			   IF(LEFT(@job_ref_no,1) = 'S')            
			   BEGIN 
					SET @barcode_html = (SELECT barcode_html FROM TBL_Subcon_TXN_WORK_ORDER WHERE job_ref_no = @job_ref_no)      
			   end
			   else 
			   begin
					SET @barcode_html = (SELECT barcode_html FROM TBL_TXN_WORK_ORDER_JOB_DET WHERE job_ref_no = @job_ref_no) 
			   end                
		   
			   SET @html = (SELECT string_a + string_b + string_c + string_d FROM #HTML_STRING)                
			   SET @html = (SELECT replace(@html, '<svg id="barcode"></svg>' , @barcode_html))             
			   SET @html_file_name = @running_no + '.html' -- 2018/05/0001.html   
			   
           end
		   else
		   begin
				create table #temp_html (html nvarchar(max))
				declare @sql varchar(max) --, @html_long nvarchar(max)
				SET @html_full_path = @folder_path + @html_file_name
			   set @sql = 
				'BULK INSERT #temp_html 
				FROM ''' + @html_full_path +
				''' WITH 
					(
						ROWTERMINATOR =''\n''
					)'
				exec(@sql)
				SELECT @html = COALESCE(@html, '') + html FROM #temp_html
				--select @html_long as html_long
				--Select * from #temp_html
				drop table #temp_html
			end
		   EXEC SPP_GENERATE_HTML @String = @html, @Path = @folder_path, @Filename = @html_file_name --Generate .html file in @folder_path                
               
		   SET @html_full_path = @folder_path + @html_file_name -- D:\VAS\TH-HEC\@guid\html_file_name.html                
		   SET @pdf_full_path = @folder_path + @running_no + '.pdf' -- D:\VAS\TH-HEC\@guid\2018/05/0001.pdf                
		   SET @strCMD = 'D:\VAS\wkhtmltopdf.exe --image-dpi -600 --image-dpi 100 -n --print-media-type -q --quiet --header-html "" --header-spacing 30 --footer-html ""   ' + @html_full_path + '  ' + @pdf_full_path +'  '                
                
		   EXEC xp_cmdshell @strCMD, no_output;                
		   DROP TABLE #HTML_STRING                
                
		   INSERT INTO #TEMP (job_ref_no, guid, file_name, file_extension)                
		   SELECT @job_ref_no, @guid, @running_no + '.pdf', '.pdf'   
		   --Generate pdf--                
                
		   ----------- Trigger email ---                
		   DECLARE @subject NVARCHAR(MAX), @body NVARCHAR(MAX), @file_attachments NVARCHAR(MAX) = '', @count INT, @i INT = 1                
		   SET @count = (SELECT COUNT(*) FROM #TEMP)                
		   WHILE @i <= @count                
		   BEGIN                
				SET @file_name = (SELECT file_name FROM #TEMP WHERE row_id = @i)                
				SET @file_attachments += 'D:\VAS\TH-HEC\' + @guid + '\' + @file_name      IF @i <> @count                
				SET @file_attachments += ';'                
				SET @i = @i + 1                
		   END                
              
		   DECLARE @email_country_hdr VARCHAR(100), @approve_link NVARCHAR(4000), @approval_email_addr NVARCHAR(4000),@ref_no NVARCHAR(4000), @rejected_link NVARCHAR(4000), @profile_name VARCHAR(50)                
		   SET @email_country_hdr = (SELECT TOP 1 email_country_hdr FROM VAS.dbo.TBL_ADM_SETTING A WITH(NOLOCK) 
		   INNER JOIN VAS.dbo.TBL_ADM_PRINCIPAL B WITH(NOLOCK) ON A.setting_id = B.setting_id 
		   INNER JOIN VAS.dbo.TBL_ADM_USER C WITH(NOLOCK) ON B.principal_id = C.principal_id WHERE user_id = @user_id) 
	   
		   SET @subject = 'Pending Approval (' + @running_no + ')'                
		   SET @ref_no = '[VAS]' + @email_country_hdr                
		   SET @approval_email_addr = (SELECT config_value FROM VAS.dbo.TBL_ADM_CONFIGURATION_TH WITH(NOLOCK) WHERE config = 'global_email_address')                
		   SET @profile_name = (SELECT config_value FROM VAS.dbo.TBL_ADM_CONFIGURATION_TH WITH(NOLOCK) WHERE config = 'email_profile_name')                
		   SET @approve_link = 'mailto:' + @approval_email_addr + '?Subject=Re:' + @ref_no + ':' + @running_no + ':A&body=Comments:%0A%0A[eom]%0A%0A'                
		   SET @rejected_link = 'mailto:' + @approval_email_addr + '?Subject=Re:' + @ref_no + ':' + @running_no + ':R&body=Comments:%0A%0A[eom]%0A%0A'                 
               
		   SET @body = '<table style="font-family:arial;font-size:10pt;">'                 
		   SET @body = '<tr><td colspan=2>This is testing site.</td></tr>'                
		   SET @body += '<tr><td colspan=2>Please click on the <b>Approve</b> or <b>Reject</b> link. Thereafter the email will be composed.</td></tr>'                
		   SET @body += '<tr><td colspan=2>Do take note that comments is required for rejection.</td></tr>'                
		   SET @body += '<tr><td colspan=2>Once done, please select <b>SEND</b> for this request to proceed to the next steps</td></tr>'                
		   SET @body += '<tr><td colspan=2>&nbsp;</td></tr>'                
		   SET @body += '<tr><td colspan=2><a href='+ @approve_link +'>Approve</a></td></tr>'                
		   SET @body += '<tr><td colspan=2>&nbsp;</td></tr>'                
		   SET @body += '<tr><td colspan=2><a href='+ @rejected_link +'>Reject</a></td></tr>'                
		   SET @body += '<tr><td colspan=2>&nbsp;</td></tr></table>'                 
                
			EXEC msdb.dbo.sp_send_dbmail                
			@profile_name = @profile_name,                
			@recipients = @email,                
			@blind_copy_recipients ='smita.thorat@itcinfotech.com',-- 'shen.yee.siow@dksh.com',                    
			@subject = @subject,                
			@body = @body,                
			@attach_query_result_as_file = 0,                
			@body_format ='HTML',                
			@importance = 'NORMAL',                
			@file_attachments = @file_attachments;                
			------ Trigger email ---                
                
		   INSERT INTO TBL_TXN_JOB_EVENT_EMAIL_LOG                
		   (job_ref_no, system_running_no, guid, email_addr, cc_addr, subject, body, sent_by, sent_date)                
		   VALUES      
		   (@job_ref_no, @running_no, @guid, @email, 'smita.thorat@itcinfotech.com', @subject, @body, @user_id, @CurrentDateTime)
		   --(@job_ref_no, @running_no, @guid, @email, 'shen.yee.siow@dksh.com', @subject, @body, @user_id, GETDATE())                
                
		   ---- Delete ALL files and folder ---                
		   DECLARE @remove_files NVARCHAR(MAX), @cmd VARCHAR(8000), @remove_folder NVARCHAR(MAX)                
		   SET @remove_files = N'D:\VAS\TH-HEC\' + @guid + '\*.*'                
		   SET @cmd = 'DEL /F /Q ' + @remove_files                
		   EXEC master..xp_cmdshell @cmd, no_output;                
                
		   SET @remove_folder = N'D:\VAS\TH-HEC\' + @guid                
		   SET @cmd = 'RMDIR /S /Q ' + @remove_folder                
		   EXEC master..xp_cmdshell @cmd, no_output;                
		   ---- Delete ALL files and folder ---                
                 
		   UPDATE TBL_TXN_JOB_EVENT                
		   SET email_sent_count = 1                
		   WHERE running_no = @running_no                
                
		   DROP TABLE #TEMP                
		   SET ARITHABORT OFF                
	  END 
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 --+++++++++++++++++++++++++++++++++++++++++++++++++  @event_id = '80' OR @event_id = '85'  Submit to SAP   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  

	  ELSE IF @event_id = '80'			-- Submit to SAP                
	  BEGIN

	     SELECT * INTO #TempProductWODetails FROM OPENJSON(@submit_obj, N'$.items') WITH (
			--vas_order VARCHAR(50) '$.vas_order',
			to_no VARCHAR(50) '$.to_no',
			inbound_doc VARCHAR(50) '$.inbound_doc',
			prd_code VARCHAR(50) '$.prd_code' ,
			batch_no VARCHAR(50)  '$.batch_no', 
			job_ref_no NVARCHAR(250)  '$.job_ref_no',
			completed_qty INT  '$.completed_qty',
			damaged_qty INT  '$.damaged_qty',
			issued_qty INT  '$.issued_qty',
			storage_type VARCHAR(50)  '$.storage_type', 
			bin_no VARCHAR(50)  '$.bin_no',
			uom NVARCHAR(250)  '$.uom',
			sloc NVARCHAR(250)  '$.sloc',
			plant NVARCHAR(250)  '$.plant',
			whs_no VARCHAR(50)  '$.whs_no', 
			stock_category CHAR(2)  '$.stock_category',
			special_stock_indicator CHAR(2) '$.special_stock_indicator',
			special_stock VARCHAR(200) '$.special_stock'

			)
			
		SELECT @completed_qty =sum(ISNULL(completed_qty,0))  ,@damaged_qty = sum(ISNULL(damaged_qty,0))   FROM #TempProductWODetails

			--SET @storage_type = (SELECT JSON_VALUE(@submit_obj, '$.storage_type'))
			--SET @bin_no = (SELECT JSON_VALUE(@submit_obj, '$.bin_no'))

		   --1. Insert into txn table                
		   INSERT INTO TBL_TXN_JOB_EVENT (running_no, job_ref_no, event_id, start_date, end_date, issued_qty, completed_qty, damaged_qty, remarks, on_hold_time, created_date, creator_user_id, storage_type, bin_no)                
		   SELECT @running_no, @job_ref_no, @event_id, CONVERT(varchar(23), REPLACE(@start_date, 'T', ' '), 121), @CurrentDateTime, @completed_qty+@damaged_qty, @completed_qty, @damaged_qty, @remarks, @total_time_taken_in_sec, @CurrentDateTime, @user_id ,'',''--@storage_type,@bin_no      
                
		   --2. Insert into sap integration table      
       
		   IF(LEFT(@job_ref_no,1) = 'S')            
		   BEGIN    
				INSERT INTO VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP                
				(country_code, process_ind, vas_order, whs_no, workorder_no, requirement_no, qty,                 
				prd_code, uom, plant, sloc, batch_no, movement_type, stock_category, created_date, created_by, status, ssto_unit_no,  ssto_section, ssto_stg_bin)                
				SELECT TOP 1 'TH', 'P', vas_order, whs_no, work_ord_ref, running_no, (ISNULL(completed_qty,0) + ISNULL(damaged_qty,0)),                
				prd_code, uom, plant, sloc, batch_no, '889', stock_category, @CurrentDateTime, 1, 'P', dsto_unit_no, dsto_section, dsto_stg_bin                
				from TBL_TXN_JOB_EVENT A                
				INNER JOIN TBL_Subcon_TXN_WORK_ORDER B WITH(NOLOCK) ON A.job_ref_no = B.job_ref_no                
				WHERE running_no = @running_no    
  
				INSERT INTO VAS_INTEGRATION_TH.dbo.[VAS_SUBCON_INBOUND_ORDER]  
					( [country_code],[process_ind], [status],[outbound_doc] ,[Subcon_Doc], [Subcon_Item_No], [whs_no], [plant], [supplier_code], [supplier_name],   
					[prd_code], [prd_desc], [uom], [batch_no], [qty], [expiry_date], [SWI_No], [created_date], [created_by], [sloc], [po_date], [subcon_po],   
					[component], [component_desc], [to_no],  [to_date], [to_time], [delete_flag], [Subcon_Job_No], [running_no], [job_ref_no])  
					--(country_code, process_ind, vas_order, whs_no, workorder_no, requirement_no, qty,                 
					--prd_code, uom, plant, sloc, batch_no, movement_type, stock_category, created_date, created_by, status, ssto_unit_no,  ssto_section, ssto_stg_bin)        
	
				SELECT	'TH', 'P','S', C.outbound_doc, C.Subcon_Doc,C.Subcon_Item_No, A.whs_no, A.plant, C.supplier_code, C.supplier_name, 
				c.prd_code, c.prd_desc, A.uom, A.batch_no, A.qty, C.expiry_date,c.SWI_No,@CurrentDateTime,'System', A.sloc, c.po_date,'',
				C.component,c.component_desc, c.to_no,c.to_date, c.to_time,0, A.workorder_no, A.requirement_no, B.job_ref_no
				FROM	VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP A
						inner join TBL_TXN_JOB_EVENT B    ON		A.requirement_no = B.running_no
						inner join VAS_INTEGRATION_TH.dbo.VAS_Subcon_TRANSFER_ORDER C ON		B.job_ref_no = C.Subcon_Job_No
						inner join TBL_Subcon_TXN_WORK_ORDER D ON		C.Subcon_Job_No = D.job_ref_no
				WHERE	A.requirement_no = @running_no 

				 --   SELECT TOP 1 'MY', 'P','S',c.outbound_doc,C.Subcon_Doc,C.Subcon_Item_No,B.whs_no,B.plant,C.supplier_code,C.supplier_name,c.prd_code,c.prd_desc,b.uom,  
				 --c.batch_no,  
				 --(ISNULL(completed_qty,0) + ISNULL(damaged_qty,0)),C.expiry_date,c.SWI_No,GETDATE(),'System',B.sloc,c.po_date,'',C.component,c.component_desc,  
				 --c.to_no,c.to_date, c.to_time,0,B.work_ord_ref  
               
				 --   from TBL_TXN_JOB_EVENT A                
				 --   INNER JOIN TBL_Subcon_TXN_WORK_ORDER B WITH(NOLOCK) ON A.job_ref_no = B.job_ref_no    
				 --INNER JOIN VAS_INTEGRATION.dbo.[VAS_Subcon_TRANSFER_ORDER] C ON  B.Subcon_WI_No = C.SWI_No  
				 --   WHERE running_no = @running_no   
		   END    
		   ELSE    
		   BEGIN    
		   --SELECT * FROM TBL_TXN_JOB_EVENT
		   	SET @storage_type = (SELECT storage_type FROM TBL_TXN_JOB_EVENT WHERE event_id=20 AND job_ref_no=@job_ref_no)
			SET @bin_no = (SELECT bin_no FROM TBL_TXN_JOB_EVENT WHERE event_id=20 AND job_ref_no=@job_ref_no)


		   --SELECT * FROM TBL_TXN_JOB_EVENT_DET--inbound_doc,vas_order,to_no
		   INSERT INTO TBL_TXN_JOB_EVENT_DET(running_no,job_ref_no,prd_code,batch_no,event_id,issued_qty,completed_qty,damaged_qty,uom,plant, sloc,whs_no,stock_category,ssto_unit_no,ssto_stg_bin,storage_type_destination,bin_destination,special_stock_indicator,special_stock,inbound_doc,to_no)
			SELECT @running_no, @job_ref_no, prd_code, batch_no, @event_id, ISNULL(completed_qty,0)+ISNULL(damaged_qty,0) ,completed_qty,  damaged_qty ,uom,plant, sloc,whs_no,stock_category,@storage_type,@bin_no, storage_type, bin_no ,special_stock_indicator,special_stock,inbound_doc,to_no  
			FROM #TempProductWODetails

		   --SELECT * FROM TBL_TXN_WORK_ORDER
		   ----CASE WHEN @JobFormat='JobFormat' THEN B.job_ref_no ELSE B.work_ord_ref  END   work_ord_ref,
		   --SELECT * FROM VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP 


				INSERT INTO VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP                
				  (country_code, process_ind, vas_order, whs_no, workorder_no, requirement_no, qty,                 
				  prd_code, uom, plant, sloc, batch_no, movement_type, stock_category, created_date, created_by, status, 
				  ssto_unit_no,  ssto_section, ssto_stg_bin,storage_type_destination,bin_destination,special_stock_indicator,special_stock,qi_type) 
				  SELECT  'TH', 'P', NULL vas_order, whs_no, @job_ref_no , running_no, ISNULL(completed_qty,0) ,--, SUM(ISNULL(completed_qty,0))--+ ISNULL(damaged_qty,0)),                
				prd_code, uom, plant, sloc, A.batch_no, '889',  stock_category, @CurrentDateTime, @user_id, 'P', 
				ssto_unit_no, '', ssto_stg_bin,storage_type_destination,bin_destination ,special_stock_indicator,special_stock,@qi_type      
				FROM TBL_TXN_JOB_EVENT_DET A  
				WHERE running_no = @running_no  AND A.job_ref_no=@job_ref_no
				--GROUP BY whs_no,running_no,prd_code, uom, plant, sloc, A.batch_no,stock_category,ssto_unit_no,ssto_stg_bin,
				--storage_type_destination,bin_destination ,special_stock_indicator,special_stock,inbound_doc,to_no




				--SELECT  'TH', 'P', NULL vas_order, whs_no, @job_ref_no , running_no, (ISNULL(completed_qty,0)) ,--+ ISNULL(damaged_qty,0)),                
				--prd_code, uom, plant, sloc, A.batch_no, '889',  stock_category, @CurrentDateTime, @user_id, 'P', 
				--ssto_unit_no, '', ssto_stg_bin,storage_type_destination,bin_destination ,special_stock_indicator,special_stock,@qi_type      
				--FROM TBL_TXN_JOB_EVENT_DET A  
				--WHERE running_no = @running_no  AND A.job_ref_no=@job_ref_no
				
			END    
	  END


	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 --+++++++++++++++++++++++++++++++++++++++++++++++++  @event_id = '81'   Submit to SAP Reverse   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  

	  ELSE IF @event_id = '81'  -- Submit to SAP Reverse       
	  BEGIN



		   --1. Insert into txn table                
		   INSERT INTO TBL_TXN_JOB_EVENT (running_no, job_ref_no, event_id, start_date, end_date, issued_qty, completed_qty, damaged_qty, remarks, on_hold_time, created_date, creator_user_id, storage_type, bin_no)                
		   SELECT @running_no, @job_ref_no, @event_id, CONVERT(varchar(23), REPLACE(@start_date, 'T', ' '), 121), @CurrentDateTime, @issued_qty, @completed_qty, @damaged_qty, @remarks, @total_time_taken_in_sec, @CurrentDateTime, @user_id ,'',''--@storage_type,@bin_no      
                
		   --2. Insert into sap integration table      
       
		   IF(LEFT(@job_ref_no,1) = 'S')            
		   BEGIN    
				INSERT INTO VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP                
				(country_code, process_ind, vas_order, whs_no, workorder_no, requirement_no, qty,                 
				prd_code, uom, plant, sloc, batch_no, movement_type, stock_category, created_date, created_by, status, ssto_unit_no,  ssto_section, ssto_stg_bin)                
				SELECT TOP 1 'TH', 'P', vas_order, whs_no, work_ord_ref, running_no, (ISNULL(completed_qty,0) + ISNULL(damaged_qty,0)),                
				prd_code, uom, plant, sloc, batch_no, '889', stock_category, @CurrentDateTime, 1, 'P', dsto_unit_no, dsto_section, dsto_stg_bin                
				from TBL_TXN_JOB_EVENT A                
				INNER JOIN TBL_Subcon_TXN_WORK_ORDER B WITH(NOLOCK) ON A.job_ref_no = B.job_ref_no                
				WHERE running_no = @running_no    
  
				INSERT INTO VAS_INTEGRATION_TH.dbo.[VAS_SUBCON_INBOUND_ORDER]  
					( [country_code],[process_ind], [status],[outbound_doc] ,[Subcon_Doc], [Subcon_Item_No], [whs_no], [plant], [supplier_code], [supplier_name],   
					[prd_code], [prd_desc], [uom], [batch_no], [qty], [expiry_date], [SWI_No], [created_date], [created_by], [sloc], [po_date], [subcon_po],   
					[component], [component_desc], [to_no],  [to_date], [to_time], [delete_flag], [Subcon_Job_No], [running_no], [job_ref_no])  
					--(country_code, process_ind, vas_order, whs_no, workorder_no, requirement_no, qty,                 
					--prd_code, uom, plant, sloc, batch_no, movement_type, stock_category, created_date, created_by, status, ssto_unit_no,  ssto_section, ssto_stg_bin)        
	
				SELECT	'TH', 'P','S', C.outbound_doc, C.Subcon_Doc,C.Subcon_Item_No, A.whs_no, A.plant, C.supplier_code, C.supplier_name, 
				c.prd_code, c.prd_desc, A.uom, A.batch_no, A.qty, C.expiry_date,c.SWI_No,@CurrentDateTime,'System', A.sloc, c.po_date,'',
				C.component,c.component_desc, c.to_no,c.to_date, c.to_time,0, A.workorder_no, A.requirement_no, B.job_ref_no
				FROM	VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP A
						inner join TBL_TXN_JOB_EVENT B    ON		A.requirement_no = B.running_no
						inner join VAS_INTEGRATION_TH.dbo.VAS_Subcon_TRANSFER_ORDER C ON		B.job_ref_no = C.Subcon_Job_No
						inner join TBL_Subcon_TXN_WORK_ORDER D ON		C.Subcon_Job_No = D.job_ref_no
				WHERE	A.requirement_no = @running_no 

				
		   END    
		   ELSE    
		   BEGIN    
		   --SELECT * FROM TBL_TXN_JOB_EVENT
		   	--SET @storage_type = (SELECT storage_type FROM TBL_TXN_JOB_EVENT WHERE event_id=20 AND job_ref_no=@job_ref_no)
			--SET @bin_no = (SELECT bin_no FROM TBL_TXN_JOB_EVENT WHERE event_id=20 AND job_ref_no=@job_ref_no)

			DECLARE @Previous_running_no VARCHAR(50)=(select TOP 1 running_no FROM TBL_TXN_JOB_EVENT WHERE job_ref_no=@job_ref_no AND event_id=80 ORDER BY created_date DESC)


		   --SELECT * FROM TBL_TXN_JOB_EVENT_DET--inbound_doc,vas_order,to_no
		   INSERT INTO TBL_TXN_JOB_EVENT_DET(running_no,job_ref_no,prd_code,batch_no,event_id,issued_qty,completed_qty,damaged_qty,uom,plant, sloc,whs_no,stock_category,ssto_unit_no,ssto_stg_bin,storage_type_destination,bin_destination,special_stock_indicator,special_stock,inbound_doc,to_no)
		   SELECT @running_no, @job_ref_no, prd_code, batch_no, @event_id, issued_qty,completed_qty,0 damaged_qty ,uom,plant, sloc,whs_no,stock_category, storage_type_destination,bin_destination,ssto_unit_no,ssto_stg_bin,special_stock_indicator,special_stock,inbound_doc,to_no
		   FROM TBL_TXN_JOB_EVENT_DET WHERE job_ref_no=@job_ref_no AND running_no=@Previous_running_no


		   --SELECT * FROM TBL_TXN_WORK_ORDER
		   ----CASE WHEN @JobFormat='JobFormat' THEN B.job_ref_no ELSE B.work_ord_ref  END   work_ord_ref,
		   --SELECT * FROM VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP 


				INSERT INTO VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP                
				  (country_code, process_ind, vas_order, whs_no, workorder_no, requirement_no, qty,                 
				  prd_code, uom, plant, sloc, batch_no, movement_type, stock_category, created_date, created_by, status, 
				  ssto_unit_no,  ssto_section, ssto_stg_bin,storage_type_destination,bin_destination,special_stock_indicator,special_stock,qi_type)                
				SELECT  'TH', 'P', NULL vas_order, whs_no, @job_ref_no , running_no, ISNULL(completed_qty,0),--SUM(ISNULL(completed_qty,0)) ,                
				prd_code, uom, plant, sloc, A.batch_no, '889',  stock_category, @CurrentDateTime, @user_id, 'P', 
				ssto_unit_no, '', ssto_stg_bin,storage_type_destination,bin_destination,special_stock_indicator,special_stock  ,@qi_type       
				from TBL_TXN_JOB_EVENT_DET A 
				WHERE running_no = @running_no  AND A.job_ref_no=@job_ref_no
				--GROUP BY whs_no,running_no,prd_code, uom, plant, sloc, A.batch_no,stock_category,ssto_unit_no,ssto_stg_bin,
				--storage_type_destination,bin_destination ,special_stock_indicator,special_stock,inbound_doc,to_no


				--SELECT  'TH', 'P', NULL vas_order, whs_no, @job_ref_no , running_no, (ISNULL(completed_qty,0)) ,--+ ISNULL(damaged_qty,0)),                
				--prd_code, uom, plant, sloc, A.batch_no, '889',  stock_category, @CurrentDateTime, @user_id, 'P', 
				--ssto_unit_no, '', ssto_stg_bin,storage_type_destination,bin_destination,special_stock_indicator,special_stock  ,@qi_type       
				--from TBL_TXN_JOB_EVENT_DET A 
				--WHERE running_no = @running_no  AND A.job_ref_no=@job_ref_no
			END    
	  END
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 --+++++++++++++++++++++++++++++++++++++++++++++++++  @event_id = '90'   Submit to SAP and Release from QI  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  

	  ELSE IF @event_id = '90'				-- Submit to SAP and Release from QI          
	  BEGIN

	  
		   --1. Insert into txn table                
		    INSERT INTO TBL_TXN_JOB_EVENT (running_no, job_ref_no, event_id, start_date, end_date, issued_qty, completed_qty, damaged_qty, remarks, on_hold_time, created_date, creator_user_id, storage_type, bin_no)                
		    SELECT TOP 1 @running_no running_no, job_ref_no, '90' event_id, CONVERT(varchar(23), REPLACE(@start_date, 'T', ' '), 121), @CurrentDateTime, issued_qty, completed_qty,0 damaged_qty, @remarks, on_hold_time, created_date, @user_id , storage_type, bin_no 
			FROM TBL_TXN_JOB_EVENT WHERE event_id=80  AND job_ref_no=@job_ref_no ORDER BY created_date desc    
	  


		   --2. Insert into sap integration table      
       
		   IF(LEFT(@job_ref_no,1) = 'S')            
		   BEGIN    
				  Print '1111'
		   END    
		   ELSE    
		   BEGIN    
		  

		   --SELECT * FROM TBL_TXN_JOB_EVENT_DET--inbound_doc,vas_order,to_no
		   INSERT INTO TBL_TXN_JOB_EVENT_DET(running_no,job_ref_no,prd_code,batch_no,event_id,issued_qty,completed_qty,damaged_qty,uom,plant, sloc,whs_no,stock_category,ssto_unit_no,ssto_stg_bin,storage_type_destination,bin_destination,special_stock_indicator,special_stock,inbound_doc,to_no)
			SELECT @running_no,job_ref_no,prd_code,batch_no,'90' event_id,issued_qty,completed_qty,0 damaged_qty,uom,plant, sloc,whs_no,stock_category,ssto_unit_no,ssto_stg_bin,storage_type_destination,bin_destination ,special_stock_indicator,special_stock,inbound_doc,to_no
			FROM TBL_TXN_JOB_EVENT_DET WHERE running_no in (SELECT TOP 1 running_no FROM TBL_TXN_JOB_EVENT WHERE event_id=80 AND job_ref_no=@job_ref_no ORDER BY created_date DESC)

		
		   --SELECT * FROM VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP 


				INSERT INTO VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP                
				  (country_code, process_ind, vas_order, whs_no, workorder_no, requirement_no, qty,                 
				  prd_code, uom, plant, sloc, batch_no, movement_type, stock_category, created_date, created_by, status, 
				  ssto_unit_no,  ssto_section, ssto_stg_bin,storage_type_destination,bin_destination,special_stock_indicator,special_stock,qi_type,line_no)                
				SELECT  'TH', 'Q', NULL vas_order, whs_no, @job_ref_no , running_no, (ISNULL(completed_qty,0)) ,--+ ISNULL(damaged_qty,0)),                
				prd_code, uom, plant, sloc, A.batch_no, '321', stock_category, @CurrentDateTime, @user_id, 'P', 
				ssto_unit_no, '', ssto_stg_bin,storage_type_destination,bin_destination ,special_stock_indicator,special_stock,@qi_type,ROW_NUMBER() OVER(ORDER BY running_no ASC)       
				from TBL_TXN_JOB_EVENT_DET A                
				--INNER JOIN TBL_TXN_WORK_ORDER B WITH(NOLOCK) ON A.job_ref_no = B.job_ref_no                
				WHERE running_no = @running_no  AND A.job_ref_no=@job_ref_no
			END    
	  END


	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 --+++++++++++++++++++++++++++++++++++++++++++++++++ Other basic events (no special actions required)  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  

	  ELSE -- Other basic events (no special actions required)                
	  BEGIN                
		   --1. Insert into txn table                
		   INSERT INTO TBL_TXN_JOB_EVENT                
		   (running_no, job_ref_no, event_id, start_date, end_date, issued_qty, remarks, on_hold_time, created_date, creator_user_id)                
		   SELECT @running_no, @job_ref_no, @event_id, CONVERT(varchar(23), REPLACE(@start_date, 'T', ' '), 121), @CurrentDateTime, @issued_qty, @remarks, @total_time_taken_in_sec, @CurrentDateTime, @user_id      
	  END                
                
	  DECLARE @event_name NVARCHAR(100)                
	  SET @event_name = (SELECT TOP 1 event_name FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK) WHERE event_id = @event_id)                
                
	  INSERT INTO TBL_ADM_AUDIT_TRAIL                
		(module, key_code, action, action_by, action_date)                
	  SELECT 'JOB-EVENT-NEW', @job_ref_no, 'Completed ' + @event_name, @user_id, @CurrentDateTime                
        
	  IF(LEFT(@job_ref_no,1) = 'S')      
	  BEGIN      
			UPDATE TBL_Subcon_TXN_WORK_ORDER                
			SET current_event = @event_id                
			WHERE job_ref_no = @job_ref_no      
	  END      
	  ELSE      
	  BEGIN      
			UPDATE TBL_TXN_WORK_ORDER_JOB_DET                
			SET current_event = @event_id                
			WHERE job_ref_no = @job_ref_no      
	  END           
	 END                
                
	 SELECT 'N' as duplicate                
                
 END TRY                
                
 BEGIN CATCH                
	SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_LINE() as ErrorLine, ERROR_MESSAGE() AS ErrorMessage;                 
 END CATCH                
END 

GO
