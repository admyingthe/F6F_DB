SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPP_GET_QI_TYPE_AUDIT_TRAIL]    
AS    
BEGIN    
 SELECT action, A.action_by, CONVERT(VARCHAR(19), action_date, 121) as action_date  
 FROM TBL_ADM_AUDIT_TRAIL A WITH(NOLOCK)  
 --INNER JOIN VASDEV.dbo.TBL_ADM_USER B WITH(NOLOCK) ON A.action_by = B.user_id  
 WHERE module = 'QI-TYPE'  
 ORDER BY action_date DESC    
END 
GO
