SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Remove product from MLL
-- Example Query: exec SPP_MST_MLL_PRD_DELETE @delete_obj=N'{"mll_no":"MLL0F3200RD00001","prd_code":"120300201"}',@user_id=N'1'
-- ===========================================================================================================================

CREATE PROCEDURE [dbo].[SPP_MST_MLL_PRD_DELETE]
	@delete_obj NVARCHAR(MAX),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @mll_no VARCHAR(50), @prd_code VARCHAR(50), @client_code VARCHAR(50), @type_of_vas VARCHAR(50), @sub VARCHAR(50)
	SET @mll_no = (SELECT JSON_VALUE(@delete_obj, '$.mll_no'))
	SET @prd_code = (SELECT JSON_VALUE(@delete_obj, '$.prd_code'))
	SET @client_code = (SELECT client_code FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_no = @mll_no)
	SET @type_of_vas = (SELECT type_of_vas FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_no = @mll_no)
	SET @sub = (SELECT sub FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_no = @mll_no)

	DELETE FROM TBL_MST_MLL_DTL
	WHERE mll_no = @mll_no AND prd_code = @prd_code

	INSERT INTO TBL_ADM_AUDIT_TRAIL
	(module, key_code, action, action_by, action_date)
	SELECT 'MLL', @mll_no, 'Deleted item ' + @prd_code, @user_id, GETDATE()

	IF (SELECT COUNT(*) FROM TBL_MST_MLL_DTL WITH(NOLOCK) WHERE @mll_no = @mll_no) = 0
	BEGIN
		DELETE FROM TBL_MST_MLL_HDR WHERE mll_no = @mll_no
	END
END

GO
