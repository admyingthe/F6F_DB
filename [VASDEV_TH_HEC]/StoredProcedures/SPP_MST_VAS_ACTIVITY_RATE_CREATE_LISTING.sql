SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CHOI CHEE KIEN
-- Create date: 10-03-2023
-- Description:	GET VAS ACTIVITY LIST
-- =============================================
CREATE PROCEDURE [dbo].[SPP_MST_VAS_ACTIVITY_RATE_CREATE_LISTING] 
	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT A.id AS 'vas_activity_id', A.description AS 'vas_activity', 0 AS 'normal_rate', 0 AS 'ot_rate'
	FROM TBL_MST_ACTIVITY_LISTING A
	ORDER BY A.type DESC
END

GO
