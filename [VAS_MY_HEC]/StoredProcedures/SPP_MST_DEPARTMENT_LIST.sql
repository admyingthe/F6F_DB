SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===============================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description:	Retrieve department list
-- Example Query: exec SPP_MST_DEPARTMENT_LIST '1'
-- ===============================================

CREATE PROCEDURE [dbo].[SPP_MST_DEPARTMENT_LIST]
	@user_id	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT dept_code as department_code, dept_name as department_name FROM TBL_MST_DEPARTMENT WITH(NOLOCK)
END

GO
