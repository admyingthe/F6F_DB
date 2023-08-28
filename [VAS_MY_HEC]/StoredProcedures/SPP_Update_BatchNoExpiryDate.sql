SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SPP_Update_BatchNoExpiryDate]     
@param nvarchar(MAX),      
@user_id bigint       
      
AS      
BEGIN      
      
DECLARE @subcon_doc NVARCHAR(50) = (SELECT JSON_VALUE(@param, '$.subcon_doc'))            
DECLARE @prd_code NVARCHAR(50) = (SELECT JSON_VALUE(@param, '$.prd_code'))        
DECLARE @subcon_item_no NVARCHAR(50) = (SELECT JSON_VALUE(@param, '$.subcon_item_no'))       
DECLARE @batch_no NVARCHAR(50) = (SELECT JSON_VALUE(@param, '$.batch_no'))       
DECLARE @expiry_date NVARCHAR(50) = (SELECT JSON_VALUE(@param, '$.expiry_date'))       
DECLARE @remark NVARCHAR(50) = (SELECT JSON_VALUE(@param, '$.remark'))       
DECLARE @prev_batch_no  NVARCHAR(50)
DECLARE @prev_expiry_date  NVARCHAR(50)
DECLARE @msg NVARCHAR(MAX)
DECLARE @subcon_job_no NVARCHAR(200)

Select TOP 1 * INTO #TMP_SUBCON_TO
from VAS_INTEGRATION.[dbo].[VAS_Subcon_TRANSFER_ORDER]
where subcon_doc in (@subcon_doc) AND prd_code in (@prd_code) AND subcon_item_no in (@subcon_item_no) 

SET @prev_batch_no=(SELECT batch_no FROM #TMP_SUBCON_TO)
SET @prev_expiry_date=(SELECT CONVERT(varchar,expiry_date,23) FROM #TMP_SUBCON_TO)
SET @subcon_job_no=(SELECT subcon_job_no FROM #TMP_SUBCON_TO)
DROP TABLE #TMP_SUBCON_TO

declare @work_ord_ref NVARCHAR(MAX), @new_work_ord_ref NVARCHAR(MAX) 

select @work_ord_ref = work_ord_ref from TBL_Subcon_TXN_WORK_ORDER where job_ref_no = @subcon_job_no

select			ROW_NUMBER() over(order by (select null)) AS srno,
				value 
into			#WORK_ORD_REF
FROM			STRING_SPLIT(@work_ord_ref, '/')

DECLARE @old_batch_no NVARCHAR(50)     
DECLARE @old_expiry_date NVARCHAR(50)

select	@old_batch_no = value
from	#WORK_ORD_REF
where	srno = 3
select	@old_expiry_date = value
from	#WORK_ORD_REF
where	srno = 4

set	@new_work_ord_ref = @work_ord_ref
set @new_work_ord_ref = REPLACE(@new_work_ord_ref,@old_expiry_date,@expiry_date)
set @new_work_ord_ref = REPLACE(@new_work_ord_ref,@old_batch_no,@batch_no)

drop table #WORK_ORD_REF

UPDATE VAS_INTEGRATION.[dbo].[VAS_Subcon_TRANSFER_ORDER]      
SET batch_no = RTRIM(LTRIM(@batch_no)) ,expiry_date =@expiry_date,remark=@remark      
WHERE subcon_doc in (@subcon_doc) AND prd_code in (@prd_code) AND subcon_item_no in (@subcon_item_no)      

UPDATE TBL_Subcon_TXN_WORK_ORDER 
SET batch_no = RTRIM(LTRIM(@batch_no)) ,expiry_date =@expiry_date, work_ord_ref = @new_work_ord_ref
WHERE job_ref_no=@subcon_job_no

update VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER_SAP
set workorder_no = @new_work_ord_ref
where workorder_no = @work_ord_ref

update VAS_INTEGRATION.dbo.VAS_SUBCON_INBOUND_ORDER
set Subcon_Job_No = @new_work_ord_ref
where job_ref_no = @subcon_job_no

IF (@prev_batch_no<>@batch_no and @prev_expiry_date<>@expiry_date)
BEGIN
SET @msg=', batch no changed from '+ RTRIM(LTRIM(@prev_batch_no))+' to '+RTRIM(LTRIM(@batch_no))+' and expiry date changed from '+ @prev_expiry_date+' to '+ @expiry_date 
END 
ELSE IF(@prev_batch_no<>@batch_no)
BEGIN
SET @msg=', batch no changed from '+ RTRIM(LTRIM(@prev_batch_no))+' to '+RTRIM(LTRIM(@batch_no))
END 
ELSE IF(@prev_expiry_date<>@expiry_date)
BEGIN
SET @msg=', expiry date changed from '+ @prev_expiry_date+' to '+ @expiry_date 
END 
ELSE
BEGIN
SET @msg=' No change in batch no/expiry date'
END 

      
INSERT INTO TBL_ADM_AUDIT_TRAIL              
  (module, key_code, action, action_by, action_date)              
  --SELECT 'Subcon Assignment List(Update BatchNo/ExpiryDate)', 'Subcon Assignment List',       
  --'Expiry Date/Batch No updated for Subcon doc- ' +@subcon_doc + ', prd_code- '+ @prd_code +', subcon item no- '+@subcon_item_no + ' with the remark- ' + @remark      
  --, @user_id, GETDATE() 
  SELECT 'Subcon Assignment List(Update BatchNo/ExpiryDate)', 'Subcon Assignment List',       
  @subcon_doc + ', '+ @prd_code +', '+@subcon_item_no + @msg
  , @user_id, GETDATE()   
      
END 
GO
