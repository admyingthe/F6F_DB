SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Check whether stock is moved to VAS area
-- Example Query: exec SPP_TXN_GET_CONFIRM_STOCK_EVENT @job_ref_no=N'2018/06/0029'
-- ==============================================================================

CREATE PROCEDURE [dbo].[SPP_TXN_GET_CONFIRM_STOCK_EVENT]
	@job_ref_no VARCHAR(50)
AS
BEGIN
SET NOCOUNT ON;

DECLARE @found_ind VARCHAR(10)

IF(LEFT(@job_ref_no,1) = 'S')
begin

if (SELECT COUNT(*) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND event_id in (80, 85)) > 0
begin

SET @found_ind = 'NA'

end
else
begin

IF (SELECT COUNT(*) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND event_id = '25') > 0
	SET @found_ind = 'True'
ELSE
	SET @found_ind = 'False'
end

end
else
begin

IF (SELECT COUNT(*) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE job_ref_no = @job_ref_no AND event_id = '25') > 0
	SET @found_ind = 'True'
ELSE
	SET @found_ind = 'False'
end

SELECT @found_ind as found_ind
END
GO
