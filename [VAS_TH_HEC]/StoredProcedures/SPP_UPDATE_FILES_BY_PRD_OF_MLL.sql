SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC SPP_UPDATE_FILES_BY_PRD_OF_MLL
@copy_mll NVARCHAR(30), @new_mll NVARCHAR(30), @prd_code NVARCHAR(20), @lst_file NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE  @lst_attachment_files NVARCHAR(MAX)
	SELECT @lst_attachment_files=lst_attachment_files FROM TBL_MST_MLL_DTL
	WHERE mll_no = @copy_mll
	AND prd_code = @prd_code

	IF(@lst_attachment_files <> NULL)
	BEGIN
		UPDATE TBL_MST_MLL_DTL
		SET has_attachment_files = 1,
		lst_attachment_files = @lst_attachment_files
		WHERE mll_no = @new_mll
		AND prd_code = @prd_code
	END
	ELSE
	BEGIN
		UPDATE TBL_MST_MLL_DTL
		SET has_attachment_files = 1,
		lst_attachment_files = @lst_file
		WHERE mll_no = @new_mll
		AND prd_code = @prd_code
	END
END
GO
