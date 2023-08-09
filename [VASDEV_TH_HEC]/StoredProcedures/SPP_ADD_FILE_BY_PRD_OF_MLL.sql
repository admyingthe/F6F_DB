SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC SPP_ADD_FILE_BY_PRD_OF_MLL
@mll_no NVARCHAR(30), @prd_code NVARCHAR(20), @file_name NVARCHAR(MAX)
AS
BEGIN
	UPDATE TBL_MST_MLL_DTL
	SET lst_attachment_files += N';' + @file_name
	WHERE mll_no = @mll_no AND prd_code = @prd_code
END
GO
