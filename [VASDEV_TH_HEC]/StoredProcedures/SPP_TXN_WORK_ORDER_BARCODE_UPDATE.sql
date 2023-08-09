SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ========================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Insert barcode html to be use in email attachment
-- Example Query:
-- ========================================================================

CREATE PROCEDURE [dbo].[SPP_TXN_WORK_ORDER_BARCODE_UPDATE] 
	@job_ref_no varchar(50),
	@barcode_html varchar(max),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE TBL_TXN_WORK_ORDER_JOB_DET
	SET barcode_html = @barcode_html
	WHERE job_ref_no = @job_ref_no
END

GO
