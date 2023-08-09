SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CHOI CHEE KIEN
-- Create date: 12-07-2023
-- Description:	DEACTIVATE USER ACCOUNT FROM API
-- =============================================
CREATE PROCEDURE SPP_API_USER_DEACTIVATE
	@login VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

    UPDATE TBL_ADM_USER
	SET status = 'D'
	WHERE login = @login
END

GO
