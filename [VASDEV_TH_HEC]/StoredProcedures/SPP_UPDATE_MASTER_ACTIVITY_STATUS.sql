SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPP_UPDATE_MASTER_ACTIVITY_STATUS]
@param NVARCHAR(MAX), @user_id INT
AS
BEGIN
	DECLARE @is_reactivated NVARCHAR(1) = CONVERT(NVARCHAR(1), CAST((SELECT JSON_VALUE(@param, '$.is_reactivated')) AS BIT)) 
	DECLARE @lst_id_change_status NVARCHAR(MAX) = (SELECT JSON_VALUE(@param, '$.lst_id_change_status'))

	CREATE TABLE #TEMP_TABLE
	(
		[row_id] INT IDENTITY(1, 1), 
		[id] INT, 
		[Activity] NVARCHAR(MAX), 
		[description] NVARCHAR(MAX)
	)

	DECLARE @query NVARCHAR(MAX)
	SET @query = 'INSERT INTO #TEMP_TABLE([id], [Activity], [description])
					SELECT [id],[Activity],[description] FROM TBL_MST_ACTIVITY_LISTING'
				+ ' WHERE id IN ' + @lst_id_change_status

	EXEC(@query)

	DECLARE @action NVARCHAR(MAX) = ''
	DECLARE @index INT = 1, @count INT = (SELECT COUNT(*) FROM #TEMP_TABLE)
	IF(@is_reactivated = '1')
	BEGIN
		SET @action = 'Reactivate'
	END
	ELSE
	BEGIN
		SET @action = 'Deactivate'
	END

	SET @query = 'UPDATE TBL_MST_ACTIVITY_LISTING
					SET status = ' + @is_reactivated
				+ ' WHERE id IN ' + @lst_id_change_status
	EXEC(@query)

	WHILE(@index <= @count)
	BEGIN
		DECLARE @affectedDescription NVARCHAR(MAX) = (SELECT [description] FROM #TEMP_TABLE WHERE [row_id] = @index)
		DECLARE @ActId NVARCHAR(MAX) = (SELECT [Activity] FROM #TEMP_TABLE WHERE [row_id] = @index)
		INSERT INTO TBL_ADM_AUDIT_TRAIL ([module]
		  ,[key_code]
		  ,[action]
		  ,[action_by]
		  ,[action_date])
	
		VALUES ('MASTER-ACTIVITY-LISTING'
		, @ActId + '-' + @affectedDescription
		, @action + ' "'+ @affectedDescription + '"'
		, @user_id
		, CONVERT(datetime, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+07:00')))

		SET @index +=1
	END
	
	DROP TABLE #TEMP_TABLE
END


GO
