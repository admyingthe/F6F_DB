SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Siow Shen Yee
-- Create date: 2018-08-23
-- Description:	To replace special charaters
-- =============================================
CREATE PROCEDURE [dbo].[REPLACE_SPECIAL_CHARACTER]
(
	@string NVARCHAR(2000),
	@result NVARCHAR(2000) OUTPUT
)
AS
BEGIN
	SET @result = (SELECT REPLACE(REPLACE(REPLACE(REPLACE(@string, '&nl', CHAR(13) + CHAR(10)), '&quot;', '"'), '&amp;', '&'), '&#39;', ''''))
END

GO
