SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--exec SPP_MST_MLL_GMP_UPDATE @param=N'{"mll_no":"MLL009103RD00005","prd_code":"100002409"}',@user_id=N'1'
CREATE PROCEDURE [dbo].[SPP_MST_MLL_GMP_UPDATE]
	@param NVARCHAR(2000),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @mll_no VARCHAR(50), @prd_code VARCHAR(50), @gmp_required INT
	SET @mll_no = (SELECT JSON_VALUE(@param, '$.mll_no'))
	SET @prd_code = (SELECT JSON_VALUE(@param, '$.prd_code'))
	SET @gmp_required = (SELECT CASE WHEN gmp_required = 1 THEN 0 ELSE 1 END FROM TBL_MST_MLL_DTL WITH(NOLOCK) WHERE mll_no = @mll_no AND prd_code = @prd_code)

	UPDATE TBL_MST_MLL_DTL
	SET gmp_required = @gmp_required
	WHERE mll_no = @mll_no AND prd_code = @prd_code

	INSERT INTO TBL_ADM_AUDIT_TRAIL
	(module, key_code, action, action_by, action_date)
	SELECT 'MLL', @mll_no, 'Updated GMP Required to ' + CAST(@gmp_required as VARCHAR(10)) + ' for ' + @prd_code, @user_id, GETDATE()
END

GO
