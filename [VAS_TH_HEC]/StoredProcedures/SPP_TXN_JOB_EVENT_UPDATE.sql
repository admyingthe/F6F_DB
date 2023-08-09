SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =====================================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-07-13
-- Description: Update Job events
-- Example Query: exec SPP_TXN_JOB_EVENT_UPDATE @param=N'{"pk":"MY00000010","name":"completed_qty","value":"499"}',@user_id=N'1'
-- =====================================================================================

CREATE PROCEDURE [dbo].[SPP_TXN_JOB_EVENT_UPDATE]
	@param NVARCHAR(MAX),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @running_no	NVARCHAR(200), @name NVARCHAR(100), @value NVARCHAR(100), @job_ref_no VARCHAR(50), @event_id VARCHAR(50), @event_name NVARCHAR(100)
	SET @running_no = (SELECT JSON_VALUE(@param, '$.pk'))
	SET @name = (SELECT JSON_VALUE(@param, '$.name'))
	SET @value = (SELECT JSON_VALUE(@param, '$.value'))
	SET @job_ref_no = (SELECT job_ref_no FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE running_no = @running_no)
	SET @event_id = (SELECT event_id FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE running_no = @running_no)
	SET @event_name = (SELECT event_name FROM TBL_MST_EVENT_CONFIGURATION_HDR WITH(NOLOCK) WHERE event_id = @event_id)
	
	DECLARE @error_ind INT = 0, @completed_qty INT, @damaged_qty INT, @issued_qty INT, @sql NVARCHAR(MAX)
	SET @completed_qty = (SELECT ISNULL(completed_qty,0) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE running_no = @running_no)
	SET @damaged_qty = (SELECT ISNULL(damaged_qty,0) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE running_no = @running_no)
	SET @issued_qty = (SELECT ISNULL(issued_qty,0) FROM TBL_TXN_JOB_EVENT WITH(NOLOCK) WHERE running_no = @running_no)
	IF @name = 'completed_qty'
		IF (@value + @damaged_qty > @issued_qty)
		SET @error_ind = 1

	IF @name = 'damaged_qty'
		IF (@value + @completed_qty > @issued_qty)
		SET @error_ind = 1

	IF @error_ind = 0
	BEGIN
		SET @sql = 'UPDATE TBL_TXN_JOB_EVENT SET ' + @name + ' = N''' + @value + ''' WHERE running_no = ''' + @running_no + ''' AND (event_id <> ''25'' OR event_id <> ''76'' OR event_id <> ''77'')'
		EXEC (@sql)
		INSERT INTO TBL_ADM_AUDIT_TRAIL
		(module, key_code, action, action_by, action_date)
		SELECT 'JOB-EVENT', @job_ref_no, '[' + @running_no + '] Updated ' + @event_name + ' [' + @name + ']', @user_id, GETDATE()
	END
END
GO
