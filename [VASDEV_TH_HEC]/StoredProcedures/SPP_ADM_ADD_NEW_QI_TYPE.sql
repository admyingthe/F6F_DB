SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPP_ADM_ADD_NEW_QI_TYPE]  
@qi_type VARCHAR(50),  
@qi_desc VARCHAR(150)  
AS  
BEGIN  
 DECLARE @total_row INT = 0  
 SET @total_row = (SELECT COUNT(*) FROM [dbo].[TBL_ADM_QI_TYPE] WHERE qi_type = @qi_type AND qi_desc = @qi_desc)  
  
 IF @total_row = 0  
 BEGIN  
  INSERT INTO [dbo].[TBL_ADM_QI_TYPE]
  (qi_type,qi_desc,status)
  VALUES (@qi_type, @qi_desc, 'Inactive')  
  
  SELECT id FROM [dbo].[TBL_ADM_QI_TYPE]   
  WHERE qi_type = @qi_type   
  AND qi_desc = @qi_desc
 END  
 ELSE  
 BEGIN  
  SELECT -1  
 END  
END
GO
