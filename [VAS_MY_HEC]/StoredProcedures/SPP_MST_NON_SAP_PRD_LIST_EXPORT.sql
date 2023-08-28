SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPP_MST_NON_SAP_PRD_LIST_EXPORT]    
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
    
 --SET @sql += ' SELECT COUNT(*) AS ttl_rows FROM [dbo].[TBL_MST_PRODUCT] WITH (NOLOCK) WHERE [type] = ''NONSAP'''    
 EXEC (@sql)    

 CREATE TABLE #PRD_TEMPNAME (page_dtl_id INT, input_name VARCHAR(50), display_name NVARCHAR(250)) 

 INSERT INTO #PRD_TEMPNAME (page_dtl_id, input_name, display_name) VALUES
	('1', 'prd_code', 'PRODUCT CODE'),
	('2', 'prd_desc', 'PRODUCT DESC'),
	('3', 'princode', 'PRINCODE'),
	('4', 'old_mat_code', 'OLD MAT CODE'),
	('5', 'base_uom', 'BASE UOM'),
	('6', 'product_type', 'PRODUCT TYPE'),
	('7', 'tax_code', 'TAX CODE'),
	('8', 'tax_rate', 'TAX RATE'),
	('9', 'prdgrp4', 'PRDGRP4'),
	('10', 'reg_no', 'REG NO'),
	('11', 'temp', 'TEMP'),
	('12', 'status', 'STATUS');

	SELECT * FROM #PRD_TEMPNAME

END
GO
