SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPP_ADM_GET_STORAGE_TYPE_AND_BIN]
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX) = 'SELECT id
		, [warehouse_no]
		, [storage_type]
		, [bin_no]
		, [status]
	FROM [dbo].[TBL_ADM_STORAGE_TYPE_AND_BIN]
	WITH (NOLOCK)
	ORDER BY storage_type, bin_no'

	SET @sql += ' SELECT COUNT(*) AS ttl_rows FROM [dbo].[TBL_ADM_STORAGE_TYPE_AND_BIN]'
	EXEC (@sql)
END
GO
