SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================================
-- Author:		Smita Thorat
-- Create date: 2022-08-02
-- Description: Release temperature logger
-- Example Query: exec SPP_MST_RELEASE_LOGGER @param=N'{"vas_order":"","prd_code":"","batch_no":"","item_no":""}',@user_id=N'1'
-- ===========================================================================================================================

CREATE PROCEDURE [dbo].[SPP_MST_RELEASE_LOGGER]
	@param nvarchar(max),
	@user_id int,
	@remark nvarchar (500)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @vas_order VARCHAR(50), @prd_code VARCHAR(50), @batch_no VARCHAR(50), @to_no VARCHAR(50)--, @item_no VARCHAR(50)
	SET @vas_order = (SELECT JSON_VALUE(@param, '$.vas_order'))
	SET @prd_code = (SELECT JSON_VALUE(@param, '$.prd_code'))
	SET @batch_no = (SELECT JSON_VALUE(@param, '$.batch_no'))
	SET @to_no = (SELECT JSON_VALUE(@param, '$.to_no'))
	--SET @item_no = (SELECT JSON_VALUE(@param, '$.item_no'))


	CREATE TABLE #jsonTemp (
		vas_order VARCHAR(50),
		prd_code VARCHAR(50),
		batch_no VARCHAR(50),
		to_no VARCHAR(50)
	)

-- Insert JSON data into the temporary table
	INSERT INTO #jsonTemp (vas_order, prd_code, batch_no, to_no)
	SELECT vas_order, prd_code, batch_no, to_no
	FROM OPENJSON(@param) WITH (
		vas_order VARCHAR(50),
		prd_code VARCHAR(50),
		batch_no VARCHAR(50),
		to_no VARCHAR(50)
	)

	UPDATE  T 
	SET T.temp_logger = 'R',
	    T.temp_logger_released_by = @user_id,
		T.temp_logger_released_date = GETDATE(),
		T.temp_logger_remark=@remark
	FROM VAS_INTEGRATION_TH.dbo.VAS_TRANSFER_ORDER T
	INNER JOIN #jsonTemp R ON R.vas_order = T.vas_order AND R.prd_code = T.prd_code AND R.batch_no = T.batch_no AND R.to_no = T.to_no

	IF OBJECT_ID('tempdb..#jsonTemp') IS NOT NULL
    DROP TABLE #jsonTemp

END

GO
