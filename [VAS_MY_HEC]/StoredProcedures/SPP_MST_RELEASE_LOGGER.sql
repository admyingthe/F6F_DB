SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Release temperature logger
-- Example Query: exec SPP_MST_RELEASE_LOGGER @param=N'{"vas_order":"","prd_code":"","batch_no":"","item_no":""}',@user_id=N'1'
-- ===========================================================================================================================

CREATE PROCEDURE [dbo].[SPP_MST_RELEASE_LOGGER]
	@param nvarchar(max),
	@user_id int
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @vas_order VARCHAR(50), @prd_code VARCHAR(50), @batch_no VARCHAR(50)--, @item_no VARCHAR(50)
	SET @vas_order = (SELECT JSON_VALUE(@param, '$.vas_order'))
	SET @prd_code = (SELECT JSON_VALUE(@param, '$.prd_code'))
	SET @batch_no = (SELECT JSON_VALUE(@param, '$.batch_no'))
	--SET @item_no = (SELECT JSON_VALUE(@param, '$.item_no'))

    UPDATE VAS_INTEGRATION.dbo.VAS_TRANSFER_ORDER
	SET temp_logger = 'R',
		temp_logger_released_by = @user_id,
		temp_logger_released_date = GETDATE()
	WHERE vas_order = @vas_order AND prd_code = @prd_code AND batch_no = @batch_no-- AND item_no = @item_no
END

GO
