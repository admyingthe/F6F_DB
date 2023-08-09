SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SPP_ADM_STORAGE_TYPE_AND_BIN_EXPORT]
@param NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @is_export_template BIT
	SET @is_export_template = (SELECT JSON_VALUE(@param, '$.is_export_template'))
	CREATE TABLE #UPLOADED_TEMP
	(
		warehouse_no VARCHAR(50),
		storage_type VARCHAR(50),
		bin_no VARCHAR(150)
	)

	IF(@is_export_template = 0)
	BEGIN
		DECLARE @sql NVARCHAR(MAX) = '	INSERT INTO #UPLOADED_TEMP (warehouse_no, storage_type, bin_no)
										SELECT [warehouse_no], [storage_type], [bin_no] 
										FROM [dbo].[TBL_ADM_STORAGE_TYPE_AND_BIN] 
										WITH (NOLOCK)'

		DECLARE @lst_id_export NVARCHAR(MAX)
		SET @lst_id_export = (SELECT JSON_VALUE(@param, '$.lst_id_export'))
		IF @lst_id_export <> ''
		BEGIN
			SET @sql += ' WHERE [id] IN ' + @lst_id_export
		END
		
		SET @sql += ' ORDER BY [storage_type], [bin_no]'
		EXEC (@sql)
	END
	ELSE
	BEGIN
		DECLARE @countRow INT  = 0
		SELECT @countRow = COUNT(*) FROM [dbo].[TBL_ADM_STORAGE_TYPE_AND_BIN]
	
		IF @countRow > 0
		BEGIN
			INSERT INTO #UPLOADED_TEMP (warehouse_no, storage_type, bin_no)
			SELECT TOP 3 [warehouse_no], [storage_type], [bin_no] 
			FROM [dbo].[TBL_ADM_STORAGE_TYPE_AND_BIN] 
			WITH (NOLOCK)
			ORDER BY [storage_type], [bin_no]
		END
		ELSE
		BEGIN
			INSERT INTO #UPLOADED_TEMP (warehouse_no, storage_type, bin_no)
			VALUES ('T50', 'A32', 'COLDVAS01')

			INSERT INTO #UPLOADED_TEMP (warehouse_no, storage_type, bin_no)
			VALUES ('T50', 'A32', 'COLDVAS02')

			INSERT INTO #UPLOADED_TEMP (warehouse_no, storage_type, bin_no)
			VALUES ('T51', 'A32', 'COLDVAS03')
		END
	END
	

	SELECT * FROM #UPLOADED_TEMP

	CREATE TABLE #STORAGE_TYPE_AND_BIN_TEMPNAME (page_dtl_id INT, input_name VARCHAR(50), display_name NVARCHAR(250))

	SELECT * FROM #STORAGE_TYPE_AND_BIN_TEMPNAME
	UNION ALL
	SELECT '', 'warehouse_no', 'Warehouse No (3 CHR)'
	UNION ALL
	SELECT '', 'storage_type', 'Storage Type (3 CHR)'
	UNION ALL
	SELECT '', 'bin_no', 'Bin No (Max 10 CHR)'

	DROP TABLE #UPLOADED_TEMP
	DROP TABLE #STORAGE_TYPE_AND_BIN_TEMPNAME
END
GO
