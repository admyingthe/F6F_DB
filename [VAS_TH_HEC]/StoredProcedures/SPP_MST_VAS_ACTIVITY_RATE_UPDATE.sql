SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CHOI CHEE KIEN
-- Create date: 13-03-2023
-- Description:	Update VAS Activity Rate
-- =============================================
CREATE PROCEDURE [dbo].[SPP_MST_VAS_ACTIVITY_RATE_UPDATE]
	@param nvarchar(max),  
	@user_id INT  
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @new_audit_trail_id TABLE (id INT)

	SELECT vas_activity_rate_dtl_id AS vas_activity_rate_dtl_id,
	CASE WHEN ISNUMERIC(normal_rate) = 1 THEN CONVERT(decimal(18,2), normal_rate) ELSE 0 END AS normal_rate,
	CASE WHEN ISNUMERIC(ot_rate) = 1 THEN CONVERT(decimal(18,2), ot_rate) ELSE 0 END AS ot_rate
	INTO #Temp
	FROM OpenJson(@param)
	WITH (  vas_activity_rate_dtl_id int,
			normal_rate nvarchar(max),
			ot_rate nvarchar(max)
		 ) as vas_activity_rate;

	SELECT ID, dtl.Normal_Rate AS Original_Value, 'TBL_MST_VAS_ACTIVITY_RATE_DTL' AS REF_TABLE, 'NORMAL_RATE' AS REF_COLUMN, t.normal_rate AS Changed_Value
	INTO #TempAuditTrailDtl
	FROM TBL_MST_VAS_ACTIVITY_RATE_DTL dtl WITH (NOLOCK)
	JOIN #Temp t ON dtl.ID = t.vas_activity_rate_dtl_id AND dtl.Normal_Rate != t.normal_rate

	INSERT INTO #TempAuditTrailDtl
	SELECT ID, dtl.Normal_Rate AS Original_Value, 'TBL_MST_VAS_ACTIVITY_RATE_DTL' AS REF_TABLE, 'OT_RATE' AS REF_COLUMN, t.ot_rate AS Changed_Value
	FROM TBL_MST_VAS_ACTIVITY_RATE_DTL dtl WITH (NOLOCK)
	JOIN #Temp t ON dtl.ID = t.vas_activity_rate_dtl_id AND dtl.OT_Rate != t.ot_rate



	UPDATE dtl WITH (ROWLOCK , READPAST)
	SET dtl.Normal_Rate = t.normal_rate, dtl.OT_Rate = t.ot_rate, dtl.Changed_Date = GetDate(), dtl.Changed_User_Id = @user_id
	FROM TBL_MST_VAS_ACTIVITY_RATE_DTL dtl 
	JOIN #Temp t ON dtl.ID = t.vas_activity_rate_dtl_id

	DECLARE @vas_activity_rate_code nvarchar(max)

	SELECT TOP 1 @vas_activity_rate_code = hdr.VAS_Activity_Rate_Code
	FROM TBL_MST_VAS_ACTIVITY_RATE_HDR hdr
	WHERE hdr.ID = (SELECT TOP 1 dtl.VAS_Activity_Rate_Hdr_Id FROM TBL_MST_VAS_ACTIVITY_RATE_DTL dtl
					WHERE dtl.ID = (SELECT TOP 1 t.vas_activity_rate_dtl_id FROM #Temp t))

	update TBL_MST_VAS_ACTIVITY_RATE_HDR set status = 'P' where VAS_Activity_Rate_Code = @vas_activity_rate_code

	INSERT INTO TBL_ADM_AUDIT_TRAIL
	(module, key_code, action, action_by, action_date)
	OUTPUT INSERTED.ID INTO @new_audit_trail_id 
	SELECT 'VAS-Activity-Rate', @vas_activity_rate_code, 'Updated VAS Activity Rate', @user_id, CONVERT(datetime, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+07:00'))

	INSERT INTO TBL_ADM_AUDIT_TRAIL_DTL
	(audit_trail_id, ref_table, ref_id, ref_column, original_value, changed_value)
	SELECT (SELECT TOP 1 * FROM @new_audit_trail_id), REF_TABLE, ID, REF_COLUMN, Original_Value, Changed_Value
	FROM #TempAuditTrailDtl
	
END

GO
