/****** Object:  StoredProcedure [dbo].[SPP_ADM_USER_DELETE]    Script Date: 08-Aug-23 8:46:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPP_ADM_USER_DELETE]
	@login	VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE TBL_ADM_USER
	SET status = 'D'
	WHERE login = @login
END

GO
