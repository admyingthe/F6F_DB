/****** Object:  StoredProcedure [dbo].[SPP_ADM_USER_EVENT_LIST]    Script Date: 08-Aug-23 8:37:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec SPP_ADM_USER_EVENT_LIST '1','VAS_MY_HEC'
CREATE PROCEDURE [dbo].[SPP_ADM_USER_EVENT_LIST]
	@user_id	VARCHAR(10),
	@db_name	NVARCHAR(250)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql NVARCHAR(MAX)
	SET @sql = 'SELECT event_id, event_name, 0 as is_checked INTO #TEMP
				FROM ' + @db_name + '.dbo.TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK) WHERE auto_ind <> ''Y'''

	SET @sql = @sql + ' UPDATE A
					   SET is_checked = ''1''
					   FROM #TEMP A
					   WHERE EXISTS (SELECT 1 FROM TBL_ADM_USER_EVENT B WITH(NOLOCK) WHERE A.event_id = B.event_id AND B.user_id = ' + @user_id + ')'

	
	SET @sql = @sql + ' SELECT DISTINCT * FROM #TEMP ORDER BY event_id ASC'
	
	EXEC (@sql)
END
GO
