SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SPP_MST_GENERATE_RUNNING_NUMBER]
	@Module VARCHAR(100),
	@RUNNING_NO VARCHAR(200) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @Old_Last_Running_No INT, @New_Last_Running_No INT, @End_No INT, @Start_No INT, @ID INT;

	WITH TMP_VAS_RUNNING_NO AS(
		SELECT TOP 1 *
		FROM TBL_MST_RUNNING_NO WITH(NOLOCK)
		WHERE Module = @Module
	)

	SELECT @RUNNING_NO = ISNULL(Prefix, '') + CASE WHEN ([DATE_FORMAT] IS NULL) THEN '' ELSE FORMAT(GETDATE(), [Date_Format]) END + FORMAT(Last_Running_No + 1, RUNNING_NO_FORMAT),
	@New_Last_Running_No = Last_Running_No + 1, @End_No = End_No, @Start_No = Start_No, @ID = ID
	FROM TMP_VAS_RUNNING_NO

	IF @New_Last_Running_No = @End_No
	BEGIN
	   SET @New_Last_Running_No = @Start_No - 1
	END

	UPDATE TBL_MST_RUNNING_NO WITH (ROWLOCK , READPAST)
	SET Last_Running_No = @New_Last_Running_No
	WHERE TBL_MST_RUNNING_NO.ID = @ID

	--SELECT @RUNNING_NO
END

GO
