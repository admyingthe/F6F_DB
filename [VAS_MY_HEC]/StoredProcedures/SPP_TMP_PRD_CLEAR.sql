SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
CREATE PROCEDURE SPP_TMP_PRD_CLEAR    
 @user_id INT    
AS    
BEGIN    
 SET NOCOUNT ON;    
    
    DELETE FROM TBL_TMP_PRODUCT WHERE creator_user_id = @user_id    
    
END 
GO
