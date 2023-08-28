SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================================  
-- Author:  Vijitha  
-- Create date: 2021-10-26  
-- Description: To keep track of SUBCON attachments (header and detail)  
-- =====================================================================  
CREATE PROCEDURE [dbo].[SPP_MST_SUBCON_ATTACHMENT]  
 @subcon_no VARCHAR(50),  
 @action NVARCHAR(500),  
 @user_id INT  
AS  
BEGIN  
 SET NOCOUNT ON;  
  
 INSERT INTO TBL_ADM_AUDIT_TRAIL  
 (module, key_code, action, action_by, action_date)  
 VALUES('SUBCON', @subcon_no, @action, @user_id, GETDATE())  
END  
GO
