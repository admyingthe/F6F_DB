/****** Object:  StoredProcedure [dbo].[SPP_ADM_MODULE_LIST]    Script Date: 08-Aug-23 8:39:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_ADM_MODULE_LIST]

AS
BEGIN
	SET NOCOUNT ON;

	SELECT module_id, module_name FROM TBL_ADM_MODULE WITH(NOLOCK) WHERE status = 'A'
END

GO
