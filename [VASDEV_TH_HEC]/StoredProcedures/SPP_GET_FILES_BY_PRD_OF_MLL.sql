SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC SPP_GET_FILES_BY_PRD_OF_MLL
@mll_no NVARCHAR(20), @prd_code NVARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON
	SELECT has_attachment_files, lst_attachment_files 
	FROM TBL_MST_MLL_DTL WITH (NOLOCK)
	WHERE mll_no = @mll_no
	AND prd_code = @prd_code
END
GO
