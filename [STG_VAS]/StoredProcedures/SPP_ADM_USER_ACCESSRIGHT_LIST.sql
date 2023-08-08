/****** Object:  StoredProcedure [dbo].[SPP_ADM_USER_ACCESSRIGHT_LIST]    Script Date: 08-Aug-23 8:25:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPP_ADM_USER_ACCESSRIGHT_LIST] --'4'
	@user_id	VARCHAR(10)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TEMP(
		accessright_id		INTEGER,
		accessright_name	NVARCHAR(100),
		is_checked			INTEGER
	)
	
	DECLARE @ar_id INTEGER, @login NVARCHAR(50), @user_type INTEGER
	SET @ar_id = (SELECT TOP 1 accessright_id FROM TBL_ADM_USER_ACCESSRIGHT WITH(NOLOCK) WHERE user_id = @user_id)
	SET @login = (SELECT login FROM TBL_ADM_USER WITH(NOLOCK) WHERE user_id = @user_id)
	SET @user_type = (SELECT user_type_id FROM TBL_ADM_USER WITH(NOLOCK) WHERE user_id = @user_id)

	--Added for country check 
	DECLARE @countryid INTEGER
	SET @countryid = (SELECT country_id FROM TBL_ADM_USER WITH(NOLOCK) WHERE user_id = @user_id)
	--Added for country check 


	IF(@ar_id = '1' OR @login LIKE '%bsadmin%' OR @user_type = '1')
	BEGIN
		INSERT INTO #TEMP
		SELECT accessright_id, accessright_name, 0
		FROM TBL_ADM_ACCESSRIGHT A WITH(NOLOCK)
		INNER JOIN [dbo].[TBL_ADM_PRINCIPAL] P WITH(NOLOCK) ON A.principal_id=P.principal_id
		WHERE A.status = 'A'  AND P.country_id=@countryid
	END
	ELSE
	BEGIN
		INSERT INTO #TEMP
		SELECT accessright_id, accessright_name, 0
		FROM TBL_ADM_ACCESSRIGHT A WITH(NOLOCK)
		INNER JOIN [dbo].[TBL_ADM_PRINCIPAL] P WITH(NOLOCK) ON A.principal_id=P.principal_id
		WHERE A.accessright_id <> '1' AND A.status = 'A' AND P.country_id=@countryid
	END
	
	UPDATE A
	SET is_checked = '1'
	FROM #TEMP A
	WHERE EXISTS (SELECT 1 FROM TBL_ADM_USER_ACCESSRIGHT B WITH(NOLOCK) WHERE A.accessright_id = B.accessright_id AND B.user_id = @user_id)

	SELECT * FROM #TEMP
	DROP TABLE #TEMP

END
GO
