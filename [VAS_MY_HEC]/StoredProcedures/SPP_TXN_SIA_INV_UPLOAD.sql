SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
-- =====================================================  
-- Author:  Siow Shen Yee  
-- Create date: 2018-07-13  
-- Description: Insert uploaded MLL into table  
-- Example Query: exec SPP_MST_MASS_UPLOAD_MLL_UPLOAD '1'  
-- =====================================================  
  
CREATE PROCEDURE [dbo].[SPP_TXN_SIA_INV_UPLOAD]  
 @user_id INT  
AS  
BEGIN  
 SET NOCOUNT ON;  
   
 BEGIN TRY  
  SELECT *   
  INTO #TEMP_UPLOAD  
  FROM TBL_TMP_SIA_INV_UPLOAD_VALIDATED WITH(NOLOCK)  
  WHERE creator_user_id = @user_id AND (error_msg = '' OR error_msg IS NULL)
  
  INSERT INTO TBL_TXN_SIA_INV (type, vas_order, ref_doc_no, arrival_date, arrival_time, to_no, prd_code, batch_no, quantity, plant, client_code, uom, expiry_date, creator_user_id, created_date,
  changed_user_id, changed_date) 
  SELECT type, vas_order, ref_doc_no, arrival_date, arrival_time, to_no, prd_code, batch_no, quantity, plant, client_code, uom, expiry_date, creator_user_id, created_date, changed_user_id, changed_date
  FROM #TEMP_UPLOAD
  
  DECLARE @ttl_rows INT  
  SET @ttl_rows = (SELECT COUNT(1) FROM #TEMP_UPLOAD)  
                                                                                                              
  DROP TABLE #TEMP_MLL_NO  
  DROP TABLE #TEMP_UPLOAD  
  
  SELECT @ttl_rows AS ttl_rows  
  
 END TRY  
 BEGIN CATCH  
  SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_LINE() as ErrorLine, ERROR_MESSAGE() AS ErrorMessage;   
 END CATCH  
END

GO
