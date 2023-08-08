/****** Object:  StoredProcedure [dbo].[SPP_ADM_GET_USER_SUBMODULE_ACCESS_RIGHT]    Script Date: 08-Aug-23 8:39:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE SPP_ADM_GET_USER_SUBMODULE_ACCESS_RIGHT
	@param NVARCHAR(MAX),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @submodule_id INT, @accessright_id INT
	SET @submodule_id = (SELECT JSON_VALUE(@param, '$.submodule_id'))
	SET @accessright_id = (SELECT accessright_id FROM TBL_ADM_USER_ACCESSRIGHT WITH(NOLOCK) WHERE user_id = @user_id)

	IF (SELECT COUNT(*) FROM TBL_ADM_ACCESSRIGHT_DTL WITH(NOLOCK) WHERE accessright_id = @accessright_id AND submodule_id = @submodule_id AND action_id = 1) = 0
		SELECT 'N' as can_proceed
	ELSE
		SELECT 'Y' as can_proceed
END

GO
