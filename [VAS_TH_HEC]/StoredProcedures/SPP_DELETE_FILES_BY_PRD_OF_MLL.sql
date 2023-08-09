SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SPP_DELETE_FILES_BY_PRD_OF_MLL]
@mll_no NVARCHAR(30), @prd_code NVARCHAR(20), @file_name NVARCHAR(MAX)
AS
BEGIN
	DECLARE @isFound BIT = 0
	DECLARE @removeFileName NVARCHAR(MAX) = @file_name

	SELECT @isFound = 1 FROM TBL_MST_MLL_DTL
	WHERE mll_no = @mll_no AND prd_code = @prd_code
	AND lst_attachment_files LIKE N'%;'+@removeFileName+ N'%' 

	IF @isFound = 0
	BEGIN
		SELECT @isFound = 1 FROM TBL_MST_MLL_DTL
		WHERE mll_no = @mll_no AND prd_code = @prd_code
		AND lst_attachment_files LIKE N'%'+@removeFileName+ N';%'

		IF @isFound = 1
		BEGIN
			SET @removeFileName += ';'
		END
	END
	ELSE
	BEGIN
		SET @removeFileName = N';' + @removeFileName
	END

	UPDATE TBL_MST_MLL_DTL
	SET lst_attachment_files = REPLACE(lst_attachment_files, @removeFileName, '')
	WHERE mll_no = @mll_no AND prd_code = @prd_code
END
GO
