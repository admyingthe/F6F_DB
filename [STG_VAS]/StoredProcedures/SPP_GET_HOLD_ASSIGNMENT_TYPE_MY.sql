/****** Object:  StoredProcedure [dbo].[SPP_GET_HOLD_ASSIGNMENT_TYPE_MY]    Script Date: 08-Aug-23 8:25:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPP_GET_HOLD_ASSIGNMENT_TYPE_MY]  
AS  
BEGIN  
	SELECT TOP 1 [config],[config_value]
	FROM [dbo].[TBL_ADM_CONFIGURATION] WITH (NOLOCK)
	where config = 'MY_HEC_HOLD_ASSIGNMENT_VALUE'
END  
GO
