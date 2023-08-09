SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CHOI CHEE KIEN
-- Create date: 11-06-2023
-- Description:	GET ALL PRODUCT CODE
-- =============================================
CREATE PROCEDURE SPP_MST_ALL_PRD_CODE
AS
BEGIN
	SET NOCOUNT ON;

	SELECT prd_code
	FROM TBL_MST_PRODUCT WITH (NOLOCK)
END

GO
