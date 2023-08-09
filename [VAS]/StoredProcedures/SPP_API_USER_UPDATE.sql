SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CHOI CHEE KIEN
-- Create date: 12-07-2023
-- Description:	UPDATE USER ACCOUNT FROM API
-- =============================================
CREATE PROCEDURE [dbo].[SPP_API_USER_UPDATE]
	@login			VARCHAR(100),
	@country_id		VARCHAR(10) = NULL,
	@principal_id	VARCHAR(10) = NULL,
	@user_type_id	VARCHAR(10) = NULL,
	@department_code VARCHAR(10) = NULL,
	@user_name		NVARCHAR(250) = NULL,
	@email			NVARCHAR(100) = NULL,
	@wh_Code			NVARCHAR(50) = NULL,
	@pwd_expiry		INTEGER = NULL,
	@pwd_expiry_rmd	INTEGER = NULL,
	@max_retry		INTEGER = NULL,
	@status			CHAR(1) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION
			
			IF EXISTS (SELECT 1 FROM TBL_ADM_USER WITH (NOLOCK) WHERE login = @login)
			BEGIN
				UPDATE TBL_ADM_USER
				SET country_id = ISNULL(@country_id, country_id),
					principal_id = ISNULL(@principal_id, principal_id),
					user_type_id = ISNULL(@user_type_id, user_type_id),
					department = ISNULL(@department_code, department),
					user_name = ISNULL(@user_name, user_name),
					email = ISNULL(@email, email),
					pwd_expiry = ISNULL(@pwd_expiry, pwd_expiry),
					pwd_expiry_rmd = ISNULL(@pwd_expiry_rmd, pwd_expiry_rmd),
					max_retry = ISNULL(@max_retry, max_retry),
					status = ISNULL(@status, status),
					wh_code = ISNULL(@wh_Code, wh_code)
				WHERE login = @login
				SELECT 1 'IsSuccess', 'Account updated successfully' AS 'Message'
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
