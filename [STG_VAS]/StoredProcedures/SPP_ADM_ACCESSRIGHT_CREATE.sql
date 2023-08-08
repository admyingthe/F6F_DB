/****** Object:  StoredProcedure [dbo].[SPP_ADM_ACCESSRIGHT_CREATE]    Script Date: 08-Aug-23 8:46:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_ADM_ACCESSRIGHT_CREATE]
	@accessright_name	NVARCHAR(100),
	@principal_id		VARCHAR(10)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @exists_flag CHAR(1)
	SET @exists_flag = 0
	
	IF NOT EXISTS (SELECT 1 FROM TBL_ADM_ACCESSRIGHT WITH(NOLOCK) WHERE accessright_name = @accessright_name)
	BEGIN
		INSERT INTO TBL_ADM_ACCESSRIGHT
		(accessright_name , principal_id, status)
		VALUES
		(@accessright_name , @principal_id , 'A')

		SET @exists_flag = 0
	END
	ELSE
	BEGIN
		SET @exists_flag = 1
	END

	SELECT @exists_flag AS exists_flag
END


GO
