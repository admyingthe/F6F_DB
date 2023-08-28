SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
--exec SPP_MST_SUBCON_QA_UPDATE @param=N'{"subcon_no":"SUBCON009103RD00005","prd_code":"100002409"}',@user_id=N'1'  
CREATE PROCEDURE [dbo].[SPP_MST_SUBCON_QA_UPDATE]  
 @param NVARCHAR(2000),  
 @user_id INT  
AS  
BEGIN  
 SET NOCOUNT ON;  
  
 DECLARE @subcon_no VARCHAR(50), @prd_code VARCHAR(50), @qa_required INT  
 SET @subcon_no = (SELECT JSON_VALUE(@param, '$.subcon_no'))  
 SET @prd_code = (SELECT JSON_VALUE(@param, '$.prd_code'))  
 SET @qa_required = (SELECT CASE WHEN qa_required = 1 THEN 0 ELSE 1 END FROM TBL_MST_SUBCON_DTL WITH(NOLOCK) WHERE subcon_no = @subcon_no AND prd_code = @prd_code)  
  
 UPDATE TBL_MST_SUBCON_DTL  
 SET qa_required = @qa_required  
 WHERE subcon_no = @subcon_no AND prd_code = @prd_code  
  
 INSERT INTO TBL_ADM_AUDIT_TRAIL  
 (module, key_code, action, action_by, action_date)  
 SELECT 'SUBCON', @subcon_no, 'Updated QA Required to ' + CAST(@qa_required as VARCHAR(10)) + ' for ' + @prd_code, @user_id, GETDATE()  
END  
GO
