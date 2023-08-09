SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPP_ADD_MASTER_ACTIVITY]
@description NVARCHAR(MAX), @user_id INT
AS
BEGIN
	--SET @description = REPLACE(LTRIM(RTRIM(@description)), N'%', N'*')
	SET @description = LTRIM(RTRIM(dbo.URLDecode(@description)))
	IF(@description IS NOT NULL OR @description <> '')
	BEGIN
		SET NOCOUNT ON;

	DECLARE @defaultText NVARCHAR(20) = 'VAS Activities '
	DECLARE @ActId NVARCHAR(50) = @defaultText +  CONVERT(NVARCHAR(5),CONVERT(INT, (SELECT TOP 1 SUBSTRING(Activity, LEN(LEFT(Activity, LEN(@defaultText)+2)), 5) FROM TBL_MST_ACTIVITY_LISTING WITH (NOLOCK)
	ORDER BY id DESC)) + 1)
  
  DECLARE @already_has_record BIT = 0;
  SELECT @already_has_record = 1 FROM TBL_MST_ACTIVITY_LISTING
  WITH (NOLOCK)
  WHERE [description] = @description

  IF @already_has_record = 1
  BEGIN
	SELECT 'warning' AS [type], 'The record is already had in this system' AS message;
	RETURN;
  END

  INSERT INTO TBL_MST_ACTIVITY_LISTING([Activity], [description])
  VALUES(@ActId, @description)

  INSERT INTO TBL_ADM_AUDIT_TRAIL ([module]
      ,[key_code]
      ,[action]
      ,[action_by]
      ,[action_date])
	
	VALUES ('MASTER-ACTIVITY-LISTING'
	, @ActId + '-' + @description
	, 'Adding new "'+ @description + '" to master Activity'
	, @user_id
	, CONVERT(datetime, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+07:00')))

  SELECT id, [type], [Activity], [description], [status] FROM TBL_MST_ACTIVITY_LISTING
  WHERE [description] = @description
	END
END




GO
