/****** Object:  StoredProcedure [dbo].[SPP_ADM_ACCESSRIGHT_DELETE]    Script Date: 08-Aug-23 8:25:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SPP_ADM_ACCESSRIGHT_DELETE] 
	@accessright_id	INTEGER
AS
BEGIN
	SET NOCOUNT ON;

    DELETE FROM TBL_ADM_ACCESSRIGHT
	WHERE accessright_id = @accessright_id
END


GO
