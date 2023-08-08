/****** Object:  StoredProcedure [dbo].[SPP_ADM_USER_UPDATE]    Script Date: 08-Aug-23 8:39:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_ADM_USER_UPDATE]
	@user_id		INTEGER,
	@login			VARCHAR(100),
	@password		NVARCHAR(100),
	@country_id		VARCHAR(10),
	@principal_id	VARCHAR(10),
	@user_type_id	VARCHAR(10),
	@department_code VARCHAR(10),
	@user_name		NVARCHAR(250),
	@email			NVARCHAR(100),
	@whCode			NVARCHAR(50),
	@pwd_expiry		INTEGER,
	@pwd_expiry_rmd	INTEGER,
	@max_retry		INTEGER,
	@status			CHAR(1)
	
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE TBL_ADM_USER
	SET password = @password,
		country_id = @country_id,
		principal_id = @principal_id,
		user_type_id = @user_type_id,
		department = @department_code,
		user_name = @user_name,
		email = @email,
		pwd_expiry = @pwd_expiry,
		pwd_expiry_rmd = @pwd_expiry_rmd,
		max_retry = @max_retry,
		status = @status,
		wh_code = @whCode
	WHERE login = @login
END
GO
