SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPP_ADM_GET_QI_TYPE]  
AS  
BEGIN  
 DECLARE @sql NVARCHAR(MAX) = 'SELECT id    
  , [qi_type]  
  , [qi_desc]  
  , [status]  
 FROM [dbo].[TBL_ADM_QI_TYPE]  
 WITH (NOLOCK)  
 ORDER BY qi_type, qi_desc'  
  
 SET @sql += ' SELECT COUNT(*) AS ttl_rows FROM [dbo].[TBL_ADM_QI_TYPE]'  
 EXEC (@sql)  
END
GO
