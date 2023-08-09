SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		YING
-- Create date: 06-07-2023
-- Description:	Approve VAS Activity Rate
-- =============================================
CREATE PROCEDURE [dbo].[SPP_MST_VAS_ACTIVITY_RATE_APPROVE_REJECT]
	@param nvarchar(max),  
	@user_id INT  
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @new_audit_trail_id TABLE (id INT)
	DECLARE @vas_activity_rate_code nvarchar(max) = (SELECT JSON_VALUE(@param, '$.vas_activity_rate_code'))
	DECLARE @action nvarchar(max) = (SELECT JSON_VALUE(@param, '$.action'))

	IF (@action in ('A', 'R'))
	BEGIN
		UPDATE TBL_MST_VAS_ACTIVITY_RATE_HDR SET status = @action, approver_user_ID = @user_id, approval_datetime = getdate() where VAS_Activity_Rate_Code = @vas_activity_rate_code
	END

	INSERT INTO TBL_ADM_AUDIT_TRAIL
	(module, key_code, action, action_by, action_date)
	--OUTPUT INSERTED.ID INTO @new_audit_trail_id 
	SELECT 'VAS-Activity-Rate', @vas_activity_rate_code, 'Approved VAS Activity Rate', @user_id, CONVERT(datetime, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+07:00'))

	--INSERT INTO TBL_ADM_AUDIT_TRAIL_DTL
	--(audit_trail_id, ref_table, ref_id, ref_column, original_value, changed_value)
	--SELECT (SELECT TOP 1 * FROM @new_audit_trail_id), REF_TABLE, ID, REF_COLUMN, Original_Value, Changed_Value
	--FROM #TempAuditTrailDtl
	
END

GO
