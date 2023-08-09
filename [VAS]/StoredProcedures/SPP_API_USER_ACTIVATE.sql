SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CHOI CHEE KIEN
-- Create date: 12-07-2023
-- Description:	ACTIVATE USER ACCOUNT FROM API
-- =============================================
CREATE PROCEDURE [dbo].[SPP_API_USER_ACTIVATE]
	@login VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION
			
			IF EXISTS (SELECT 1 FROM TBL_ADM_USER WITH (NOLOCK) WHERE login = @login)
			BEGIN
				UPDATE TBL_ADM_USER
				SET status = 'A'
				WHERE login = @login
				SELECT 1 'IsSuccess', 'Account activated successfully' AS 'Message'
			END
			ELSE
			BEGIN
				SELECT 0 'IsSuccess', 'Invalid Login ID' AS 'Message'
			END

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT 0 'IsSuccess', ERROR_MESSAGE() AS 'Message'
	END CATCH
END

GO
