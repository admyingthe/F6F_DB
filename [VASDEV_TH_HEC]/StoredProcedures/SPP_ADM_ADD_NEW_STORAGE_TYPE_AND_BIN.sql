SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPP_ADM_ADD_NEW_STORAGE_TYPE_AND_BIN]
@warehouse_no VARCHAR(50),
@storage_type VARCHAR(50),
@bin_no VARCHAR(150)
AS
BEGIN
	DECLARE @total_row INT = 0
	SET @total_row = (SELECT COUNT(*) FROM [dbo].[TBL_ADM_STORAGE_TYPE_AND_BIN] WHERE warehouse_no = @warehouse_no AND storage_type = @storage_type AND bin_no = @bin_no)

	IF @total_row = 0
	BEGIN
		INSERT INTO [dbo].[TBL_ADM_STORAGE_TYPE_AND_BIN]
		VALUES (@warehouse_no, @storage_type, @bin_no, 'Active')

		SELECT id FROM [dbo].[TBL_ADM_STORAGE_TYPE_AND_BIN] 
		WHERE warehouse_no = @warehouse_no 
		AND storage_type = @storage_type 
		AND bin_no = @bin_no
	END
	ELSE
	BEGIN
		SELECT -1
	END
END
GO
