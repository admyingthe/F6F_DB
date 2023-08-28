SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  CHOI CHEE KIEN  
-- Create date: 26-04-2023  
-- Description: PRODUCT UPLOAD TEMPLATE  
-- =============================================  
CREATE PROCEDURE [dbo].[SPP_PRD_UPLOAD_TEMPLATE]   
AS  
BEGIN  
 SET NOCOUNT ON;  
  
 CREATE TABLE #DISPLAY_TEMP(  
  [PRODUCT CODE] VARCHAR(300),  
  [PRODUCT DESC] VARCHAR(200),    
  [PRINCODE] VARCHAR(200),  
  [OLD MAT CODE] VARCHAR(200),  
  [BASE UOM] VARCHAR(200),  
  [PRODUCT TYPE] VARCHAR(200),  
  [TAX CODE] VARCHAR(50),  
  [TAX RATE] VARCHAR(100),  
  PRDGRP4 VARCHAR(200),   
  [REG NO] VARCHAR(100),
  TEMP VARCHAR(100)
 )  
  
 CREATE TABLE #COLUMN_NAME_TEMP(  
  prd_code VARCHAR(300),  
  prd_desc VARCHAR(200),    
  princode VARCHAR(200),  
  old_mat_code VARCHAR(200),  
  base_uom VARCHAR(200),  
  prd_type VARCHAR(200),  
  tax_code VARCHAR(50),  
  tax_rate VARCHAR(100),  
  prdgrp4  VARCHAR(200),   
  reg_no   VARCHAR(100),  
  temp	   VARCHAR(100),  
  status   VARCHAR(100),  
  updated_date VARCHAR(200),  
  type VARCHAR(200),
  creator_user_id VARCHAR(100)
 )  
  
 SELECT [PRODUCT CODE], [PRODUCT DESC], PRINCODE, [OLD MAT CODE], [BASE UOM], [PRODUCT TYPE], [TAX CODE], [TAX RATE], PRDGRP4, [REG NO], TEMP
 FROM #DISPLAY_TEMP  
  
 SELECT A.COLUMN_NAME, ISNULL(B.COLUMN_NAME, '') AS 'DISPLAY_NAME', 'TEXT' AS DATA_TYPE, '' AS OPTIONS, 1 AS MANDATORY, ROW_NUMBER() OVER(ORDER BY A.ORDINAL_POSITION) AS SEQ  
 INTO #COLUMN_DETAIL  
 FROM tempdb.INFORMATION_SCHEMA.COLUMNS A WITH (NOLOCK)  
 LEFT JOIN (SELECT COLUMN_NAME, ORDINAL_POSITION FROM tempdb.INFORMATION_SCHEMA.COLUMNS WITH (NOLOCK) WHERE TABLE_NAME LIKE '%#DISPLAY_TEMP%') B ON A.ORDINAL_POSITION = B.ORDINAL_POSITION  
 WHERE A.TABLE_NAME LIKE '%#COLUMN_NAME_TEMP%'  
  
 ALTER TABLE #COLUMN_DETAIL ALTER COLUMN DATA_TYPE VARCHAR(3000)  
 ALTER TABLE #COLUMN_DETAIL ALTER COLUMN OPTIONS VARCHAR(3000)  
  
 SELECT * FROM #COLUMN_DETAIL 
END  
GO
