SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
-- ========================================================================    
-- Author:  Siow Shen Yee    
-- Create date: 2018-07-13    
-- Description: Check for valid job ref no    
-- Example Query: exec SPP_TXN_JOB_REF_NO_CHECK @job_ref_no=N'S2021/03/0011'    
-- ========================================================================    
    
CREATE PROCEDURE [dbo].[SPP_TXN_JOB_REF_NO_CHECK]    
 @job_ref_no VARCHAR(100)    
AS    
BEGIN    
 SET NOCOUNT ON;    
   
 IF(LEFT(@job_ref_no,1) ='S')  
 BEGIN  
  IF (SELECT COUNT(job_ref_no) FROM TBL_Subcon_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no) > 0    
   SELECT @job_ref_no as job_ref_no    
  ELSE    
   SELECT '' as job_ref_no  
  END  
  ELSE IF(LEFT(@job_ref_no,1) ='P')  
	BEGIN  
		IF (SELECT COUNT(job_ref_no) FROM TBL_SIA_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no) > 0    
		SELECT @job_ref_no as job_ref_no    
		ELSE    
		SELECT '' as job_ref_no  
	END  
  ELSE IF(LEFT(@job_ref_no,1) ='C')  
	BEGIN  
		IF (SELECT COUNT(job_ref_no) FROM TBL_INVOICE_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no) > 0    
		SELECT @job_ref_no as job_ref_no    
		ELSE    
		SELECT '' as job_ref_no  
	END  
  ELSE   
  BEGIN  
   IF (SELECT COUNT(job_ref_no) FROM TBL_TXN_WORK_ORDER WITH(NOLOCK) WHERE job_ref_no = @job_ref_no) > 0    
   SELECT @job_ref_no as job_ref_no    
  ELSE    
   SELECT '' as job_ref_no    
  END  
END 
GO
