/****** Object:  StoredProcedure [dbo].[SPP_ADM_ACCESSRIGHT_LIST]    Script Date: 08-Aug-23 8:39:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SPP_ADM_ACCESSRIGHT_LIST]
	@login	VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #LIST(
		accessright_id		INTEGER,
		accessright_name	NVARCHAR(100),
		principal_name		VARCHAR(100),
		total_users			INTEGER,
		status				CHAR(5)
	)

	CREATE TABLE #NUM_OF_USERS(
		accessright_id		INTEGER,
		num_of_user			INTEGER
	)

	DECLARE @ar_id INTEGER,@countryid varchar(10)
	SELECT @ar_id =accessright_id,@countryid=country_id FROM TBL_ADM_USER_ACCESSRIGHT A WITH(NOLOCK)
				  INNER JOIN TBL_ADM_USER B WITH(NOLOCK) ON A.user_id = B.user_id
				  WHERE B.login = @login

				 
	


	IF (@ar_id = '1')
	BEGIN
		INSERT INTO #LIST
		SELECT accessright_id, accessright_name, B.principal_name, '0', A.status
		FROM TBL_ADM_ACCESSRIGHT A WITH(NOLOCK)
		LEFT JOIN TBL_ADM_PRINCIPAL B WITH(NOLOCK) ON A.principal_id = B.principal_id 
		WHERE B.country_id  = @countryid
	END
	ELSE
	BEGIN
		INSERT INTO #LIST
		SELECT accessright_id, accessright_name, B.principal_name, '0', A.status
		FROM TBL_ADM_ACCESSRIGHT A WITH(NOLOCK)
		LEFT JOIN TBL_ADM_PRINCIPAL B WITH(NOLOCK) ON A.principal_id = B.principal_id
		WHERE accessright_id <> '1' AND B.country_id  = @countryid
	END

	INSERT INTO #NUM_OF_USERS
	SELECT A.accessright_id, COUNT(DISTINCT user_id)
	FROM TBL_ADM_USER_ACCESSRIGHT A WITH(NOLOCK)
	INNER JOIN TBL_ADM_ACCESSRIGHT B WITH(NOLOCK) ON A.accessright_id = B.accessright_id
	WHERE A.accessright_id = B.accessright_id
	GROUP BY A.accessright_id

	UPDATE A
	SET total_users = ISNULL(B.num_of_user,0)
	FROM #LIST A
	LEFT JOIN #NUM_OF_USERS B WITH(NOLOCK) ON A.accessright_id = B.accessright_id

	SELECT * FROM #LIST

	DROP TABLE #LIST
	DROP TABLE #NUM_OF_USERS

END

GO
