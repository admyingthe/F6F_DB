SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CHOI CHEE KIEN
-- Create date: 2023-07-12
-- Description:	CHANGE USER PASSWORD FROM API
-- =============================================
CREATE PROCEDURE [dbo].[SPP_API_CHANGE_PASSWORD]
	@login nvarchar(100) = '',
	@new_password nvarchar(100) = '',
	@confirm_password nvarchar(100) = ''
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION
			
			IF EXISTS (SELECT 1 FROM TBL_ADM_USER WITH (NOLOCK) WHERE login = @login)
			BEGIN
				IF(@confirm_password = @new_password)
				BEGIN
					UPDATE U
					SET U.password = @new_password
					FROM TBL_ADM_USER U
					WHERE U.login = @login
					SELECT 1 'IsSuccess', 'Changed password successfully' AS 'Message'
				END
				ELSE
				BEGIN
					SELECT 0 'IsSuccess', 'Confirm password does not matched' AS 'Message'
				END
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
