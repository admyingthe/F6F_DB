SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
-- ==============================        
-- Author:          
-- Create date:         
-- Description: Create Subcon Work Order        
-- Example Query:        
-- ==============================        
--EXEC [SPP_Subcon_TXN_WORK_ORDER_CREATE] @submit_obj =N'{"urgent":0,"job_ref_no":"","commencement_date":"","completion_date":"","qty_of_goods":"438","num_of_days_to_complete":"","save":"Save","cancel":"Back","print":"Print","update":"Update","work_ord_ref":"BIO-LIFE M/100895659/ABC123/2029-03-31","client_name":"BIO-LIFE M","prd_code":"100895659","prd_desc":"MULTIVITAMINS W MINERALS 30","batch_no":"ABC123","expiry_date":"2029-03-31","ttl_qty_eaches":"438","Subcon_PONO":"","work_ord_status":"","attachment_list":"","remarks":"","vas_activities":"","others":"","client_ref_no":"","client_code":"0805","mode":"New"}',@user_id = 1    
 -- EXEC [SPP_Subcon_TXN_WORK_ORDER_CREATE] @submit_obj =N'{"urgent":0,"job_ref_no":"","commencement_date":"","completion_date":"","qty_of_goods":"438","num_of_days_to_complete":"","save":"Save","cancel":"Back","print":"Print","update":"Update","work_ord_ref":"BIO-LIFE M/100895659/ABC456/2022-01-31","client_name":"BIO-LIFE M","prd_code":"100895659","prd_desc":"MULTIVITAMINS W MINERALS 30","batch_no":"ABC456","expiry_date":"2022-01-31","ttl_qty_eaches":"438","Subcon_PONO":"","work_ord_status":"","attachment_list":"","remarks":"","vas_activities":"","others":"","client_ref_no":"","client_code":"0805","mode":"New"}',@user_id = 1   
CREATE PROCEDURE [dbo].[SPP_Subcon_TXN_WORK_ORDER_CREATE]         
 @submit_obj nvarchar(max),        
 @user_id VARCHAR(10)        
AS        
BEGIN        
 SET NOCOUNT ON;        
        
    DECLARE @work_ord_ref VARCHAR(50), @Subcon_WI_No VARCHAR(50), @client_code VARCHAR(50), @prd_code VARCHAR(50), @batch_no VARCHAR(50),         
 @item_no VARCHAR(50),@subcon_doc VARCHAR(100), @ttl_qty_eaches INT, @arrival_date VARCHAR(50), @Subcon_PONO VARCHAR(50),         
 @urgent VARCHAR(10), @commencement_date VARCHAR(50), @completion_date VARCHAR(50), @qty_of_goods INT, @num_of_days_to_complete INT,         
 @others NVARCHAR(250), @mode VARCHAR(50), @job_ref_no VARCHAR(50)        
        
 SET @work_ord_ref = (SELECT JSON_VALUE(@submit_obj, '$.work_ord_ref'))        
 SET @client_code = (SELECT JSON_VALUE(@submit_obj, '$.client_code'))        
 SET @Subcon_WI_No = (SELECT JSON_VALUE(@submit_obj, '$.Subcon_WI_No'))        
 SET @prd_code = (SELECT JSON_VALUE(@submit_obj, '$.prd_code'))        
 SET @batch_no = (SELECT JSON_VALUE(@submit_obj, '$.batch_no'))        
 SET @item_no = (SELECT JSON_VALUE(@submit_obj, '$.item_no'))    
 SET @subcon_doc = (SELECT JSON_VALUE(@submit_obj, '$.subcon_doc'))       
 SET @arrival_date = (SELECT JSON_VALUE(@submit_obj, '$.arrival_date'))        
 SET @ttl_qty_eaches = (SELECT JSON_VALUE(@submit_obj, '$.ttl_qty_eaches'))        
 SET @Subcon_PONO = (SELECT JSON_VALUE(@submit_obj, '$.subcon_PO_no'))        
 SET @urgent = (SELECT JSON_VALUE(@submit_obj, '$.urgent'))        
 SET @commencement_date = (SELECT JSON_VALUE(@submit_obj, '$.commencement_date'))        
 SET @completion_date = (SELECT JSON_VALUE(@submit_obj, '$.completion_date'))        
 SET @qty_of_goods = (SELECT JSON_VALUE(@submit_obj, '$.qty_of_goods'))        
 SET @num_of_days_to_complete = (SELECT JSON_VALUE(@submit_obj, '$.num_of_days_to_complete'))        
 SET @others = (SELECT JSON_VALUE(@submit_obj, '$.others'))        
 SET @mode = (SELECT JSON_VALUE(@submit_obj, '$.mode'))        
 SET @job_ref_no = (SELECT JSON_VALUE(@submit_obj, '$.job_ref_no'))        
        
 IF @commencement_date = '' SET @commencement_date = NULL        
 IF @completion_date = '' SET @completion_date = NULL
 IF @arrival_date = '' SET @arrival_date = NULL
        
 EXEC REPLACE_SPECIAL_CHARACTER @others, @others OUTPUT        
        
 DECLARE @qty_to_use INT        
 IF (@qty_of_goods <> 0) SET @qty_to_use = @qty_of_goods        
 ELSE SET @qty_to_use = @ttl_qty_eaches        
        
 IF (@mode = 'New')        
 BEGIN        
  DECLARE @new_job_ref_no VARCHAR(50) = 1, @len INT = 4, @to_no VARCHAR(50)
      
  SELECT TOP 1 @new_job_ref_no = CAST(CAST(RIGHT(job_ref_no, @len) as INT) + 1 AS VARCHAR(50))        
         FROM (SELECT job_ref_no FROM TBL_Subcon_TXN_WORK_ORDER WHERE SUBSTRING(job_ref_no, 2, @len) = CAST(YEAR(GETDATE()) as VARCHAR(50))       
   AND SUBSTRING(job_ref_no, 7, 2) = CAST(FORMAT(GETDATE(),'MM') as VARCHAR(50))) A ORDER BY CAST(RIGHT(job_ref_no, @len) AS INT) DESC       
         
  SET @new_job_ref_no = (SELECT 'S' + CAST(YEAR(GETDATE()) as VARCHAR(50)) + '/' + CAST(FORMAT(GETDATE(),'MM') as VARCHAR(50)) + '/' + REPLICATE('0', @len - LEN(@new_job_ref_no)) + @new_job_ref_no)        
  SET @to_no = (SELECT top 1 to_no FROM VAS_INTEGRATION.dbo.VAS_Subcon_TRANSFER_ORDER WITH(NOLOCK) WHERE SWI_No = @Subcon_WI_No AND prd_code = @prd_code AND batch_no = @batch_no and subcon_doc = @subcon_doc) -- AND item_no = @item_no)        
 -- SET @inbound_doc = (SELECT TOP 1 inbound_doc FROM VAS_INTEGRATION.dbo.VAS_Subcon_TRANSFER_ORDER WITH(NOLOCK) WHERE SWI_No = @Subcon_WI_No AND prd_code = @prd_code AND batch_no = @batch_no ) --AND item_no = @item_no)        
        
  IF (SELECT COUNT(*) FROM TBL_Subcon_TXN_WORK_ORDER WITH(NOLOCK) WHERE work_ord_ref = @work_ord_ref AND prd_code = @prd_code AND Subcon_WI_No = @Subcon_WI_No AND to_no = @to_no and subcon_po_no = @Subcon_PONO) = 0 -- AND item_no = @item_no) = 0        
  BEGIN      
  print('insert')    
   INSERT INTO TBL_Subcon_TXN_WORK_ORDER        
   (work_ord_ref, work_ord_status, job_ref_no, subcon_PO_no, client_code, prd_code,          
    subcon_WI_no,batch_no, to_no, whs_no,   plant,         
   --ssto_unit_no, dsto_unit_no, dsto_section, dsto_stg_bin, item_no, sloc, uom,         
       sloc, uom,expiry_date,         
     ttl_qty_eaches, arrival_date, urgent, commencement_date, completion_date, qty_of_goods, num_of_days_to_complete,         
    creator_user_id, created_date, others, current_event)        
   SELECT DISTINCT @work_ord_ref, 'IP', @new_job_ref_no, @Subcon_PONO, @client_code, @prd_code,         
    @Subcon_WI_No,@batch_no, to_no, whs_no,   plant,        
   --ssto_unit_no, dsto_unit_no, dsto_section, dsto_stg_bin, @item_no, sloc, uom,        
       sloc, uom, expiry_date,    
    @ttl_qty_eaches, @arrival_date, @urgent, @commencement_date, @completion_date, @qty_of_goods,         
   @num_of_days_to_complete, @user_id, GETDATE(), @others, '00'        
   FROM VAS_INTEGRATION.dbo.VAS_Subcon_TRANSFER_ORDER WITH(NOLOCK)         
   WHERE SWI_No = @Subcon_WI_No AND prd_code = @prd_code  AND batch_no = @batch_no and to_no = @to_no and subcon_doc = @subcon_doc--AND item_no = @item_no        
     
   UPDATE VAS_INTEGRATION.dbo.VAS_SubCon_TRANSFER_ORDER        
   SET Subcon_Job_No = @new_job_ref_no        
   WHERE subcon_doc=@subcon_doc and SWI_No = @Subcon_WI_No AND prd_code = @prd_code  --AND item_no = @item_no        
        
   DECLARE @running_no VARCHAR(50) = 1, @length INT = 8        
   SELECT TOP 1 @running_no = CAST(CAST(RIGHT(running_no, @length) as INT) + 1 AS VARCHAR(50))        
          FROM (SELECT running_no FROM TBL_TXN_JOB_EVENT) A ORDER BY CAST(RIGHT(running_no, @length) AS INT) DESC        
   SET @running_no = 'MY' + REPLICATE('0', @length - LEN(@running_no)) + @running_no        
           
   INSERT INTO TBL_TXN_JOB_EVENT        
   (running_no, job_ref_no, event_id, start_date, issued_qty, created_date, creator_user_id)        
   VALUES        
   (@running_no, @new_job_ref_no, '00', GETDATE(), @qty_to_use, GETDATE(), @user_id)     
   
   INSERT INTO TBL_ADM_AUDIT_TRAIL        
  (module, key_code, action, action_by, action_date)        
  SELECT 'Subcon_WORK_ORDER', @new_job_ref_no, 'Created', @user_id, GETDATE()   
        
   SELECT @new_job_ref_no as job_ref_no        
  END        
  ELSE        
  SELECT '' as job_ref_no        
 END         ELSE IF (@mode = 'Edit')        
 BEGIN        
  UPDATE TBL_Subcon_TXN_WORK_ORDER        
  SET others = @others,        
   urgent = @urgent,        
   commencement_date = @commencement_date,        
   completion_date = @completion_date,        
   qty_of_goods = @qty_of_goods,        
   num_of_days_to_complete = @num_of_days_to_complete,        
   changed_date = GETDATE(),        
   changed_user_id = @user_id        
  WHERE job_ref_no = @job_ref_no        
        
  INSERT INTO TBL_ADM_AUDIT_TRAIL        
  (module, key_code, action, action_by, action_date)        
  SELECT 'Subcon_WORK_ORDER', @job_ref_no, 'Updated', @user_id, GETDATE()        
        
  SELECT job_ref_no FROM TBL_Subcon_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no        
 END        
END   
  
GO
