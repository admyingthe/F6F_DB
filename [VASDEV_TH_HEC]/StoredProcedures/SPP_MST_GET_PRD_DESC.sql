SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ========================================================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description:	Retrieve Product Description/Name
-- Example Query: exec SPP_MST_GET_PRD_DESC @param=N'{"prd_code":"100002785","client_code":"0053","mll_no":"MLL0053RD0004"}'
-- ========================================================================================================================

CREATE PROCEDURE [dbo].[SPP_MST_GET_PRD_DESC] 
	@param nvarchar(max) = ''
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @prd_code VARCHAR(50), @client_code VARCHAR(50), @mll_no VARCHAR(50)
	SET @prd_code = (SELECT JSON_VALUE(@param, '$.prd_code'))
	SET @client_code = (SELECT JSON_VALUE(@param, '$.client_code'))
	SET @mll_no = (SELECT JSON_VALUE(@param, '$.mll_no'))

	IF @mll_no <> ''
		SELECT prd_desc FROM TBL_MST_PRODUCT WITH(NOLOCK)
		WHERE prd_code = LTRIM(RTRIM(@prd_code)) AND princode = @client_code
		AND prd_code NOT IN (SELECT prd_code FROM TBL_MST_MLL_DTL WITH(NOLOCK) WHERE mll_no = @mll_no)
	ELSE
		SELECT prd_desc FROM TBL_MST_PRODUCT WITH(NOLOCK)
		WHERE prd_code = LTRIM(RTRIM(@prd_code)) 
END
GO
