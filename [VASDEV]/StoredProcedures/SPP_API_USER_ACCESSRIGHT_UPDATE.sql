SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CHOI CHEE KIEN
-- Create date: 2023-07-12
-- Description:	ASSIGN ACCESS RIGHT TO USER
-- =============================================
CREATE PROCEDURE SPP_API_USER_ACCESSRIGHT_UPDATE
	@user_id			VARCHAR(MAX),
	@accessright_id		VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM TBL_ADM_USER_ACCESSRIGHT WHERE user_id = @user_id
	IF @accessright_id != '' AND @accessright_id IS NOT NULL
	BEGIN
		INSERT INTO TBL_ADM_USER_ACCESSRIGHT
		(user_id, accessright_id, status)
		SELECT @user_id, @accessright_id, 'A'
	END
END

GO
