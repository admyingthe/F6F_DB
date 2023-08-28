SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec SPP_MST_GET_QA_EMAIL_CONFIG @param=N'{"dept":"D1"}'

Create PROCEDURE [dbo].[SPP_MST_GET_QA_EMAIL_CONFIG]
	@param VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

   DECLARE @ind VARCHAR(20)
	SET @ind = (SELECT JSON_VALUE(@param,'$.ind'))

	IF @ind = 'email'
	BEGIN
		/** QA Email Configuration **/
		DECLARE @dept VARCHAR(50)
		SET @dept = (SELECT JSON_VALUE(@param, '$.dept'))

		SELECT A.dept_code, B.dept_name, A.client_code, C.client_name, recipients, copy_recipients 
		FROM TBL_MST_QA_EMAIL_CONFIGURATION A WITH(NOLOCK)
		INNER JOIN TBL_MST_DEPARTMENT B WITH(NOLOCK) ON A.dept_code = B.dept_code
		INNER JOIN TBL_MST_CLIENT C WITH(NOLOCK) ON A.client_code = C.client_code
		WHERE A.dept_code = @dept
		ORDER BY A.dept_code, A.client_code
	END
END

GO
