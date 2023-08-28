SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Retrieve PPM material that have balance quantity
-- Example Query: exec SPP_TXN_GET_PPM_BALANCE @param=N'{"job_ref_no":"2018/07/0006"}'
-- ==================================================================================

CREATE PROCEDURE [dbo].[SPP_TXN_GET_PPM_BALANCE] 
	@param NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @job_ref_no VARCHAR(50)
	SET @job_ref_no = (SELECT JSON_VALUE(@param, '$.job_ref_no'))

	SELECT A.prd_code, B.prd_desc, (required_qty - issued_qty) as balance_qty, (required_qty - issued_qty) as required_qty 
	FROM TBL_TXN_PPM A WITH(NOLOCK)
	INNER JOIN TBL_MST_PRODUCT B WITH(NOLOCK) ON A.prd_code = B.prd_code
	WHERE job_ref_no = @job_ref_no AND (system_running_no IS NOT NULL OR system_running_no <> '') AND required_qty - issued_qty <> 0 
END

GO
