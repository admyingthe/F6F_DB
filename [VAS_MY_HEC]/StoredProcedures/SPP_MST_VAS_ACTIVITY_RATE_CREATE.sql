SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		CHOI CHEE KIEN
-- Create date: 10-03-2023
-- Description:	CREATE VAS ACTIVITY RATE
-- =============================================
CREATE PROCEDURE [dbo].[SPP_MST_VAS_ACTIVITY_RATE_CREATE] 
	@param nvarchar(max),
	@effective_start_date nvarchar(20), 
	@effective_end_date nvarchar(20) = '2999-12-31', 
	@user_id varchar(100)
AS
BEGIN
	DECLARE @vas_activity_rate_code nvarchar(max)
	DECLARE @new_id TABLE (id INT)
	DECLARE @new_audit_trail_id TABLE (id INT)
	DECLARE @new_dtl_id TABLE (id INT)
	EXEC SPP_MST_GENERATE_RUNNING_NUMBER 'VAS_ACTIVITY_RATE', @vas_activity_rate_code OUTPUT

	INSERT INTO TBL_MST_VAS_ACTIVITY_RATE_HDR(vas_activity_rate_code, effective_start_date, effective_end_date, created_date, Changed_Date, Creator_User_Id, Changed_User_Id) 
	OUTPUT inserted.id INTO @new_id
	VALUES(@vas_activity_rate_code, @effective_start_date, @effective_end_date, GETDATE(), GETDATE(), @user_id, @user_id)

	INSERT INTO TBL_MST_VAS_ACTIVITY_RATE_DTL(VAS_ACTIVITY_RATE_HDR_ID, VAS_ACTIVITY_ID, NORMAL_RATE, OT_RATE, CREATED_DATE, CHANGED_DATE, CREATOR_USER_ID, CHANGED_USER_ID)
	OUTPUT INSERTED.ID INTO @new_dtl_id
	SELECT (SELECT TOP 1 * FROM @new_id), vas_activity_id,
	CASE WHEN ISNUMERIC(normal_rate) = 1 THEN CONVERT(decimal(18,2), normal_rate) ELSE 0 END AS normal_rate,
	CASE WHEN ISNUMERIC(ot_rate) = 1 THEN CONVERT(decimal(18,2), ot_rate) ELSE 0 END AS ot_rate,
	GETDATE(), GETDATE(), @user_id, @user_id
	FROM OpenJson(@param)
	WITH (  vas_activity_id int,
			normal_rate nvarchar(max),
			ot_rate nvarchar(max)
		 ) as vas_activity_rate;

	UPDATE A WITH (ROWLOCK , READPAST)
	SET A.Effective_End_Date = DATEADD(DAY, -1, @effective_start_date)
	FROM TBL_MST_VAS_ACTIVITY_RATE_HDR A
	WHERE Effective_End_Date IS NULL OR Effective_End_Date >= @effective_start_date
	AND A.ID != (SELECT TOP 1 * FROM @new_id)

	INSERT INTO TBL_ADM_AUDIT_TRAIL
	(module, key_code, action, action_by, action_date)
	OUTPUT INSERTED.ID INTO @new_audit_trail_id 
	SELECT 'VAS-Activity-Rate', @vas_activity_rate_code, 'Created VAS Activity Rate', @user_id, CONVERT(datetime, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+07:00'))

	SELECT dtl.* INTO #TempDtl
	FROM TBL_MST_VAS_ACTIVITY_RATE_DTL dtl WITH (NOLOCK)
	JOIN @new_dtl_id id ON dtl.Id = id.Id

	INSERT INTO TBL_ADM_AUDIT_TRAIL_DTL
	(audit_trail_id, ref_table, ref_id, ref_column, original_value, changed_value)
	SELECT (SELECT TOP 1 * FROM @new_audit_trail_id), 'TBL_MST_VAS_ACTIVITY_RATE_DTL', dtl.ID, 'NORMAL_RATE', NULL, Normal_Rate
	FROM #TempDtl dtl WITH (NOLOCK)
	UNION ALL
	SELECT (SELECT TOP 1 * FROM @new_audit_trail_id), 'TBL_MST_VAS_ACTIVITY_RATE_DTL', dtl.ID, 'OT_RATE', NULL, OT_Rate
	FROM #TempDtl dtl WITH (NOLOCK)

END

GO
