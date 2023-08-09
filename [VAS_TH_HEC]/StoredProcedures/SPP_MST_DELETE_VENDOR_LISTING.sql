SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SPP_MST_DELETE_VENDOR_LISTING
	-- Add the parameters for the stored procedure here
	@param NVARCHAR(MAX)  
	, @user_id INT  
AS
BEGIN
	DECLARE @lst_id_delete NVARCHAR(MAX)  
	SET @lst_id_delete = (SELECT JSON_VALUE(@param, '$.lst_id_delete'))

	CREATE TABLE #TEMP  
	(  
	row_no INT IDENTITY(1,1),  
	id INT NOT NULL,  
	key_code NVARCHAR(100),  
	[action] NVARCHAR(100)  
	)  

	DECLARE @sql NVARCHAR(MAX) = ' INSERT INTO #TEMP  
	(id, key_code, [action])  
	SELECT id, ''Delete current items'', ''Delete - '' + vendor_code + '' - '' + vendor_name + '' - '' + ship_to_code + '' - '' +  sold_to_code FROM [dbo].[TBL_MST_VENDOR_LISTING] WHERE id IN ' + @lst_id_delete  

	DECLARE @sql2 NVARCHAR(MAX) = 'DELETE [dbo].[TBL_MST_VENDOR_LISTING] WHERE id IN ' + @lst_id_delete
	
	EXEC (@sql) 
	EXEC (@sql2) 

	DECLARE @total INT = (SELECT COUNT(*) FROM #TEMP)  
	DECLARE @i INT = 0  
	
	WHILE @i <= @total  
	BEGIN  
		DECLARE @current_key_code NVARCHAR(100) = ''  
		DECLARE @current_action NVARCHAR(100) = ''  
  
		SELECT @current_key_code = key_code, @current_action = [action] FROM #TEMP WHERE row_no = @i  
  
		IF @current_key_code <> '' AND @current_action <> ''  
		BEGIN  
		EXEC [SPP_MST_VENDOR_MASTER_AUDIT_TRAIL] @current_key_code, @current_action, @user_id  
		END  
  
		SET @i += 1  
	END  
  
	DROP TABLE #TEMP  
END

GO
