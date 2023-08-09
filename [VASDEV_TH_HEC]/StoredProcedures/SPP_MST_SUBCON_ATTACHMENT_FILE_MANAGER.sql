SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_MST_SUBCON_ATTACHMENT_FILE_MANAGER]
	@submit_obj NVARCHAR(MAX),
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @action VARCHAR(50)
	SET @action = (JSON_VALUE(@submit_obj, N'$.eventName'))

	CREATE TABLE #TEMP_FILE_DATA(
		name NVARCHAR(4000),
		fullpath NVARCHAR(4000),
		itemtype VARCHAR(50),
		subcon_no VARCHAR(50),
		prd_code VARCHAR(50)
	)
	
	INSERT INTO #TEMP_FILE_DATA (name, fullpath, itemtype)
	SELECT * FROM OPENJSON(@submit_obj, N'$.items') WITH (name NVARCHAR(4000) '$.name', fullPath NVARCHAR(4000) '$.fullPath', itemType VARCHAR(50) '$.itemType')

	UPDATE #TEMP_FILE_DATA
	SET subcon_no = SUBSTRING(fullpath, 9, 16),
		prd_code = SUBSTRING(fullpath, 26, 9)
	--WHERE itemtype = 'File'

	INSERT INTO TBL_ADM_AUDIT_TRAIL
	(module, key_code, action, action_by, action_date)
	SELECT 'SUBCON', subcon_no, @action + ' ' + name, @user_id, GETDATE() FROM #TEMP_FILE_DATA

	DROP TABLE #TEMP_FILE_DATA
END
GO
