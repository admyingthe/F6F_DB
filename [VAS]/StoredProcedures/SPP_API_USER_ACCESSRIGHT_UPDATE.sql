SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CHOI CHEE KIEN
-- Create date: 2023-07-12
-- Description:	ASSIGN ACCESS RIGHT TO USER
-- =============================================
CREATE PROCEDURE [dbo].[SPP_API_USER_ACCESSRIGHT_UPDATE]
	@user_id			VARCHAR(MAX),
	@accessright_id		VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION
			
			IF EXISTS (SELECT 1 FROM TBL_ADM_USER WITH (NOLOCK) WHERE user_id = @user_id)
			BEGIN
			DELETE FROM TBL_ADM_USER_ACCESSRIGHT WHERE user_id = @user_id

			IF EXISTS (SELECT 1 FROM TBL_ADM_ACCESSRIGHT WITH (NOLOCK) WHERE accessright_id = @accessright_id)
			BEGIN
				INSERT INTO TBL_ADM_USER_ACCESSRIGHT
				(user_id, accessright_id, status)
				SELECT @user_id, @accessright_id, 'A'
				SELECT 1 'IsSuccess', 'Access right assigned successfully' AS 'Message'
			END
			ELSE
			BEGIN
				SELECT 0 'IsSuccess', 'Invalid access right id' AS 'Message'
			END

			END
			ELSE
			BEGIN
				SELECT 0 'IsSuccess', 'Invalid user id' AS 'Message'
			END

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT 0 'IsSuccess', ERROR_MESSAGE() AS 'Message'
	END CATCH

END

GO
