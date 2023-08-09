SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec SPP_MST_GET_MASTER_DATA @param=N'{"dept":"D1"}'

CREATE PROCEDURE [dbo].[SPP_MST_GET_MASTER_DATA]
	@param VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ind VARCHAR(20)
	SET @ind = (SELECT JSON_VALUE(@param,'$.ind'))

	IF @ind = 'email'
	BEGIN
		/** MLL Email Configuration **/
		DECLARE @dept VARCHAR(50)
		SET @dept = (SELECT JSON_VALUE(@param, '$.dept'))

		SELECT A.dept_code, B.dept_name, A.client_code, C.client_name, recipients, copy_recipients 
		FROM TBL_MST_MLL_EMAIL_CONFIGURATION A WITH(NOLOCK)
		INNER JOIN TBL_MST_DEPARTMENT B WITH(NOLOCK) ON A.dept_code = B.dept_code
		INNER JOIN TBL_MST_CLIENT C WITH(NOLOCK) ON A.client_code = C.client_code
		WHERE A.dept_code = @dept
		ORDER BY A.dept_code, A.client_code
	END
	ELSE IF @ind = 'client_autocomplete'
	BEGIN
		--/** Client **/
		SELECT LTRIM(RTRIM(MatGrp)) COLLATE SQL_Latin1_General_CP1_CI_AS + ' - ' + LTRIM(RTRIM(MatGrpDesc)) COLLATE SQL_Latin1_General_CP1_CI_AS as name 
		FROM SERVER1.TH_DW.dbo.M_MatGrp WITH(NOLOCK)
		WHERE MatGrp  COLLATE SQL_Latin1_General_CP1_CI_AS NOT IN (SELECT client_code FROM TBL_MST_CLIENT WITH(NOLOCK))
	END
	ELSE IF @ind = 'client_list'
	BEGIN
		SELECT client_code, client_name FROM TBL_MST_CLIENT WITH(NOLOCK)
	END

	ELSE IF @ind = 'approver_email'
	BEGIN
		/** MLL Email Approver **/
		SELECT LTRIM(RTRIM(dept_code)) as dept_code, dept_name, approver_email FROM TBL_MST_DEPARTMENT WITH(NOLOCK)
	END
END
GO
