SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-08-23
-- Description:	To keep track of MLL attachments (header and detail)
-- =====================================================================
CREATE PROCEDURE SPP_MST_MLL_ATTACHMENT
	@mll_no VARCHAR(50),
	@action NVARCHAR(500),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO TBL_ADM_AUDIT_TRAIL
	(module, key_code, action, action_by, action_date)
	VALUES('MLL', @mll_no, @action, @user_id, GETDATE())
END

GO
