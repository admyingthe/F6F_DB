SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
-- =============================================================================================================      
-- Author:        
-- Create date:       
-- Description: Retrieve all the active Subcon for the selected Client and Product      
-- Example Query: exec [SPP_MST_GET_PRD_Subcon] @param=N'{"prd_code":"100814312","client_code":"0E43"}', @user_id = 1      
-- =============================================================================================================      
      
CREATE PROCEDURE [dbo].[SPP_MST_GET_PRD_Subcon]      
 @param nvarchar(max),      
 @user_id INT      
AS      
BEGIN      
 SET NOCOUNT ON;      
      
 DECLARE @client_code VARCHAR(50), @prd_code VARCHAR(50),@Subcon_SWI_No VARCHAR(100)      
 SET @client_code = (SELECT JSON_VALUE(@param, '$.client_code'))      
 SET @prd_code = (SELECT JSON_VALUE(@param, '$.prd_code'))  
 SET @Subcon_SWI_No = (SELECT JSON_VALUE(@param, '$.SWI_No'))  
      
 SELECT A.client_code, type_of_vas, sub, sub_name,  A.subcon_no as Subcon_WI_No, '' as start_date, '' as end_date, subcon_desc,
 expiry_date ,B.subcon_status
 FROM VAS_MY_HEC.dbo.TBL_MST_SUBCON_HDR A WITH(NOLOCK)      
 INNER JOIN VAS_MY_HEC.dbo.TBL_MST_SUBCON_DTL B WITH(NOLOCK) ON A.subcon_no = B.subcon_no      
 INNER JOIN TBL_MST_CLIENT_SUB C WITH(NOLOCK) ON A.sub = C.sub_code AND A.client_code = C.client_code      
 WHERE A.subcon_no = @Subcon_SWI_No AND A.client_code = @client_code AND prd_code = @prd_code --AND A.subcon_status != 'Delete'      --
       
      
END 
GO
