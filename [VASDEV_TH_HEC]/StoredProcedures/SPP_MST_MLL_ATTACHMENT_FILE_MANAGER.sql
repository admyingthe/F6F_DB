SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =====================================================================
-- Author:		Siow Shen Yee
-- Create date: 2018-12-17
-- Description:	To keep track of MLL attachments
-- 1. exec SPP_MST_MLL_ATTACHMENT_FILE_MANAGER @submit_obj=N'{"eventName": "deleted","items": [{"name": "Jellyfish.jpg","fullPath": "[Root]:\\MLL009100RD00003\\100788605\\Jellyfish.jpg","itemType": "File","extension": "jpg","size": 775702},{"name": "Koala.jpg","fullPath": "[Root]:\\MLL009100RD00003\\100788605\\Koala.jpg","itemType": "File","extension": "jpg","size": 780831}]}',@user_id=N'1'
-- 2. exec SPP_MST_MLL_ATTACHMENT_FILE_MANAGER @submit_obj=N'{"eventName": "deleted","items": [{"name": "MLL009100RD00004","fullPath": "[Root]:\\MLL009100RD00004","itemType": "Folder","extension": "","size": null}]}',@user_id=N'1'
-- =====================================================================
CREATE PROCEDURE [dbo].[SPP_MST_MLL_ATTACHMENT_FILE_MANAGER]
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
		mll_no VARCHAR(50),
		prd_code VARCHAR(50)
	)
	
	INSERT INTO #TEMP_FILE_DATA (name, fullpath, itemtype)
	SELECT * FROM OPENJSON(@submit_obj, N'$.items') WITH (name NVARCHAR(4000) '$.name', fullPath NVARCHAR(4000) '$.fullPath', itemType VARCHAR(50) '$.itemType')

	UPDATE #TEMP_FILE_DATA
	SET mll_no = SUBSTRING(fullpath, 9, 16),
		prd_code = SUBSTRING(fullpath, 26, 9)
	--WHERE itemtype = 'File'

	INSERT INTO TBL_ADM_AUDIT_TRAIL
	(module, key_code, action, action_by, action_date)
	SELECT 'MLL', mll_no, @action + ' ' + name, @user_id, GETDATE() FROM #TEMP_FILE_DATA

	DROP TABLE #TEMP_FILE_DATA
END
GO
