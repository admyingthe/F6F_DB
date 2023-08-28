SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_MST_VENDOR_LISTING_EXPORT]
	-- Add the parameters for the stored procedure here
	@param NVARCHAR(MAX)
AS
BEGIN
	DECLARE @is_export_template BIT  
	SET @is_export_template = (SELECT JSON_VALUE(@param, '$.is_export_template'))  
	CREATE TABLE #UPLOADED_TEMP  
	(  
	vendor_code VARCHAR(50),  
	vendor_name NVARCHAR(max),
	ship_to_code NVARCHAR(max),
	sold_to_code NVARCHAR(max),
	prayer_code NVARCHAR(max),
	material_group NVARCHAR(max)
	)  
  
	IF(@is_export_template = 0)  
	BEGIN  
	DECLARE @sql NVARCHAR(MAX) = ' INSERT INTO #UPLOADED_TEMP (vendor_code, vendor_name, ship_to_code, sold_to_code, prayer_code, material_group)  
		SELECT [vendor_code], [vendor_name], [ship_to_code], [sold_to_code], [prayer_code], [material_group]
		FROM [dbo].[TBL_MST_VENDOR_LISTING]   
		WITH (NOLOCK)'  
  
	DECLARE @lst_id_export NVARCHAR(MAX)  
	SET @lst_id_export = (SELECT JSON_VALUE(@param, '$.lst_id_export'))  
	IF @lst_id_export <> ''  
	BEGIN  
	SET @sql += ' WHERE [id] IN ' + @lst_id_export  
	END  
    
	SET @sql += ' ORDER BY [vendor_code], [vendor_name]'  
	EXEC (@sql)  
	END  
	ELSE  
	BEGIN  
	DECLARE @countRow INT  = 0  
	SELECT @countRow = COUNT(*) FROM [dbo].[TBL_MST_VENDOR_LISTING]  
   
	IF @countRow > 0  
	BEGIN  
	INSERT INTO #UPLOADED_TEMP (vendor_code, vendor_name, ship_to_code, sold_to_code, prayer_code, material_group)  
	SELECT TOP 3 [vendor_code], [vendor_name], [ship_to_code], [sold_to_code], [prayer_code], [material_group]   
	FROM [dbo].[TBL_MST_VENDOR_LISTING]   
	WITH (NOLOCK)  
	ORDER BY [vendor_code], [vendor_name]  
	END  
	END  
   
  
	SELECT * FROM #UPLOADED_TEMP  
  
	CREATE TABLE #VENDOR_MASTER_LISTING_TEMPNAME (page_dtl_id INT, input_name VARCHAR(50), display_name NVARCHAR(250))  
  
	SELECT * FROM #VENDOR_MASTER_LISTING_TEMPNAME  
	UNION ALL  
	SELECT '', 'vendor_code', 'Vendor Code'  
	UNION ALL  
	SELECT '', 'vendor_name', 'Vendor Name'  
	UNION ALL  
	SELECT '', 'ship_to_code', 'Ship To Code'  
	UNION ALL  
	SELECT '', 'sold_to_code', 'Sold To Code'  
	UNION ALL  
	SELECT '', 'material_group', 'Material Group'  
  
	DROP TABLE #UPLOADED_TEMP  
	DROP TABLE #VENDOR_MASTER_LISTING_TEMPNAME
END

GO
