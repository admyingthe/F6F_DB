/****** Object:  StoredProcedure [dbo].[SPP_ADM_ACCESSRIGHTDTL_LIST]    Script Date: 08-Aug-23 8:37:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_ADM_ACCESSRIGHTDTL_LIST]
	@module_id		VARCHAR(10),
	@accessright_id	VARCHAR(10)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT * FROM TBL_ADM_ACCESSRIGHT_DTL WITH(NOLOCK)
	WHERE accessright_id = @accessright_id AND module_id = @module_id
END

GO
