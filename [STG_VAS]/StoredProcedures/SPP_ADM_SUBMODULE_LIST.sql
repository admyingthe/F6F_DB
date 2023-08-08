/****** Object:  StoredProcedure [dbo].[SPP_ADM_SUBMODULE_LIST]    Script Date: 08-Aug-23 8:46:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_ADM_SUBMODULE_LIST]
	@module_id	VARCHAR(10)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT submodule_id, submodule_name FROM TBL_ADM_SUBMODULE WITH(NOLOCK) 
	WHERE module_id = @module_id AND status = 'A'
END


GO
