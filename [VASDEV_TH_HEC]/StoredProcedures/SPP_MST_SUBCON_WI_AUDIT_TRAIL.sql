SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_MST_SUBCON_WI_AUDIT_TRAIL]
	@subcon_no VARCHAR(50),
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
		('SUBCON', @subcon_no, 'Uploaded file(s) [' + @prd_list + ']' + @file_list, @user_id, GETDATE())
	END
	ELSE IF(@action_ind = 'D')
	BEGIN
		INSERT INTO TBL_ADM_AUDIT_TRAIL
		(module, key_code, action, action_by, action_date)
		VALUES
		('SUBCON', @subcon_no, 'Deleted file(s) [' + @prd_list + ']' + @file_list, @user_id, GETDATE())
	END
END

GO
