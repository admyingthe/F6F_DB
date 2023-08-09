SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ========================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Delete manually added PPM product
-- Example Query: exec SPP_TXN_PPM_DELETE @delete_obj=N'{"job_ref_no":"2018/06/0029","line_no":3}',@user_id=1
-- ========================================================================

CREATE PROCEDURE [dbo].[SPP_TXN_PPM_DELETE]
	@delete_obj NVARCHAR(MAX),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @job_ref_no VARCHAR(50), @line_no INT
	SET @job_ref_no = (SELECT JSON_VALUE(@delete_obj, '$.job_ref_no'))
	SET @line_no = (SELECT JSON_VALUE(@delete_obj, '$.line_no'))

	DELETE FROM TBL_TXN_PPM WHERE job_ref_no = @job_ref_no AND line_no = @line_no AND manual_ppm = 1

	INSERT INTO TBL_ADM_AUDIT_TRAIL
	(module, key_code, action , action_by, action_date)
	VALUES('PPM-SEARCH', @job_ref_no, 'Deleted manual PPM material', @user_id, GETDATE())
END
GO
