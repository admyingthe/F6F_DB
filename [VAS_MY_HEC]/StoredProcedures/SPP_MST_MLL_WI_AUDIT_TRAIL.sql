SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec SPP_MST_MLL_WI_AUDIT_TRAIL @mll_no=N'MLL097900RD00003',@prd_list=N'120332677,120332678,120332679',@file_list=N'Desert.jpg,F 8.5.1-02-03 Reconciliation, Mock-Up, Line Clearance, Training & Final Inspection Checklist Rev 3 01 May 2017.pdf,MLL.xlsx',@user_id=N'1'
CREATE PROCEDURE SPP_MST_MLL_WI_AUDIT_TRAIL
	@mll_no VARCHAR(50),
	@prd_list VARCHAR(MAX),
	@file_list NVARCHAR(MAX),
	@action_ind CHAR(1),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	IF(@action_ind = 'I')
	BEGIN
		INSERT INTO TBL_ADM_AUDIT_TRAIL
		(module, key_code, action, action_by, action_date)
		VALUES
		('MLL', @mll_no, 'Uploaded file(s) [' + @prd_list + ']' + @file_list, @user_id, GETDATE())
	END
	ELSE IF(@action_ind = 'D')
	BEGIN
		INSERT INTO TBL_ADM_AUDIT_TRAIL
		(module, key_code, action, action_by, action_date)
		VALUES
		('MLL', @mll_no, 'Deleted file(s) [' + @prd_list + ']' + @file_list, @user_id, GETDATE())
	END
END

GO
