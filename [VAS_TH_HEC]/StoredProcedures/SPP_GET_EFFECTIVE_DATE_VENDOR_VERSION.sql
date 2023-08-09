SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPP_GET_EFFECTIVE_DATE_VENDOR_VERSION]
@param NVARCHAR(MAX)
AS
BEGIN

	DECLARE @vendor_name NVARCHAR(20) = (SELECT JSON_VALUE(@param, '$.vendor_name'))

	SELECT LEFT(effective_date, 10) AS date_from, RIGHT(effective_date, 10) AS date_to
	FROM TBL_ADM_VENDOR_VERSION
	WHERE vendor_name = @vendor_name
	GROUP BY effective_date
END
GO
