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
	@wo_type varchar(50),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	IF (@wo_type = 'Redressing')
	BEGIN
		UPDATE TBL_INVOICE_TXN_WORK_ORDER
		SET barcode_html = @barcode_html
		WHERE job_ref_no = @job_ref_no
	END
	ELSE IF (@wo_type = 'SIA')
	BEGIN
		UPDATE TBL_TXN_WORK_ORDER
		SET barcode_html = @barcode_html
		WHERE job_ref_no = @job_ref_no
	END
	ELSE IF (@wo_type = 'Invoice')
	BEGIN
		UPDATE TBL_SIA_TXN_WORK_ORDER
		SET barcode_html = @barcode_html
		WHERE job_ref_no = @job_ref_no
	END
END

GO
