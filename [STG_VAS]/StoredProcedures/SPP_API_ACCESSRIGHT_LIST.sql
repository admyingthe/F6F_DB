/****** Object:  StoredProcedure [dbo].[SPP_API_ACCESSRIGHT_LIST]    Script Date: 08-Aug-23 8:46:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  CHOI CHEE KIEN  
-- Create date: 28-06-2023  
-- Description: GET ACCESS RIGHT FOR IGA API  
-- =============================================  
CREATE PROCEDURE SPP_API_ACCESSRIGHT_LIST   
 @accessright_name AS VARCHAR(200) = NULL,  
 @page_number AS INT = NULL,  
 @page_size AS INT = NULL  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
 DECLARE @sql AS VARCHAR(MAX)  
  
    SET @sql = 'SELECT A.accessright_id, A.accessright_name, C.country_code, C.country_name, B.principal_code, B.principal_name, A.status 
FROM TBL_ADM_ACCESSRIGHT A WITH (NOLOCK)
JOIN TBL_ADM_PRINCIPAL B WITH (NOLOCK) ON A.principal_id = B.principal_id
JOIN TBL_ADM_COUNTRY C WITH (NOLOCK) ON B.country_id = C.country_id
WHERE A.status = ''A'''+ 
CASE WHEN @accessright_name IS NOT NULL AND @accessright_name <> '' THEN 'AND accessright_name LIKE ''%' + @accessright_name + '%'''   
 ELSE '' END   
 +  
 'ORDER BY accessright_name'  
 +  
 CASE WHEN @page_number IS NULL AND @page_size IS NULL THEN ''  
 ELSE ' OFFSET ' + CAST(ISNULL(@page_size, 50) * (ISNULL(@page_number, 1) - 1) AS VARCHAR(200)) + ' ROWS' +  
 ' FETCH NEXT ' + CAST(ISNULL(@page_size, 50) AS VARCHAR(200)) + ' ROWS ONLY'  
 END  
  
 EXEC(@sql)  
END  
GO
