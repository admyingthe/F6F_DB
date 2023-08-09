SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CHOI CHEE KIEN
-- Create date: 2023-07-12
-- Description:	CHANGE USER PASSWORD FROM API
-- =============================================
CREATE PROCEDURE SPP_API_CHANGE_PASSWORD
	@LOGIN_ID nvarchar(100) = '',    
	@PASSWORD nvarchar(100) = '',
	@CONFIRM_PASSWORD nvarchar(100) = ''
AS
BEGIN
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE U
	SET U.password = @PASSWORD
	FROM TBL_ADM_USER U
	WHERE U.login = @LOGIN_ID

END

GO
