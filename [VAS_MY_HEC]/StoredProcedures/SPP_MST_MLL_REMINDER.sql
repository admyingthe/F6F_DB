SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Siow Shen Yee
-- Create date: 15-08-2018
-- Description:	(Run by Job) Send out reminder email for all MLL which already submitted but yet to be approved
-- =============================================
CREATE PROCEDURE [dbo].[SPP_MST_MLL_REMINDER]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT IDENTITY(INT, 1, 1) AS row_num, mll_no, submitted_by INTO #TEMP_SUBMITTED_MLL 
	FROM TBL_MST_MLL_HDR WITH(NOLOCK) WHERE mll_status = 'Submitted'

	DECLARE @count INT, @i INT = 1, @mll_no VARCHAR(50), @submitted_by INT
	SET @count = (SELECT COUNT(1) FROM #TEMP_SUBMITTED_MLL)
	
	WHILE @i <= @count
	BEGIN
		SELECT @mll_no = mll_no, @submitted_by = submitted_by FROM #TEMP_SUBMITTED_MLL WITH(NOLOCK) WHERE row_num = @i

		EXEC SPP_MST_MLL_EMAIL 'Submitted', @mll_no, @submitted_by

		SET @i = @i + 1
	END

	DROP TABLE #TEMP_SUBMITTED_MLL
END

GO
