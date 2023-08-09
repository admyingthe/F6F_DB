SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		YING
-- Create date: 04-07-2023
-- Description:	GET RATE APPROVER LIST
-- =============================================

-- exec [SPP_MST_GET_RATE_APPROVER_CONFIG]

CREATE PROCEDURE [dbo].[SPP_MST_GET_RATE_APPROVER_CONFIG] 
	
AS
BEGIN

	select A.client_code, B.client_name,  A.recipients, A.copy_recipients from TBL_MST_RATE_APPROVER_CONFIGURATION A
	INNER JOIN TBL_MST_CLIENT B WITH(NOLOCK) ON A.client_code = B.client_code
    
	
	--SELECT
	--	t1.client_code,
	--	t3.client_name,
	--	t1.approver_user_ID,
	--	STUFF((
	--		SELECT ',' + t2.user_name
	--		FROM VAS.DBO.TBL_ADM_USER t2
	--		WHERE t2.user_id IN (
	--			SELECT value
	--			FROM STRING_SPLIT(t1.approver_user_ID, ',')
	--		)
	--		FOR XML PATH('')
	--	), 1, 1, '') AS approver_user_name,
	--	STUFF((
	--		SELECT ',' + t2.email
	--		FROM VAS.DBO.TBL_ADM_USER t2
	--		WHERE t2.user_id IN (
	--			SELECT value
	--			FROM STRING_SPLIT(t1.approver_user_ID, ',')
	--		)
	--		FOR XML PATH('')
	--	), 1, 1, '') AS recipients,
	--	t1.copy_recipients
	--FROM TBL_MST_RATE_APPROVER_CONFIGURATION t1
	--INNER JOIN TBL_MST_CLIENT t3 ON t3.client_code = t1.client_code
	--GROUP BY t1.approver_user_ID, t1.client_code, t3.client_name, t1.copy_recipients

END

GO
