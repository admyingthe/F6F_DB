SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<CHOI CHEE KIEN>
-- Create date: <20230302>
-- Description:	<VAS ACTIVITY RATE>
-- =============================================
-- exec [SPP_MST_VAS_ACTIVITY_RATE_LISTING] @param=N'{"vas_activity_rate_code":"020320230014","page_index":1,"page_size":20,"export_ind":0}', @user_id=N'8032'
-- exec [SPP_MST_VAS_ACTIVITY_RATE_LISTING] @param=N'{"vas_activity_rate_code":"140320230002","page_index":1,"page_size":20,"export_ind":0}', @user_id=N'8032'

CREATE PROCEDURE [dbo].[SPP_MST_VAS_ACTIVITY_RATE_LISTING]
	@param nvarchar(max),  
	@user_id INT  
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @vas_activity_rate_code VARCHAR(50), @page_index INT, @page_size INT, @export_ind CHAR(1)  
	SET @vas_activity_rate_code = (SELECT JSON_VALUE(@param, '$.vas_activity_rate_code'))  
	SET @page_index = (SELECT JSON_VALUE(@param, '$.page_index'))  
	SET @page_size = (SELECT JSON_VALUE(@param, '$.page_size'))
	SET @export_ind = (SELECT JSON_VALUE(@param, '$.export_ind'))

	SELECT vas.description AS 'vas_activity', dtl.Normal_Rate AS 'normal_rate', dtl.OT_Rate AS 'ot_rate', dtl.ID AS 'vas_activity_rate_dtl_id'
	INTO #TempVasActivityRate
	FROM TBL_MST_VAS_ACTIVITY_RATE_DTL dtl WITH(NOLOCK)
	JOIN TBL_MST_VAS_ACTIVITY_RATE_HDR hdr WITH(NOLOCK) ON dtl.VAS_Activity_Rate_HDR_ID = hdr.ID
	JOIN TBL_MST_ACTIVITY_LISTING vas WITH(NOLOCK) ON dtl.VAS_Activity_ID = vas.ID
	WHERE hdr.VAS_Activity_Rate_Code = @vas_activity_rate_code
	ORDER BY vas.type DESC

	SELECT COUNT(1) as ttl_rows FROM #TempVasActivityRate  --1
	
	SELECT * FROM #TempVasActivityRate --2

	SELECT @export_ind --3

	SELECT list_dtl_id, list_col_name as input_name, list_default_display_name as display_name  --4  
 FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_LISTING_DTL WITH(NOLOCK)  
 WHERE list_hdr_id IN (SELECT list_hdr_id FROM VAS.dbo.TBL_ADM_CONFIG_PAGE_LISTING_HDR WITH(NOLOCK) WHERE page_code = 'VAS-ACTIVITY-RATE-SEARCH'  
 ) AND list_col_name in (SELECT name FROM tempdb.sys.columns where object_id = object_id('tempdb..#TempVasActivityRate'))

 SELECT hdr.Effective_Start_Date AS 'effective_start_date', hdr.Effective_End_Date AS 'effective_end_date', 
 CASE hdr.status WHEN 'P' THEN 'Pending' WHEN 'A' THEN 'Approved' WHEN 'R' THEN 'Rejected' END AS 'status',
 CASE WHEN u.email IS NULL THEN '-' ELSE u.email END as 'approver_email', CASE WHEN hdr.approval_datetime is NULL then '-' ELSE Convert(VARCHAR(10), hdr.approval_datetime, 121) END as 'approval_datetime'
 FROM TBL_MST_VAS_ACTIVITY_RATE_HDR hdr
 LEFT JOIN VAS.DBO.TBL_ADM_USER u ON hdr.approver_user_ID = u.user_id
 WHERE hdr.VAS_Activity_Rate_Code = @vas_activity_rate_code

 SELECT key_code, [action], u.user_name AS action_by, FORMAT(action_date, 'yyyy-MM-dd HH:mm:ss') AS 'action_date'
 FROM TBL_ADM_AUDIT_TRAIL a WITH (NOLOCK)
 JOIN VAS.dbo.TBL_ADM_USER u WITH (NOLOCK) ON a.action_by = u.user_id
 WHERE key_code = @vas_activity_rate_code ORDER BY ACTION_DATE DESC

 DROP TABLE #TempVasActivityRate

END

GO
