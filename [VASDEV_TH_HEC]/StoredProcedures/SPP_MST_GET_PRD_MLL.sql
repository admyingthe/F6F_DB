SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description:	Retrieve all the active MLL for the selected Client and Product
-- Example Query: exec SPP_MST_GET_PRD_MLL @param=N'{"prd_code":"100911400","client_code":"0F12"}', @user_id = 1
-- =============================================================================================================

CREATE PROCEDURE [dbo].[SPP_MST_GET_PRD_MLL]
	@param	nvarchar(max),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @client_code VARCHAR(50), @prd_code VARCHAR(50)
	SET @client_code = (SELECT JSON_VALUE(@param, '$.client_code'))
	SET @prd_code = (SELECT JSON_VALUE(@param, '$.prd_code'))

	DECLARE @wh_code varchar(10)
 SET @wh_code = (SELECT wh_code FROM VASDEV.dbo.TBL_ADM_USER WITH(NOLOCK) WHERE user_id = @user_id)  --T50


	SELECT A.client_code, type_of_vas, sub, sub_name,  A.mll_no, start_date, end_date, mll_desc
	FROM VAS_TH_HEC.dbo.TBL_MST_MLL_HDR A WITH(NOLOCK)
	INNER JOIN VAS_TH_HEC.dbo.TBL_MST_MLL_DTL B WITH(NOLOCK) ON A.mll_no = B.mll_no
	INNER JOIN TBL_MST_CLIENT_SUB C WITH(NOLOCK) ON A.sub = C.sub_code AND A.client_code = C.client_code
	WHERE A.client_code = @client_code AND prd_code = @prd_code AND mll_status = 'Approved' AND (GETDATE() BETWEEN start_date AND end_date)
	AND C.wh_code=@wh_code
END
GO
