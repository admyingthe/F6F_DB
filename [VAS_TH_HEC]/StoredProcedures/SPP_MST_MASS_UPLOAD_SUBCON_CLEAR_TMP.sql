SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_MST_MASS_UPLOAD_SUBCON_CLEAR_TMP]
	@user_id	INT
AS
BEGIN
	SET NOCOUNT ON;

    DELETE FROM TBL_TMP_MASS_UPLOAD_SUBCON  WHERE user_id = @user_id

END
GO
