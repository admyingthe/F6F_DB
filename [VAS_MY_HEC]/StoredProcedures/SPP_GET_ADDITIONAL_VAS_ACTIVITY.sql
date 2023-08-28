SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPP_GET_ADDITIONAL_VAS_ACTIVITY]
@job_ref_no nvarchar(20),
@activity_type nvarchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	--SELECT vas_activity, normal_rate, ot_rate FROM TBL_ADM_VENDOR_VERSION WITH(NOLOCK)
	--WHERE vendor_name = @selectedVendor
	--AND indicator = 'Additional'

	DECLARE @jobCreatedDate datetime

	select top 1 @jobCreatedDate = created_date from [TBL_TXN_WORK_ORDER] where job_ref_no = @job_ref_no

	SELECT A.id, A.description as vas_activity, B.Normal_Rate as normal_rate, B.OT_Rate as ot_rate FROM [TBL_MST_ACTIVITY_LISTING] A WITH (NOLOCK)  
	INNER JOIN [TBL_MST_VAS_ACTIVITY_RATE_DTL] B WITH (NOLOCK) ON A.ID = B.VAS_ACTIVITY_ID
	INNER JOIN [TBL_MST_VAS_ACTIVITY_RATE_HDR] C WITH(NOLOCK) ON B.VAS_ACTIVITY_RATE_HDR_ID = C.ID
	WHERE @jobCreatedDate BETWEEN C.Effective_Start_Date AND C.Effective_End_Date AND A.type = @activity_type and A.status = 1
END
GO
