SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec SPP_ADM_USER_PWD_UPDATE @user_id=N'1',@old_pwd=N'P+jUwjxdIhc=',@new_pwd=N'yd7xBy57yBJJHpiyxoU2sQ=='

CREATE PROCEDURE [dbo].[SPP_ADM_USER_PWD_UPDATE]
	@user_id	INTEGER,
	@old_pwd	NVARCHAR(100),
	@new_pwd	NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	IF (SELECT COUNT(1) FROM TBL_ADM_PWD_HIST WITH(NOLOCK) WHERE user_id = @user_id AND password = @new_pwd) > 0
	BEGIN
		SELECT 4 as ind
	END
	ELSE
	BEGIN
		DECLARE @num_of_pwd INT
		SET @num_of_pwd = (SELECT ISNULL(COUNT(1),0) FROM TBL_ADM_PWD_HIST WITH(NOLOCK) WHERE user_id = @user_id)

		IF @num_of_pwd > 8
		BEGIN
			SELECT TOP 8 * INTO #TEMP_EIGHT FROM TBL_ADM_PWD_HIST WITH(NOLOCK) WHERE user_id = @user_id ORDER BY created_date DESC
			
			DELETE FROM TBL_ADM_PWD_HIST
			WHERE NOT EXISTS( SELECT 1 FROM #TEMP_EIGHT Where TBL_ADM_PWD_HIST.user_id = #TEMP_EIGHT.user_id AND TBL_ADM_PWD_HIST.password = #TEMP_EIGHT.password)

			DROP TABLE #TEMP_EIGHT
		END

		INSERT INTO TBL_ADM_PWD_HIST
		(user_id, password, created_date)
		VALUES(@user_id, @new_pwd, GETDATE())

		UPDATE A
		SET password = @new_pwd, pwd_changed_date = GETDATE(), first_login = 0, login_cnt = 0
		FROM TBL_ADM_USER A WITH(NOLOCK)
		WHERE user_id = @user_id

		SELECT 5 as ind
	END

	--UPDATE A
	--SET password = @new_pwd, pwd_changed_date = GETDATE(), first_login = 0
	--FROM TBL_ADM_USER A WITH(NOLOCK)
	--WHERE user_id = @user_id

	--SELECT 1 as ind
END
GO
