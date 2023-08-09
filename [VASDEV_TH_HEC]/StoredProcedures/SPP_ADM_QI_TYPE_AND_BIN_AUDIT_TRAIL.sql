SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPP_ADM_QI_TYPE_AND_BIN_AUDIT_TRAIL]  
@key_code VARCHAR(100),  
@action VARCHAR (250),  
@user_id INT  
AS  
BEGIN  
 INSERT INTO TBL_ADM_AUDIT_TRAIL    
 (module, key_code, [action], action_by, action_date)    
 VALUES('QI-TYPE', @key_code, @action, @user_id, GETDATE())   
END  
GO
