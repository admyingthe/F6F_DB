SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
-- ======================================================================================================================  
-- Author:  Siow Shen Yee  
-- Create date: 2018-07-13  
-- Description: Retrieve uploaded MLL data to be display on web before confirm uploading  
-- Example Query: exec SPP_MST_MASS_UPLOAD_MLL_LIST @param=N'{"page_index":0,"page_size":20,"export_ind":0}',@user_id=N'1'  
-- Output:  
-- 1) ttl_rows - Total rows  
-- 2) total_success_rows - Total success rows  
-- 3) total_error_rows - Total rows with errors  
-- 4) dt - Data  
-- 5) export_ind - Export Indicator  
-- ======================================================================================================================  
  
CREATE PROCEDURE [dbo].[SPP_TXN_SIA_INV_UPLOAD_LIST]  
 @param NVARCHAR(MAX),  
 @user_id INT  
AS  
BEGIN  
 SET NOCOUNT ON;  
  
 DECLARE @page_index INT, @page_size INT, @export_ind CHAR(1)  
 SET @page_index = (SELECT JSON_VALUE(@param, '$.page_index'))  
 SET @page_size = (SELECT JSON_VALUE(@param, '$.page_size'))  
 SET @export_ind = (SELECT JSON_VALUE(@param, '$.export_ind'))  
  
 SELECT COUNT(1) as ttl_rows FROM TBL_TMP_SIA_INV_UPLOAD_VALIDATED WITH(NOLOCK) WHERE creator_user_id = @user_id -- 1. Total rows  
 SELECT COUNT(1) as total_success_rows FROM TBL_TMP_SIA_INV_UPLOAD_VALIDATED WITH(NOLOCK) WHERE creator_user_id = @user_id AND error_msg = '' -- 2. Total success rows  
 SELECT COUNT(1) as total_error_rows FROM TBL_TMP_SIA_INV_UPLOAD_VALIDATED WITH(NOLOCK) WHERE creator_user_id = @user_id AND error_msg <> '' -- 3. Total error rows  
  
 IF (@export_ind = '0')  
 begin  
  SELECT  A.Type, A.Vas_Order AS 'VAS Order', A.Ref_Doc_No AS 'Ref Doc No', A.Arrival_Date AS 'Arrival Date', A.Arrival_Time AS 'Arrival Time', 
  A.to_no AS 'TO No', A.prd_code AS 'Product Code', A.batch_no AS 'Batch No', A.quantity AS Quantity, A.plant AS Plant, 
  A.client_code + CASE WHEN B.client_name IS NOT NULL OR B.client_name <> '' THEN ' - ' + B.client_name
  ELSE ''
  END as 'Client Code', 
  A.uom AS UOM, A.expiry_date AS 'Expiry Date', A.error_msg AS 'Error Message'
  INTO #UPLOADED_TEMP_ORIGINAL
  FROM TBL_TMP_SIA_INV_UPLOAD_VALIDATED A   
  LEFT JOIN TBL_MST_CLIENT B WITH(NOLOCK) ON A.client_code = B.client_code
  WHERE A.creator_user_id = @user_id  
  
  select *   
  into #UPLOADED_TEMP  
  from #UPLOADED_TEMP_ORIGINAL  
  ORDER BY LEN([Error Message]) DESC  
  OFFSET @page_index * @page_size ROWS  
  FETCH NEXT @page_size ROWS ONLY  
  
  SELECT * FROM #UPLOADED_TEMP

  end  
 ELSE IF (@export_ind = '1') 
 BEGIN
  SELECT  A.Type, A.Vas_Order AS 'VAS Order', A.Ref_Doc_No AS 'Ref Doc No', A.Arrival_Date AS 'Arrival Date', A.Arrival_Time AS 'Arrival Time', 
  A.to_no AS 'TO No', A.prd_code AS 'Product Code', A.batch_no AS 'Batch No', A.quantity AS 'Quantity', A.plant AS 'Plant', 
  A.client_code + ' - ' + B.client_name as 'Client Code', A.uom AS UOM, A.expiry_date AS 'Expiry Date', A.error_msg AS 'Error Message' 
  INTO #UPLOADED_TEMP_EXPORT
  FROM TBL_TMP_SIA_INV_UPLOAD_VALIDATED A   
  INNER JOIN TBL_MST_CLIENT B WITH(NOLOCK) ON A.client_code = B.client_code
  WHERE A.creator_user_id = @user_id  

  SELECT * FROM #UPLOADED_TEMP_EXPORT   
  
 END

  SELECT @export_ind AS export_ind -- 5. Export ind
  
END  
GO
