SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Retrieve all Still active MLL
-- Example Query: exec SPP_MST_MLL_GET_EXISTING_APPROVED @param=N'{"mll_no":"MLL005300RD00001","start_date":"","end_date":""}',@user_id=1
-- ======================================================================================================================================

CREATE PROCEDURE [dbo].[SPP_MST_MLL_GET_EXISTING_APPROVED]
	@param NVARCHAR(MAX),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @mll_no VARCHAR(50), @start_date DATETIME, @end_date DATETIME, @client_code VARCHAR(50), @type_of_vas VARCHAR(50), @sub VARCHAR(50)
	SET @mll_no = (SELECT JSON_VALUE(@param, '$.mll_no'))
	SET @start_date = (SELECT JSON_VALUE(@param, '$.start_date'))
	SET @end_date = (SELECT JSON_VALUE(@param, '$.end_date'))
	SET @client_code = (SELECT client_code FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_no = @mll_no)
	SET @type_of_vas = (SELECT type_of_vas FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_no = @mll_no)
	SET @sub = (SELECT sub FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_no = @mll_no)

	SELECT mll_no as header, convert(varchar(10), start_date, 121) + ' - ' + convert(varchar(10), end_date, 121) as detail FROM TBL_MST_MLL_HDR WITH(NOLOCK)
	WHERE client_code = @client_code AND type_of_vas = @type_of_vas AND sub = @sub AND end_date > @start_date AND mll_status = 'Approved'
END

GO
