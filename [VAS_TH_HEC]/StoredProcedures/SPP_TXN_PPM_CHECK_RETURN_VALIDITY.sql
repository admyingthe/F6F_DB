SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ========================================================================
-- Author:		Ying
-- Create date: 2023-05-08
-- Description: Check Return PPM Validity
-- Example Query: exec SPP_TXN_PPM_CHECK_RETURN_VALIDITY '{"job_ref_no":"G2022/09/00040","line_no":"1"}'

-- ========================================================================

CREATE PROCEDURE [dbo].[SPP_TXN_PPM_CHECK_RETURN_VALIDITY]
	@param NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	--declare @param nvarchar(max) = '{"job_ref_no":"G2022/09/00040","line_no":"5"}'

	DECLARE @job_ref_no VARCHAR(50), @line_no NVARCHAR(2000)
	SET @job_ref_no = (SELECT JSON_VALUE(@param, '$.job_ref_no'))
	SET @line_no = (SELECT JSON_VALUE(@param, '$.line_no'))

	IF exists (SELECT 1 FROM TBL_TXN_PPM P
		LEFT JOIN VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER_SAP S WITH(NOLOCK) ON P.system_running_no = S.requirement_no AND P.prd_code = S.prd_code AND P.job_ref_no = S.workorder_no AND S.country_code = 'TH' AND P.line_no = S.line_no 
		WHERE P.job_ref_no = @job_ref_no AND P.line_no = @line_no
		AND (P.action_from_reopen = 'Add' OR P.action_from_reopen IS NULL) AND P.system_running_no IS NOT NULL AND S.status = 'R'
	)
	BEGIN
		SELECT 1 as valid
	END
	ELSE
	BEGIN
		SELECT 0 as valid
	END

END

GO
