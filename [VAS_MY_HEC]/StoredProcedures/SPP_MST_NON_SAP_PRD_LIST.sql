SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPP_MST_NON_SAP_PRD_LIST]  
AS  
BEGIN  
 DECLARE @sql NVARCHAR(MAX) = 'SELECT [prd_code]  
  , [prd_desc]  
  , [princode]  
  , [old_mat_code]  
  , [base_uom]
  , [prd_type]
  , [tax_code]
  , [tax_rate]
  , [prdgrp4]
  , [reg_no]
  , [temp]
  , (CASE WHEN status = ''X'' THEN ''Inactive''
  ELSE ''Active'' END) AS status
 FROM [dbo].[TBL_MST_PRODUCT]  
 WITH (NOLOCK)
 WHERE [type] = ''NONSAP'''  
  
 SET @sql += ' SELECT COUNT(*) AS ttl_rows FROM [dbo].[TBL_MST_PRODUCT] WITH (NOLOCK) WHERE [type] = ''NONSAP'''  
 EXEC (@sql)  
END
GO
