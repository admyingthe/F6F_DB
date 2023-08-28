SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [SPP_MST_GET_VENDOR_LISTING]
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX) = 'SELECT [id]
    ,[vendor_code]
    ,[vendor_name]
    ,[ship_to_code]
    ,[sold_to_code]
    ,[prayer_code]
    ,[material_group]
	,[status]
    ,[created_date]
    ,[creator_user_id]
    ,[changed_date]
    ,[changed_user_id]
	FROM [dbo].[TBL_MST_VENDOR_LISTING]  
	WITH (NOLOCK)    
	ORDER BY vendor_code, vendor_name'    
    
	SET @sql += ' SELECT COUNT(*) AS ttl_rows FROM [dbo].[TBL_MST_VENDOR_LISTING]'   
	EXEC (@sql) 
END

GO
