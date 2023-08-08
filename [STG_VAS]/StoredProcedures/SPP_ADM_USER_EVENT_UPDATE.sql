/****** Object:  StoredProcedure [dbo].[SPP_ADM_USER_EVENT_UPDATE]    Script Date: 08-Aug-23 8:39:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_ADM_USER_EVENT_UPDATE]
	@userid_list			VARCHAR(MAX),
	@event_id_list			VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT * INTO #LOGIN FROM SF_SPLIT(@userid_list,',','''')
	SELECT * INTO #EVENT FROM SF_SPLIT(@event_id_list,',','''')

	DECLARE @user_id	VARCHAR(10)
	SET @user_id = (SELECT DISTINCT Data FROM #LOGIN WITH(NOLOCK))

	IF @event_id_list = N'0'
	BEGIN
		DELETE FROM TBL_ADM_USER_EVENT WHERE user_id = @user_id
	END
	ELSE
	BEGIN
		DELETE FROM TBL_ADM_USER_EVENT WHERE user_id = @user_id

		INSERT INTO TBL_ADM_USER_EVENT
		(user_id, event_id)
		SELECT T1.Data, T2.Data FROM #LOGIN T1 WITH(NOLOCK) 
		INNER JOIN #EVENT T2 WITH(NOLOCK) ON T1.Id = T2.Id
	END

	DROP TABLE #LOGIN
	DROP TABLE #EVENT
END

GO
